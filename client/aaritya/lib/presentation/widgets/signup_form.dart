import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SignupForm extends StatefulWidget {
  final void Function(String username, String email, String password) onSubmit;
  final String buttonText;
  final VoidCallback onLoginPressed;

  const SignupForm({
    Key? key,
    required this.onSubmit,
    required this.buttonText,
    required this.onLoginPressed,
  }) : super(key: key);

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Animate(
          effects: [FadeEffect(duration: 600.ms), SlideEffect(begin: Offset(0, -0.2), end: Offset.zero, duration: 600.ms)],
          child: Text(
            'Create Account',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 24),
        Animate(
          effects: [FadeEffect(duration: 600.ms, delay: 200.ms), SlideEffect(begin: Offset(-0.2, 0), end: Offset.zero, duration: 600.ms)],
          child: _buildTextField(
            controller: _usernameController,
            labelText: 'Username',
            prefixIcon: Icons.person,
          ),
        ),
        SizedBox(height: 16),
        Animate(
          effects: [FadeEffect(duration: 600.ms, delay: 400.ms), SlideEffect(begin: Offset(0.2, 0), end: Offset.zero, duration: 600.ms)],
          child: _buildTextField(
            controller: _emailController,
            labelText: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        SizedBox(height: 16),
        Animate(
          effects: [FadeEffect(duration: 600.ms, delay: 600.ms), SlideEffect(begin: Offset(-0.2, 0), end: Offset.zero, duration: 600.ms)],
          child: _buildTextField(
            controller: _passwordController,
            labelText: 'Password',
            prefixIcon: Icons.lock,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 24),
        Animate(
          effects: [FadeEffect(duration: 600.ms, delay: 800.ms), SlideEffect(begin: Offset(0, 0.2), end: Offset.zero, duration: 600.ms)],
          child: ElevatedButton(
            onPressed: () => widget.onSubmit(
              _usernameController.text,
              _emailController.text,
              _passwordController.text,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                widget.buttonText,
                style: TextStyle(fontSize: 16),
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        SizedBox(height: 16),
        Animate(
          effects: [FadeEffect(duration: 600.ms, delay: 1000.ms)],
          child: TextButton(
            onPressed: widget.onLoginPressed,
            child: Text(
              'Already a user? Log In',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Theme.of(context).primaryColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
