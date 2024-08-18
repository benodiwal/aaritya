import 'package:flutter/material.dart';
import 'package:aaritya/core/network/api_service.dart';
import 'package:aaritya/presentation/widgets/signup_form.dart';

class SignupPage extends StatelessWidget {
  final ApiService _apiService = ApiService();

  SignupPage({Key? key}) : super(key: key);

  void _signup(BuildContext context, String username, String email, String password) async {
    try {
      await _apiService.signup(username, email, password);
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup failed')),
      );
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SignupForm(
                onSubmit: (username, email, password) => _signup(context, username, email, password),
                buttonText: 'Sign Up',
                onLoginPressed: () => _navigateToLogin(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
