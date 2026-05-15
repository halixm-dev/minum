// lib/src/features/auth/presentation/pages/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:minum/src/features/auth/presentation/widgets/social_login_button.dart';
import 'package:minum/src/core/utils/logger.dart';

/// A screen that serves as the main entry point for authentication, offering
/// options to sign in with Google or to skip and use the app as a guest.
class LoginScreen extends StatelessWidget {
  /// Creates a `LoginScreen`.
  const LoginScreen({super.key});

  /// Handles the Google Sign-In process by dispatching event to AuthBloc.
  void _loginWithGoogle(BuildContext context) {
    context.read<AuthBloc>().add(SignInWithGoogleRequested());
  }

  /// Skips the login process and navigates to the home screen in guest mode.
  void _skipLogin(BuildContext context) {
    logger.i("LoginScreen: 'Skip login' pressed. Navigating to HomeScreen.");
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final String? returnToRoute =
              ModalRoute.of(context)?.settings.arguments as String?;
          if (returnToRoute != null) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(returnToRoute, (route) => false);
          }
          // AuthGateScreen handles the main navigation on auth state change
        } else if (state is AuthError) {
          AppUtils.showSnackBar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
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
                        Symbols.water_drop,
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
                    AppStrings.stayHydratedEffortlessly,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const Spacer(flex: 3),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SocialLoginButton(
                        text: AppStrings.loginWithGoogle,
                        assetName: 'assets/images/google_logo.png',
                        isLoading: state is AuthLoading,
                        onPressed: () => _loginWithGoogle(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerLow,
                          foregroundColor: colorScheme.onSurfaceVariant,
                          side: BorderSide(color: colorScheme.outline),
                        ).merge(theme.outlinedButtonTheme.style),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => _skipLogin(context),
                    child: const Text(AppStrings.skipLoginForNow),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppStrings.guestModeLimitations,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic),
                  ),
                  const Spacer(flex: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      AppStrings.loginLaterHint,
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
      ),
    );
  }
}
