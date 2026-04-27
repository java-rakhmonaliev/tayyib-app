import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://13.217.178.63';
  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // ── Token storage ─────────────────────────────────────────────────────────

  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_userKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── API calls ─────────────────────────────────────────────────────────────

  static Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String madhab,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'madhab': madhab,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await saveTokens(data['access'], data['refresh']);
      final user = UserModel.fromJson(data['user']);
      await saveUser(user);
      return user;
    }
    throw Exception(data['error'] ?? 'Registration failed');
  }

  static Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      final user = UserModel.fromJson(data['user']);
      await saveUser(user);
      return user;
    }
    throw Exception(data['error'] ?? 'Login failed');
  }

  static Future<UserModel> getProfile() async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch profile');
  }

  static Future<void> updateMadhab(String madhab) async {
    final token = await getAccessToken();
    await http.patch(
      Uri.parse('$baseUrl/api/auth/profile/update/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'madhab': madhab}),
    );
  }
}