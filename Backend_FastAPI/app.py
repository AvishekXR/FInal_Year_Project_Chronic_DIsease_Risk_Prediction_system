

import os
from sqlalchemy import create_engine, Column, Integer, String, DateTime, ForeignKey, inspect
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
from dotenv import load_dotenv

# database connection
load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set. Copy .env.example to .env and fill in your values.")
engine = create_engine(DATABASE_URL)
Base = declarative_base()

# Define diabetes table 
class DiabetesPredictionDB(Base):
    __tablename__ = "diabetes_predictions"
    
    id = Column('id', Integer, primary_key=True, index=True)
    age = Column('age', Integer)
    gender = Column('gender', Integer)
    polyuria = Column('polyuria', Integer)
    polydipsia = Column('polydipsia', Integer)
    weight_loss = Column('weight_loss', Integer)
    weakness = Column('weakness', Integer)
    polyphagia = Column('polyphagia', Integer)
    genital_thrush = Column('genital_thrush', Integer)
    visual_blurring = Column('visual_blurring', Integer)
    itching = Column('itching', Integer)
    irritability = Column('irritability', Integer)
    delayed_healing = Column('delayed_healing', Integer)
    partial_paresis = Column('partial_paresis', Integer)
    muscle_stiffness = Column('muscle_stiffness', Integer)
    alopecia = Column('alopecia', Integer)
    obesity = Column('obesity', Integer)
    risk_level = Column('risk_level', String(50))
    probability = Column('probability', String(50))
    created_at = Column('created_at', DateTime, default=datetime.utcnow)

# Define prediction_results table 
class PredictionResult(Base):
    __tablename__ = "prediction_results"
    id = Column(Integer, primary_key=True, index=True)
    kidney_id = Column(Integer, ForeignKey("kidney_predictions.id"), nullable=True)
    diabetes_id = Column(Integer, ForeignKey("diabetes_predictions.id"), nullable=True)
    disease_type = Column(String(50))  
    risk_classification = Column(String(50))
    probability_score = Column(String(50))
    generated_at = Column(DateTime, default=datetime.utcnow)

if __name__ == "__main__":
    inspector = inspect(engine)
    
    # Check what tables exist before
    existing_tables = inspector.get_table_names()
    print("=" * 70)
    print(" EXISTING TABLES BEFORE:")
    print("=" * 70)
    for table in existing_tables:
        print(f"   ✓ {table}")
    
    # Check prediction_results table structure
    print("\n" + "=" * 70)
    print("CHECKING prediction_results TABLE:")
    print("=" * 70)
    if 'prediction_results' in existing_tables:
        columns = inspector.get_columns('prediction_results')
        has_disease_type = False
        for col in columns:
            print(f"   - {col['name']} ({col['type']})")
            if col['name'] == 'disease_type':
                has_disease_type = True
        
        if has_disease_type:
            print("\n   disease_type column EXISTS - tracking working correctly!")
        else:
            print("\n   disease_type column MISSING - will recreate table")
            Base.metadata.drop_all(engine, tables=[PredictionResult.__table__])
            Base.metadata.create_all(engine, tables=[PredictionResult.__table__])
            print("   ✓ prediction_results table recreated with disease_type")
    else:
        print("    prediction_results table doesn't exist - will create it")
        Base.metadata.create_all(engine, tables=[PredictionResult.__table__])
        print("   ✓ prediction_results table created")
    
   
    print("\n" + "=" * 70)
    print("  DROPPING diabetes_predictions TABLE:")
    print("=" * 70)
    if 'diabetes_predictions' in existing_tables:
        Base.metadata.drop_all(engine, tables=[DiabetesPredictionDB.__table__])
        print("   ✓ diabetes_predictions table dropped")
    else:
        print("   ⚠️  diabetes_predictions table doesn't exist")
    
    
    print("\n" + "=" * 70)
    print("🔨 CREATING diabetes_predictions TABLE:")
    print("=" * 70)
    Base.metadata.create_all(engine, tables=[DiabetesPredictionDB.__table__])
    print("   ✓ diabetes_predictions table created with lowercase columns")
    
  
    inspector = inspect(engine)
    existing_tables = inspector.get_table_names()
    print("\n" + "=" * 70)
    print("📋 EXISTING TABLES AFTER:")
    print("=" * 70)
    for table in existing_tables:
        print(f"   ✓ {table}")
    
    # Show the columns of diabetes_predictions
    print("\n" + "=" * 70)
    print("📊 diabetes_predictions COLUMNS:")
    print("=" * 70)
    columns = inspector.get_columns('diabetes_predictions')
    for col in columns:
        print(f"   - {col['name']} ({col['type']})")
    
    # Show the columns of prediction_results
    print("\n" + "=" * 70)
    print("📊 prediction_results COLUMNS:")
    print("=" * 70)
    columns = inspector.get_columns('prediction_results')
    for col in columns:
        indicator = "✅" if col['name'] == 'disease_type' else "  "
        print(f"   {indicator} {col['name']} ({col['type']})")
    
    print("\n" + "=" * 70)
    print("✅ SUCCESS!")
    print("=" * 70)
    print("   - diabetes_predictions table recreated with lowercase columns")
    print("   - prediction_results table has disease_type column")
    print("   - kidney_predictions table was NOT touched")
    print("\n🚀 You can now restart your FastAPI server!")
    print("=" * 70)