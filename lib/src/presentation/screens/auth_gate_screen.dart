// lib/src/presentation/screens/auth_gate_screen.dart
import 'package:flutter/material.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/screens/auth/login_screen.dart';
import 'package:minum/src/presentation/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger

/// A screen that acts as a gatekeeper for authentication.
///
/// This screen listens to the [AuthProvider] and directs the user to the
/// appropriate screen based on their authentication status.
class AuthGateScreen extends StatefulWidget {
  /// Creates an `AuthGateScreen`.
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.authStatus) {
      case AuthStatus.uninitialized:
      case AuthStatus.authenticating:
        logger.i(
            "AuthGate: Auth status is ${authProvider.authStatus}. Showing loading indicator.");
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.authenticated:
        logger.i("AuthGate: User authenticated. Navigating to HomeScreen.");
        return const HomeScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.authError:
        logger.i(
            "AuthGate: User unauthenticated or error. Navigating to LoginScreen.");
        return const LoginScreen();
    }
  }
}
