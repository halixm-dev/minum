// lib/src/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:minum/src/features/hydration/data/models/hydration_entry_model.dart';
import 'package:minum/src/features/auth/presentation/pages/auth/forgot_password_screen.dart';
import 'package:minum/src/features/auth/presentation/pages/auth/login_screen.dart';
import 'package:minum/src/features/auth/presentation/pages/auth/register_screen.dart';
import 'package:minum/src/features/auth/presentation/pages/auth_gate_screen.dart';
import 'package:minum/src/core/presentation/pages/not_found_screen.dart';
import 'package:minum/src/features/hydration/presentation/pages/home/add_water_log_screen.dart';
import 'package:minum/src/features/hydration/presentation/pages/home/home_screen.dart';
import 'package:minum/src/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:minum/src/features/user/presentation/pages/profile_screen.dart';
import 'package:minum/src/features/settings/presentation/pages/settings_screen.dart';
import 'package:minum/src/core/presentation/pages/splash_screen.dart';
import 'package:minum/src/features/hydration/presentation/pages/stats/hydration_history_screen.dart';

import 'app_routes.dart';

/// A utility class for handling navigation and routing within the application.
///
/// This class centralizes route generation and provides static methods for
/// common navigation patterns.
class AppRouter {
  /// Generates a route based on the provided [RouteSettings].
  ///
  /// This method is used by the `onGenerateRoute` property of `MaterialApp`.
  /// It maps route names to their corresponding screen widgets.
  /// @return A `Route` object for the requested route.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.authGate:
        return MaterialPageRoute(builder: (_) => const AuthGateScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
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
        return MaterialPageRoute(
            builder: (_) => const HydrationHistoryScreen());
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

  /// Navigates to a new screen.
  static void navigateTo(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Navigates to a new screen and replaces the current screen.
  static void navigateToAndReplace(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  /// Navigates to a new screen and removes all previous screens from the stack.
  static void navigateToAndRemoveUntil(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
        context, routeName, (Route<dynamic> route) => false,
        arguments: arguments);
  }

  /// Pops the current screen from the navigation stack.
  static void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }
}
