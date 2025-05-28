// lib/src/presentation/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? elevation;
  final double borderRadius;
  final Widget? icon; // Optional icon

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.elevation,
    this.borderRadius = 8.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ??
        theme.elevatedButtonTheme.style?.backgroundColor?.resolve({}) ??
        theme.colorScheme.primary;
    final effectiveTextColor = textColor ??
        theme.elevatedButtonTheme.style?.foregroundColor?.resolve({}) ??
        theme.colorScheme.onPrimary;
    final effectiveHeight = height ?? 50.h; // Default height

    return SizedBox(
      width: width ?? double.infinity, // Default to full width
      height: effectiveHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          padding: icon != null
              ? EdgeInsets.symmetric(horizontal: 16.w)
              : EdgeInsets.symmetric(
                  vertical: 0, horizontal: 24.w), // Adjust padding if icon
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
          elevation: elevation ??
              (isLoading || onPressed == null
                  ? 0
                  : 2), // No elevation when loading/disabled
          textStyle: theme.elevatedButtonTheme.style?.textStyle?.resolve({}) ??
              TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ).copyWith(
          // Ensure minimum size is respected, especially for height
          minimumSize: WidgetStateProperty.all(Size(0, effectiveHeight)),
          // Handle disabled state color more explicitly if needed
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                // Updated to use withAlpha for opacity change
                return effectiveBackgroundColor
                    .withAlpha((255 * 0.5).round()); // 0.5 opacity
              }
              return effectiveBackgroundColor; // Use the component's default.
            },
          ),
        ),
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5.w,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : (icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon!,
                      SizedBox(width: 8.w),
                      Text(text),
                    ],
                  )
                : Text(text)),
      ),
    );
  }
}
