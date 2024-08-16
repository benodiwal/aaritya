import 'package:aaritya/presentation/pages/login_page.dart';
import 'package:aaritya/presentation/pages/signup_page.dart';
import 'package:aaritya/presentation/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignupPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => MainContainer());
      default:
        return MaterialPageRoute(builder: (_) => LoginPage());
    }
  }
}
