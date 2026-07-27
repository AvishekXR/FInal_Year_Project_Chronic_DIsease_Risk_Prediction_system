import random

# =====================================================
# KIDNEY GUIDANCE — ENGLISH
# =====================================================
kidney_low_en = [
    "Your kidney health looks excellent! Keep up the great habits.",
    "Continue a balanced diet with plenty of fruits and vegetables.",
    "Stay active with regular exercise — it protects your kidneys.",
    "Drink plenty of water and limit salt intake.",
    "Maintain a healthy weight through good lifestyle choices.",
    "Get annual check-ups to stay ahead of any issues.",
    "Avoid smoking and limit alcohol for long-term wellness.",
    "Limit processed foods which are high in hidden sodium.",
    "Ensure you get 7-8 hours of sleep to help body regulation."
]

kidney_medium_en = [
    "Moderate risk detected — consult a doctor for further tests.",
    "Reduce salt and processed foods in your daily diet.",
    "Increase physical activity to 30 minutes most days.",
    "Monitor blood pressure and blood sugar at home regularly.",
    "Manage stress with relaxation or light exercise.",
    "Limit alcohol and quit smoking if you do.",
    "Small consistent changes can improve your kidney health.",
    "Review any over-the-counter NSAIDs (like Ibuprofen) with a doctor.",
    "Stay hydrated, but avoid sugary sodas and energy drinks."
]

kidney_high_en = [
    "High risk result — see a nephrologist as soon as possible.",
    "Follow a strict renal diet recommended by your doctor.",
    "Control blood pressure and blood sugar very carefully.",
    "Avoid smoking, alcohol, and unnecessary painkillers.",
    "Regular lab tests and specialist visits are essential.",
    "Watch for symptoms like swelling, fatigue, or urine changes.",
    "Rest and follow medical advice strictly for better outcomes.",
    "Limit potassium and phosphorus-rich foods if advised by a specialist.",
    "Keep a log of your daily fluid intake and blood pressure."
]

# =====================================================
# KIDNEY GUIDANCE — NEPALI
# =====================================================
kidney_low_np = [
    "तपाईंको मिर्गौला स्वास्थ्य उत्कृष्ट देखिन्छ! राम्रो बानी कायम राख्नुहोस्।",
    "सन्तुलित खाना खानुहोस् र प्रशस्त फलफूल तथा तरकारी प्रयोग गर्नुहोस्।",
    "नियमित व्यायाम गर्नुहोस् — यसले मिर्गौलालाई सुरक्षा दिन्छ।",
    "धेरै पानी पिउनुहोस् र नुन कम गर्नुहोस्।",
    "स्वस्थ तौल कायम राख्न राम्रो जीवनशैली अपनाउनुहोस्।",
    "वार्षिक स्वास्थ्य जाँच गराइरहनुहोस्।",
    "धूम्रपान र मदिरा छोड्नुहोस्।",
    "प्रशोधित र बट्टाका खानेकुराहरू कम गर्नुहोस्।"
]

kidney_medium_np = [
    "मध्यम जोखिम देखियो — चिकित्सकसँग परामर्श लिनुहोस्।",
    "नुन र बजारिया खानेकुरा कम गर्नुहोस्।",
    "दैनिक ३० मिनेट व्यायाम गर्ने बानी बसाल्नुहोस्।",
    "रक्तचाप र चिनीको मात्रा नियमित जाँच गर्नुहोस्।",
    "तनाव कम गर्न ध्यान वा हल्का व्यायाम गर्नुहोस्।",
    "मदिरा र धूम्रपानबाट टाढै रहनुहोस्।",
    "मिर्गौला स्वास्थ्य सुधार गर्न जीवनशैलीमा सुधार गर्नुहोस्।"
]

kidney_high_np = [
    "उच्च जोखिम — तुरुन्तै मिर्गौला विशेषज्ञसँग जाँच गराउनुहोस्।",
    "डाक्टरले भनेको खानपान कडाइसाथ पालना गर्नुहोस्।",
    "रक्तचाप र चिनीको मात्रा नियन्त्रणमा राख्नुहोस्।",
    "दुखाइ कम गर्ने औषधि जथाभावी सेवन नगर्नुहोस्।",
    "पिसाबमा हुने परिवर्तन वा शरीर सुन्निने लक्षणमा ध्यान दिनुहोस्।",
    "नियमित प्रयोगशाला जाँच र विशेषज्ञको सल्लाह लिनुहोस्।",
    "आराम गर्नुहोस् र स्वास्थ्य सल्लाह कडाइसाथ मान्नुहोस्।"
]

# =====================================================
# DIABETES GUIDANCE — ENGLISH
# =====================================================
diabetes_low_en = [
    "Your diabetes risk is low — keep maintaining your healthy lifestyle.",
    "Eat a balanced diet rich in whole grains, fruits, and vegetables.",
    "Stay active with regular exercise to keep your blood sugar stable.",
    "Limit sugary drinks, sweets, and processed snacks.",
    "Keep a healthy body weight to reduce future diabetes risk.",
    "Get regular blood sugar check-ups once a year.",
    "Drink plenty of water throughout the day.",
    "Reduce stress through meditation, yoga, or light walks.",
    "Get 7-8 hours of quality sleep every night."
]

diabetes_medium_en = [
    "Moderate diabetes risk — consult your doctor for a detailed check-up.",
    "Monitor your blood sugar levels regularly at home.",
    "Cut down on refined carbs, white rice, and sugary foods.",
    "Exercise at least 30 minutes a day, 5 days a week.",
    "Maintain a healthy weight — even small weight loss helps.",
    "Avoid skipping meals; eat at consistent times daily.",
    "Limit alcohol intake as it affects blood sugar levels.",
    "Include fiber-rich foods like legumes and leafy greens in your diet.",
    "Manage stress — high stress can raise blood sugar levels."
]

diabetes_high_en = [
    "High diabetes risk — please see a doctor or endocrinologist immediately.",
    "Follow a strict diabetic diet as recommended by your healthcare provider.",
    "Monitor your blood sugar levels multiple times a day.",
    "Take your prescribed medication exactly as directed by your doctor.",
    "Avoid all added sugars, sugary drinks, and high-carb foods.",
    "Exercise regularly but consult your doctor before starting any program.",
    "Watch for symptoms like extreme thirst, frequent urination, or dizziness.",
    "Get regular lab tests to monitor HbA1c and other key markers.",
    "Keep a daily log of your blood sugar, meals, and medication."
]

# =====================================================
# DIABETES GUIDANCE — NEPALI
# =====================================================
diabetes_low_np = [
    "तपाईंको मधुमेह जोखिम कम छ — स्वस्थ जीवनशैली कायम राख्नुहोस्।",
    "सन्तुलित खाना खानुहोस् जसमा अन्न, फलफूल र तरकारी रहेको हुन्छ।",
    "नियमित व्यायाम गर्नुहोस् जसले रक्त शर्करा स्थिर राख्छ।",
    "मिठाई र प्रशोधित खाना कम गर्नुहोस्।",
    "स्वस्थ तौल कायम गर्नुहोस् जसले भविष्यमा मधुमेह जोखिम कम गर्छ।",
    "वर्षमा एकपटक रक्त शर्करा जाँच गराउनुहोस्।",
    "दिनभर प्रशस्त पानी पिउनुहोस्।",
    "ध्यान, योग वा पैदल हिँडाइबाट तनाव कम गर्नुहोस्।",
    "रात्रिमा ७-८ घन्टा राम्रो निद्रा लिनुहोस्।"
]

diabetes_medium_np = [
    "मध्यम मधुमेह जोखिम — तपाईंको डाक्टरसँग विस्तृत जाँच गराउनुहोस्।",
    "घरमा नियमित रक्त शर्करा स्तर जाँच गर्नुहोस्।",
    "शुद्धिकृत कार्बोहाइड्रेट, सेतो चामल र मिठा खाना कम गर्नुहोस्।",
    "दिनमा ३० मिनेट, हप्तामा ५ दिन व्यायाम गर्नुहोस्।",
    "स्वस्थ तौल कायम गर्नुहोस् — थोरै तौल घटाउनु पनि सहयोग गर्छ।",
    "खाना नछोड्नुहोस्; दैनिक एकै समयमा खानुहोस्।",
    "मदिरा कम गर्नुहोस् किनभने यसले रक्त शर्करामा प्रभाव पार्छ।",
    "खानामा फाइबर बढी भएका खाना जस्तै दाल र हरिया तरकारी समावेश गर्नुहोस्।",
    "तनाव व्यवस्थित गर्नुहोस् — उच्च तनावले रक्त शर्करा बढाउन सक्छ।"
]

diabetes_high_np = [
    "उच्च मधुमेह जोखिम — तुरुन्तै डाक्टर वा मधुमेह विशेषज्ञसँग भेटनुहोस्।",
    "स्वास्थ्यकर्मीले सिफारिस गरेको कडा मधुमेह आहार पालना गर्नुहोस्।",
    "दिनमा धेरै पटक आफ्नो रक्त शर्करा स्तर जाँच गर्नुहोस्।",
    "डाक्टरले भनेको अनुसार नै औषधि लिनुहोस्।",
    "सबै प्रकारका मिठाई, मिठा पेय र उच्च कार्बोहाइड्रेट खाना छोड्नुहोस्।",
    "नियमित व्यायाम गर्नुहोस् तर कुनै कार्यक्रम सुरु गर्नुभन्दा पहिले डाक्टरसँग सल्लाह गर्नुहोस्।",
    "अत्यधिक तिर्खा, बारम्बार पिसाब वा चक्कर जस्ता लक्षणमा ध्यान दिनुहोस्।",
    "HbA1c र अन्य प्रमुख सूचकहरू जाँच गर्न नियमित प्रयोगशाला परीक्षण गराउनुहोस्।",
    "दैनिक रक्त शर्करा, खाना र औषधिको अभिलेख राख्नुहोस्।"
]

# =====================================================
# MAIN FUNCTION — Routes to correct list
# =====================================================
def get_medical_guidance(risk_level: str, disease_type: str = "kidney", language: str = "en") -> list:
    """
    Returns 4 random unique guidance messages.
    
    disease_type: "kidney" or "diabetes"
    language: "en" (English) or "np" (Nepali)
    risk_level: "low", "medium", "high"
    """
    # Normalize risk level
    risk = risk_level.lower()
    if risk in ["positive", "high"]:
        level = "high"
    elif risk in ["medium"]:
        level = "medium"
    else:
        level = "low"

    # Normalize language suffix
    suffix = "_np" if language == "np" else "_en"

    # Normalize disease type
    disease = "diabetes" if disease_type == "diabetes" else "kidney"

    # Build the list name: e.g. "kidney_low_en" or "diabetes_high_np"
    list_name = f"{disease}_{level}{suffix}"

    # Safely get the list from globals
    advice_list = globals().get(list_name, kidney_low_en)  # fallback to kidney_low_en

    # Return 4 unique random messages
    return random.sample(advice_list, min(4, len(advice_list)))