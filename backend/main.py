from fastapi import FastAPI, File, UploadFile, Form, Depends, HTTPException, APIRouter
from typing import Optional
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import os
import shutil
import tempfile
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import time  # عشان timestamp الصورة
from gradio_client import Client, handle_file
from fastapi.middleware.cors import CORSMiddleware

# --- 1. إعدادات قاعدة البيانات ---
SQLALCHEMY_DATABASE_URL = "sqlite:///./doctors.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# جدول الدكاترة
class Doctor(Base):
    __tablename__ = "doctors"
    id = Column(Integer, primary_key=True, index=True)
    fullName = Column(String)
    userName = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    phone = Column(String, nullable=True)
    gender = Column(String)
    profileImage = Column(String)  # مسار الصورة


# جدول سجلات الأشعة (للتاريخ والواجهة)
class ScanRecord(Base):
    __tablename__ = "scan_records"
    id = Column(Integer, primary_key=True, index=True)
    imagePath = Column(String)
    detectionClass = Column(String)
    confidence = Column(String, default="0")
    description = Column(String, nullable=True)
    isReviewed = Column(String, default="false")
    uploadDate = Column(String)


# إنشاء الجدول لو مش موجود
Base.metadata.create_all(bind=engine)

app = FastAPI()

# سماح بالوصول من الموبايل وأي دومين (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# فولدر حفظ الصور
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# تفعيل الـ Static Files عشان الصور تظهر في التطبيق
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# --- تعريف الـ Router (مهم جداً) ---
router = APIRouter(prefix="/api/Auth", tags=["Auth"])

# موديل استقبال كود التفعيل
class VerifyCodeRequest(BaseModel):
    email: str
    code: str

# 👇👇 دالة التفعيل (Verification Endpoint)
@router.post("/verify")
async def verify_code(request: VerifyCodeRequest):
    # طباعة الكود في التيرمينال عشان تشوفه
    print(f"\n✅✅ Verification Code Received for {request.email}: {request.code} ✅✅\n")
    
    # رد النجاح
    return {"message": "Code verified successfully", "status": "Success"}

# ⚠️⚠️ السطر الأهم: ربط الـ Router بالتطبيق ⚠️⚠️
app.include_router(router)

# دالة مساعدة للاتصال بالداتابيز
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def home():
    return {"message": "Server is Running... You are ready! 🚀"}

# --- 2. نقطة التسجيل (Register API) ---
@app.post("/api/Auth/register/doctor")
async def register_doctor(
    fullName: str = Form(...),
    userName: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    phone: Optional[str] = Form(None),
    gender: str = Form(...),
    profileProfile: UploadFile = File(...),
    licenseFront: Optional[UploadFile] = File(None),
    licenseBack: Optional[UploadFile] = File(None),
    clinicAddress: Optional[str] = Form(None),
    latitude: Optional[str] = Form(None),
    longitude: Optional[str] = Form(None),
    dateOfBirth: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    # حفظ الصورة
    file_path = f"{UPLOAD_DIR}/{int(time.time())}_{profileProfile.filename}"
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(profileProfile.file, buffer)

    # حفظ البيانات في الداتابيز
    new_doctor = Doctor(
        fullName=fullName,
        userName=userName,
        email=email,
        password=password,
        phone=phone,
        gender=gender,
        profileImage=file_path
    )

    try:
        db.add(new_doctor)
        db.commit()
        db.refresh(new_doctor)
    except Exception as e:
        return {"status": "error", "message": str(e)}

    # توليد كود تفعيل وهمي وطباعته
    import random
    fake_code = random.randint(1000, 9999)
    print(f"\n🔔 INFO: Verification code for {email} is: {fake_code} 🔔\n")

    return {
        "email": email,
        "token": "fake-jwt-token",
        "userId": new_doctor.id,
        "role": "Doctor"
    }

# --- 3. نقطة تسجيل الدخول (Login API) ---
@app.post("/api/Auth/login")
async def login(
    email: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db)
):
    doctor = db.query(Doctor).filter(Doctor.email == email).first()
    
    if not doctor:
        raise HTTPException(status_code=400, detail="User not found")
    
    if doctor.password != password:
        raise HTTPException(status_code=400, detail="Incorrect password")
    
    img_path = doctor.profileImage if doctor.profileImage else ""
    user_id_str = str(doctor.id) 

    return {
        "token": "fake-login-token-123",
        "user": {
            "id": user_id_str,
            "userId": user_id_str,
            "User_Id": user_id_str,
            "profilePicture": img_path,
            "fullName": doctor.fullName,
            "userName": doctor.userName,
            "email": doctor.email,
            "role": "Doctor",
            "gender": doctor.gender,
            "dateOfBirth": None,
            "latitude": None,
            "longitude": None,
            "age": None
        }
    }

# --- 4. نقطة تعديل البيانات (Update Profile API) ---
@app.post("/api/Account/UpdateProfile")
async def update_profile(
    email: str = Form(...),
    fullName: Optional[str] = Form(None),
    phone: Optional[str] = Form(None),
    gender: Optional[str] = Form(None),
    photo: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    doctor = db.query(Doctor).filter(Doctor.email == email).first()
    
    if not doctor:
        raise HTTPException(status_code=404, detail="User not found")
    
    if fullName: doctor.fullName = fullName
    if phone: doctor.phone = phone
    if gender: doctor.gender = gender
    
    if photo:
        filename = os.path.basename(photo.filename) 
        filename = f"{int(time.time())}_{filename}"
        file_path = f"{UPLOAD_DIR}/{filename}"
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(photo.file, buffer)
            
        doctor.profileImage = file_path
        
    try:
        db.commit()
        db.refresh(doctor)
    except Exception as e:
        return {"status": "error", "message": str(e)}

    img_path = doctor.profileImage if doctor.profileImage else ""

    return {
    "status": True,
    "message": "Profile updated successfully",
    "data": {
        "token": "fake-login-token-123",
        "user": {
            "id": str(doctor.id),
            "email": doctor.email,
            "fullName": doctor.fullName,
            "userName": doctor.userName,
            "phone": doctor.phone if doctor.phone else "",
            "gender": doctor.gender,
            "profilePicture": img_path,
            "role": "Doctor",
            "dateOfBirth": None,
            "latitude": None,
            "longitude": None,
            "age": None
        }
    }
}


# --- 5. X-Ray / Chest Scan prediction (Hugging Face Space Ibrahim2002/xray_ai) ---
HF_SPACE = "Ibrahim2002/xray_ai"
API_NAME = "/predict"


def _parse_label_result(result):
    """Parse Gradio Label output: dict[str,float], or list containing it, or confidences list."""
    prediction_str = "Unknown"
    confidence = 0.0

    # Unwrap if API returns a list (e.g. single output as [dict])
    if isinstance(result, (list, tuple)) and len(result) > 0:
        result = result[0]

    if result is None:
        return prediction_str, confidence

    if isinstance(result, dict):
        # Format 1: {"Covid": 0.1, "Lung Cancer": 0.2, "Normal": 0.6, "Pneumonia": 0.1}
        items = []
        for k, v in result.items():
            if k in ("label", "confidences") or (isinstance(k, str) and k.startswith("_")):
                continue
            try:
                items.append((str(k), float(v)))
            except (TypeError, ValueError):
                pass
        if items:
            top_class, top_prob = max(items, key=lambda x: x[1])
            return top_class, round(top_prob * 100, 1)

        # Format 2: {"label": "Covid", "confidences": [{"label": "Covid", "confidence": 0.85}, ...]}
        if "label" in result and "confidences" in result:
            pred = result.get("label")
            conf_list = result.get("confidences") or []
            for c in conf_list:
                if isinstance(c, dict) and c.get("label") == pred:
                    conf = c.get("confidence")
                    if conf is not None:
                        return str(pred), round(float(conf) * 100, 1)
            # Fallback: use first confidence (top class)
            if conf_list and isinstance(conf_list[0], dict):
                c0 = conf_list[0]
                return str(c0.get("label", pred)), round(float(c0.get("confidence", 0)) * 100, 1)
            return str(pred), confidence

        if "label" in result:
            return str(result["label"]), confidence

    if isinstance(result, str):
        return result, confidence

    return prediction_str, confidence


@app.post("/api/ChestScan/upload")
async def chest_scan_upload(
    image: UploadFile = File(...),
    Longitude: Optional[float] = Form(None),
    Latitude: Optional[float] = Form(None),
    db: Session = Depends(get_db),
):
    """Accepts X-ray image, calls Hugging Face Gradio Space, returns prediction and saves to history."""
    if not image.filename:
        raise HTTPException(status_code=400, detail="No image file provided")

    suffix = os.path.splitext(image.filename)[1] or ".png"
    image.file.seek(0)
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        shutil.copyfileobj(image.file, tmp)
        tmp_path = tmp.name

    try:
        client = Client(HF_SPACE)
        result = client.predict(
            image=handle_file(tmp_path),
            api_name=API_NAME,
        )
        print(f"[ChestScan] HF Space raw result type={type(result).__name__!r} value={result!r}")

        prediction_str, confidence = _parse_label_result(result)
        description = f"Result from X-ray AI: {prediction_str} ({confidence}%)"

        # Save image to uploads and store record for history
        from datetime import datetime
        ts = int(time.time())
        saved_filename = f"scan_{ts}_{image.filename or 'image'}"
        saved_path = f"{UPLOAD_DIR}/{saved_filename}"
        shutil.copy(tmp_path, saved_path)

        scan_record = ScanRecord(
            imagePath=saved_path,
            detectionClass=prediction_str,
            confidence=str(confidence),
            description=description,
            isReviewed="false",
            uploadDate=datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.000Z"),
        )
        db.add(scan_record)
        db.commit()
        db.refresh(scan_record)

        return {
            "prediction": prediction_str,
            "confidence": confidence,
            "description": description,
            "heatmap_base64": None,
            "imagePath": f"/{scan_record.imagePath}",
            "id": scan_record.id,
        }
    except Exception as e:
        print(f"[ChestScan] Error calling HF Space: {e!r}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        try:
            os.unlink(tmp_path)
        except Exception:
            pass


@app.get("/MriScan")
def get_scan_history(
    pageIndex: int = 0,
    pageSize: int = 10,
    db: Session = Depends(get_db),
):
    """Returns paginated scan history for History and Recent History screens."""
    from math import ceil
    query = db.query(ScanRecord).order_by(ScanRecord.id.desc())
    total = query.count()
    total_pages = ceil(total / pageSize) if pageSize > 0 else 0
    items = query.offset(pageIndex * pageSize).limit(pageSize).all()
    data = [
        {
            "imagePath": f"/{r.imagePath}",
            "detectionClass": r.detectionClass,
            "isReviewed": r.isReviewed == "true",
            "uploadDate": r.uploadDate,
            "doctorReview": None,
            "confidence": float(r.confidence) if r.confidence else 0,
            "description": r.description or "",
        }
        for r in items
    ]
    return {
        "pageIndex": pageIndex,
        "pageSize": pageSize,
        "count": len(data),
        "totalPages": total_pages,
        "data": data,
    }