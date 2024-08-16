import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginForm extends StatefulWidget {
  final void Function(String email, String password) onSubmit;
  final String buttonText;
  final VoidCallback onSignUpPressed;

  const LoginForm({
    Key? key,
    required this.onSubmit,
    required this.buttonText,
    required this.onSignUpPressed,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Animate(
            effects: [FadeEffect(duration: 600.ms), SlideEffect(begin: Offset(0, -0.2), end: Offset.zero, duration: 600.ms)],
            child: Text(
              'Welcome Back',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          Animate(
            effects: [FadeEffect(duration: 600.ms, delay: 200.ms), SlideEffect(begin: Offset(-0.2, 0), end: Offset.zero, duration: 600.ms)],
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 16),
          Animate(
            effects: [FadeEffect(duration: 600.ms, delay: 400.ms), SlideEffect(begin: Offset(0.2, 0), end: Offset.zero, duration: 600.ms)],
            child: TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
          ),
          const SizedBox(height: 24),
          Animate(
            effects: [FadeEffect(duration: 600.ms, delay: 600.ms), SlideEffect(begin: Offset(0, 0.2), end: Offset.zero, duration: 600.ms)],
            child: ElevatedButton(
              onPressed: () => widget.onSubmit(
                _emailController.text,
                _passwordController.text,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  widget.buttonText,
                  style: const TextStyle(fontSize: 18),
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
          const SizedBox(height: 16),
          Animate(
            effects: [FadeEffect(duration: 600.ms, delay: 800.ms)],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password functionality
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                TextButton(
                  onPressed: widget.onSignUpPressed,
                  child: Text(
                    'New to app? Sign Up',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
