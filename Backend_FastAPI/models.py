from sqlalchemy import Column, Integer, Float, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from database import Base

class KidneyPredictionDB(Base):
    __tablename__ = "kidney_predictions"
    id = Column(Integer, primary_key=True, index=True)
    # Inputs
    age = Column(Integer)
    gender = Column(Integer)
    systolic_bp = Column(Float)
    bmi = Column(Float)
    smoking = Column(Integer)
    alcohol = Column(Integer)
    physical_activity = Column(Integer)
    edema = Column(Integer)
    urine_changes = Column(Integer)
    nausea = Column(Integer)
    family_history = Column(Integer)
    diabetes_meds = Column(Integer)
    # Labs (Stored as Float, can be NULL)
    creatinine = Column(Float, nullable=True)
    bun = Column(Float, nullable=True)
    hemoglobin = Column(Float, nullable=True)
    sodium = Column(Float, nullable=True)
    gfr = Column(Float, nullable=True)
    acr = Column(Float, nullable=True)
    # Result
    risk_level = Column(String(50))
    probability = Column(String(20))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class DiabetesPredictionDB(Base):
    __tablename__ = "diabetes_predictions"
    id = Column(Integer, primary_key=True, index=True)
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
    # Result
    risk_level = Column(String(50))
    probability = Column(String(20))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class PredictionResult(Base):
    __tablename__ = "prediction_results"
    id = Column(Integer, primary_key=True, index=True)
    kidney_id = Column(Integer, ForeignKey('kidney_predictions.id'), nullable=True)
    diabetes_id = Column(Integer, ForeignKey('diabetes_predictions.id'), nullable=True)
    disease_type = Column(String(50), nullable=False)  
    risk_classification = Column(String(50))
    probability_score = Column(String(20))
    generated_at = Column(DateTime(timezone=True), server_default=func.now())