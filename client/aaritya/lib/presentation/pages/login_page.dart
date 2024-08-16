import 'package:aaritya/core/network/api_service.dart';
import 'package:aaritya/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final ApiService _apiService = ApiService();

  void _login(BuildContext context, String email, String password) async {
    try {
      await _apiService.login(email, password);
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: LoginForm(
          onSubmit: (email, password) => _login(context, email, password),
          buttonText: 'Login',
        ),
      ),
    );
  }
}
