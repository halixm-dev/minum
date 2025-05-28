// lib/src/widgets/common/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// AppColors import removed as styles should come from the theme.

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final String? initialValue; // Used only when controller is null

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autovalidateMode,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The inputDecorationTheme is now expected to be fully defined in AppTheme.
    final inputDecorationTheme = theme.inputDecorationTheme;

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // labelStyle, hintStyle, border, enabledBorder, focusedBorder, etc.,
        // will now be taken directly from the inputDecorationTheme.
        // No need for ?? fallbacks if the theme is comprehensive.
        labelStyle: inputDecorationTheme.labelStyle,
        hintStyle: inputDecorationTheme.hintStyle,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20.sp) : null, // Icon size can be themed via IconThemeData if needed
        suffixIcon: suffixIcon,
        border: inputDecorationTheme.border,
        enabledBorder: inputDecorationTheme.enabledBorder,
        focusedBorder: inputDecorationTheme.focusedBorder,
        errorBorder: inputDecorationTheme.errorBorder,
        focusedErrorBorder: inputDecorationTheme.focusedErrorBorder,
        disabledBorder: inputDecorationTheme.disabledBorder,
        filled: inputDecorationTheme.filled, // Should be true in M3 theme
        fillColor: inputDecorationTheme.fillColor, // Should be defined in M3 theme
        contentPadding: inputDecorationTheme.contentPadding, // Should be defined in M3 theme
        // Ensure floatingLabelBehavior is consistent with M3, usually 'auto' or 'always'
        floatingLabelBehavior: inputDecorationTheme.floatingLabelBehavior ?? FloatingLabelBehavior.auto,
        errorStyle: inputDecorationTheme.errorStyle, // Ensure this is also themed
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      // Input text style should ideally come from the global text theme, e.g., bodyLarge.
      // The M3 inputDecorationTheme in AppTheme sets bodyLarge for labelStyle and hintStyle.
      // The actual input text style is typically derived from the context's default text style or can be set here.
      style: theme.textTheme.bodyLarge,
    );
  }
}
