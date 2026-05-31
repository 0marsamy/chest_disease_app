import logging
import os
import random
import shutil
import tempfile
import time
from datetime import datetime
from typing import Optional

from fastapi import Depends, FastAPI, File, Form, HTTPException, Request, UploadFile
from fastapi.responses import JSONResponse
from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Float,
    Integer,
    String,
    create_engine,
    text,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Session, sessionmaker

from xray_services import classify_xray, validate_xray

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

SQLALCHEMY_DATABASE_URL = "sqlite:///./doctors.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


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
    is_verified = Column(Boolean, default=False)
    verification_code = Column(String, nullable=True)


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


def _ensure_doctor_columns() -> None:
    """Simple SQLite-safe migration for new verification fields."""
    with engine.connect() as conn:
        cols = {row[1] for row in conn.execute(text("PRAGMA table_info(doctors)")).fetchall()}
        if "is_verified" not in cols:
            conn.execute(text("ALTER TABLE doctors ADD COLUMN is_verified BOOLEAN DEFAULT 0"))
        if "verification_code" not in cols:
            conn.execute(text("ALTER TABLE doctors ADD COLUMN verification_code TEXT"))
        conn.commit()


_ensure_doctor_columns()

app = FastAPI()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def _generate_otp() -> str:
    return f"{random.randint(0, 999999):06d}"


@app.get("/")
def home():
    return {"message": "Server is Running... You are ready! 🚀"}


@app.post("/api/Auth/register/doctor")
async def register_doctor(
    fullName: str = Form(...),
    userName: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    phone: Optional[str] = Form(None),
    gender: str = Form(...),
    profileProfile: Optional[UploadFile] = File(None),
    licenseFront: Optional[UploadFile] = File(None),
    licenseBack: Optional[UploadFile] = File(None),
    clinicAddress: Optional[str] = Form(None),
    latitude: Optional[str] = Form(None),
    longitude: Optional[str] = Form(None),
    dateOfBirth: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    file_path = None
    if profileProfile and profileProfile.filename:
        file_path = f"{UPLOAD_DIR}/{profileProfile.filename}"
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(profileProfile.file, buffer)

    otp = _generate_otp()
    new_doctor = Doctor(
        fullName=fullName,
        userName=userName,
        email=email,
        password=password,
        phone=phone,
        gender=gender,
        profileImage=file_path,
        is_verified=False,
        verification_code=otp,
    )

    try:
        db.add(new_doctor)
        db.commit()
        db.refresh(new_doctor)
        logger.info("New signup needs verification: email=%s code=%s", email, otp)
    except Exception as e:
        logger.exception("Register failed")
        return {"status": "error", "message": str(e)}

    return {
        "email": email,
        "userId": new_doctor.id,
        "role": "Doctor",
        "requiresVerification": True,
        "message": "Verification code generated.",
    }


@app.post("/api/Auth/login")
async def login(
    email: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db),
):
    doctor = db.query(Doctor).filter(Doctor.email == email).first()
    if not doctor:
        raise HTTPException(status_code=400, detail="User not found")
    if doctor.password != password:
        raise HTTPException(status_code=400, detail="Incorrect password")
    if not bool(doctor.is_verified):
        raise HTTPException(status_code=403, detail="Please verify your email before login.")

    img_path = doctor.profileImage if doctor.profileImage else ""
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
        },
    }


@app.post("/forgot-password")
@app.post("/api/Auth/forgetPassword")
async def forgot_password(
    request: Request,
    email: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    if not email:
        try:
            payload = await request.json()
            email = payload.get("email")
        except Exception:
            email = None
    if not email:
        raise HTTPException(status_code=400, detail="Email is required.")
    doctor = db.query(Doctor).filter(Doctor.email == email).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Email not found.")
    doctor.verification_code = _generate_otp()
    db.commit()
    logger.info("Forgot password OTP generated: email=%s code=%s", email, doctor.verification_code)
    return {"status": "success", "email": email, "message": "OTP generated."}


@app.post("/verify-email")
@app.post("/api/Auth/verify")
@app.post("/api/Auth/verifyEmail")
async def verify_email(
    request: Request,
    email: Optional[str] = Form(None),
    code: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    if not email or not code:
        try:
            payload = await request.json()
            email = email or payload.get("email")
            code = code or payload.get("code")
        except Exception:
            pass
    if not email or not code:
        raise HTTPException(status_code=400, detail="Email and code are required.")
    doctor = db.query(Doctor).filter(Doctor.email == email).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="User not found.")
    if doctor.verification_code != code:
        raise HTTPException(status_code=400, detail="Invalid verification code.")
    doctor.is_verified = True
    doctor.verification_code = None
    db.commit()
    return {"status": "success", "message": "Email verified successfully."}


@app.post("/api/ChestScan/upload")
async def chest_scan_upload(
    image: UploadFile = File(...),
    Longitude: Optional[float] = Form(None),
    Latitude: Optional[float] = Form(None),
    db: Session = Depends(get_db),
):
    suffix = os.path.splitext(image.filename or "")[1] or ".png"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        content = await image.read()
        tmp.write(content)
        tmp_path = tmp.name

    try:
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

        try:
            result = classify_xray(tmp_path)
        except Exception as e:
            logger.exception("Main classification model failed: %s", e)
            raise HTTPException(
                status_code=500,
                detail="Classification service failed. Please try again later.",
            ) from e

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
            "segmented_base64": result.get("segmented_base64"), # <--- الإضافة هنا
            "heatmap_base64": result.get("heatmap_base64"),
            "imagePath": rel_path,
            "id": scan.id,
        }
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


@app.get("/api/ChestScan/history")
@app.get("/MriScan")
async def get_scans(
    pageIndex: int = 0,
    pageSize: int = 10,
    db: Session = Depends(get_db),
):
    total = db.query(Scan).count()
    offset = pageIndex * pageSize
    rows = db.query(Scan).order_by(Scan.uploadDate.desc()).offset(offset).limit(pageSize).all()
    total_pages = (total + pageSize - 1) // pageSize if pageSize > 0 else 0

    data = [
        {
            "imagePath": r.imagePath,
            "detectionClass": r.detectionClass,
            "isReviewed": r.isReviewed or False,
            "uploadDate": r.uploadDate.isoformat() + "Z"
            if r.uploadDate
            else datetime.utcnow().isoformat() + "Z",
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