// lib/src/core/theme/app_theme.dart
// dynamic_color import removed as CorePalette is no longer directly used here.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts
import 'package:minum/src/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._(); // Private constructor

  static final ThemeData lightTheme = buildThemeDataFromScheme(
      const ColorScheme.light(
        brightness: Brightness.light,
        primary: AppColors.primaryColor,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainerLight,
        onPrimaryContainer: AppColors.onPrimaryContainerLight,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.onSecondaryLight,
        secondaryContainer: AppColors.secondaryContainerLight,
        onSecondaryContainer: AppColors.onSecondaryContainerLight,
        tertiary: AppColors.tertiaryLight,
        onTertiary: AppColors.onTertiaryLight,
        tertiaryContainer: AppColors.tertiaryContainerLight,
        onTertiaryContainer: AppColors.onTertiaryContainerLight,
        error: AppColors.errorColor,
        onError: AppColors.onError,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        onSurfaceVariant: AppColors.onSurfaceVariantLight,
        outline: AppColors.outlineLight,
        outlineVariant: AppColors.outlineVariantLight,
        shadow: AppColors.shadowColor,
        scrim: Colors.black12,
        inverseSurface: AppColors.darkSurface,
        onInverseSurface: AppColors.darkText,
        inversePrimary: AppColors.primaryColorDark,
        surfaceTint: AppColors.primaryColor,
      ),
      Brightness.light);

  static final ThemeData darkTheme = buildThemeDataFromScheme(
      const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primaryColorDark,
        onPrimary: AppColors.onPrimaryDark,
        primaryContainer: AppColors.primaryContainerDark,
        onPrimaryContainer: AppColors.onPrimaryContainerDark,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.onSecondaryDark,
        secondaryContainer: AppColors.secondaryContainerDark,
        onSecondaryContainer: AppColors.onSecondaryContainerDark,
        tertiary: AppColors.tertiaryDark,
        onTertiary: AppColors.onTertiaryDark,
        tertiaryContainer: AppColors.tertiaryContainerDark,
        onTertiaryContainer: AppColors.onTertiaryContainerDark,
        error: AppColors.errorColor,
        onError: AppColors.onError,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        outline: AppColors.outlineDark,
        outlineVariant: AppColors.outlineVariantDark,
        shadow: AppColors.shadowColor,
        scrim: Colors.black54,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        inverseSurface: AppColors.lightSurface,
        onInverseSurface: AppColors.lightText,
        inversePrimary: AppColors.primaryColor,
        surfaceTint: AppColors.primaryColorDark,
      ),
      Brightness.dark);

  static ThemeData themeFromSeed(
      {required Color seedColor, required Brightness brightness}) {
    final colorScheme =
        ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    return buildThemeDataFromScheme(colorScheme, brightness);
  }

  // The themeFromCorePalette method has been removed because this file should no longer
  // directly reference CorePalette from the dynamic_color package.
  // ThemeProvider is now responsible for converting a CorePalette to a ColorScheme
  // (using AppTheme.themeFromSeed if necessary, or directly creating ColorScheme objects)
  // and then calling buildThemeDataFromScheme or themeFromSeed.

  static ThemeData buildThemeDataFromScheme(
      ColorScheme colorScheme, Brightness brightness) {
    final baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary, // M2 compatibility
      scaffoldBackgroundColor: colorScheme.surface,
      // M3 uses surface for AppBars by default, but surfaceContainer might be desired for a slight tint
      appBarTheme: AppBarTheme(
        elevation: 0,
        // backgroundColor: colorScheme.surface, // Standard M3 AppBar
        backgroundColor:
            colorScheme.surfaceContainer, // Slightly more elevated/distinct
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        titleTextStyle: GoogleFonts.roboto(
          color: colorScheme.onSurface,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme(baseTextTheme.copyWith(
        displayLarge: TextStyle(
            fontSize: 57.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        displayMedium: TextStyle(
            fontSize: 45.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        displaySmall: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        headlineLarge: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        headlineMedium: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface), // Often onSurface for emphasis
        headlineSmall: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface), // Often onSurface for emphasis
        titleLarge: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface), // M3 titles are often onSurface
        titleMedium: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface),
        titleSmall: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface),
        bodyLarge: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        bodyMedium: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant),
        bodySmall: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant),
        labelLarge: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onPrimary), // Used in ElevatedButtons
        labelMedium: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface), // Or onSurface
        labelSmall: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface), // Or onSurface
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
          textStyle: GoogleFonts.roboto(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500), // M3 uses labelLarge for buttons
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  20.r)), // M3 uses full pill shape (large radius)
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // M3 TextFields are typically filled
        fillColor:
            colorScheme.surfaceContainerHighest, // M3 filled text field color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide
              .none, // M3 uses no border for filled variant by default, relies on fill
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide:
              BorderSide.none, // Or colorScheme.outline for a subtle border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(
              color: colorScheme.primary, width: 2.0), // Focused indicator
        ),
        labelStyle: GoogleFonts.roboto(
            color: colorScheme.onSurfaceVariant, fontSize: 14.sp),
        hintStyle: GoogleFonts.roboto(
            color: colorScheme.onSurfaceVariant, fontSize: 14.sp),
      ),
      cardTheme: CardThemeData(
        // Corrected from CardTheme to CardThemeData
        elevation: 0, // M3 cards can be elevation 0 if filled/stroked
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.r))),
        color: colorScheme.surfaceContainer, // M3 card color
        // surfaceTintColor: colorScheme.surfaceTint, // Optional tint for elevation effect
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3, // M3 FABs have a slight elevation
      ),
      buttonTheme: ButtonThemeData(
        // Keep M2 buttonTheme for compatibility if needed by older custom widgets
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)), // M3 like pill shape
        buttonColor: colorScheme.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      // Consider adding other M3 component themes:
      // dialogTheme: DialogTheme(backgroundColor: colorScheme.surfaceContainerHigh, titleTextStyle: ...),
      // bottomSheetTheme: BottomSheetThemeData(backgroundColor: colorScheme.surfaceContainer),
      // chipTheme: ChipThemeData(backgroundColor: colorScheme.secondaryContainer, labelStyle: TextStyle(color: colorScheme.onSecondaryContainer)),
      // navigationBarTheme: NavigationBarThemeData(backgroundColor: colorScheme.surfaceContainer, indicatorColor: colorScheme.secondaryContainer),
    );
  }
}
