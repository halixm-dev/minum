// lib/src/presentation/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/main.dart';

/// A welcome screen that is shown to the user when they first open the app.
///
/// This screen provides options to start using the app immediately (as a guest)
/// or to navigate to the login screen.
class WelcomeScreen extends StatelessWidget {
  /// Creates a `WelcomeScreen`.
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withAlpha(153),
                colorScheme.secondary.withAlpha(102),
                colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 0.9],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(flex: 2),
                Image.asset(
                  AppAssets.appLogo,
                  height: 120.h,
                  color: colorScheme.primary,
                  errorBuilder: (context, error, stackTrace) {
                    logger.e("WelcomeScreen: Error loading app logo: $error");
                    return Icon(Symbols.water_drop,
                        size: 120.h, color: colorScheme.primary);
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium
                      ?.copyWith(color: colorScheme.primary),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your personal hydration companion.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const Spacer(flex: 3),
                FilledButton(
                  onPressed: () {
                    logger.i(
                        "WelcomeScreen: 'Start Now' pressed. Navigating to HomeScreen.");
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home, (route) => false);
                  },
                  child: const Text('Start Now'),
                ),
                SizedBox(height: 16.h),
                OutlinedButton(
                  onPressed: () {
                    logger.i(
                        "WelcomeScreen: 'Login' pressed. Navigating to LoginScreen.");
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  },
                  child: const Text(AppStrings.login),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
