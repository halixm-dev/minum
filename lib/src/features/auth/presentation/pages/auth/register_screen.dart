// lib/src/features/auth/presentation/pages/auth/register_screen.dart
import 'package:flutter/gestures.dart';
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

/// A screen for new users to register an account using their email and password
/// or through Google Sign-In.
class RegisterScreen extends StatefulWidget {
  /// Creates a `RegisterScreen`.
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Attempts to register a new user with the provided form details.
  void _registerUser() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignUpWithEmailRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _displayNameController.text.trim(),
          ));
    }
  }

  /// Initiates the registration process using Google Sign-In.
  void _registerWithGoogle() {
    context.read<AuthBloc>().add(SignInWithGoogleRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppUtils.showSnackBar(context, state.message, isError: true);
        }
        // Authenticated state is handled by AuthGateScreen
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Form(
                key: _formKey,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final isLoading = authState is AuthLoading;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Image.asset(
                          AppAssets.appLogo,
                          height: 70.h,
                          color: colorScheme.primary,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Symbols.water_drop,
                              size: 70.h,
                              color: colorScheme.primary),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall
                              ?.copyWith(color: colorScheme.primary),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Join Minum and stay hydrated!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        TextFormField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            hintText: 'Your Name',
                            prefixIcon: Icon(Symbols.person),
                          ),
                          validator: (value) => AppUtils.validateNotEmpty(value,
                              fieldName: "Display name"),
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: AppStrings.email,
                            hintText: 'you@example.com',
                            prefixIcon: Icon(Symbols.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: AppUtils.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: AppStrings.password,
                            hintText: 'Create a password (min. 6 characters)',
                            prefixIcon: const Icon(Symbols.lock),
                            suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Symbols.visibility_off
                                    : Symbols.visibility),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword)),
                          ),
                          obscureText: _obscurePassword,
                          validator: AppUtils.validatePassword,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: AppStrings.confirmPassword,
                            hintText: 'Re-enter your password',
                            prefixIcon: const Icon(Symbols.lock),
                            suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword
                                    ? Symbols.visibility_off
                                    : Symbols.visibility),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword)),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) =>
                              AppUtils.validateConfirmPassword(
                                  _passwordController.text, value),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _registerUser(),
                        ),
                        SizedBox(height: 24.h),
                        FilledButton(
                          onPressed: isLoading ? null : _registerUser,
                          child: isLoading
                              ? SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: colorScheme.onPrimary))
                              : const Text(AppStrings.register),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: <Widget>[
                            const Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text('Or sign up with',
                                  style: theme.textTheme.bodySmall),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        SocialLoginButton(
                          text: AppStrings.registerWithGoogle,
                          assetName: 'assets/images/google_logo.png',
                          isLoading: isLoading,
                          onPressed: _registerWithGoogle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerLow,
                            foregroundColor: colorScheme.onSurfaceVariant,
                            side: BorderSide(color: colorScheme.outline),
                          ).merge(theme.outlinedButtonTheme.style),
                        ),
                        SizedBox(height: 32.h),
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: AppStrings.alreadyHaveAccount,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant),
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' ${AppStrings.signInHere}',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: colorScheme.primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      if (!isLoading) {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                AppRoutes.login);
                                      }
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
