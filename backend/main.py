from fastapi import FastAPI, File, UploadFile, Form, Depends, HTTPException, APIRouter
from typing import Optional
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import os
import shutil
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import time # عشان timestamp الصورة

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
    profileImage = Column(String) # مسار الصورة

# إنشاء الجدول لو مش موجود
Base.metadata.create_all(bind=engine)

app = FastAPI()

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