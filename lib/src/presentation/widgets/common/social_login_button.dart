// lib/src/presentation/widgets/common/social_login_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_colors.dart'; // For default text color

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String assetName; // Path to the social icon asset (e.g., Google logo)
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.assetName,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Default to a light background for social buttons, often white or very light grey
    final effectiveBackgroundColor = backgroundColor ??
        (theme.brightness == Brightness.light
            ? Colors.white
            : AppColors.darkSurface);
    // Default text color often contrasts with the button's light background
    final effectiveTextColor = textColor ??
        (theme.brightness == Brightness.light
            ? AppColors.lightText
            : AppColors.darkText);
    final effectiveHeight = height ?? 50.h;

    return SizedBox(
      width: width ?? double.infinity,
      height: effectiveHeight,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          side: BorderSide(
            color: theme.brightness == Brightness.light
                ? AppColors.lightInputBorder
                : AppColors.darkInputBorder,
            width: 1.w,
          ),
          foregroundColor: effectiveTextColor,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
          textStyle: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: effectiveTextColor),
        ).copyWith(
          minimumSize: WidgetStateProperty.all(Size(0, effectiveHeight)),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                // Use withAlpha for disabled state background
                return effectiveBackgroundColor.withAlpha((255 * 0.7).round());
              }
              return effectiveBackgroundColor;
            },
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5.w,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    assetName,
                    height: 22.h, // Adjust size as needed
                    width: 22.w,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if asset fails to load
                      return Icon(Icons.login,
                          size: 22.sp, color: effectiveTextColor);
                    },
                  ),
                  SizedBox(width: 12.w),
                  Text(text),
                ],
              ),
      ),
    );
  }
}
