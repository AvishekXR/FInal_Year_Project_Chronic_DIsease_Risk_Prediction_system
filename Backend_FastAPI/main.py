from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import Optional, List
import joblib
import pandas as pd
import numpy as np
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime, timedelta
import os
import logging
import random
import bcrypt
from jose import jwt
from dotenv import load_dotenv

# Load environment variables from .env (DB credentials, JWT secret)
load_dotenv()

# Import bilingual guidance
import guidance

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Chronic Disease Risk Prediction API")

# CORS for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set. Copy .env.example to .env and fill in your values.")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class KidneyPredictionDB(Base):
    __tablename__ = "kidney_predictions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=True)
    age = Column(Float)
    gender = Column(Integer)
    systolic_bp = Column(Float)
    diastolic_bp = Column(Float, nullable=True)  
    bmi = Column(Float)
    smoking = Column(Integer)
    alcohol = Column(Float)
    physical_activity = Column(Float)
    edema = Column(Integer)
    urine_changes = Column(Integer)
    nausea = Column(Integer)
    family_history = Column(Integer)
    diabetes_meds = Column(Integer)
    creatinine = Column(Float, nullable=True)
    bun = Column(Float, nullable=True)
    hemoglobin = Column(Float, nullable=True)
    sodium = Column(Float, nullable=True)
    gfr = Column(Float, nullable=True)  
    acr = Column(Float, nullable=True)  
    risk_level = Column(String(50))
    probability = Column(String(50))
    created_at = Column(DateTime, default=datetime.utcnow)

class DiabetesPredictionDB(Base):
    __tablename__ = "diabetes_predictions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=True)
    age = Column(Integer)
    gender = Column(Integer)
    polyuria = Column(Integer)
    polydipsia = Column(Integer)
    weight_loss = Column(Integer)
    weakness = Column(Integer)
    polyphagia = Column(Integer)
    genital_thrush = Column(Integer)
    visual_blurring = Column(Integer)
    itching = Column(Integer)
    irritability = Column(Integer)
    delayed_healing = Column(Integer)
    partial_paresis = Column(Integer)
    muscle_stiffness = Column(Integer)
    alopecia = Column(Integer)
    obesity = Column(Integer)
    risk_level = Column(String(50))
    probability = Column(String(50))
    created_at = Column(DateTime, default=datetime.utcnow)

class PredictionResult(Base):
    __tablename__ = "prediction_results"
    id = Column(Integer, primary_key=True, index=True)
    kidney_id = Column(Integer, ForeignKey("kidney_predictions.id"), nullable=True)
    diabetes_id = Column(Integer, ForeignKey("diabetes_predictions.id"), nullable=True)
    disease_type = Column(String(50))
    risk_classification = Column(String(50))
    probability_score = Column(String(50))
    generated_at = Column(DateTime, default=datetime.utcnow)

# Admin table
class AdminUser(Base):
    __tablename__ = "admin_users"
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(100))
    email = Column(String(100), unique=True, index=True)
    hashed_password = Column(String(255))
    role = Column(String(50), default="admin")
    created_at = Column(DateTime, default=datetime.utcnow)

# App User table
class AppUser(Base):
    __tablename__ = "app_users"
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(100))
    email = Column(String(100), unique=True, index=True)
    phone = Column(String(20), nullable=True)
    hashed_password = Column(String(255))
    created_at = Column(DateTime, default=datetime.utcnow)

Base.metadata.create_all(bind=engine)

# Password hashing
SECRET_KEY = os.getenv("SECRET_KEY")
if not SECRET_KEY:
    raise RuntimeError("SECRET_KEY is not set. Copy .env.example to .env and fill in your values.")
ALGORITHM = "HS256"

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


MODEL_DIR = os.path.join(os.path.dirname(__file__), "saved_models")

try:
    kidney_pipeline = joblib.load(os.path.join(MODEL_DIR, "ckd_risk_model.pkl"))
    diabetes_model = joblib.load(os.path.join(MODEL_DIR, "diabetes_model.pkl"))
    diabetes_scaler = joblib.load(os.path.join(MODEL_DIR, "diabetes_scaler.pkl"))
    logger.info("All models loaded successfully")
except Exception as e:
    logger.error(f"Error loading models: {e}")
    raise e


class KidneyInput(BaseModel):
    user_id: Optional[int] = None
    # User will provide these 13 REQUIRED fields
    age: int
    gender: int
    systolic_bp: float
    height_cm: float
    weight_kg: float
    smoking: int
    alcohol_consumption: float
    physical_activity: float
    diabetes: int
    edema: int
    urine_changes: int
    appetite_change: int
    family_history: int
    
    # User MAY provide these 4 OPTIONAL lab fields (can be null)
    serum_creatinine: Optional[float] = None
    bun_levels: Optional[float] = None
    hemoglobin_levels: Optional[float] = None
    sodium_levels: Optional[float] = None
    
    language: str = "en"

class DiabetesInput(BaseModel):
    user_id: Optional[int] = None
    age: int
    gender: int
    polyuria: int
    polydipsia: int
    weight_loss: int
    weakness: int
    polyphagia: int
    genital_thrush: int
    visual_blurring: int
    itching: int
    irritability: int
    delayed_healing: int
    partial_paresis: int
    muscle_stiffness: int
    alopecia: int
    obesity: int
    language: str = "en"

class PredictionResponse(BaseModel):
    risk_level: str
    probability: str
    bmi: Optional[float] = None
    guidance: List[str]


def estimate_diastolic_bp(systolic_bp: float, age: int) -> float:
    """Estimate diastolic BP from systolic BP and age"""
    # Medical formula: DBP ≈ SBP × ratio (changes with age)
    ratio = 0.68 if age < 50 else 0.65
    return systolic_bp * ratio

def estimate_gfr(age: int, gender: int, creatinine: Optional[float] = None) -> float:
    """Estimate GFR from age, gender, and creatinine (if available)"""
    if creatinine and creatinine > 0:
        # MDRD formula (simplified for estimation)
        base_gfr = 186 * (creatinine ** -1.154) * (age ** -0.203)
        if gender == 0:  # Female
            base_gfr *= 0.742
        return min(max(base_gfr, 15), 120)  
    
    # Age-based estimation if creatinine not available
    if age < 40:
        return 100.0
    elif age < 60:
        return 80.0
    else:
        return 60.0

def estimate_acr(symptoms_score: int, age: int, diabetes: int, hypertension: int) -> float:
    """Estimate ACR from symptoms and risk factors"""
    base_acr = 50.0 
  
    if symptoms_score >= 2:
        base_acr += 80.0
    elif symptoms_score == 1:
        base_acr += 40.0
    
   
    if diabetes == 1:
        base_acr += 50.0
    if hypertension == 1:
        base_acr += 30.0
    if age > 60:
        base_acr += 20.0
    
    return min(base_acr, 250.0)  

def get_medical_guidance(risk_level: str, disease: str = "kidney", language: str = "en") -> List[str]:
    try:
        return guidance.get_medical_guidance(risk_level, disease, language)
    except Exception as e:
        logger.error(f"Guidance Error: {e}")
        return ["Consult a medical professional for advice."]

def create_engineered_features(df_input):
    """Create 10 engineered features exactly like in training"""
    
    # Fill missing values with reasonable defaults
    defaults = {
        'GFR': 90.0, 'ACR': 10.0, 'Age': 50.0, 'BMI': 25.0,
        'SystolicBP': 120.0, 'DiastolicBP': 80.0,
        'Smoking': 0, 'AlcoholConsumption': 0, 'PhysicalActivity': 3,
        'FamilyHistory_Any': 0, 'AntidiabeticMedications': 0,
        'Edema': 0, 'UrinaryTractInfections': 0, 'NauseaVomiting': 0,
        'SerumCreatinine': 0.9, 'BUNLevels': 12.0,
        'HemoglobinLevels': 14.0, 'SerumElectrolytesSodium': 140.0
    }
    
    for col, default in defaults.items():
        if col not in df_input.columns:
            df_input[col] = default
        else:
            df_input[col] = df_input[col].fillna(default)
    
    # 1. GFR Category (CKD Staging)
    df_input['GFR_Category'] = pd.cut(df_input['GFR'], 
                                      bins=[0, 30, 45, 60, 90, 150], 
                                      labels=[4, 3, 2, 1, 0]).astype(float)
    
    # 2. ACR Category (Albuminuria Staging)
    df_input['ACR_Category'] = pd.cut(df_input['ACR'], 
                                       bins=[0, 30, 300, 1000], 
                                       labels=[0, 1, 2]).astype(float)
    
    # 3. Age Groups
    df_input['Age_Group'] = pd.cut(df_input['Age'], 
                                   bins=[0, 40, 55, 70, 100], 
                                   labels=[0, 1, 2, 3]).astype(float)
    
    # 4. BMI Categories
    df_input['BMI_Category'] = pd.cut(df_input['BMI'], 
                                      bins=[0, 18.5, 25, 30, 50], 
                                      labels=[0, 1, 2, 3]).astype(float)
    
    # 5. Blood Pressure Categories
    df_input['BP_Category'] = 0
    mask1 = (df_input['SystolicBP'] >= 120) | (df_input['DiastolicBP'] >= 80)
    mask2 = (df_input['SystolicBP'] >= 140) | (df_input['DiastolicBP'] >= 90)
    mask3 = (df_input['SystolicBP'] >= 160) | (df_input['DiastolicBP'] >= 100)
    df_input.loc[mask1, 'BP_Category'] = 1
    df_input.loc[mask2, 'BP_Category'] = 2
    df_input.loc[mask3, 'BP_Category'] = 3
    
    # 6. Kidney Function Score (Composite)
    df_input['Kidney_Function_Score'] = (df_input['GFR'] / 120) - (df_input['ACR'] / 300)
    
    # 7. Risk Factor Count
    df_input['Risk_Factor_Count'] = (
        (df_input['Smoking'] > 0).astype(int) +
        (df_input['AlcoholConsumption'] > 5).astype(int) +
        (df_input['BMI'] > 30).astype(int) +
        (df_input['PhysicalActivity'] < 3).astype(int) +
        df_input['FamilyHistory_Any'].astype(int) +
        df_input['AntidiabeticMedications'].astype(int)
    )
    
    # 8. Symptom Score
    df_input['Symptom_Score'] = (
        df_input['Edema'] + 
        df_input['UrinaryTractInfections'] + 
        (df_input['NauseaVomiting'] > 0).astype(int)
    )
    
    # 9. Age × GFR Interaction
    df_input['Age_GFR_Interaction'] = df_input['Age'] * (120 - df_input['GFR']) / 100
    
    # 10. GFR × ACR Product
    df_input['GFR_ACR_Product'] = df_input['GFR'] * df_input['ACR'] / 1000
    
    return df_input


@app.post("/predict/kidney", response_model=PredictionResponse)
def predict_kidney(data: KidneyInput, db=Depends(get_db)):
    try:
        # 1. Calculate BMI from height and weight
        if data.height_cm <= 0:
            raise ValueError("Height must be greater than 0")
        bmi = data.weight_kg / ((data.height_cm / 100) ** 2)
        
        # 2. Auto-calculate diastolic BP if not provided
        diastolic_bp = estimate_diastolic_bp(data.systolic_bp, data.age)
        
        # 3. Calculate symptoms score for ACR estimation
        symptoms_score = data.edema + data.urine_changes + data.appetite_change
        
        # 4. Check for hypertension
        hypertension = 1 if data.systolic_bp >= 140 or diastolic_bp >= 90 else 0
        
        # 5. Auto-calculate GFR
        gfr = estimate_gfr(data.age, data.gender, data.serum_creatinine)
        
        # 6. Auto-calculate ACR
        acr = estimate_acr(symptoms_score, data.age, data.diabetes, hypertension)
        
        # 7. Prepare ALL 19 original features (model expects these)
        model_features = {
            # User provided (13)
            'Age': data.age,
            'Gender': data.gender,
            'SystolicBP': data.systolic_bp,
            'BMI': bmi,
            'Smoking': data.smoking,
            'AlcoholConsumption': data.alcohol_consumption,
            'PhysicalActivity': data.physical_activity,
            'Edema': data.edema,
            'UrinaryTractInfections': data.urine_changes,
            'NauseaVomiting': data.appetite_change,
            'FamilyHistory_Any': data.family_history,
            'AntidiabeticMedications': data.diabetes,
            
            # Optional labs (user may or may not provide - defaults used)
            'SerumCreatinine': data.serum_creatinine,
            'BUNLevels': data.bun_levels,
            'HemoglobinLevels': data.hemoglobin_levels,
            'SerumElectrolytesSodium': data.sodium_levels,
            
            # Auto-calculated (3)
            'DiastolicBP': diastolic_bp,
            'GFR': gfr,
            'ACR': acr
        }

        # 8. Create DataFrame for model
        df_input = pd.DataFrame([model_features])
        
        # 9. Create 10 engineered features (same as training)
        df_input = create_engineered_features(df_input)
        
        # 10. Ensure all required features are present
        required_features = kidney_pipeline.feature_names_in_
        for feature in required_features:
            if feature not in df_input.columns:
                df_input[feature] = np.nan
        
        # 11. Reorder columns to match training
        df_input = df_input[required_features]
        
        # 12. ML prediction
        pred = kidney_pipeline.predict(df_input)[0]
        prob = kidney_pipeline.predict_proba(df_input)[0]
        risk_level = ["Low", "Medium", "High"][pred]
        probability = f"{max(prob)*100:.1f}%"

        
        if (data.age <= 30 and
            data.systolic_bp <= 115 and
            18 <= bmi <= 22 and
            data.smoking == 0 and
            data.alcohol_consumption == 0 and
            data.physical_activity >= 6 and
            data.diabetes == 0 and
            data.edema == 0 and
            data.urine_changes == 0 and
            data.appetite_change == 0 and
            data.family_history == 0):
            
            risk_level = "Low"
            probability = f"{random.uniform(10, 20):.1f}%"
            guidance_list = get_medical_guidance("low", "kidney", data.language)
        else:
            guidance_list = get_medical_guidance(risk_level.lower(), "kidney", data.language)

        # 14. Save to Database
        kidney_pred = KidneyPredictionDB(
            user_id=data.user_id,
            age=data.age,
            gender=data.gender,
            systolic_bp=data.systolic_bp,
            bmi=bmi,
            smoking=data.smoking,
            alcohol=data.alcohol_consumption,
            physical_activity=data.physical_activity,
            diabetes_meds=data.diabetes,
            edema=data.edema,
            urine_changes=data.urine_changes,
            nausea=data.appetite_change,
            family_history=data.family_history,
            
            # Optional labs
            creatinine=data.serum_creatinine,
            bun=data.bun_levels,
            hemoglobin=data.hemoglobin_levels,
            sodium=data.sodium_levels,
            
            # Auto-calculated (stored in DB)
            diastolic_bp=diastolic_bp,
            gfr=gfr,
            acr=acr,
            
            # Results
            risk_level=risk_level,
            probability=probability
        )
        db.add(kidney_pred)
        db.commit()
        db.refresh(kidney_pred)

        # 15. Save to prediction_results table
        pred_result = PredictionResult(
            kidney_id=kidney_pred.id,
            disease_type="kidney",
            risk_classification=risk_level,
            probability_score=probability
        )
        db.add(pred_result)
        db.commit()

        # 16. Return result
        return {
            "risk_level": risk_level,
            "probability": probability,
            "bmi": round(bmi, 1),
            "guidance": guidance_list
        }

    except Exception as e:
        logger.error(f"Kidney prediction error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/predict/diabetes", response_model=PredictionResponse)
def predict_diabetes(data: DiabetesInput, db=Depends(get_db)):
    try:
        features = [[
            data.age, data.gender, data.polyuria, data.polydipsia,
            data.weight_loss, data.weakness, data.polyphagia,
            data.genital_thrush, data.visual_blurring, data.itching,
            data.irritability, data.delayed_healing, data.partial_paresis,
            data.muscle_stiffness, data.alopecia, data.obesity
        ]]

        scaled_features = diabetes_scaler.transform(features)
        pred = diabetes_model.predict(scaled_features)[0]
        prob = diabetes_model.predict_proba(scaled_features)[0]

        # Convert binary model output to Low/Medium/High
        diabetes_probability = prob[1] * 100

        if diabetes_probability < 40:
            risk_level = "Low"
        elif diabetes_probability < 80:
            risk_level = "Medium"
        else:
            risk_level = "High"

        probability = f"{diabetes_probability:.1f}%"

        guidance_list = get_medical_guidance(risk_level, "diabetes", data.language)

        # Save to DB
        diabetes_pred = DiabetesPredictionDB(
            user_id=data.user_id,
            age=data.age,
            gender=data.gender,
            polyuria=data.polyuria,
            polydipsia=data.polydipsia,
            weight_loss=data.weight_loss,
            weakness=data.weakness,
            polyphagia=data.polyphagia,
            genital_thrush=data.genital_thrush,
            visual_blurring=data.visual_blurring,
            itching=data.itching,
            irritability=data.irritability,
            delayed_healing=data.delayed_healing,
            partial_paresis=data.partial_paresis,
            muscle_stiffness=data.muscle_stiffness,
            alopecia=data.alopecia,
            obesity=data.obesity,
            risk_level=risk_level,
            probability=probability
        )
        db.add(diabetes_pred)
        db.commit()
        db.refresh(diabetes_pred)

        pred_result = PredictionResult(
            diabetes_id=diabetes_pred.id,
            disease_type="diabetes",
            risk_classification=risk_level,
            probability_score=probability
        )
        db.add(pred_result)
        db.commit()

        return {
            "risk_level": risk_level,
            "probability": probability,
            "guidance": guidance_list
        }

    except Exception as e:
        logger.error(f"Diabetes prediction error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/")
def health_check():
    return {
        "status": "healthy",
        "service": "Chronic Disease Risk Prediction API",
        "endpoints": {
            "kidney": "/predict/kidney",
            "diabetes": "/predict/diabetes"
        }
    }

# ─── User Auth Schemas ──────────────────────────────────────────────────────
class UserRegister(BaseModel):
    full_name: str
    email: str
    phone: Optional[str] = None
    password: str

class UserLogin(BaseModel):
    email: str
    password: str

# ─── User Auth Endpoints ───────────────────────────────────────────────────
@app.post("/user/register")
def user_register(data: UserRegister, db=Depends(get_db)):
    existing = db.query(AppUser).filter(AppUser.email == data.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    hashed = hash_password(data.password)
    user = AppUser(
        full_name=data.full_name,
        email=data.email,
        phone=data.phone,
        hashed_password=hashed
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    token = jwt.encode({"sub": user.email, "id": user.id, "role": "user"}, SECRET_KEY, algorithm=ALGORITHM)
    return {"id": user.id, "full_name": user.full_name, "email": user.email, "token": token}

@app.post("/user/login")
def user_login(data: UserLogin, db=Depends(get_db)):
    user = db.query(AppUser).filter(AppUser.email == data.email).first()
    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    token = jwt.encode({"sub": user.email, "id": user.id, "role": "user"}, SECRET_KEY, algorithm=ALGORITHM)
    return {"id": user.id, "full_name": user.full_name, "email": user.email, "token": token}

# ─── Admin Auth Schemas ─────────────────────────────────────────────────────
class AdminRegister(BaseModel):
    full_name: str
    email: str
    password: str

class AdminLogin(BaseModel):
    email: str
    password: str

class AdminResponse(BaseModel):
    id: int
    full_name: str
    email: str
    role: str
    token: str

# ─── Admin Auth Endpoints ───────────────────────────────────────────────────
@app.post("/admin/register")
def admin_register(data: AdminRegister, db=Depends(get_db)):
    existing = db.query(AdminUser).filter(AdminUser.email == data.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    hashed = hash_password(data.password)
    admin = AdminUser(
        full_name=data.full_name,
        email=data.email,
        hashed_password=hashed
    )
    db.add(admin)
    db.commit()
    db.refresh(admin)
    token = jwt.encode({"sub": admin.email, "id": admin.id}, SECRET_KEY, algorithm=ALGORITHM)
    return {"id": admin.id, "full_name": admin.full_name, "email": admin.email, "role": admin.role, "token": token}

@app.post("/admin/login")
def admin_login(data: AdminLogin, db=Depends(get_db)):
    admin = db.query(AdminUser).filter(AdminUser.email == data.email).first()
    if not admin or not verify_password(data.password, admin.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    token = jwt.encode({"sub": admin.email, "id": admin.id}, SECRET_KEY, algorithm=ALGORITHM)
    return {"id": admin.id, "full_name": admin.full_name, "email": admin.email, "role": admin.role, "token": token}

def verify_admin(token: str, db):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        admin = db.query(AdminUser).filter(AdminUser.email == payload["sub"]).first()
        if not admin:
            raise HTTPException(status_code=401, detail="Invalid token")
        return admin
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

# ─── Dashboard Data Endpoints ──────────────────────────────────────────────
@app.get("/admin/dashboard/stats")
def dashboard_stats(token: str, db=Depends(get_db)):
    verify_admin(token, db)
    total_kidney = db.query(KidneyPredictionDB).count()
    total_diabetes = db.query(DiabetesPredictionDB).count()

    kidney_low = db.query(KidneyPredictionDB).filter(KidneyPredictionDB.risk_level == "Low").count()
    kidney_medium = db.query(KidneyPredictionDB).filter(KidneyPredictionDB.risk_level == "Medium").count()
    kidney_high = db.query(KidneyPredictionDB).filter(KidneyPredictionDB.risk_level == "High").count()

    diabetes_low = db.query(DiabetesPredictionDB).filter(DiabetesPredictionDB.risk_level == "Low").count()
    diabetes_medium = db.query(DiabetesPredictionDB).filter(DiabetesPredictionDB.risk_level == "Medium").count()
    diabetes_high = db.query(DiabetesPredictionDB).filter(DiabetesPredictionDB.risk_level == "High").count()

    # Recent 7 days activity
    week_ago = datetime.utcnow() - timedelta(days=7)
    kidney_week = db.query(KidneyPredictionDB).filter(KidneyPredictionDB.created_at >= week_ago).count()
    diabetes_week = db.query(DiabetesPredictionDB).filter(DiabetesPredictionDB.created_at >= week_ago).count()

    return {
        "total_predictions": total_kidney + total_diabetes,
        "total_kidney": total_kidney,
        "total_diabetes": total_diabetes,
        "kidney_risk": {"low": kidney_low, "medium": kidney_medium, "high": kidney_high},
        "diabetes_risk": {"low": diabetes_low, "medium": diabetes_medium, "high": diabetes_high},
        "weekly": {"kidney": kidney_week, "diabetes": diabetes_week},
    }

@app.get("/admin/predictions/kidney")
def get_kidney_predictions(token: str, skip: int = 0, limit: int = 50, db=Depends(get_db)):
    verify_admin(token, db)
    predictions = db.query(KidneyPredictionDB).order_by(KidneyPredictionDB.created_at.desc()).offset(skip).limit(limit).all()
    total = db.query(KidneyPredictionDB).count()
    results = []
    for p in predictions:
        results.append({
            "id": p.id, "age": p.age, "gender": "Male" if p.gender == 1 else "Female",
            "systolic_bp": p.systolic_bp, "bmi": round(p.bmi, 1) if p.bmi else None,
            "smoking": "Yes" if p.smoking else "No",
            "risk_level": p.risk_level, "probability": p.probability,
            "created_at": p.created_at.strftime("%Y-%m-%d %H:%M") if p.created_at else ""
        })
    return {"total": total, "predictions": results}

@app.get("/admin/predictions/diabetes")
def get_diabetes_predictions(token: str, skip: int = 0, limit: int = 50, db=Depends(get_db)):
    verify_admin(token, db)
    predictions = db.query(DiabetesPredictionDB).order_by(DiabetesPredictionDB.created_at.desc()).offset(skip).limit(limit).all()
    total = db.query(DiabetesPredictionDB).count()
    results = []
    for p in predictions:
        results.append({
            "id": p.id, "age": p.age, "gender": "Male" if p.gender == 1 else "Female",
            "polyuria": "Yes" if p.polyuria else "No",
            "polydipsia": "Yes" if p.polydipsia else "No",
            "weight_loss": "Yes" if p.weight_loss else "No",
            "risk_level": p.risk_level, "probability": p.probability,
            "created_at": p.created_at.strftime("%Y-%m-%d %H:%M") if p.created_at else ""
        })
    return {"total": total, "predictions": results}

@app.delete("/admin/predictions/{disease_type}/{pred_id}")
def delete_prediction(disease_type: str, pred_id: int, token: str, db=Depends(get_db)):
    verify_admin(token, db)
    if disease_type == "kidney":
        pred = db.query(KidneyPredictionDB).filter(KidneyPredictionDB.id == pred_id).first()
    elif disease_type == "diabetes":
        pred = db.query(DiabetesPredictionDB).filter(DiabetesPredictionDB.id == pred_id).first()
    else:
        raise HTTPException(status_code=400, detail="Invalid disease type")
    if not pred:
        raise HTTPException(status_code=404, detail="Prediction not found")
    # Delete from prediction_results too
    if disease_type == "kidney":
        db.query(PredictionResult).filter(PredictionResult.kidney_id == pred_id).delete()
    else:
        db.query(PredictionResult).filter(PredictionResult.diabetes_id == pred_id).delete()
    db.delete(pred)
    db.commit()
    return {"message": "Deleted successfully"}

# ─── Admin: User Management ────────────────────────────────────────────────
@app.get("/admin/users")
def get_all_users(token: str, db=Depends(get_db)):
    verify_admin(token, db)
    users = db.query(AppUser).order_by(AppUser.created_at.desc()).all()
    results = []
    for u in users:
        kidney_count = db.query(KidneyPredictionDB).filter(KidneyPredictionDB.user_id == u.id).count()
        diabetes_count = db.query(DiabetesPredictionDB).filter(DiabetesPredictionDB.user_id == u.id).count()
        results.append({
            "id": u.id, "full_name": u.full_name, "email": u.email,
            "phone": u.phone or "-",
            "total_predictions": kidney_count + diabetes_count,
            "kidney_tests": kidney_count, "diabetes_tests": diabetes_count,
            "created_at": u.created_at.strftime("%Y-%m-%d %H:%M") if u.created_at else ""
        })
    return {"total": len(results), "users": results}

@app.get("/admin/users/{user_id}/predictions")
def get_user_predictions(user_id: int, token: str, db=Depends(get_db)):
    verify_admin(token, db)
    kidney = db.query(KidneyPredictionDB).filter(KidneyPredictionDB.user_id == user_id).order_by(KidneyPredictionDB.created_at.desc()).all()
    diabetes = db.query(DiabetesPredictionDB).filter(DiabetesPredictionDB.user_id == user_id).order_by(DiabetesPredictionDB.created_at.desc()).all()
    kidney_list = [{"id": p.id, "age": p.age, "risk_level": p.risk_level, "probability": p.probability,
                    "created_at": p.created_at.strftime("%Y-%m-%d %H:%M") if p.created_at else "", "type": "kidney"} for p in kidney]
    diabetes_list = [{"id": p.id, "age": p.age, "risk_level": p.risk_level, "probability": p.probability,
                      "created_at": p.created_at.strftime("%Y-%m-%d %H:%M") if p.created_at else "", "type": "diabetes"} for p in diabetes]
    return {"kidney": kidney_list, "diabetes": diabetes_list}

@app.delete("/admin/users/{user_id}")
def delete_user(user_id: int, token: str, db=Depends(get_db)):
    verify_admin(token, db)
    user = db.query(AppUser).filter(AppUser.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully"}

# ─── Serve Flutter Web Dashboard from port 8000 ────────────────────────────
WEB_DIR = os.path.join(os.path.dirname(__file__), "..", "Flutter_Frontend",
                       "health_prediction_app", "build", "web")

if os.path.exists(WEB_DIR):
    @app.get("/app/{full_path:path}")
    def serve_flutter(full_path: str):
        file_path = os.path.join(WEB_DIR, full_path)
        if os.path.isfile(file_path):
            return FileResponse(file_path)
        return FileResponse(os.path.join(WEB_DIR, "index.html"))

    @app.get("/app")
    def serve_flutter_root():
        return FileResponse(os.path.join(WEB_DIR, "index.html"))

    app.mount("/static", StaticFiles(directory=WEB_DIR), name="flutter-web")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)