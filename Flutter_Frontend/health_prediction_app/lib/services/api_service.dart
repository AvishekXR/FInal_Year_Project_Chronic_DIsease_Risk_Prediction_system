import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ApiService {
  /// Predict Kidney Disease Risk
  static Future<Map<String, dynamic>> predictKidney(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict/kidney'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Kidney prediction failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error during kidney prediction: $e');
    }
  }

  /// Predict Diabetes Risk
  static Future<Map<String, dynamic>> predictDiabetes(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict/diabetes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Diabetes prediction failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error during diabetes prediction: $e');
    }
  }
}