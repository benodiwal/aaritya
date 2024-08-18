import 'package:aaritya/main.dart';
import 'package:aaritya/presentation/pages/signup_page.dart';
import 'package:aaritya/presentation/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaritya/presentation/pages/login_page.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
      case '/':
      return MaterialPageRoute(
      builder: (context) {
      final isAuthenticated = Provider.of<AuthenticationState>(context).isAuthenticated;
      return isAuthenticated ? MainContainer() : LoginPage();
    },
  );
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignupPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
