import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class AdminService {
  static String? _token;
  static String? _adminName;
  static String? _adminEmail;

  static bool get isLoggedIn => _token != null;
  static String get adminName => _adminName ?? '';
  static String get adminEmail => _adminEmail ?? '';

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'full_name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _adminName = data['full_name'];
      _adminEmail = data['email'];
      return data;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['detail'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _adminName = data['full_name'];
      _adminEmail = data['email'];
      return data;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['detail'] ?? 'Login failed');
    }
  }

  static void logout() {
    _token = null;
    _adminName = null;
    _adminEmail = null;
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard/stats?token=$_token'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load stats');
  }

  static Future<Map<String, dynamic>> getKidneyPredictions({int skip = 0, int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/predictions/kidney?token=$_token&skip=$skip&limit=$limit'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load kidney predictions');
  }

  static Future<Map<String, dynamic>> getDiabetesPredictions({int skip = 0, int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/predictions/diabetes?token=$_token&skip=$skip&limit=$limit'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load diabetes predictions');
  }

  static Future<void> deletePrediction(String diseaseType, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/predictions/$diseaseType/$id?token=$_token'),
    );
    if (response.statusCode != 200) throw Exception('Failed to delete');
  }

  static Future<Map<String, dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users?token=$_token'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load users');
  }

  static Future<Map<String, dynamic>> getUserPredictions(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/$userId/predictions?token=$_token'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load user predictions');
  }

  static Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/users/$userId?token=$_token'),
    );
    if (response.statusCode != 200) throw Exception('Failed to delete user');
  }
}
