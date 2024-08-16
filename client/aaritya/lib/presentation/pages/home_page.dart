import 'package:aaritya/core/network/api_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final ApiService _apiService = ApiService();

  void _logout(BuildContext context) async {
    await _apiService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}
