import requests
import json

# Test with minimal user input (no lab tests)
test_data = {
   
    "age": 55,  # Increased age
    "gender": 0,
    "systolic_bp": 145,  # Stage 1 hypertension
    "height_cm": 160,
    "weight_kg": 70,
    "smoking": 0,
    "alcohol_consumption": 5,
    "physical_activity": 2,
    "diabetes": 0,  # Still no diabetes
    "edema": 0,
    "urine_changes": 1,
    "appetite_change": 0,
    "family_history": 1,
    "language": "en"
}


response = requests.post("http://127.0.0.1:8000/predict/kidney", json=test_data)
print(f"Status: {response.status_code}")
print(f"Response: {json.dumps(response.json(), indent=2)}")