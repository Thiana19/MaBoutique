import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/auth_response.dart';

class ApiService {
  // For Android emulator - use 10.0.2.2 to access host machine
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  // Made public for other services to use
  static Map<String, String> getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Sign up user
  static Future<AuthResponse> signup({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: getHeaders(),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
        }),
      );

      print('📤 Signup response status: ${response.statusCode}');
      print('📤 Signup response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to sign up');
      }
    } catch (e) {
      print('❌ Signup error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Login user
  static Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: getHeaders(), // This sets Content-Type: application/json
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('📤 Login response status: ${response.statusCode}');
      print('📤 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to login');
      }
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get current user info
  static Future<User> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to get user info');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Test authenticated endpoint
  static Future<String> testAuth(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/test'),
        headers: getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Authentication failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Check if server is running
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: getHeaders(),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}