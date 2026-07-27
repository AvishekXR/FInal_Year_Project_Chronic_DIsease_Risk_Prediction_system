// File: lib/models/diabetes_input.dart
// REPLACE your entire file with this

class DiabetesInput {
  final int age;
  final int gender;
  final int polyuria;
  final int polydipsia;
  final int weightLoss;
  final int weakness;
  final int polyphagia;
  final int genitalThrush;
  final int visualBlurring;
  final int itching;
  final int irritability;
  final int delayedHealing;
  final int partialParesis;
  final int muscleStiffness;
  final int alopecia;
  final int obesity;
  final int? userId;
  final String language;          // ← ADDED: language field

  DiabetesInput({
    this.userId,
    required this.age,
    required this.gender,
    required this.polyuria,
    required this.polydipsia,
    required this.weightLoss,
    required this.weakness,
    required this.polyphagia,
    required this.genitalThrush,
    required this.visualBlurring,
    required this.itching,
    required this.irritability,
    required this.delayedHealing,
    required this.partialParesis,
    required this.muscleStiffness,
    required this.alopecia,
    required this.obesity,
    this.language = 'en',         // ← ADDED: default English
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'polyuria': polyuria,
      'polydipsia': polydipsia,
      'weight_loss': weightLoss,
      'weakness': weakness,
      'polyphagia': polyphagia,
      'genital_thrush': genitalThrush,
      'visual_blurring': visualBlurring,
      'itching': itching,
      'irritability': irritability,
      'delayed_healing': delayedHealing,
      'partial_paresis': partialParesis,
      'muscle_stiffness': muscleStiffness,
      'alopecia': alopecia,
      'obesity': obesity,
      'language': language,       // ← ADDED: sends language to API
      if (userId != null) 'user_id': userId,
    };
  }
}