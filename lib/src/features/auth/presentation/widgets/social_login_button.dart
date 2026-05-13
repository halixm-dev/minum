// lib/src/presentation/widgets/common/social_login_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A customizable button for social login actions.
///
/// This button is styled as an `OutlinedButton` and can display a social media
/// icon, text, and a loading indicator.
class SocialLoginButton extends StatelessWidget {
  /// The text to display on the button.
  final String text;
  /// The path to the social icon asset.
  final String assetName;
  /// The callback that is called when the button is tapped.
  final VoidCallback? onPressed;
  /// A flag to indicate if the button is in a loading state.
  final bool isLoading;
  /// The width of the button.
  final double? width;
  /// The style of the button.
  final ButtonStyle? style;

  /// Creates a `SocialLoginButton`.
  const SocialLoginButton({
    super.key,
    required this.text,
    required this.assetName,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.outlinedButtonTheme.style ?? const ButtonStyle();

    ButtonStyle effectiveStyle = baseStyle;
    if (style != null) {
      effectiveStyle = baseStyle.merge(style);
    }

    Color progressIndicatorColor =
        effectiveStyle.foregroundColor?.resolve({WidgetState.disabled}) ??
            theme.colorScheme.onSurface.withAlpha(97);
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetName,
            height: 20.h,
            width: 20.w,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Symbols.login,
                  size: 20.sp, color: progressIndicatorColor);
            },
          ),
          SizedBox(width: 12.w),
          Text(text),
        ],
      );
    }

    final button = OutlinedButton(
      style: effectiveStyle,
      onPressed: isLoading ? null : onPressed,
      child: buttonChild,
    );

    if (width != null) {
      return SizedBox(
        width: width == double.infinity ? double.infinity : width,
        child: button,
      );
    }

    return button;
  }
}
