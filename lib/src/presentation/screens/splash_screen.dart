// lib/src/presentation/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minum/main.dart'; // For logger

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    logger.i("SplashScreen: initState called.");
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    logger.i("SplashScreen: _navigateToNextScreen called.");
    await Future.delayed(const Duration(seconds: 3));
    logger.i("SplashScreen: Delay completed.");

    if (!mounted) {
      logger.w(
          "SplashScreen: Widget not mounted after delay, aborting navigation.");
      return;
    }

    try {
      logger.i("SplashScreen: Attempting to access SharedPreferences.");
      final prefs = await SharedPreferences.getInstance();
      final bool onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;
      logger.i(
          "SplashScreen: Onboarding completed status from SharedPreferences: $onboardingCompleted");

      if (!onboardingCompleted) {
        logger.i(
            "SplashScreen: Navigating to OnboardingScreen (AppRoutes.onboarding).");
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
        } else {
          logger.w(
              "SplashScreen: Context not available for onboarding navigation.");
        }
      } else {
        // If onboarding IS completed, navigate to the simplified LoginScreen
        logger.i(
            "SplashScreen: Onboarding complete. Navigating to LoginScreen (AppRoutes.login).");
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
              AppRoutes.login); // Changed from AppRoutes.welcome
        } else {
          logger.w(
              "SplashScreen: Context not available for login screen navigation.");
        }
      }
    } catch (e, stackTrace) {
      logger.e("SplashScreen: Error in _navigateToNextScreen: $e",
          error: e, stackTrace: stackTrace);
      if (mounted) {
        logger.w(
            "SplashScreen: Fallback navigation to LoginScreen due to error.");
        Navigator.of(context)
            .pushReplacementNamed(AppRoutes.login); // Fallback to LoginScreen
      } else {
        logger
            .e("SplashScreen: Context not available for fallback navigation.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i("SplashScreen: build method called.");
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light
          ? colorScheme.primary // Use M3 color
          : colorScheme.surface, // Use M3 color for dark splash background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              AppAssets.appLogo,
              width: 150.w,
              height: 150.h,
              // For M3, if the logo is simple, consider tinting with onPrimary or onSurface
              color: theme.brightness == Brightness.light
                  ? colorScheme.onPrimary
                  : colorScheme.primary,
              errorBuilder: (context, error, stackTrace) {
                logger.e("SplashScreen: Error loading app logo: $error");
                return Icon(Icons.water_drop_outlined,
                    size: 100.sp,
                    color: theme.brightness == Brightness.light
                        ? colorScheme.onPrimary
                        : colorScheme.primary);
              },
            ),
            SizedBox(height: 20.h),
            Text(
              'Minum',
              style: theme.textTheme.displaySmall?.copyWith(
                // M3 text style
                color: theme.brightness == Brightness.light
                    ? colorScheme.onPrimary
                    : colorScheme.primary,
              ),
            ),
            SizedBox(height: 8.h), // Changed from 10.h to 8.h
            Text(
              'Stay Hydrated, Stay Healthy',
              style: theme.textTheme.titleMedium?.copyWith(
                // M3 text style
                color: theme.brightness == Brightness.light
                    ? colorScheme.onPrimary.withValues(alpha: 0.8)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 40.h),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.brightness == Brightness.light
                    ? colorScheme.onPrimary
                    : colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
