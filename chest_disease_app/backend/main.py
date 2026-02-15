from fastapi import FastAPI, File, UploadFile, Form, Depends, HTTPException
from typing import Optional
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import os
import shutil

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
    profileImage = Column(String) # مسار الصورة

# إنشاء الجدول لو مش موجود
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
            "dateOfBirth": None,  # Add this field
            "role": "Doctor",
            "gender": doctor.gender,
            "latitude": None,     # Add this field
            "longitude": None,    # Add this field
            "age": None           # Add this field
        }
    }