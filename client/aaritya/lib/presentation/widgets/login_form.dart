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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final contentPadding = EdgeInsets.symmetric(
          horizontal: maxWidth > 600 ? 48.0 : 24.0,
          vertical: 24.0,
        );

        return Padding(
          padding: contentPadding,
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
              SizedBox(height: maxWidth > 600 ? 48 : 32),
              Animate(
                effects: [FadeEffect(duration: 600.ms, delay: 200.ms), SlideEffect(begin: Offset(-0.2, 0), end: Offset.zero, duration: 600.ms)],
                child: _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 16),
              Animate(
                effects: [FadeEffect(duration: 600.ms, delay: 400.ms), SlideEffect(begin: Offset(0.2, 0), end: Offset.zero, duration: 600.ms)],
                child: _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                ),
              ),
              SizedBox(height: maxWidth > 600 ? 24 : 20),
              Animate(
                effects: [FadeEffect(duration: 600.ms, delay: 600.ms), SlideEffect(begin: Offset(0, 0.2), end: Offset.zero, duration: 600.ms)],
                child: ElevatedButton(
                  onPressed: () => widget.onSubmit(
                    _emailController.text,
                    _passwordController.text,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: maxWidth > 600 ? 16.0 : 12.0),
                    child: Text(
                      widget.buttonText,
                      style: TextStyle(fontSize: maxWidth > 600 ? 18 : 16),
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
              SizedBox(height: maxWidth > 600 ? 16 : 12),
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
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: isPassword && !_isPasswordVisible,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
