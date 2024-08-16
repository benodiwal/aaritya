import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final void Function(String email, String password) onSubmit;
  final String buttonText;

  const LoginForm({
    Key? key,
    required this.onSubmit,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => onSubmit(
            _emailController.text,
            _passwordController.text,
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }
}
