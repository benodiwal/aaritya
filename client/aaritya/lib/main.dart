import 'package:aaritya/core/network/api_service.dart';
import 'package:aaritya/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ApiService _apiService = ApiService();

  bool isAuthenticated = await _apiService.isAuthenticated();
  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  MyApp({required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aaritya',
      debugShowCheckedModeBanner: false,
      initialRoute: !isAuthenticated ? '/home' : '/login',
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
