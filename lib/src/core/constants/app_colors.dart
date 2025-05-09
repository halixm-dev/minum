// lib/src/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor

  // --- Primary & Accent Colors ---
  static const Color primaryColor = Color(0xFF00A9FF); // A vibrant blue
  static const Color accentColor = Color(0xFF89CFF3);  // A lighter, complementary blue
  static const Color primaryColorDark = Color(0xFF008DDD); // Slightly darker for dark theme primary
  static const Color accentColorDark = Color(0xFF60A3D9);  // Lighter accent for dark theme

  // --- Text Colors ---
  // Light Theme
  static const Color lightText = Color(0xFF1D2A3A); // Dark grey for main text
  static const Color lightTextSecondary = Color(0xFF5A6A7A); // Medium grey for subtitles
  static const Color lightTextHint = Color(0xFF8C9BAB); // Lighter grey for hints

  // Dark Theme
  static const Color darkText = Color(0xFFE0E0E0); // Light grey for main text
  static const Color darkTextSecondary = Color(0xFFB0B0B0); // Medium light grey for subtitles
  static const Color darkTextHint = Color(0xFF8A8A8A); // Darker grey for hints

  // --- Background Colors ---
  // Light Theme
  static const Color lightScaffoldBackground = Color(0xFFF4F7FA); // Very light grey/blue
  static const Color lightBackground = Color(0xFFFFFFFF); // White
  static const Color lightSurface = Color(0xFFFFFFFF); // White (for cards, dialogs)
  static const Color lightAppBarBackground = Color(0xFFFFFFFF);
  static const Color lightAppBarText = Color(0xFF1D2A3A);
  static const Color lightInputBorder = Color(0xFFD0D5DD);

  // Dark Theme
  static const Color darkScaffoldBackground = Color(0xFF121212); // Common dark theme bg
  static const Color darkBackground = Color(0xFF1E1E1E); // Slightly lighter dark
  static const Color darkSurface = Color(0xFF2C2C2C); // For cards, dialogs in dark mode
  static const Color darkAppBarBackground = Color(0xFF1E1E1E);
  static const Color darkAppBarText = Color(0xFFE0E0E0);
  static const Color darkInputBorder = Color(0xFF4A4A4A);


  // --- Common Colors ---
  static const Color errorColor = Color(0xFFD32F2F); // Standard red for errors
  static const Color successColor = Color(0xFF388E3C); // Standard green for success
  static const Color warningColor = Color(0xFFFFA000); // Standard orange for warnings

  // --- On-Color (Text/icons on colored backgrounds) ---
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onError = Colors.white;
  static const Color onPrimaryDark = Colors.white;
  static const Color onSecondaryDark = Colors.black;

  // --- Icon Colors ---
  static const Color lightIcon = Color(0xFF5A6A7A);
  static const Color darkIcon = Color(0xFFB0B0B0);

  // --- Other UI Elements ---
  static const Color dividerColor = Color(0xFFE0E0E0); // For light theme
  static const Color darkDividerColor = Color(0xFF3A3A3A); // For dark theme
  static const Color shadowColor = Color(0x33000000); // Light shadow
}