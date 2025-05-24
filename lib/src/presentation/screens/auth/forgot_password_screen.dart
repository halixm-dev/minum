// lib/src/presentation/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_colors.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/widgets/common/custom_button.dart';
import 'package:minum/src/presentation/widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';
// For logger

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.sendPasswordResetEmail(_emailController.text.trim());
        if (mounted) {
          AppUtils.showSnackBar(context, AppStrings.passwordResetEmailSent);
          // Optionally navigate back or to login after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop();
          });
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showSnackBar(context, authProvider.errorMessage ?? e.toString(), isError: true);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        elevation: 0,
        centerTitle: true,
      ),
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
                  Icon(Icons.lock_reset_outlined, size: 70.h, color: Theme.of(context).colorScheme.primary), // Changed
                  SizedBox(height: 20.h),
                  Text(
                    'Forgot Your Password?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Enter your email address below and we\'ll send you a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 32.h),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: AppUtils.validateEmail,
                  ),
                  SizedBox(height: 24.h),

                  // Send Reset Link Button
                  CustomButton(
                    text: 'Send Reset Link',
                    isLoading: _isLoading,
                    onPressed: _sendResetEmail,
                  ),
                  SizedBox(height: 20.h),

                  TextButton(
                    onPressed: () {
                      if (!_isLoading) Navigator.of(context).pop(); // Go back to Login
                    },
                    child: const Text('Back to Login'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
