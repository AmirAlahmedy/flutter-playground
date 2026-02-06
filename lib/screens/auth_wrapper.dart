import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  bool _showSignUp = false;

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    _authService.authStateChanges.listen((state) {
      // Rebuild when auth state changes
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (_authService.isLoggedIn) {
      return const HomeScreen();
    }

    // Show sign up or sign in based on state
    if (_showSignUp) {
      return SignUpScreen(
        onSignInTap: () {
          setState(() {
            _showSignUp = false;
          });
        },
      );
    } else {
      return SignInScreen(
        onSignUpTap: () {
          setState(() {
            _showSignUp = true;
          });
        },
      );
    }
  }
}
