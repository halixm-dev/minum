// lib/src/core/utils/app_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minum/src/core/constants/app_strings.dart'; // For validation messages
import 'package:minum/src/data/models/user_model.dart'; // For MeasurementUnit

/// A utility class providing common functions for the application.
///
/// This class includes formatters, validators, UI helpers, and other
/// miscellaneous utilities.
class AppUtils {
  /// Private constructor to prevent instantiation.
  AppUtils._();

  // --- Formatters ---
  /// Formats a [DateTime] object into a string with the given [format].
  ///
  /// The default format is 'yyyy-MM-dd'.
  /// @return The formatted date string.
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  /// Formats a [DateTime] object into a time string with the given [format].
  ///
  /// The default format is 'hh:mm a'.
  /// @return The formatted time string.
  static String formatTime(DateTime time, {String format = 'hh:mm a'}) {
    return DateFormat(format).format(time);
  }

  /// Formats a [DateTime] object into a date and time string with the given [format].
  ///
  /// The default format is 'yyyy-MM-dd, hh:mm a'.
  /// @return The formatted date and time string.
  static String formatDateTime(DateTime dateTime,
      {String format = 'yyyy-MM-dd, hh:mm a'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Formats a numeric [amount] into a string with a fixed number of decimal digits.
  ///
  /// The default number of decimal digits is 0.
  /// @return The formatted amount string.
  static String formatAmount(double amount, {int decimalDigits = 0}) {
    return amount.toStringAsFixed(decimalDigits);
  }

  // --- Validators ---
  /// Validates an email string.
  ///
  /// Returns an error message if the email is empty or invalid, otherwise null.
  /// @return A validation error message or null.
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

  /// Validates a password string.
  ///
  /// Returns an error message if the password is empty or too short, otherwise null.
  /// @return A validation error message or null.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 6) {
      return AppStrings.weakPassword; // Or more specific criteria
    }
    return null;
  }

  /// Validates that a confirmation password matches the original password.
  ///
  /// Returns an error message if the confirmation password is empty or does not
  /// match, otherwise null.
  /// @return A validation error message or null.
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

  /// Validates that a string is not empty.
  ///
  /// Returns an error message if the string is empty, otherwise null.
  /// The [fieldName] is used in the error message.
  /// @return A validation error message or null.
  static String? validateNotEmpty(String? value,
      {String fieldName = "This field"}) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required."; // Or use AppStrings.fieldRequired
    }
    return null;
  }

  /// Validates that a string represents a valid number.
  ///
  /// Options to [allowDecimal] and [allowNegative] values.
  /// @return A validation error message or null.
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
  /// Shows a `SnackBar` with the given [message].
  ///
  /// The [isError] flag determines the background color of the `SnackBar`.
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

  /// Shows a loading dialog with an optional [message].
  ///
  /// The dialog is not dismissible by the user.
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

  /// Hides the currently shown loading dialog.
  static void hideLoadingDialog(BuildContext context) {
    // Check if there's a dialog to pop to avoid errors
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// Shows a confirmation dialog with the given [title] and [content].
  ///
  /// Returns `true` if the user confirms, `false` if the user cancels, and
  /// `null` if the dialog is dismissed.
  /// The [confirmText] and [cancelText] can be customized.
  /// @return A `Future` that resolves to a boolean or null.
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
  /// Converts a value in milliliters to the user's preferred measurement unit.
  ///
  /// The [valueMl] is the value in milliliters.
  /// The [unit] is the target `MeasurementUnit`.
  /// @return The converted value.
  static double convertToPreferredUnit(double valueMl, MeasurementUnit unit) {
    if (unit == MeasurementUnit.oz) {
      return valueMl / 29.5735; // mL to fluid ounces conversion
    }
    return valueMl;
  }
}

// --- String Extension for Capitalization ---
/// An extension on the `String` class to provide a `capitalize` method.
extension StringExtension on String {
  /// Capitalizes the first letter of the string and converts the rest to lowercase.
  ///
  /// @return The capitalized string.
  String capitalize() {
    if (isEmpty) return "";
    if (length == 1) return toUpperCase();
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
