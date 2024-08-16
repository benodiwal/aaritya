import 'package:aaritya/core/network/api_service.dart';
import 'package:aaritya/presentation/widgets/signup_form.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  final ApiService _apiService = ApiService();

  void _signup(BuildContext context, String username, String email, String password) async {
    try {
      await _apiService.signup(username, email, password);
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Center(
        child: SignupForm(
          onSubmit: (username, email, password) => _signup(context, username, email, password),
          buttonText: 'Signup',
        ),
      ),
    );
  }
}
