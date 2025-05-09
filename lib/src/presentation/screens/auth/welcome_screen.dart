// lib/src/presentation/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_colors.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/widgets/common/custom_button.dart';
import 'package:minum/main.dart'; // For logger

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withAlpha(150),
                AppColors.accentColor.withAlpha(100),
                theme.scaffoldBackgroundColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 0.8],
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
                  AppAssets.appLogo, // Ensure you have this asset
                  height: 120.h,
                  errorBuilder: (context, error, stackTrace) {
                    logger.e("WelcomeScreen: Error loading app logo: $error");
                    return Icon(Icons.water_drop_rounded, size: 120.h, color: AppColors.primaryColor);
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your personal hydration companion.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.titleMedium?.color?.withAlpha(200),
                  ),
                ),
                const Spacer(flex: 3),
                CustomButton(
                  text: 'Start Now',
                  onPressed: () {
                    logger.i("WelcomeScreen: 'Start Now' pressed. Navigating to HomeScreen.");
                    // Navigate directly to HomeScreen, implying a guest mode or skipping login for now.
                    // AuthGate will still protect routes if actual authentication is required later.
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                  },
                  backgroundColor: AppColors.primaryColor,
                  textColor: Colors.white,
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  text: AppStrings.login,
                  onPressed: () {
                    logger.i("WelcomeScreen: 'Login' pressed. Navigating to LoginScreen.");
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  },
                  backgroundColor: theme.brightness == Brightness.light ? Colors.white : AppColors.darkSurface,
                  textColor: AppColors.primaryColor,
                  // Add a border for better visual distinction for the secondary button
                  // This requires modifying CustomButton or using OutlinedButton directly.
                  // For now, using CustomButton as is.
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
