// lib/src/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor

  // --- Primary & Accent Colors (Used for M3 primary/secondary) ---
  static const Color primaryColor = Color(0xFF00A9FF); // M3 primary (Light)
  static const Color accentColor = Color(0xFF89CFF3);  // M3 secondary (Light)
  static const Color primaryColorDark = Color(0xFF008DDD); // M3 primary (Dark)
  static const Color accentColorDark = Color(0xFF60A3D9);  // M3 secondary (Dark)

  // --- Text Colors (Mainly covered by onSurface, onSurfaceVariant etc. in ColorScheme) ---
  // Light Theme
  static const Color lightText = Color(0xFF1D2A3A); // Used for M3 onSurface (Light)
  // static const Color lightTextSecondary = Color(0xFF5A6A7A); // Consider using onSurfaceVariant
  // static const Color lightTextHint = Color(0xFF8C9BAB); // Consider using onSurfaceVariant.withOpacity(0.6) or similar

  // Dark Theme
  static const Color darkText = Color(0xFFE0E0E0); // Used for M3 onSurface (Dark)
  // static const Color darkTextSecondary = Color(0xFFB0B0B0); // Consider using onSurfaceVariant
  // static const Color darkTextHint = Color(0xFF8A8A8A); // Consider using onSurfaceVariant.withOpacity(0.6) or similar

  // --- Background Colors (Mapped to M3 surface roles in ColorScheme) ---
  // Light Theme
  static const Color lightScaffoldBackground = Color(0xFFF4F7FA); // Used for M3 surface, surfaceContainerLow (Light)
  static const Color lightBackground = Color(0xFFFFFFFF); // Used for M3 surfaceContainerHighest (Light)
  static const Color lightSurface = Color(0xFFFFFFFF); // Used for M3 surfaceContainer (Light)
  // static const Color lightAppBarBackground = Color(0xFFFFFFFF); // Superseded by AppBarTheme
  // static const Color lightAppBarText = Color(0xFF1D2A3A); // Superseded by AppBarTheme
  // static const Color lightInputBorder = Color(0xFFD0D5DD); // Superseded by InputDecorationTheme

  // Dark Theme
  static const Color darkScaffoldBackground = Color(0xFF121212); // Used for M3 surface, surfaceContainerLowest (Dark)
  static const Color darkBackground = Color(0xFF1E1E1E); // Used for M3 surfaceContainerLow (Dark)
  static const Color darkSurface = Color(0xFF2C2C2C); // Used for M3 surfaceContainer (Dark)
  // static const Color darkAppBarBackground = Color(0xFF1E1E1E); // Superseded by AppBarTheme
  // static const Color darkAppBarText = Color(0xFFE0E0E0); // Superseded by AppBarTheme
  // static const Color darkInputBorder = Color(0xFF4A4A4A); // Superseded by InputDecorationTheme


  // --- Semantic Colors (Error is M3, Success/Warning are custom) ---
  static const Color errorColor = Color(0xFFD32F2F); // M3 error
  static const Color successColor = Color(0xFF388E3C); // Standard green for success
  static const Color warningColor = Color(0xFFFFA000); // Standard orange for warnings

  // --- On-Color (Text/icons on colored backgrounds) ---
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black; // For light theme accentColor (secondaryLight)
  static const Color onError = Colors.white; // For light theme errorColor (remains for light theme)
  static const Color onPrimaryDark = Colors.white; // M3 onPrimary (Dark)
  static const Color onSecondaryDark = onPrimaryContainerDark; // Changed from Colors.black for better M3 dark theme contrast

  // --- Icon Colors (Superseded by IconTheme using onSurfaceVariant) ---
  // static const Color lightIcon = Color(0xFF5A6A7A);
  // static const Color darkIcon = Color(0xFFB0B0B0);

  // --- Other UI Elements ---
  // static const Color dividerColor = Color(0xFFE0E0E0); // Consider using ColorScheme.outline or outlineVariant
  // static const Color darkDividerColor = Color(0xFF3A3A3A); // Consider using ColorScheme.outline or outlineVariant
  static const Color shadowColor = Color(0x33000000); // M3 shadow (used in ColorScheme)

  // --- Material 3 Semantic Colors (Defined for direct use in ColorScheme) ---

  // --- M3 Light Theme Colors ---
  // Primary Family
  static const Color primaryContainerLight = Color(0xFFD1E4FF);
  static const Color onPrimaryContainerLight = Color(0xFF001D36);

  // Secondary Family (derived from accentColor)
  static const Color secondaryLight = accentColor; // M3 secondary can be the M2 accent
  static const Color onSecondaryLight = onSecondary; // M3 onSecondary for M2 accent (Colors.black)
  static const Color secondaryContainerLight = Color(0xFFCFE6F2);
  static const Color onSecondaryContainerLight = Color(0xFF0A1E29);

  // Tertiary Family
  static const Color tertiaryLight = Color(0xFF008080); // Teal
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFB2DFDB);
  static const Color onTertiaryContainerLight = Color(0xFF002524);

  // Surface Variant Family
  static const Color surfaceVariantLight = Color(0xFFE0E4E8);
  static const Color onSurfaceVariantLight = Color(0xFF404850); // Could also be lightTextSecondary

  // Outline Family
  static const Color outlineLight = Color(0xFF73777F);
  static const Color outlineVariantLight = Color(0xFFC3C7CF);

  // Error Container Family (Light)
  static const Color errorContainerLight = Color(0xFFF9DEDC);
  static const Color onErrorContainerLight = Color(0xFF410E0B);

  // New Surface Tones (Light) - Based on lightScaffoldBackground F4F7FA and lightBackground FFFFFF
  static const Color surfaceDimLight = Color(0xFFE4E7EA); // Darker than scaffold bg
  static const Color surfaceBrightLight = Color(0xFFFCFCFC); // Lighter than scaffold bg, but not pure white
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceContainerLowLight = Color(0xFFF4F7FA); // Existing scaffold bg
  static const Color surfaceContainerLight = Color(0xFFEFF2F5);   // Slightly above scaffold bg
  static const Color surfaceContainerHighLight = Color(0xFFE9ECF0);  // Higher than container
  static const Color surfaceContainerHighestLight = Color(0xFFE3E6E9); // Highest, but below pure white background typically used for app bar

  // --- M3 Dark Theme Colors ---
  // Primary Family
  static const Color primaryContainerDark = Color(0xFF004A77);
  static const Color onPrimaryContainerDark = Color(0xFFD1E4FF);

  // Secondary Family (derived from accentColorDark)
  static const Color secondaryDark = accentColorDark; // M3 secondary can be the M2 accentDark
  // AppColors.onSecondaryDark (Colors.black) will be used for onSecondaryDark in ColorScheme
  static const Color secondaryContainerDark = Color(0xFF2C4A5E);
  static const Color onSecondaryContainerDark = Color(0xFFCFE6F2);

  // Tertiary Family
  static const Color tertiaryDark = Color(0xFF006A6A);
  static const Color onTertiaryDark = Color(0xFFFFFFFF);
  static const Color tertiaryContainerDark = Color(0xFF004D4D);
  static const Color onTertiaryContainerDark = Color(0xFFB2DFDB);

  // Surface Variant Family
  static const Color surfaceVariantDark = Color(0xFF42474E);
  static const Color onSurfaceVariantDark = Color(0xFFC1C7CE); // Could also be darkTextSecondary

  // Outline Family
  static const Color outlineDark = Color(0xFF8D9199);
  static const Color outlineVariantDark = Color(0xFF43474E); // Can be same as surfaceVariantDark

  // M3 Error Colors for Dark Theme (to be used in ColorScheme.dark)
  static const Color errorDarkM3 = Color(0xFFFFB4AB);
  static const Color onErrorDarkM3 = Color(0xFF690005);

  // Error Container Family (Dark) - These are correctly defined for M3 already
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  // New Surface Tones (Dark) - Based on darkScaffoldBackground 121212 and darkBackground 1E1E1E
  static const Color surfaceDimDark = Color(0xFF0E0E0E); // Darker than scaffold bg
  static const Color surfaceBrightDark = Color(0xFF3A3A3A); // Lighter than darkSurface
  static const Color surfaceContainerLowestDark = Color(0xFF0A0A0A); // Darkest
  static const Color surfaceContainerLowDark = Color(0xFF1E1E1E); // Existing darkBackground
  static const Color surfaceContainerDark = Color(0xFF232323);    // Slightly above darkBackground
  static const Color surfaceContainerHighDark = Color(0xFF2D2D2D);  // Higher than container
  static const Color surfaceContainerHighestDark = Color(0xFF383838); // Highest, for things like AppBars
}