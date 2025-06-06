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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _loginWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Capture the context that is valid *before* the async operation.
    // This context will be used for showing and hiding the dialog.
    final BuildContext dialogContext = context;
    // Capture the ModalRoute before potential async gaps if possible, though settings.arguments should be stable.
    final String? returnToRoute =
        ModalRoute.of(dialogContext)?.settings.arguments as String?;

    AppUtils.showLoadingDialog(dialogContext,
        message: "Connecting to Google...");

    bool signInSuccess = false;
    String? loginError;

    try {
      signInSuccess = await authProvider
          .signInWithGoogle(); // Returns true on success, false on error/cancel

      if (!signInSuccess && authProvider.authStatus == AuthStatus.authError) {
        // Error message is already set by AuthProvider's _handleAuthError
        loginError = authProvider.errorMessage ??
            "Google Sign-In failed. Please try again.";
      } else if (!signInSuccess &&
          authProvider.authStatus == AuthStatus.unauthenticated) {
        // User cancelled, no error message needed unless you want to show one.
        // loginError = "Google Sign-In cancelled."; // Optional
      }
      // If signInSuccess is true, _currentUser is set in AuthProvider but AuthStatus is not yet 'authenticated'.
    } catch (e) {
      // Fallback for truly unexpected errors not caught by AuthProvider
      logger
          .e("LoginScreen: Unexpected error during signInWithGoogle call: $e");
      loginError = "An unexpected error occurred. Please try again.";
      // Ensure authProvider status is error if we hit here, though it should be set by provider.
      // authProvider.forceErrorState("Unexpected error"); // Hypothetical method
    } finally {
      if (dialogContext.mounted) {
        AppUtils.hideLoadingDialog(dialogContext);
      }
    }

    if (signInSuccess && mounted) {
      // Check 'mounted' for the LoginScreen context
      authProvider.completeGoogleSignIn(); // This will trigger AuthGate

      // Now, handle navigation based on returnToRoute
      // This happens *after* AuthProvider has notified AuthGate.
      // If returnToRoute is null, AuthGate's navigation to home will proceed.
      // If returnToRoute is not null, this will override AuthGate's default.
      // This specific timing might need adjustment if AuthGate's navigation is too fast.
      // A slight delay before this custom navigation might be needed, or AuthGate needs to be aware.
      // For now, let's try direct navigation.
      if (returnToRoute != null) {
        // Ensure this context for navigation is still valid if there was a build in between
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(returnToRoute, (route) => false);
        }
      }
      // If returnToRoute is null, AuthGate will navigate to home.
    } else if (loginError != null && mounted) {
      AppUtils.showSnackBar(context, loginError, isError: true);
    }
  }

  void _skipLogin() {
    logger.i("LoginScreen: 'Skip login' pressed. Navigating to HomeScreen.");
    // Navigate directly to HomeScreen, implying a guest mode.
    // AuthGate will still protect routes if actual authentication is required later.
    // If a user is already "logged in" as guest, this ensures they stay on home.
    // If they are truly logged out, AuthGate will handle it if they try to access protected content.
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context); // For status listening
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
                colorScheme.primaryContainer
                    .withValues(alpha: 0.3), // Adjusted opacity
                colorScheme.surface,
                colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.3, 1.0], // Adjusted stop
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
                  color: colorScheme.primary, // Optionally tint logo
                  errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.water_drop_rounded,
                      size: 100.h,
                      color: colorScheme.primary),
                ),
                SizedBox(height: 16.h),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: colorScheme.primary,
                    // fontWeight removed, use M3 theme's definition
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Stay hydrated, effortlessly.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant, // Use onSurfaceVariant
                  ),
                ),
                const Spacer(flex: 3),

                SocialLoginButton(
                  text: AppStrings.loginWithGoogle,
                  assetName: 'assets/images/google_logo.png',
                  isLoading:
                      authProvider.authStatus == AuthStatus.authenticating,
                  onPressed: _loginWithGoogle,
                  // Style the SocialLoginButton (which is an OutlinedButton)
                  // to have a surface-like background for this specific "Google" look.
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        colorScheme.surfaceContainerLow, // Light background
                    foregroundColor:
                        colorScheme.onSurfaceVariant, // Text/icon color
                    side: BorderSide(color: colorScheme.outline),
                    // Padding, shape, etc., will be inherited from OutlinedButtonTheme or can be set here
                  ).merge(theme.outlinedButtonTheme
                      .style), // Merge to keep theme defaults like shape
                ),
                SizedBox(height: 16.h), // Reduced from 20.h

                // Skip Login Button - using TextButton for less emphasis
                TextButton(
                  onPressed: _skipLogin,
                  // Style will come from TextButtonThemeData in AppTheme
                  child: const Text('Skip login for now'),
                ),
                const Spacer(flex: 1),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    "You can log in later from settings to sync your data.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant), // Use onSurfaceVariant
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
