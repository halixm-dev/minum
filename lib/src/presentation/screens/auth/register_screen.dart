// lib/src/presentation/screens/auth/register_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_colors.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/widgets/common/custom_button.dart';
import 'package:minum/src/presentation/widgets/common/custom_text_field.dart';
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
        AppUtils.showSnackBar(context, authProvider.errorMessage ?? AppStrings.anErrorOccurred, isError: true);
      }
      // AuthGate will handle navigation if successful
    }
  }

  Future<void> _registerWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    AppUtils.showLoadingDialog(context, message: "Connecting to Google...");

    await authProvider.signInWithGoogle(); // signInWithGoogle handles both sign-in and registration flow

    if (mounted) AppUtils.hideLoadingDialog(context);

    if (authProvider.authStatus == AuthStatus.authError && mounted) {
      AppUtils.showSnackBar(context, authProvider.errorMessage ?? AppStrings.anErrorOccurred, isError: true);
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
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.water_drop, size: 70.h, color: AppColors.primaryColor),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Join Minum and stay hydrated!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 28.h),

                  // Display Name Field
                  CustomTextField(
                    controller: _displayNameController,
                    labelText: 'Display Name',
                    hintText: 'Your Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) => AppUtils.validateNotEmpty(value, fieldName: "Display name"),
                  ),
                  SizedBox(height: 16.h),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: AppUtils.validateEmail,
                  ),
                  SizedBox(height: 16.h),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    labelText: AppStrings.password,
                    hintText: 'Create a password (min. 6 characters)',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                    validator: AppUtils.validatePassword,
                  ),
                  SizedBox(height: 16.h),

                  // Confirm Password Field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: AppStrings.confirmPassword,
                    hintText: 'Re-enter your password',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                    validator: (value) => AppUtils.validateConfirmPassword(_passwordController.text, value),
                  ),
                  SizedBox(height: 24.h),

                  // Register Button
                  CustomButton(
                    text: AppStrings.register,
                    isLoading: authProvider.authStatus == AuthStatus.authenticating &&
                        (authProvider.errorMessage == null || !authProvider.errorMessage!.toLowerCase().contains("google")),
                    onPressed: _registerUser,
                  ),
                  SizedBox(height: 20.h),

                  // "Or sign up with"
                  Row(
                    children: <Widget>[
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text('Or sign up with', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Google Register Button
                  SocialLoginButton(
                    text: AppStrings.registerWithGoogle,
                    assetName: 'assets/images/google_logo.png', // Make sure you have this asset
                    isLoading: authProvider.authStatus == AuthStatus.authenticating &&
                        authProvider.errorMessage == null &&
                        _emailController.text.isEmpty, // Basic check if it's Google auth
                    onPressed: _registerWithGoogle,
                  ),
                  SizedBox(height: 32.h),

                  // Already have an account? Login
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: AppStrings.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: <TextSpan>[
                          TextSpan(
                            text: AppStrings.signInHere,
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
