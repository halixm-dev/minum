// lib/src/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:minum/src/core/constants/app_colors.dart'; // Removed as per instructions

class AppTheme {
  AppTheme._(); // Private constructor

  // Define base TextThemes
  static final TextTheme _lightTextTheme = GoogleFonts.robotoTextTheme(ThemeData.light().textTheme);
  static final TextTheme _darkTextTheme = GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme);

  // Create MaterialTheme instances
  static final MaterialTheme _lightMaterialTheme = MaterialTheme(_lightTextTheme);
  static final MaterialTheme _darkMaterialTheme = MaterialTheme(_darkTextTheme);

  // Static ThemeData getters using MaterialTheme
  static ThemeData get lightTheme => _lightMaterialTheme.light();
  static ThemeData get darkTheme => _darkMaterialTheme.dark();

  static ThemeData get lightMediumContrastTheme => _lightMaterialTheme.lightMediumContrast();
  static ThemeData get lightHighContrastTheme => _lightMaterialTheme.lightHighContrast();
  static ThemeData get darkMediumContrastTheme => _darkMaterialTheme.darkMediumContrast();
  static ThemeData get darkHighContrastTheme => _darkMaterialTheme.darkHighContrast();
  

  static ThemeData themeFromSeed(
      {required Color seedColor, required Brightness brightness}) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    // Create a base TextTheme based on brightness for themeFromSeed
    final baseTextTheme = brightness == Brightness.light
        ? GoogleFonts.robotoTextTheme(ThemeData.light().textTheme)
        : GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme);
    return buildThemeDataFromScheme(colorScheme, baseTextTheme);
  }

  // Static style for Filled Tonal Button
  static ButtonStyle filledButtonTonalStyle(
      ColorScheme colorScheme, TextTheme textTheme) {
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.r))),
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

  // Updated to accept a TextTheme instead of Brightness
  static ThemeData buildThemeDataFromScheme(
      ColorScheme colorScheme, TextTheme baseTheme) {
    // Brightness can be derived from the colorScheme
    final brightness = colorScheme.brightness;
    
    // The provided baseTheme is already a GoogleFonts.robotoTextTheme via MaterialTheme instance
    // or explicitly created in themeFromSeed.
    // So, m3BaseTextTheme is effectively the passed 'baseTheme'.
    final TextTheme m3TextTheme = baseTheme.copyWith( // Apply color scheme specific colors to the passed text theme
      displayLarge: baseTheme.displayLarge?.copyWith(
          fontSize: 57.sp, // These sizes are examples, ensure they match your m3BaseTextTheme
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 64.0 / 57.0,
          color: colorScheme.onSurface),
      displayMedium: baseTheme.displayMedium?.copyWith(
          fontSize: 45.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 52.0 / 45.0,
          color: colorScheme.onSurface),
      displaySmall: baseTheme.displaySmall?.copyWith(
          fontSize: 36.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 44.0 / 36.0,
          color: colorScheme.onSurface),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
          fontSize: 32.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 40.0 / 32.0,
          color: colorScheme.onSurface),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
          fontSize: 28.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 36.0 / 28.0,
          color: colorScheme.onSurface),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
          fontSize: 24.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 32.0 / 24.0,
          color: colorScheme.onSurface),
      titleLarge: baseTheme.titleLarge?.copyWith(
          fontSize: 22.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 28.0 / 22.0,
          color: colorScheme.onSurface),
      titleMedium: baseTheme.titleMedium?.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15.sp,
          height: 24.0 / 16.0,
          color: colorScheme.onSurface),
      titleSmall: baseTheme.titleSmall?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1.sp,
          height: 20.0 / 14.0,
          color: colorScheme.onSurface),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5.sp,
          height: 24.0 / 16.0,
          color: colorScheme.onSurface),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25.sp,
          height: 20.0 / 14.0,
          color: colorScheme.onSurfaceVariant),
      bodySmall: baseTheme.bodySmall?.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4.sp,
          height: 16.0 / 12.0,
          color: colorScheme.onSurfaceVariant),
      labelLarge: baseTheme.labelLarge?.copyWith( // Used for buttons etc.
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1.sp,
          height: 20.0 / 14.0,
          color: colorScheme.onPrimary), // Example, check if this is always onPrimary or varies
      labelMedium: baseTheme.labelMedium?.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5.sp,
          height: 16.0 / 12.0,
          color: colorScheme.onSurfaceVariant),
      labelSmall: baseTheme.labelSmall?.copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5.sp,
          height: 16.0 / 11.0,
          color: colorScheme.onSurfaceVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness, // Derived from colorScheme
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
        titleTextStyle:
            m3TextTheme.titleLarge, // Use fully defined M3 titleLarge
      ),
      textTheme: m3TextTheme, // Assign the fully M3-compliant textTheme
      // --- Button Themes ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(0, 40.h)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r))),
          padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w)),
          textStyle: WidgetStateProperty.all(
              m3TextTheme.labelLarge?.copyWith(color: colorScheme.primary)),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.12);
            }
            return colorScheme.surface; // Enabled
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return colorScheme.primary; // Enabled
          }),
          surfaceTintColor: WidgetStateProperty.all(colorScheme.primary),
          elevation: WidgetStateProperty.resolveWith<double?>(
              (Set<WidgetState> states) {
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
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r))),
          padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w)),
          textStyle: WidgetStateProperty.all(
              m3TextTheme.labelLarge), // labelLarge color is onPrimary
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.12);
            }
            return colorScheme.primary; // Enabled
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return colorScheme.onPrimary; // Enabled
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(0, 40.h)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r))),
          padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w)),
          textStyle: WidgetStateProperty.all(
              m3TextTheme.labelLarge?.copyWith(color: colorScheme.primary)),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            // Outlined buttons typically don't change background color with states like hover/pressed
            // unless a specific overlay is applied, which is handled by default by Flutter's ButtonStyleButton.
            return Colors.transparent; // Always transparent background
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return colorScheme.primary; // Enabled
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.12));
            }
            if (states.contains(WidgetState.focused)) {
              // M3 focus indicator for outlined can be stronger border
              return BorderSide(
                  color: colorScheme.primary,
                  width:
                      1.0); // Example, M3 might use a thicker outline or an overlay
            }
            return BorderSide(color: colorScheme.outline); // Enabled
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(0, 40.h)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r))),
          padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w)),
          textStyle: WidgetStateProperty.all(
              m3TextTheme.labelLarge?.copyWith(color: colorScheme.primary)),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            return colorScheme.primary; // Enabled
          }),
        ),
      ),

      // --- InputDecorationTheme (for TextFields) ---
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h), // M3 default is often 16dp symmetric
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
          borderSide: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.12), width: 1.0),
        ),
        labelStyle: m3TextTheme.bodyLarge
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: m3TextTheme.bodyLarge
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle: m3TextTheme.bodySmall?.copyWith(color: colorScheme.error),
      ),

      // --- CardTheme (Defaulting to M3 Filled Card style) ---
      cardTheme: CardThemeData(
        elevation: 0.0,
        color: colorScheme.surfaceContainer, // M3 Filled Card color
        surfaceTintColor:
            Colors.transparent, // M3 Filled cards often don't show tint
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(12.r))), // M3 "Medium" radius
      ),

      iconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant), // Default icon color

      // --- FloatingActionButton ---
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3.0, // M3 FABs standard elevation (level 3)
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                16.r)), // M3 "Medium" shape category for standard FAB
        extendedTextStyle: m3TextTheme.labelLarge?.copyWith(
            color: colorScheme
                .onPrimaryContainer), // Ensure color matches foregroundColor
      ),

      // --- DialogTheme ---
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: 6.0, // M3 Dialog elevation (level 3 = 6dp)
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r)), // M3 "ExtraLarge" shape
        titleTextStyle: m3TextTheme
            .headlineSmall, // Already has onSurface color from m3TextTheme
        contentTextStyle: m3TextTheme
            .bodyMedium, // Already has onSurfaceVariant color from m3TextTheme
      ),

      // --- BottomSheetTheme ---
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme
            .surfaceContainer, // M3 modal bottom sheet uses surfaceContainer
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
        backgroundColor:
            colorScheme.surface, // M3 Assist chip (outlined) background
        labelStyle: m3TextTheme.labelLarge?.copyWith(
            color: colorScheme
                .onSurface), // M3 uses onSurface for outlined assist chip text
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
        backgroundColor:
            colorScheme.surfaceContainer, // M3 default Navigation Bar
        indicatorColor:
            colorScheme.secondaryContainer, // Indicator for selected item
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
                color: colorScheme
                    .onSecondaryContainer); // Icon color for selected
          }
          return IconThemeData(
              color: colorScheme.onSurfaceVariant); // Icon color for unselected
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
          final style = m3TextTheme.labelMedium!; // M3 uses labelMedium
          if (states.contains(WidgetState.selected)) {
            return style.copyWith(
                color: colorScheme.onSurface); // Text color for selected
          }
          return style.copyWith(
              color: colorScheme.onSurfaceVariant); // Text color for unselected
        }),
        height: 80.h, // M3 Navigation Bar height is 80dp
        elevation:
            2.0, // M3 Navigation Bar default elevation (level 2 = 3dp, but Flutter M3 default is 2.0)
      ),

      // --- ListTileTheme ---
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        titleTextStyle:
            m3TextTheme.bodyLarge, // M3 default for main text in a ListTile
        subtitleTextStyle: m3TextTheme.bodyMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        dense: false,
        shape: null, // Standard is rectangular
        contentPadding:
            null, // Use M3 defaults (typically EdgeInsets.symmetric(horizontal: 16.0))
      ),

      // --- DropdownMenuTheme ---
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: m3TextTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface), // Text in the field itself
        // inputDecorationTheme: a specific one if needed, else global is used.
        menuStyle: MenuStyle(
          backgroundColor:
              WidgetStateProperty.all(colorScheme.surfaceContainer),
          elevation: WidgetStateProperty.all(3.0), // M3 menu elevation
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r))),
          // Minimum width of the menu should match the width of the DropdownMenu.
          // Maximum height could be constrained too.
        ),
      ),

      // --- DatePickerTheme ---
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        headerBackgroundColor: colorScheme
            .surfaceContainerHigh, // M3 often uses surface for header
        headerForegroundColor:
            colorScheme.onSurfaceVariant, // For "Select date" text
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        dayStyle:
            m3TextTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        weekdayStyle: m3TextTheme.bodySmall
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        yearStyle:
            m3TextTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        todayBorder: BorderSide(
            color: colorScheme.primary), // Styles today's date border
        todayForegroundColor: WidgetStateProperty.all(colorScheme
            .primary), // Styles today's date text color if not selected
        todayBackgroundColor: WidgetStateProperty.all(Colors
            .transparent), // Ensure today (not selected) has no specific background unless desired
        dayForegroundColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            // For selected days (including if today is selected)
            return colorScheme.onPrimary;
          }
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          // For "today" specifically when it's not selected, todayForegroundColor handles it.
          // This is for other, non-today, non-selected, non-disabled days.
          return colorScheme.onSurface; // Default text color for other days
        }),
        dayBackgroundColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            // For selected days (including if today is selected)
            return colorScheme.primary;
          }
          // No specific background for other days (including today if not selected)
          return Colors.transparent;
        }),
        // Ensure other properties like headerForegroundColor, backgroundColor etc. are direct Color values:
        // headerForegroundColor: colorScheme.onSurfaceVariant, // Already correct from previous step
        // backgroundColor: colorScheme.surfaceContainerHigh, // Already correct
      ),

      // --- TimePickerTheme ---
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        hourMinuteShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        hourMinuteColor: colorScheme
            .surfaceContainerHighest, // M3 uses a slightly different surface for time inputs
        hourMinuteTextColor: colorScheme.onSurface,
        dayPeriodShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        dayPeriodColor:
            colorScheme.surfaceContainerHighest, // Background for AM/PM
        dayPeriodTextColor: colorScheme.onPrimaryContainer,
        dayPeriodBorderSide:
            BorderSide.none, // M3 often has no border for day period toggle
        dialHandColor: colorScheme.primary,
        dialBackgroundColor:
            colorScheme.surfaceContainerHighest, // Background of the dial
        dialTextColor: colorScheme.onPrimary,
        // `dialItemColor` might be needed for the inner circle of selected item on dial
        helpTextStyle: m3TextTheme.labelSmall?.copyWith(
            color: colorScheme
                .onSurfaceVariant), // For "Select time" or "Enter time"
        // inputDecorationTheme for TimePickerEntryMode.input can be inherited or specified
      ),
    );
  }
}

// --- ExtendedColor and ColorFamily Classes (as provided in issue) ---
class ExtendedColor {
  final Color seed, vibrant, vibrantTonal, onVibrant, onVibrantTonal;
  ExtendedColor({
    required this.seed,
    required this.vibrant,
    required this.vibrantTonal,
    required this.onVibrant,
    required this.onVibrantTonal,
  });
}

class ColorFamily {
  final Color color;
  final Color onColor;
  final Color container;
  final Color onContainer;
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.container,
    required this.onContainer,
  });
}

// --- MaterialTheme Class ---
class MaterialTheme {
  final TextTheme textTheme;
  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF006A60),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF74F8E5),
      onPrimaryContainer: Color(0xFF00201C),
      secondary: Color(0xFF4A635F),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFCCE8E2),
      onSecondaryContainer: Color(0xFF05201C),
      tertiary: Color(0xFF456179),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFCCE5FF),
      onTertiaryContainer: Color(0xFF001E31),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFF4FAF8),
      onSurface: Color(0xFF161D1B),
      surfaceContainerHighest: Color(0xFFDAE5E1),
      onSurfaceVariant: Color(0xFF3F4946),
      outline: Color(0xFF6F7976),
      outlineVariant: Color(0xFFBEC9C5),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2B3230),
      onInverseSurface: Color(0xFFECF2EF),
      inversePrimary: Color(0xFF53DBC9),
      surfaceTint: Color(0xFF006A60),
      // Custom Colors
      // vibrant: Color(0xFF3F51B5), // Example - replace with actual if needed
      // onVibrant: Color(0xFFFFFFFF),
      // vibrantTonal: Color(0xFFC5CAE9),
      // onVibrantTonal: Color(0xFF1A237E),
    );
  }

  ThemeData light() => theme(lightScheme());

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF004C45),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF008375),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFF2E4844),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF607A75),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFF2A465D),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF5C7890),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFF8C0009),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFDA342E),
      onErrorContainer: Color(0xFFFFFFFF),
      surface: Color(0xFFF4FAF8),
      onSurface: Color(0xFF161D1B),
      surfaceContainerHighest: Color(0xFFDAE5E1),
      onSurfaceVariant: Color(0xFF3B4543),
      outline: Color(0xFF57615E),
      outlineVariant: Color(0xFF737D7A),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2B3230),
      onInverseSurface: Color(0xFFECF2EF),
      inversePrimary: Color(0xFF53DBC9),
      surfaceTint: Color(0xFF006A60),
    );
  }

  ThemeData lightMediumContrast() => theme(lightMediumContrastScheme());

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF002824),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF004C45),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFF0D2724),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF2E4844),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFF05263C),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF2A465D),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFF4E0002),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFF8C0009),
      onErrorContainer: Color(0xFFFFFFFF),
      surface: Color(0xFFF4FAF8),
      onSurface: Color(0xFF000000),
      surfaceContainerHighest: Color(0xFFBFCED8), // Adjusted, was DAE5E1
      onSurfaceVariant: Color(0xFF1E2624),
      outline: Color(0xFF3B4543),
      outlineVariant: Color(0xFF3B4543), // Same as outline
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2B3230), // Needs re-evaluation for high contrast
      onInverseSurface: Color(0xFFFFFFFF), // Needs re-evaluation
      inversePrimary: Color(0xFF84FFF0), // Adjusted, was 53DBC9
      surfaceTint: Color(0xFF006A60),
    );
  }

  ThemeData lightHighContrast() => theme(lightHighContrastScheme());

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF53DBC9),
      onPrimary: Color(0xFF003731),
      primaryContainer: Color(0xFF005048),
      onPrimaryContainer: Color(0xFF74F8E5),
      secondary: Color(0xFFB0CCC6),
      onSecondary: Color(0xFF1C3531),
      secondaryContainer: Color(0xFF324B47),
      onSecondaryContainer: Color(0xFFCCE8E2),
      tertiary: Color(0xFFADC9E5),
      onTertiary: Color(0xFF153349),
      tertiaryContainer: Color(0xFF2D4A61),
      onTertiaryContainer: Color(0xFFCCE5FF),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF161D1B),
      onSurface: Color(0xFFDAE5E1),
      surfaceContainerHighest: Color(0xFF3A4643), // Adjusted, was 3F4946
      onSurfaceVariant: Color(0xFFBEC9C5),
      outline: Color(0xFF899390),
      outlineVariant: Color(0xFF3F4946),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFDAE5E1),
      onInverseSurface: Color(0xFF2B3230), // Adjusted, was 161D1B
      inversePrimary: Color(0xFF006A60),
      surfaceTint: Color(0xFF53DBC9),
    );
  }

  ThemeData dark() => theme(darkScheme());

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF56E0CD),
      onPrimary: Color(0xFF001B18),
      primaryContainer: Color(0xFF06A393),
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFFB4D0CA),
      onSecondary: Color(0xFF001B18),
      secondaryContainer: Color(0xFF7C9792),
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFFB1CDE9),
      onTertiary: Color(0xFF00182A),
      tertiaryContainer: Color(0xFF7693AF),
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFFFBAB1),
      onError: Color(0xFF370001),
      errorContainer: Color(0xFFFF5449),
      onErrorContainer: Color(0xFF000000),
      surface: Color(0xFF161D1B),
      onSurface: Color(0xFFF2FCF9), // Adjusted, was DAE5E1
      surfaceContainerHighest: Color(0xFF46524F), // Adjusted, was 3A4643
      onSurfaceVariant: Color(0xFFC2CDC9), // Adjusted, was BEC9C5
      outline: Color(0xFFA0ABA7), // Adjusted, was 899390
      outlineVariant: Color(0xFF808D8A), // Adjusted, was 737D7A -> 3F4946
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFDAE5E1),
      onInverseSurface: Color(0xFF252C2A), // Adjusted, was 2B3230
      inversePrimary: Color(0xFF00524A), // Adjusted, was 006A60
      surfaceTint: Color(0xFF53DBC9),
    );
  }

  ThemeData darkMediumContrast() => theme(darkMediumContrastScheme());

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFF1FFFC),
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFF56E0CD),
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFFF1FFFC),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFFB4D0CA),
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFFF3FBFF),
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFFB1CDE9),
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFFFF9F9),
      onError: Color(0xFF000000),
      errorContainer: Color(0xFFFFBAB1),
      onErrorContainer: Color(0xFF000000),
      surface: Color(0xFF161D1B),
      onSurface: Color(0xFFFFFFFF),
      surfaceContainerHighest: Color(0xFFBFCED8), // Adjusted, was 46524F
      onSurfaceVariant: Color(0xFFF1FFFC), // Adjusted, was C2CDC9
      outline: Color(0xFFC2CDC9), // Adjusted, was A0ABA7
      outlineVariant: Color(0xFFC2CDC9), // Same as outline
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFDAE5E1), // Needs re-evaluation
      onInverseSurface: Color(0xFF000000), // Needs re-evaluation
      inversePrimary: Color(0xFF00302A), // Adjusted
      surfaceTint: Color(0xFF53DBC9),
    );
  }

  ThemeData darkHighContrast() => theme(darkHighContrastScheme());

  ThemeData theme(ColorScheme colorScheme) {
    // This will call AppTheme.buildThemeDataFromScheme
    // The textTheme from the MaterialTheme instance will be used.
    // AppTheme.buildThemeDataFromScheme already handles applying bodyColor and displayColor
    // from the colorScheme to the textTheme.    
    // The `textTheme` parameter of MaterialTheme's constructor is expected to be a 
    // GoogleFonts.robotoTextTheme-ified TextTheme.
    // `buildThemeDataFromScheme` then takes this, and applies color scheme specific colors.
    return AppTheme.buildThemeDataFromScheme(colorScheme, textTheme);
  }
}
