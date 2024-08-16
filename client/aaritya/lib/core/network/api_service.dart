import 'dart:convert';
import 'package:aaritya/core/constants/keys.dart';
import 'package:aaritya/core/utils/jwt_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _storage = const FlutterSecureStorage();

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://localhost:8000/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: Keys.jwtTokenKey, value: data['token']);
      return data['token'];
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('https://localhost:8000/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: Keys.jwtTokenKey, value: data['token']);
    } else {
      throw Exception('Failed to signup');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: Keys.jwtTokenKey);
  }

  Future<bool> isAuthenticated() async {
    String? token = await _storage.read(key: Keys.jwtTokenKey);
    if (token != null && !JwtHelper.isExpired(token)) {
      return true;
    }
    return false;
  }
}
