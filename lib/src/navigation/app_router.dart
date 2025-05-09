// lib/src/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/presentation/screens/auth/forgot_password_screen.dart';
import 'package:minum/src/presentation/screens/auth/login_screen.dart';
import 'package:minum/src/presentation/screens/auth/register_screen.dart';
import 'package:minum/src/presentation/screens/auth_gate_screen.dart';
import 'package:minum/src/presentation/screens/core/not_found_screen.dart';
import 'package:minum/src/presentation/screens/home/add_water_log_screen.dart';
import 'package:minum/src/presentation/screens/home/home_screen.dart';
import 'package:minum/src/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:minum/src/presentation/screens/profile/profile_screen.dart';
import 'package:minum/src/presentation/screens/settings/settings_screen.dart';
import 'package:minum/src/presentation/screens/splash_screen.dart';
import 'package:minum/src/presentation/screens/stats/hydration_history_screen.dart';

import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    // case AppRoutes.welcome: // Removed
    //   return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case AppRoutes.authGate:
        return MaterialPageRoute(builder: (_) => const AuthGateScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register: // Kept for potential direct access or future re-introduction
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword: // Kept for potential direct access
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.addWaterLog:
        HydrationEntry? entryToEdit;
        if (args is HydrationEntry) {
          entryToEdit = args;
        }
        return MaterialPageRoute(
          builder: (_) => AddWaterLogScreen(entryToEdit: entryToEdit),
        );
      case AppRoutes.history:
        return MaterialPageRoute(builder: (_) => const HydrationHistoryScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => NotFoundScreen(routeName: settings.name),
        );
    }
  }

  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (Route<dynamic> route) => false, arguments: arguments);
  }

  static void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }
}
