// lib/src/presentation/screens/auth_gate_screen.dart
import 'package:flutter/material.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/screens/auth/login_screen.dart'; // To be created
import 'package:minum/src/presentation/screens/home/home_screen.dart'; // To be created
// import 'package:minum/src/presentation/screens/onboarding/onboarding_screen.dart'; // If you have onboarding
// import 'package:shared_preferences/shared_preferences.dart'; // For onboarding check
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  // bool _onboardingCompleted = false;
  // bool _isLoadingOnboardingStatus = true;

  @override
  void initState() {
    super.initState();
    // _checkOnboardingStatus();
  }

  // Future<void> _checkOnboardingStatus() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  //   } catch (e) {
  //     logger.e("AuthGate: Error reading onboarding status: $e");
  //     _onboardingCompleted = false; // Default to not completed on error
  //   }
  //   setState(() {
  //     _isLoadingOnboardingStatus = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // if (_isLoadingOnboardingStatus) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }

    // if (!_onboardingCompleted) {
    //   logger.i("AuthGate: Onboarding not completed, navigating to OnboardingScreen.");
    //   // Use WidgetsBinding.instance.addPostFrameCallback to avoid setState errors during build
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) { // Ensure widget is still mounted before navigating
    //        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    //     }
    //   });
    //   // Return a placeholder while navigation happens
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    switch (authProvider.authStatus) {
      case AuthStatus.uninitialized:
      case AuthStatus.authenticating:
        logger.i("AuthGate: Auth status is ${authProvider.authStatus}. Showing loading indicator.");
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.authenticated:
        logger.i("AuthGate: User authenticated. Navigating to HomeScreen.");
        // User is authenticated, show the HomeScreen
        // We return HomeScreen directly. If HomeScreen itself needs to redirect or load, it will handle it.
        return const HomeScreen(); // To be created
      case AuthStatus.unauthenticated:
      case AuthStatus.authError:
      logger.i("AuthGate: User unauthenticated or error. Navigating to LoginScreen.");
        // User is not authenticated, or an error occurred, show the LoginScreen
        return const LoginScreen(); // To be created
    }
  }
}
