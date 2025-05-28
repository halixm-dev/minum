// lib/src/widgets/common/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_colors.dart'; // Using AppColors for consistency

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
    final inputDecorationTheme = theme.inputDecorationTheme;

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: inputDecorationTheme.labelStyle ??
            TextStyle(fontSize: 14.sp, color: AppColors.lightTextSecondary),
        hintStyle: inputDecorationTheme.hintStyle ??
            TextStyle(fontSize: 14.sp, color: AppColors.lightTextHint),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20.sp) : null,
        suffixIcon: suffixIcon,
        border: inputDecorationTheme.border ??
            OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
        enabledBorder: inputDecorationTheme.enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide:
                  BorderSide(color: AppColors.lightInputBorder, width: 1.w),
            ),
        focusedBorder: inputDecorationTheme.focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.5.w),
            ),
        errorBorder: inputDecorationTheme.errorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide:
                  BorderSide(color: theme.colorScheme.error, width: 1.w),
            ),
        focusedErrorBorder: inputDecorationTheme.focusedErrorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide:
                  BorderSide(color: theme.colorScheme.error, width: 1.5.w),
            ),
        disabledBorder: inputDecorationTheme.disabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.w),
            ),
        filled: inputDecorationTheme.filled,
        fillColor: inputDecorationTheme.fillColor,
        contentPadding: inputDecorationTheme.contentPadding ??
            EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
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
      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15.sp),
    );
  }
}
