// lib/src/presentation/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// A screen that allows users to request a password reset email.
class ForgotPasswordScreen extends StatefulWidget {
  /// Creates a `ForgotPasswordScreen`.
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

  /// Sends a password reset email to the address entered in the text field.
  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.sendPasswordResetEmail(_emailController.text.trim());
        if (mounted) {
          AppUtils.showSnackBar(context, AppStrings.passwordResetEmailSent);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop();
          });
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showSnackBar(
              context, authProvider.errorMessage ?? e.toString(),
              isError: true);
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
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
                  Icon(Symbols.lock_reset,
                      size: 64.h,
                      color:
                          theme.colorScheme.primary),
                  SizedBox(height: 20.h),
                  Text(
                    'Forgot Your Password?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Enter your email address below and we\'ll send you a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 32.h),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppStrings.email,
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Symbols.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: AppUtils.validateEmail,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _sendResetEmail(),
                  ),
                  SizedBox(height: 24.h),
                  FilledButton(
                    onPressed: _isLoading ? null : _sendResetEmail,
                    child: _isLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: theme.colorScheme.onPrimary))
                        : const Text('Send Reset Link'),
                  ),
                  SizedBox(height: 20.h),
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
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
