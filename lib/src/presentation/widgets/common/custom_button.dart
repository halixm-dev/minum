// lib/src/presentation/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A custom button that aligns with Material 3 FilledButton styling by default.
/// It supports a loading state and an optional icon.
/// For different button styles (Elevated, Outlined, Text), use the respective
/// Material 3 widgets directly.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height; // Note: M3 button height is typically controlled by padding and text style.
  final Widget? icon;
  final ButtonStyle? style; // Allow full style override if needed

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use the theme's FilledButton style as a base
    final baseStyle = theme.filledButtonTheme.style ?? const ButtonStyle();

    // Merge with provided style if any
    ButtonStyle effectiveStyle = baseStyle;
    if (style != null) {
      effectiveStyle = baseStyle.merge(style);
    }
    
    // Override text style color if loading, to ensure progress indicator visibility
    // M3 themes should handle disabled state opacity for text and background.
    final progressIndicatorColor = effectiveStyle.foregroundColor?.resolve({WidgetState.disabled}) ?? theme.colorScheme.onSurface.withValues(alpha: 0.38);


    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 20.r, // Standard size for CircularProgressIndicator in buttons
        height: 20.r,
        child: CircularProgressIndicator(
          strokeWidth: 2.5.w,
          valueColor: AlwaysStoppedAnimation<Color>(progressIndicatorColor),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: 8.w),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    final button = FilledButton(
      style: effectiveStyle,
      onPressed: isLoading ? null : onPressed,
      child: buttonChild,
    );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height, // If height is provided, SizedBox forces it.
        child: button,
      );
    }

    return button;
  }
}
