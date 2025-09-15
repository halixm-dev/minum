// lib/src/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/widgets/common/social_login_button.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger

/// A screen that serves as the main entry point for authentication, offering
/// options to sign in with Google or to skip and use the app as a guest.
class LoginScreen extends StatefulWidget {
  /// Creates a `LoginScreen`.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Handles the Google Sign-In process.
  ///
  /// Shows a loading dialog, calls the [AuthProvider] to sign in, and handles
  /// success, cancellation, or error states.
  Future<void> _loginWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final BuildContext dialogContext = context;
    final String? returnToRoute =
        ModalRoute.of(dialogContext)?.settings.arguments as String?;

    AppUtils.showLoadingDialog(dialogContext,
        message: "Connecting to Google...");

    bool signInSuccess = false;
    String? loginError;

    try {
      signInSuccess = await authProvider.signInWithGoogle();

      if (!signInSuccess && authProvider.authStatus == AuthStatus.authError) {
        loginError = authProvider.errorMessage ??
            "Google Sign-In failed. Please try again.";
      }
    } catch (e) {
      logger
          .e("LoginScreen: Unexpected error during signInWithGoogle call: $e");
      loginError = "An unexpected error occurred. Please try again.";
    } finally {
      if (dialogContext.mounted) {
        AppUtils.hideLoadingDialog(dialogContext);
      }
    }

    if (signInSuccess && mounted) {
      authProvider.completeGoogleSignIn();
      if (returnToRoute != null) {
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(returnToRoute, (route) => false);
        }
      }
    } else if (loginError != null && mounted) {
      AppUtils.showSnackBar(context, loginError, isError: true);
    }
  }

  /// Skips the login process and navigates to the home screen in guest mode.
  void _skipLogin() {
    logger.i("LoginScreen: 'Skip login' pressed. Navigating to HomeScreen.");
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
                colorScheme.primaryContainer.withAlpha(77),
                colorScheme.surface,
                colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(flex: 2),
                Image.asset(
                  AppAssets.appLogo,
                  height: 100.h,
                  color: colorScheme.primary,
                  errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.water_drop_rounded,
                      size: 100.h,
                      color: colorScheme.primary),
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
                  'Stay hydrated, effortlessly.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const Spacer(flex: 3),
                SocialLoginButton(
                  text: AppStrings.loginWithGoogle,
                  assetName: 'assets/images/google_logo.png',
                  isLoading:
                      authProvider.authStatus == AuthStatus.authenticating,
                  onPressed: _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerLow,
                    foregroundColor: colorScheme.onSurfaceVariant,
                    side: BorderSide(color: colorScheme.outline),
                  ).merge(theme.outlinedButtonTheme.style),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: _skipLogin,
                  child: const Text('Skip login for now'),
                ),
                const Spacer(flex: 1),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    "You can log in later from settings to sync your data.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
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
