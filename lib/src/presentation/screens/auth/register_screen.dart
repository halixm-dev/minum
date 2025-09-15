// lib/src/presentation/screens/auth/register_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/widgets/common/social_login_button.dart';
import 'package:provider/provider.dart';

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
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      AppUtils.showLoadingDialog(context, message: "Creating account...");

      await authProvider.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );

      if (mounted) AppUtils.hideLoadingDialog(context);

      if (authProvider.authStatus == AuthStatus.authError && mounted) {
        AppUtils.showSnackBar(
            context, authProvider.errorMessage ?? AppStrings.anErrorOccurred,
            isError: true);
      }
    }
  }

  /// Initiates the registration process using Google Sign-In.
  Future<void> _registerWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    AppUtils.showLoadingDialog(context, message: "Connecting to Google...");

    await authProvider.signInWithGoogle();

    if (mounted) AppUtils.hideLoadingDialog(context);

    if (authProvider.authStatus == AuthStatus.authError && mounted) {
      AppUtils.showSnackBar(
          context, authProvider.errorMessage ?? AppStrings.anErrorOccurred,
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    AppAssets.appLogo,
                    height: 70.h,
                    color: Theme.of(context).colorScheme.primary,
                    errorBuilder: (context, error, stackTrace) => Icon(
                        Symbols.water_drop,
                        size: 70.h,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Join Minum and stay hydrated!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
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
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword)),
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
                    validator: (value) => AppUtils.validateConfirmPassword(
                        _passwordController.text, value),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _registerUser(),
                  ),
                  SizedBox(height: 24.h),
                  FilledButton(
                    onPressed:
                        authProvider.authStatus == AuthStatus.authenticating
                            ? null
                            : _registerUser,
                    child: authProvider.authStatus ==
                                AuthStatus.authenticating &&
                            (authProvider.errorMessage == null ||
                                !authProvider.errorMessage!
                                    .toLowerCase()
                                    .contains("google"))
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Theme.of(context).colorScheme.onPrimary))
                        : const Text(AppStrings.register),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: <Widget>[
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text('Or sign up with',
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SocialLoginButton(
                    text: AppStrings.registerWithGoogle,
                    assetName: 'assets/images/google_logo.png',
                    isLoading:
                        authProvider.authStatus == AuthStatus.authenticating &&
                            authProvider.errorMessage == null &&
                            _emailController.text.isEmpty,
                    onPressed: _registerWithGoogle,
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerLow,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.outline),
                    ).merge(Theme.of(context).outlinedButtonTheme.style),
                  ),
                  SizedBox(height: 32.h),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: AppStrings.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' ${AppStrings.signInHere}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                if (authProvider.authStatus !=
                                    AuthStatus.authenticating) {
                                  Navigator.of(context)
                                      .pushReplacementNamed(AppRoutes.login);
                                }
                              },
                          ),
                        ],
                      ),
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
