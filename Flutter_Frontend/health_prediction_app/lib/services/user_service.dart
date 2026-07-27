import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class UserService {
  static String? _token;
  static int? _userId;
  static String? _userName;
  static String? _userEmail;

  static bool get isLoggedIn => _token != null;
  static int? get userId => _userId;
  static String get userName => _userName ?? '';
  static String get userEmail => _userEmail ?? '';
  static String? get token => _token;

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, {String? phone}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _userId = data['id'];
      _userName = data['full_name'];
      _userEmail = data['email'];
      return data;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['detail'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _userId = data['id'];
      _userName = data['full_name'];
      _userEmail = data['email'];
      return data;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['detail'] ?? 'Login failed');
    }
  }

  static void logout() {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
  }
}
