// lib/src/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minum/src/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._(); // Private constructor

  static final ThemeData lightTheme = buildThemeDataFromScheme(
      ColorScheme.light(
        brightness: Brightness.light,
        primary: AppColors.primaryColor, // M3: primary
        onPrimary: AppColors.onPrimary, // M3: onPrimary
        primaryContainer: AppColors.primaryContainerLight, // M3: primaryContainer
        onPrimaryContainer: AppColors.onPrimaryContainerLight, // M3: onPrimaryContainer
        secondary: AppColors.secondaryLight, // M3: secondary (from accentColor)
        onSecondary: AppColors.onSecondaryLight, // M3: onSecondary
        secondaryContainer: AppColors.secondaryContainerLight, // M3: secondaryContainer
        onSecondaryContainer: AppColors.onSecondaryContainerLight, // M3: onSecondaryContainer
        tertiary: AppColors.tertiaryLight, // M3: tertiary
        onTertiary: AppColors.onTertiaryLight, // M3: onTertiary
        tertiaryContainer: AppColors.tertiaryContainerLight, // M3: tertiaryContainer
        onTertiaryContainer: AppColors.onTertiaryContainerLight, // M3: onTertiaryContainer
        error: AppColors.errorColor, // M3: error (Updated to #BA1A1A)
        onError: AppColors.onError, // M3: onError
        errorContainer: AppColors.errorContainerLight, // M3: errorContainer (Updated to #FFDAD6)
        onErrorContainer: AppColors.onErrorContainerLight, // M3: onErrorContainer (Updated to #410002)
        surface: AppColors.lightScaffoldBackground, // M3: surface (main background - using lightScaffoldBackground)
        onSurface: AppColors.lightText, // M3: onSurface
        surfaceDim: AppColors.surfaceDimLight, // M3: surfaceDim
        surfaceBright: AppColors.surfaceBrightLight, // M3: surfaceBright
        surfaceContainerLowest: AppColors.surfaceContainerLowestLight, // M3: surfaceContainerLowest
        surfaceContainerLow: AppColors.surfaceContainerLowLight, // M3: surfaceContainerLow (matches lightScaffoldBackground)
        surfaceContainer: AppColors.surfaceContainerLight, // M3: surfaceContainer (for cards - using lightSurface)
        surfaceContainerHigh: AppColors.surfaceContainerHighLight, // M3: surfaceContainerHigh
        surfaceContainerHighest: AppColors.surfaceContainerHighestLight, // M3: surfaceVariant (using AppColor E0E4E8)
        onSurfaceVariant: AppColors.onSurfaceVariantLight, // M3: onSurfaceVariant
        outline: AppColors.outlineLight, // M3: outline
        outlineVariant: AppColors.outlineVariantLight, // M3: outlineVariant
        inverseSurface: AppColors.darkScaffoldBackground, // M3: inverseSurface (dark theme's scaffold)
        onInverseSurface: AppColors.darkText, // M3: onInverseSurface (dark theme's text)
        inversePrimary: AppColors.primaryColorDark, // M3: inversePrimary (dark theme's primary)
        shadow: AppColors.shadowColor, // M3: shadow
        scrim: Colors.black.withAlpha(82), // M3: scrim (Standard ~32% opacity black)
        surfaceTint: AppColors.primaryColor, // M3: surfaceTint (typically primary color)
      ),
      Brightness.light);

  static final ThemeData darkTheme = buildThemeDataFromScheme(
      ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primaryColorDark, // M3: primary
        onPrimary: AppColors.onPrimaryDark, // M3: onPrimary
        primaryContainer: AppColors.primaryContainerDark, // M3: primaryContainer
        onPrimaryContainer: AppColors.onPrimaryContainerDark, // M3: onPrimaryContainer
        secondary: AppColors.secondaryDark, // M3: secondary (from accentColorDark)
        onSecondary: AppColors.onSecondaryDark, // M3: onSecondary
        secondaryContainer: AppColors.secondaryContainerDark, // M3: secondaryContainer
        onSecondaryContainer: AppColors.onSecondaryContainerDark, // M3: onSecondaryContainer
        tertiary: AppColors.tertiaryDark, // M3: tertiary
        onTertiary: AppColors.onTertiaryDark, // M3: onTertiary
        tertiaryContainer: AppColors.tertiaryContainerDark, // M3: tertiaryContainer
        onTertiaryContainer: AppColors.onTertiaryContainerDark, // M3: onTertiaryContainer
        error: AppColors.errorDarkM3, // M3: error (#FFB4AB)
        onError: AppColors.onErrorDarkM3, // M3: onError (#690005)
        errorContainer: AppColors.errorContainerDark, // M3: errorContainer (#93000A)
        onErrorContainer: AppColors.onErrorContainerDark, // M3: onErrorContainer (#FFDAD6)
        surface: AppColors.darkScaffoldBackground, // M3: surface (main background - using darkScaffoldBackground)
        onSurface: AppColors.darkText, // M3: onSurface
        surfaceDim: AppColors.surfaceDimDark, // M3: surfaceDim
        surfaceBright: AppColors.surfaceBrightDark, // M3: surfaceBright
        surfaceContainerLowest: AppColors.surfaceContainerLowestDark, // M3: surfaceContainerLowest
        surfaceContainerLow: AppColors.surfaceContainerLowDark, // M3: surfaceContainerLow (using darkBackground)
        surfaceContainer: AppColors.surfaceContainerDark, // M3: surfaceContainer (for cards - using darkSurface)
        surfaceContainerHigh: AppColors.surfaceContainerHighDark, // M3: surfaceContainerHigh
        surfaceContainerHighest: AppColors.surfaceContainerHighestDark, // M3: surfaceVariant
        onSurfaceVariant: AppColors.onSurfaceVariantDark, // M3: onSurfaceVariant
        outline: AppColors.outlineDark, // M3: outline
        outlineVariant: AppColors.outlineVariantDark, // M3: outlineVariant
        inverseSurface: AppColors.lightScaffoldBackground, // M3: inverseSurface (light theme's scaffold)
        onInverseSurface: AppColors.lightText, // M3: onInverseSurface (light theme's text)
        inversePrimary: AppColors.primaryColor, // M3: inversePrimary (light theme's primary)
        shadow: AppColors.shadowColor, // M3: shadow
        scrim: Colors.black.withAlpha(102), // M3: scrim (Standard ~40% opacity black for dark)
        surfaceTint: AppColors.primaryColorDark, // M3: surfaceTint (typically primary color for dark theme)
      ),
      Brightness.dark);

  static ThemeData themeFromSeed(
      {required Color seedColor, required Brightness brightness}) {
    final colorScheme =
        ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    return buildThemeDataFromScheme(colorScheme, brightness);
  }

  // Static style for Filled Tonal Button
  static ButtonStyle filledButtonTonalStyle(ColorScheme colorScheme, TextTheme textTheme) {
    return FilledButton.styleFrom(
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
      textStyle: textTheme.labelLarge,
      minimumSize: Size(0, 40.h),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    );
  }

  // Static CardTheme for Elevated Card
  static CardTheme cardThemeElevated(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 1.0,
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.r))),
    );
  }

  // Static CardTheme for Outlined Card
  static CardTheme cardThemeOutlined(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 0.0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    );
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
    final m3BaseTextTheme =
        GoogleFonts.robotoTextTheme(baseTextTheme); // Using Roboto as specified

    // Create the M3 TextTheme with updated font sizes, weights, letter spacing, and line heights
    final TextTheme m3TextTheme = m3BaseTextTheme.copyWith(
      displayLarge: m3BaseTextTheme.displayLarge?.copyWith(
          fontSize: 57.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 64.0 / 57.0,
          color: colorScheme.onSurface),
      displayMedium: m3BaseTextTheme.displayMedium?.copyWith(
          fontSize: 45.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 52.0 / 45.0,
          color: colorScheme.onSurface),
      displaySmall: m3BaseTextTheme.displaySmall?.copyWith(
          fontSize: 36.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 44.0 / 36.0,
          color: colorScheme.onSurface),
      headlineLarge: m3BaseTextTheme.headlineLarge?.copyWith(
          fontSize: 32.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 40.0 / 32.0,
          color: colorScheme.onSurface),
      headlineMedium: m3BaseTextTheme.headlineMedium?.copyWith(
          fontSize: 28.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 36.0 / 28.0,
          color: colorScheme.onSurface),
      headlineSmall: m3BaseTextTheme.headlineSmall?.copyWith(
          fontSize: 24.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 32.0 / 24.0,
          color: colorScheme.onSurface),
      titleLarge: m3BaseTextTheme.titleLarge?.copyWith(
          fontSize: 22.sp,
          fontWeight: FontWeight.w400, // M3 spec can vary; 400 is common for titles.
          letterSpacing: 0,
          height: 28.0 / 22.0,
          color: colorScheme.onSurface), // Often used for AppBars
      titleMedium: m3BaseTextTheme.titleMedium?.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15.sp,
          height: 24.0 / 16.0,
          color: colorScheme.onSurface),
      titleSmall: m3BaseTextTheme.titleSmall?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1.sp,
          height: 20.0 / 14.0,
          color: colorScheme.onSurface),
      bodyLarge: m3BaseTextTheme.bodyLarge?.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5.sp, // Current: 0.5sp, M3 spec also shows 0.15 for some. Kept 0.5.
          height: 24.0 / 16.0,
          color: colorScheme.onSurface),
      bodyMedium: m3BaseTextTheme.bodyMedium?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25.sp,
          height: 20.0 / 14.0,
          color: colorScheme.onSurfaceVariant), // M3 bodyMedium is often onSurfaceVariant
      bodySmall: m3BaseTextTheme.bodySmall?.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4.sp,
          height: 16.0 / 12.0,
          color: colorScheme.onSurfaceVariant), // M3 bodySmall is often onSurfaceVariant
      labelLarge: m3BaseTextTheme.labelLarge?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1.sp,
          height: 20.0 / 14.0,
          color: colorScheme.onPrimary), // Used in ElevatedButtons
      labelMedium: m3BaseTextTheme.labelMedium?.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5.sp,
          height: 16.0 / 12.0,
          color: colorScheme.onSurfaceVariant),
      labelSmall: m3BaseTextTheme.labelSmall?.copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5.sp,
          height: 16.0 / 11.0,
          color: colorScheme.onSurfaceVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary, // M2 compatibility
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        elevation:
            0, // M3 default elevation is 0, relies on surfaceTint for scroll edge
        backgroundColor: colorScheme.surface, // M3 default is surface
        surfaceTintColor: colorScheme.surfaceTint,
        iconTheme: IconThemeData(
            color: colorScheme.onSurfaceVariant), // Icons on app bar
        titleTextStyle: m3TextTheme.titleLarge, // Use fully defined M3 titleLarge
      ),
      textTheme: m3TextTheme, // Assign the fully M3-compliant textTheme
      // --- Button Themes ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(0, 40.h)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w)),
          textStyle: WidgetStateProperty.all(m3TextTheme.labelLarge?.copyWith(color: colorScheme.primary)),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha:0.12);
            }
            return colorScheme.surface; // Enabled
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha:0.38);
            }
            return colorScheme.primary; // Enabled
          }),
          surfaceTintColor: WidgetStateProperty.all(colorScheme.primary),
          elevation: WidgetStateProperty.resolveWith<double?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return 2.0; // M3 spec suggests a slight increase on hover for elevated
            }
            if (states.contains(WidgetState.pressed)) {
              return 1.0; // M3 spec often has same or slightly different for pressed
            }
            return 1.0; // Default enabled elevation
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(0, 40.h)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w)),
          textStyle: WidgetStateProperty.all(m3TextTheme.labelLarge), // labelLarge color is onPrimary
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha:0.12);
            }
            return colorScheme.primary; // Enabled
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha:0.38);
            }
            return colorScheme.onPrimary; // Enabled
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(0, 40.h)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w)),
          textStyle: WidgetStateProperty.all(m3TextTheme.labelLarge?.copyWith(color: colorScheme.primary)),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            // Outlined buttons typically don't change background color with states like hover/pressed
            // unless a specific overlay is applied, which is handled by default by Flutter's ButtonStyleButton.
            return Colors.transparent; // Always transparent background
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha:0.38);
            }
            return colorScheme.primary; // Enabled
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: colorScheme.onSurface.withValues(alpha:0.12));
            }
            if (states.contains(WidgetState.focused)) { // M3 focus indicator for outlined can be stronger border
              return BorderSide(color: colorScheme.primary, width: 1.0); // Example, M3 might use a thicker outline or an overlay
            }
            return BorderSide(color: colorScheme.outline); // Enabled
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(0, 40.h)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w)),
          textStyle: WidgetStateProperty.all(m3TextTheme.labelLarge?.copyWith(color: colorScheme.primary)),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha:0.38);
            }
            return colorScheme.primary; // Enabled
          }),
        ),
      ),

      // --- InputDecorationTheme (for TextFields) ---
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h), // M3 default is often 16dp symmetric
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)), // M3 ExtraSmall
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha:0.12), width: 1.0),
        ),
        labelStyle: m3TextTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: m3TextTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle: m3TextTheme.bodySmall?.copyWith(color: colorScheme.error),
      ),

      // --- CardTheme (Defaulting to M3 Filled Card style) ---
      cardTheme: CardThemeData(
        elevation: 0.0,
        color: colorScheme.surfaceContainer, // M3 Filled Card color
        surfaceTintColor: Colors.transparent, // M3 Filled cards often don't show tint
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.r))), // M3 "Medium" radius
      ),

      iconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant), // Default icon color

      // --- FloatingActionButton ---
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3.0, // M3 FABs standard elevation (level 3)
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)), // M3 "Medium" shape category for standard FAB
        extendedTextStyle: m3TextTheme.labelLarge?.copyWith(color: colorScheme.onPrimaryContainer), // Ensure color matches foregroundColor
      ),

      // --- DialogTheme ---
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: 6.0, // M3 Dialog elevation (level 3 = 6dp)
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r)), // M3 "ExtraLarge" shape
        titleTextStyle: m3TextTheme.headlineSmall, // Already has onSurface color from m3TextTheme
        contentTextStyle: m3TextTheme.bodyMedium, // Already has onSurfaceVariant color from m3TextTheme
      ),

      // --- BottomSheetTheme ---
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer, // M3 modal bottom sheet uses surfaceContainer
        modalBackgroundColor: colorScheme.surfaceContainer,
        elevation: 6.0, // M3 modal bottom sheet elevation (level 3 = 6dp)
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(28.r)) // M3 "ExtraLarge" top corners
            ),
        // surfaceTintColor: colorScheme.surfaceTint, // Optional: if elevation tint is desired
      ),

      // --- ChipTheme --- (Defaulting to M3 Assist chip - outlined style)
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface, // M3 Assist chip (outlined) background
        labelStyle: m3TextTheme.labelLarge?.copyWith(color: colorScheme.onSurface), // M3 uses onSurface for outlined assist chip text
        side: BorderSide(color: colorScheme.outline), // M3 Outlined Assist chip
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r)), // M3 "Small" shape
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        iconTheme: IconThemeData(
            color: colorScheme.primary, // Leading icon for assist chip
            size: 18.sp),
        showCheckmark: false, // Default for assist chips
        // selectedColor: colorScheme.secondaryContainer, // For Filter chips (selected state)
        // deleteIconColor: colorScheme.onSecondaryContainer, // For Input chips (if using them)
      ),

      // --- NavigationBarTheme ---
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer, // M3 default Navigation Bar
        indicatorColor: colorScheme.secondaryContainer, // Indicator for selected item
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onSecondaryContainer); // Icon color for selected
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant); // Icon color for unselected
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((Set<WidgetState> states) {
          final style = m3TextTheme.labelMedium!; // M3 uses labelMedium
          if (states.contains(WidgetState.selected)) {
            return style.copyWith(color: colorScheme.onSurface); // Text color for selected
          }
          return style.copyWith(color: colorScheme.onSurfaceVariant); // Text color for unselected
        }),
        height: 80.h, // M3 Navigation Bar height is 80dp
        elevation: 2.0, // M3 Navigation Bar default elevation (level 2 = 3dp, but Flutter M3 default is 2.0)
      ),

      // --- ListTileTheme ---
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        titleTextStyle: m3TextTheme.bodyLarge, // M3 default for main text in a ListTile
        subtitleTextStyle: m3TextTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        dense: false,
        shape: null, // Standard is rectangular
        contentPadding: null, // Use M3 defaults (typically EdgeInsets.symmetric(horizontal: 16.0))
      ),

      // --- DropdownMenuTheme ---
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: m3TextTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), // Text in the field itself
        // inputDecorationTheme: a specific one if needed, else global is used.
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
          elevation: WidgetStateProperty.all(3.0), // M3 menu elevation
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r))),
          // Minimum width of the menu should match the width of the DropdownMenu.
          // Maximum height could be constrained too.
        ),
      ),

      // --- DatePickerTheme ---
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        headerBackgroundColor: colorScheme.surfaceContainerHigh, // M3 often uses surface for header
        headerForegroundColor: colorScheme.onSurfaceVariant, // For "Select date" text
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        dayStyle: m3TextTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        weekdayStyle: m3TextTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        yearStyle: m3TextTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        todayBorder: BorderSide(color: colorScheme.primary),
        todayForegroundColor: WidgetStateProperty.all(colorScheme.primary),
        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.38);
          }
          // Today's date, not selected
          if (states.contains(WidgetState.today) && !states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurface; // Default
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent; // Default
        }),
        // Other properties like `dayOverlayColor`, `yearForegroundColor`, `yearBackgroundColor` can be set if needed.
      ),

      // --- TimePickerTheme ---
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        hourMinuteColor: colorScheme.surfaceContainerHighest, // M3 uses a slightly different surface for time inputs
        hourMinuteTextColor: colorScheme.onSurface,
        dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        dayPeriodColor: colorScheme.surfaceContainerHighest, // Background for AM/PM
        dayPeriodTextColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimaryContainer; // Or onPrimary if dayPeriodColor was primary
          }
          return colorScheme.onSurfaceVariant; // Unselected
        }),
        dayPeriodBorderSide: BorderSide.none, // M3 often has no border for day period toggle
        dialHandColor: colorScheme.primary,
        dialBackgroundColor: colorScheme.surfaceContainerHighest, // Background of the dial
        dialTextColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary; // Text on the selected dial item (on hand)
          }
          return colorScheme.onSurface; // Text on unselected dial items
        }),
        // `dialItemColor` might be needed for the inner circle of selected item on dial
        helpTextStyle: m3TextTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant), // For "Select time" or "Enter time"
        // inputDecorationTheme for TimePickerEntryMode.input can be inherited or specified
      ),
    );
  }
}
