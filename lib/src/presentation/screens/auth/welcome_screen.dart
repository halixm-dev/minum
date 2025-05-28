// lib/src/presentation/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Scaffold background will be theme.colorScheme.surface by default from AppTheme
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary
                    .withValues(alpha: 0.6), // Adjusted opacity for M3 feel
                colorScheme.secondary
                    .withValues(alpha: 0.4), // Adjusted opacity for M3 feel
                colorScheme.surface, // End with the surface color
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 0.9], // Adjusted stops
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
                  color: colorScheme
                      .primary, // Optionally tint logo with primary color if it's a template image
                  errorBuilder: (context, error, stackTrace) {
                    logger.e("WelcomeScreen: Error loading app logo: $error");
                    return Icon(Icons.water_drop_rounded,
                        size: 120.h, color: colorScheme.primary);
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: colorScheme.primary, // Use colorScheme.primary
                    // fontWeight is part of displayMedium in M3 theme
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your personal hydration companion.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme
                        .onSurfaceVariant, // Use onSurfaceVariant for less emphasis
                  ),
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
