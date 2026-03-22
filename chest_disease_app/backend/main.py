import logging
import os
import shutil
import tempfile
import time
from datetime import datetime
from typing import Optional

from fastapi import FastAPI, File, Form, HTTPException, UploadFile, Depends
from fastapi.responses import JSONResponse
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Session, sessionmaker

from xray_services import classify_xray, validate_xray

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# --- 1. إعدادات قاعدة البيانات (ملف بسيط اسمه doctors.db) ---
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
    profileImage = Column(String)


class Scan(Base):
    __tablename__ = "scans"
    id = Column(Integer, primary_key=True, index=True)
    imagePath = Column(String)
    detectionClass = Column(String)
    confidence = Column(Float)
    description = Column(String)
    isReviewed = Column(Boolean, default=False)
    uploadDate = Column(DateTime, default=datetime.utcnow)


Base.metadata.create_all(bind=engine)

app = FastAPI()

# فولدر حفظ الصور
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

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

# --- 2. نقطة التسجيل (Registration API) ---
 @app.post("/api/Auth/register/doctor")
async def register_doctor(
    fullName: str = Form(...),
    userName: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    phone: Optional[str] = Form(None),
    gender: str = Form(...),
    # الملفات: الصورة بس إجباري، والباقي اختياري ومش هيعمل كراش
    profileProfile: UploadFile = File(...), 
    licenseFront: Optional[UploadFile] = File(None),
    licenseBack: Optional[UploadFile] = File(None),
    clinicAddress: Optional[str] = Form(None), # اختياري
    latitude: Optional[str] = Form(None),
    longitude: Optional[str] = Form(None),
    dateOfBirth: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    # حفظ الصورة
    file_path = f"{UPLOAD_DIR}/{profileProfile.filename}"
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

    # الرد بصيغة نجاح يفهمها الموبايل
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
    
    # التأكد إن الصورة مش Null (نبعت نص فاضي لو مفيش صورة)
    img_path = doctor.profileImage if doctor.profileImage else ""

    # بناء الرد حسب الموديل بتاع فلاتر
    return {
        "token": "fake-login-token-123",
        "user": {
            "id": doctor.id,
            "profilePicture": img_path,
            "fullName": doctor.fullName,
            "userName": doctor.userName,
            "email": doctor.email,
            "dateOfBirth": None,
            "role": "Doctor",
            "gender": doctor.gender,
            "latitude": None,
            "longitude": None,
            "age": None,
        }
    }


# --- 4. Chest Scan Upload (with OOD validation) ---
@app.post("/api/ChestScan/upload")
async def chest_scan_upload(
    image: UploadFile = File(...),
    Longitude: Optional[float] = Form(None),
    Latitude: Optional[float] = Form(None),
    db: Session = Depends(get_db),
):
    """
    Upload chest X-ray for classification.
    1. Validate via OOD model (X-ray vs Not X-ray).
    2. If valid, run main classification and save to DB.
    """
    suffix = os.path.splitext(image.filename or "")[1] or ".png"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        content = await image.read()
        tmp.write(content)
        tmp_path = tmp.name

    try:
        # Step 1: OOD validation
        try:
            is_valid_xray = validate_xray(tmp_path)
        except Exception as e:
            logger.exception("OOD API failed: %s", e)
            raise HTTPException(
                status_code=500,
                detail="OOD validation service failed. Please try again later.",
            ) from e

        if not is_valid_xray:
            return JSONResponse(
                status_code=400,
                content={
                    "status": "invalid_image",
                    "message": "Please upload a valid chest X-ray image.",
                },
            )

        # Step 2: Main classification
        try:
            result = classify_xray(tmp_path)
        except Exception as e:
            logger.exception("Main classification model failed: %s", e)
            raise HTTPException(
                status_code=500,
                detail="Classification service failed. Please try again later.",
            ) from e

        # Step 3: Save image and record to DB
        timestamp = int(time.time())
        safe_name = f"scan_{timestamp}_{(image.filename or 'image')}".replace(" ", "_")
        save_path = os.path.join(UPLOAD_DIR, safe_name)
        shutil.copy(tmp_path, save_path)
        rel_path = f"/{UPLOAD_DIR}/{safe_name}".replace("//", "/")

        scan = Scan(
            imagePath=rel_path,
            detectionClass=result["prediction"],
            confidence=result["confidence"],
            description=result["description"],
        )
        db.add(scan)
        db.commit()
        db.refresh(scan)

        return {
            "prediction": result["prediction"],
            "confidence": result["confidence"],
            "description": result["description"],
            "heatmap_base64": result.get("heatmap_base64"),
            "imagePath": rel_path,
            "id": scan.id,
        }
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


# --- 5. Get scan history (MriScan) ---
@app.get("/MriScan")
async def get_scans(
    pageIndex: int = 0,
    pageSize: int = 10,
    db: Session = Depends(get_db),
):
    """Paginated scan history for History / Recent History screens."""
    total = db.query(Scan).count()
    offset = pageIndex * pageSize
    rows = db.query(Scan).order_by(Scan.uploadDate.desc()).offset(offset).limit(pageSize).all()
    total_pages = (total + pageSize - 1) // pageSize if pageSize > 0 else 0

    data = [
        {
            "imagePath": r.imagePath,
            "detectionClass": r.detectionClass,
            "isReviewed": r.isReviewed or False,
            "uploadDate": r.uploadDate.isoformat() + "Z" if r.uploadDate else datetime.utcnow().isoformat() + "Z",
            "doctorReview": None,
            "confidence": r.confidence,
            "description": r.description,
        }
        for r in rows
    ]

    return {
        "pageIndex": pageIndex,
        "pageSize": pageSize,
        "count": total,
        "totalPages": total_pages,
        "data": data,
    }