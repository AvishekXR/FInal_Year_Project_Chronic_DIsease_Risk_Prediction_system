class KidneyInput {
  final int age;
  final int gender;
  final double systolicBp;
  final double heightCm;
  final double weightKg;
  final int smoking;
  final double alcoholConsumption;
  final double physicalActivity;
  final int diabetes;
  final int edema;
  final int urineChanges;
  final int appetiteChange;
  final int familyHistory;
  final double? serumCreatinine;
  final double? bunLevels;
  final double? hemoglobinLevels;
  final double? sodiumLevels;

  KidneyInput({
    required this.age,
    required this.gender,
    required this.systolicBp,
    required this.heightCm,
    required this.weightKg,
    required this.smoking,
    required this.alcoholConsumption,
    required this.physicalActivity,
    required this.diabetes,
    required this.edema,
    required this.urineChanges,
    required this.appetiteChange,
    required this.familyHistory,
    this.serumCreatinine,
    this.bunLevels,
    this.hemoglobinLevels,
    this.sodiumLevels,
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'systolic_bp': systolicBp,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'smoking': smoking,
        'alcohol_consumption': alcoholConsumption,
        'physical_activity': physicalActivity,
        'diabetes': diabetes,
        'edema': edema,
        'urine_changes': urineChanges,
        'appetite_change': appetiteChange,
        'family_history': familyHistory,
        'serum_creatinine': serumCreatinine,
        'bun_levels': bunLevels,
        'hemoglobin_levels': hemoglobinLevels,
        'sodium_levels': sodiumLevels,
      };
}