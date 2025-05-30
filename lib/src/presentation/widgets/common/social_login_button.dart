// lib/src/presentation/widgets/common/social_login_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String assetName; // Path to the social icon asset (e.g., Google logo)
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  // final double? height; // Removed height, M3 buttons derive height from theme/content
  final ButtonStyle? style; // Allow full style override if needed

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.assetName,
    this.onPressed,
    this.isLoading = false,
    this.width,
    // this.height, // Removed height
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use the theme's OutlinedButton style as a base
    final baseStyle = theme.outlinedButtonTheme.style ?? const ButtonStyle();

    // Merge with provided style if any
    ButtonStyle effectiveStyle = baseStyle;
    if (style != null) {
      effectiveStyle = baseStyle.merge(style);
    }

    // Determine color for progress indicator and fallback icon
    // This should ideally come from the resolved foregroundColor of the button style
    Color progressIndicatorColor =
        effectiveStyle.foregroundColor?.resolve({WidgetState.disabled}) ??
            theme.colorScheme.onSurface.withValues(alpha: 0.38);
    if (effectiveStyle.foregroundColor?.resolve({}) != null) {
      progressIndicatorColor = effectiveStyle.foregroundColor!.resolve({})!;
    }

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 20.r,
        height: 20.r,
        child: CircularProgressIndicator(
          strokeWidth: 2.5.w,
          valueColor: AlwaysStoppedAnimation<Color>(progressIndicatorColor),
        ),
      );
    } else {
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize:
            MainAxisSize.min, // Ensure button doesn't stretch unnecessarily
        children: [
          Image.asset(
            assetName,
            height: 20.h, // Standard icon size for buttons
            width: 20.w,
            // color: progressIndicatorColor, // This will only work for SVGs or template images
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.login,
                  size: 20.sp, color: progressIndicatorColor);
            },
          ),
          SizedBox(
              width: 12
                  .w), // M3 recommended spacing between icon and label is 8dp, but 12 can be fine.
          Text(text),
        ],
      );
    }

    final button = OutlinedButton(
      style: effectiveStyle,
      onPressed: isLoading ? null : onPressed,
      child: buttonChild,
    );

    // If width is specified, wrap in SizedBox to control width.
    // Height is now determined by the button's content and theme.
    if (width != null) {
      return SizedBox(
        width: width == double.infinity ? double.infinity : width,
        child: button,
      );
    }

    return button;
  }
}
