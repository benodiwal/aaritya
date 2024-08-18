import 'package:aaritya/core/network/api_service.dart';
import 'package:aaritya/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ApiService apiService = ApiService();
  bool isAuthenticated = await apiService.isAuthenticated();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthenticationState(isAuthenticated),
      child: MyApp(),
    ),
  );
}

class AuthenticationState extends ChangeNotifier {
  bool _isAuthenticated;
  AuthenticationState(this._isAuthenticated);
  bool get isAuthenticated => _isAuthenticated;
  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationState>(
      builder: (context, authState, _) {
        return MaterialApp(
          title: 'Aaritya',
          debugShowCheckedModeBanner: false,
          initialRoute: authState.isAuthenticated ? '/home' : '/login',
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
