// lib/src/core/utils/app_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minum/src/core/constants/app_strings.dart'; // For validation messages
import 'package:minum/src/data/models/user_model.dart'; // For MeasurementUnit

class AppUtils {
  AppUtils._(); // Private constructor

  // --- Formatters ---
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    // Standard format
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime time, {String format = 'hh:mm a'}) {
    return DateFormat(format).format(time);
  }

  static String formatDateTime(DateTime dateTime,
      {String format = 'yyyy-MM-dd, hh:mm a'}) {
    // Standard format
    return DateFormat(format).format(dateTime);
  }

  static String formatAmount(double amount, {int decimalDigits = 0}) {
    return amount.toStringAsFixed(decimalDigits);
  }

  // --- Validators ---
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 6) {
      return AppStrings.weakPassword; // Or more specific criteria
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (password != confirmPassword) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }

  static String? validateNotEmpty(String? value,
      {String fieldName = "This field"}) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required."; // Or use AppStrings.fieldRequired
    }
    return null;
  }

  static String? validateNumber(String? value,
      {bool allowDecimal = false, bool allowNegative = false}) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    final num? number = num.tryParse(value);
    if (number == null) {
      return AppStrings.invalidNumber;
    }
    if (!allowNegative && number < 0) {
      return AppStrings.positiveNumberRequired;
    }
    if (!allowDecimal && value.contains('.')) {
      return "Decimal values are not allowed.";
    }
    return null;
  }

  // --- UI Helpers ---
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context)
        .removeCurrentSnackBar(); // Remove previous snackbar if any
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> showLoadingDialog(BuildContext context,
      {String message = AppStrings.loading}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must not close it manually
      builder: (BuildContext dialogContext) {
        // Renamed to avoid conflict
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    // Check if there's a dialog to pop to avoid errors
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = AppStrings.ok,
    String cancelText = AppStrings.cancel,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        // Renamed to avoid conflict
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text(cancelText),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          TextButton(
            child: Text(confirmText),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
  }

  // --- Unit Conversion Helper ---
  static double convertToPreferredUnit(double valueMl, MeasurementUnit unit) {
    if (unit == MeasurementUnit.oz) {
      return valueMl / 29.5735; // mL to fluid ounces conversion
    }
    return valueMl;
  }
}

// --- String Extension for Capitalization ---
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    if (length == 1) return toUpperCase();
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
