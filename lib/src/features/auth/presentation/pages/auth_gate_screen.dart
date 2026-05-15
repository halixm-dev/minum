// lib/src/features/auth/presentation/pages/auth_gate_screen.dart
import 'package:flutter/material.dart';
import 'package:minum/src/features/auth/presentation/pages/auth/login_screen.dart';
import 'package:minum/src/features/hydration/presentation/pages/home/home_screen.dart';
import 'package:minum/src/core/utils/logger.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_state.dart';

/// A screen that acts as a gatekeeper for authentication.
///
/// This screen listens to the [AuthBloc] and directs the user to the
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
    final authState = context.watch<AuthBloc>().state;

    if (authState is AuthInitial || authState is AuthLoading) {
      logger.i(
          "AuthGate: Auth status is \${authState.runtimeType}. Showing loading indicator.");
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (authState is Authenticated) {
      logger.i("AuthGate: User authenticated. Navigating to HomeScreen.");
      return const HomeScreen();
    } else if (authState is Unauthenticated || authState is AuthError) {
      logger.i(
          "AuthGate: User unauthenticated or error. Navigating to LoginScreen.");
      return const LoginScreen();
    } else {
      return const LoginScreen();
    }
  }
}
