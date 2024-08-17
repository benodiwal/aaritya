import 'dart:convert';
import 'package:aaritya/core/constants/keys.dart';
import 'package:aaritya/core/utils/jwt_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _storage = const FlutterSecureStorage();
  static const String baseUrl = 'https://d676-36-255-84-98.ngrok-free.app ';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: Keys.jwtTokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
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
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'username': username, 'email': email, 'password': password}),
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

  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/me'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user profile');
    }
  }

  Future<int> getUserRank() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/rank'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['rank'];
    } else {
      throw Exception('Failed to get user rank');
    }
  }

  Future<List<Map<String, dynamic>>> getUserQuizzes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/quizzes'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> quizzes = jsonDecode(response.body);
      return quizzes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get user quizzes');
    }
  }

  Future<Map<String, dynamic>> getQuizById(String quizId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/$quizId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get quiz');
    }
  }

    Future<Map<String, dynamic>> getQuizzes({required int page, required int pageSize}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quizzes?page=$page&pageSize=$pageSize'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load quizzes: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error: $e');
      throw Exception('Network error occurred: $e');
    }
  }

  Future<bool> createQuiz(Map<String, dynamic> quizData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quiz'),
      headers: await _getHeaders(),
      body: jsonEncode(quizData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to create quiz');
    }
  }

  Future<bool> submitQuizAttempt(
      String quizId, List<Map<String, dynamic>> answers) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quiz-attempt'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'quizId': quizId,
        'answers': answers,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to submit quiz attempt');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/leaderboard'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> leaderboard = jsonDecode(response.body);
      return leaderboard.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get leaderboard');
    }
  }
}
