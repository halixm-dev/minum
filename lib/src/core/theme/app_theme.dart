// lib/src/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts
import 'package:minum/src/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._(); // Private constructor

  // Helper to apply Inter font with specific styles

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
    // fontFamily: 'Inter', // No longer needed, GoogleFonts handles it
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.lightAppBarBackground,
      iconTheme: const IconThemeData(color: AppColors.lightAppBarText),
      titleTextStyle: GoogleFonts.inter( // Apply Inter font
        color: AppColors.lightAppBarText,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.accentColor,
      surface: AppColors.lightSurface,
      error: AppColors.errorColor,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.lightText,
      onError: AppColors.onError,
    ),
    textTheme: GoogleFonts.interTextTheme( // Apply Inter to the whole text theme
        ThemeData.light().textTheme.copyWith( // Start with base light theme text styles
          displayLarge: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.lightText),
          displayMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.lightText),
          headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.lightText),
          titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.lightText),
          bodyLarge: TextStyle(fontSize: 16.sp, color: AppColors.lightText),
          bodyMedium: TextStyle(fontSize: 14.sp, color: AppColors.lightTextSecondary),
          labelLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.onPrimary),
        )
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.onPrimary,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
        textStyle: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600), // Apply Inter
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.lightInputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.lightInputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(color: AppColors.lightTextSecondary, fontSize: 14.sp), // Apply Inter
      hintStyle: GoogleFonts.inter(color: AppColors.lightTextHint, fontSize: 14.sp), // Apply Inter
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      color: AppColors.lightSurface,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.lightIcon,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.onPrimary,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColorDark,
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    // fontFamily: 'Inter', // No longer needed
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.darkAppBarBackground,
      iconTheme: const IconThemeData(color: AppColors.darkAppBarText),
      titleTextStyle: GoogleFonts.inter( // Apply Inter
        color: AppColors.darkAppBarText,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColorDark,
      secondary: AppColors.accentColorDark,
      surface: AppColors.darkSurface,
      error: AppColors.errorColor,
      onPrimary: AppColors.onPrimaryDark,
      onSecondary: AppColors.onSecondaryDark,
      onSurface: AppColors.darkText,
      onError: AppColors.onError,
    ),
    textTheme: GoogleFonts.interTextTheme( // Apply Inter to the whole text theme
        ThemeData.dark().textTheme.copyWith( // Start with base dark theme text styles
          displayLarge: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
          displayMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
          headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
          titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
          bodyLarge: TextStyle(fontSize: 16.sp, color: AppColors.darkText),
          bodyMedium: TextStyle(fontSize: 14.sp, color: AppColors.darkTextSecondary),
          labelLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.onPrimaryDark),
        )
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      buttonColor: AppColors.primaryColorDark,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColorDark,
        foregroundColor: AppColors.onPrimaryDark,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
        textStyle: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600), // Apply Inter
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.darkInputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.darkInputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.primaryColorDark, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(color: AppColors.darkTextSecondary, fontSize: 14.sp), // Apply Inter
      hintStyle: GoogleFonts.inter(color: AppColors.darkTextHint, fontSize: 14.sp), // Apply Inter
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      color: AppColors.lightSurface,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.darkIcon,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColorDark,
      foregroundColor: AppColors.onPrimaryDark,
    ),
  );
}
