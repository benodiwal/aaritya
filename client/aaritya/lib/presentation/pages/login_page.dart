import 'package:aaritya/main.dart';
import 'package:flutter/material.dart';
import 'package:aaritya/core/network/api_service.dart';
import 'package:aaritya/presentation/widgets/login_form.dart';
import 'package:aaritya/presentation/pages/signup_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final ApiService _apiService = ApiService();

  LoginPage({Key? key}) : super(key: key);

  void _login(BuildContext context, String email, String password) async {
    try {
      await _apiService.login(email, password);
      Provider.of<AuthenticationState>(context, listen: false).setAuthenticated(true);
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignupPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                LoginForm(
                  onSubmit: (email, password) => _login(context, email, password),
                  buttonText: 'Login',
                  onSignUpPressed: () => _navigateToSignup(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
