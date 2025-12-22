import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  static User? _currentUser;
  static String? _currentToken;

  // Initialize auth service (call this in main.dart)
  static Future<void> initialize() async {
    await _loadStoredData();
  }

  // Load stored token and user data
  static Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString(_tokenKey);
    
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  // Save authentication data
  static Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, authResponse.accessToken);
    await prefs.setString(_userKey, jsonEncode(authResponse.user.toJson()));
    
    _currentToken = authResponse.accessToken;
    _currentUser = authResponse.user;
  }

  // Clear authentication data
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    
    _currentToken = null;
    _currentUser = null;
  }

  // Getters
  static bool get isLoggedIn => _currentToken != null && _currentUser != null;
  static User? get currentUser => _currentUser;
  static String? get currentToken => _currentToken;

  // Login
  static Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final authResponse = await ApiService.login(
        username: username,
        password: password,
      );
      
      await _saveAuthData(authResponse);
      return authResponse;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Sign up
  static Future<AuthResponse> signup({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final authResponse = await ApiService.signup(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      
      await _saveAuthData(authResponse);
      return authResponse;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Logout
  static Future<void> logout() async {
    await _clearAuthData();
  }

  // Refresh user data
  static Future<User> refreshUserData() async {
    if (_currentToken == null) {
      throw Exception('No authentication token');
    }
    
    try {
      final user = await ApiService.getCurrentUser(_currentToken!);
      _currentUser = user;
      
      // Update stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      return user;
    } catch (e) {
      // If token is invalid, clear auth data
      await _clearAuthData();
      throw Exception('Session expired');
    }
  }

  // Check if authentication is valid
  static Future<bool> validateAuthentication() async {
    if (!isLoggedIn) return false;
    
    try {
      await ApiService.getCurrentUser(_currentToken!);
      return true;
    } catch (e) {
      await _clearAuthData();
      return false;
    }
  }
}