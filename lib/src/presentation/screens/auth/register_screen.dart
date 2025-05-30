// lib/src/presentation/screens/auth/register_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/widgets/common/social_login_button.dart';
import 'package:provider/provider.dart';
// For logger

class RegisterScreen extends StatefulWidget {
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
      // AuthGate will handle navigation if successful
    }
  }

  Future<void> _registerWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    AppUtils.showLoadingDialog(context, message: "Connecting to Google...");

    await authProvider
        .signInWithGoogle(); // signInWithGoogle handles both sign-in and registration flow

    if (mounted) AppUtils.hideLoadingDialog(context);

    if (authProvider.authStatus == AuthStatus.authError && mounted) {
      AppUtils.showSnackBar(
          context, authProvider.errorMessage ?? AppStrings.anErrorOccurred,
          isError: true);
    }
    // AuthGate will handle navigation if successful
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
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // Optionally tint logo
                    errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.water_drop,
                        size: 70.h,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  SizedBox(height: 8.h), // Changed from 10.h to 8.h
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          // fontWeight removed, use M3 theme's definition
                        ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Join Minum and stay hydrated!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant, // Adjusted for less emphasis
                        ),
                  ),
                  SizedBox(height: 28.h),

                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Your Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => AppUtils.validateNotEmpty(value,
                        fieldName: "Display name"),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 16.h),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.email,
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
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
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
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
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
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
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall), // Changed to bodySmall for hierarchy
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
                      // Consistent Google button styling
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
                      textAlign: TextAlign.center, // Center align RichText
                      text: TextSpan(
                        text: AppStrings.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                ' ${AppStrings.signInHere}', // Added space for better separation
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              // fontWeight removed, rely on theme or default
                              decoration: TextDecoration.underline,
                              decorationColor: Theme.of(context)
                                  .colorScheme
                                  .primary, // Explicit underline color
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                if (authProvider.authStatus !=
                                    AuthStatus.authenticating) {
                                  // Prevent navigation while loading
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
