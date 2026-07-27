class AppLocale {
  static bool isNepali = false;

  static String t(String en, String ne) => isNepali ? ne : en;

  // --- TITLES & BUTTONS ---
  static String get appTitle => t("Health Risk Predictor", "स्वास्थ्य जोखिम सूचक");
  static String get kidneyTitle => t("Kidney Health Check", "मिर्गौला स्वास्थ्य जाँच");
  static String get diabetesTitle => t("Diabetes Risk Check", "मधुमेह जोखिम जाँच");
  static String get predictBtn => t("Analyze My Health", "मेरो स्वास्थ्य जाँच गर्नुहोस्");

  // --- SHARED PARAMETERS ---
  static String get age => t("Your Age", "तपाईंको उमेर");
  static String get gender => t("Gender", "लिङ्ग");
  static String get male => t("Male", "पुरुष");
  static String get female => t("Female", "महिला");
  static String get height => t("Height (cm)", "उचाइ (से.मि.)");
  static String get weight => t("Weight (kg)", "तौल (के.जी.)");

  // --- KIDNEY FORM PARAMETERS ---
  static String get systolicBp => t("Blood Pressure (Top Number)", "रक्तचाप (माथिल्लो अंक)");
  static String get smoking => t("Do you smoke?", "के तपाईं धुम्रपान गर्नुहुन्छ?");
  static String get alcohol => t("Alcohol Consumption (freq)", "मदिरा सेवन (दैनिक/हप्ता)");
  static String get physical => t("Physical Activity (hrs/week)", "शारीरिक व्यायाम (घन्टा/हप्ता)");
  static String get diabetesHist => t("History of Diabetes", "मधुमेहको इतिहास");
  static String get edema => t("Are your ankles, feet, or face swollen?", "खुट्टा वा अनुहार सुन्निएको छ?");
  static String get urine => t("Is your urine foamy or unusual color?", "पिसाबको रङ्गमा परिवर्तन वा फिँज छ?");
  static String get appetite => t("Have you lost your appetite or feel sick?", "खाना खान मन लाग्दैन वा वाकवाकी लाग्छ?");
  static String get familyHist => t("Family members with kidney issues?", "परिवारमा कसैलाई मिर्गौला रोग छ?");
  
  // The 4 Kidney Lab Values (Optional)
  static String get creatinine => t("Creatinine Level (mg/dL)", "क्रिएटिनिन लेभल");
  static String get bun => t("BUN Level (mg/dL)", "BUN लेभल");
  static String get hemoglobin => t("Hemoglobin Level (g/dL)", "हेमोग्लोबिन लेभल");
  static String get sodium => t("Sodium Level (mEq/L)", "सोडियम लेभल");

  // --- DIABETES FORM PARAMETERS ---
  static String get polyuria => t("Do you urinate (pee) very frequently?", "के तपाईंलाई पटक-पटक पिसाब लाग्छ?");
  static String get polydipsia => t("Do you feel excessively thirsty all the time?", "के तपाईंलाई धेरै तिर्खा लाग्छ?");
  static String get weightLoss => t("Have you lost weight suddenly without trying?", "अचानक तौल घटेको छ?");
  static String get weakness => t("Do you feel weak or tired often?", "के तपाईंलाई कमजोरी महसुस हुन्छ?");
  static String get polyphagia => t("Do you feel excessively hungry?", "के तपाईंलाई धेरै भोक लाग्छ?");
  static String get thrush => t("Do you have any genital infections (Thrush)?", "यौनाङ्गमा संक्रमणको समस्या छ?");
  static String get blurring => t("Do you have any blurred or fuzzy vision?", "के तपाईंको आँखा धमिलो देखिन्छ?");
  static String get itching => t("Do you have itchy skin or rashes?", "के शरीर चिलाउने समस्या छ?");
  static String get irritability => t("Do you feel irritable or get annoyed easily?", "के तपाईंलाई झर्को लाग्ने समस्या छ?");
  static String get healing => t("Do your wounds take a long time to heal?", "घाउ निको हुन धेरै समय लाग्छ?");
  static String get paresis => t("Do you feel any partial muscle weakness?", "के मांसपेशीमा कमजोरी महसुस हुन्छ?");
  static String get stiffness => t("Do you have muscle stiffness?", "मांसपेशी कडा हुने समस्या छ?");
  static String get alopecia => t("Do you have patches of hair loss?", "के कपाल झर्ने समस्या छ?");
  static String get obesity => t("Do you consider yourself overweight?", "के तपाईं मोटोपनाको समस्यामा हुनुहुन्छ?");

 static String get resultTitle => t("Prediction Result", "नतिजा");
 static String get closeBtn => t("Close", "बन्द गर्नुहोस्");
}