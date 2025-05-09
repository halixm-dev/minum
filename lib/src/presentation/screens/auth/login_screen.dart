// lib/src/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_colors.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/widgets/common/custom_button.dart';
import 'package:minum/src/presentation/widgets/common/social_login_button.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<void> _loginWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    AppUtils.showLoadingDialog(context, message: "Connecting to Google...");

    await authProvider.signInWithGoogle();

    if (mounted) AppUtils.hideLoadingDialog(context);

    // AuthGate will handle navigation if successful.
    // If there's an error, AuthProvider's status will be authError,
    // and AuthGate might keep showing LoginScreen or an error.
    // We can show a snackbar here for immediate feedback on Google Sign-In failure.
    if (authProvider.authStatus == AuthStatus.authError && mounted) {
      AppUtils.showSnackBar(context, authProvider.errorMessage ?? "Google Sign-In failed. Please try again.", isError: true);
    }
  }

  void _skipLogin() {
    logger.i("LoginScreen: 'Skip login' pressed. Navigating to HomeScreen.");
    // Navigate directly to HomeScreen, implying a guest mode.
    // AuthGate will still protect routes if actual authentication is required later.
    // If a user is already "logged in" as guest, this ensures they stay on home.
    // If they are truly logged out, AuthGate will handle it if they try to access protected content.
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // For status listening
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration( // Optional: Add a subtle gradient or background image
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withAlpha(100),
                theme.scaffoldBackgroundColor,
                theme.scaffoldBackgroundColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(flex: 2),
                // App Logo and Name
                Image.asset(
                  AppAssets.appLogo,
                  height: 100.h,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.water_drop_rounded, size: 100.h, color: AppColors.primaryColor),
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
                  'Stay hydrated, effortlessly.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.titleMedium?.color?.withAlpha(200)
                  ),
                ),
                const Spacer(flex: 3),

                // Login with Google Button
                SocialLoginButton(
                  text: AppStrings.loginWithGoogle,
                  assetName: 'assets/images/google_logo.png', // Make sure you have this asset
                  isLoading: authProvider.authStatus == AuthStatus.authenticating,
                  onPressed: _loginWithGoogle,
                  backgroundColor: Colors.white, // Explicit white background for Google button
                  textColor: Colors.black87, // Typical Google button text color
                ),
                SizedBox(height: 20.h),

                // Skip Login Button
                CustomButton(
                  text: 'Skip login for now',
                  onPressed: _skipLogin,
                  backgroundColor: AppColors.primaryColor.withAlpha(50), // A lighter, less prominent color
                  textColor: AppColors.primaryColor,
                ),
                const Spacer(flex: 1),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    "You can log in later from settings to sync your data.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
