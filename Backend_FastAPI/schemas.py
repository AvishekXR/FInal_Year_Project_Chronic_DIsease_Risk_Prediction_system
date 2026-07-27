from pydantic import BaseModel
from typing import Optional


class KidneyInput(BaseModel):
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

    
    serum_creatinine: Optional[float] = None
    bun_levels: Optional[float] = None
    hemoglobin_levels: Optional[float] = None
    sodium_levels: Optional[float] = None


class DiabetesInput(BaseModel):
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