// lib/src/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A utility class for creating and managing Material 3 themes.
///
/// This class provides static methods to generate `ThemeData` for light, dark,
/// and contrast themes, as well as themes from a seed color. It encapsulates
/// the logic for color schemes, text themes, and component styles.
class AppTheme {
  /// Private constructor to prevent instantiation.
  AppTheme._();

  // Define base TextThemes
  static final TextTheme _lightTextTheme =
      GoogleFonts.robotoTextTheme(ThemeData.light().textTheme);
  static final TextTheme _darkTextTheme =
      GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme);

  // Create MaterialTheme instances
  static final MaterialTheme _lightMaterialTheme =
      MaterialTheme(_lightTextTheme);
  static final MaterialTheme _darkMaterialTheme = MaterialTheme(_darkTextTheme);

  // Static ThemeData getters using MaterialTheme
  /// The default light theme for the application.
  static ThemeData get lightTheme => _lightMaterialTheme.light();

  /// The default dark theme for the application.
  static ThemeData get darkTheme => _darkMaterialTheme.dark();

  /// A medium contrast light theme.
  static ThemeData get lightMediumContrastTheme =>
      _lightMaterialTheme.lightMediumContrast();

  /// A high contrast light theme.
  static ThemeData get lightHighContrastTheme =>
      _lightMaterialTheme.lightHighContrast();

  /// A medium contrast dark theme.
  static ThemeData get darkMediumContrastTheme =>
      _darkMaterialTheme.darkMediumContrast();

  /// A high contrast dark theme.
  static ThemeData get darkHighContrastTheme =>
      _darkMaterialTheme.darkHighContrast();

  /// Creates a `ThemeData` object from a seed color and brightness.
  ///
  /// The [seedColor] is used to generate a `ColorScheme`.
  /// The [brightness] determines whether to use a light or dark theme.
  /// @return A `ThemeData` object.
  static ThemeData themeFromSeed(
      {required Color seedColor, required Brightness brightness}) {
    final colorScheme =
        ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    // Create a base TextTheme based on brightness for themeFromSeed
    final baseTextTheme = brightness == Brightness.light
        ? GoogleFonts.robotoTextTheme(ThemeData.light().textTheme)
        : GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme);
    return buildThemeDataFromScheme(colorScheme, baseTextTheme);
  }

  /// Creates a `ButtonStyle` for a filled tonal button.
  ///
  /// The [colorScheme] and [textTheme] are used to style the button.
  /// @return A `ButtonStyle` object.
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

  /// Creates a `CardThemeData` for an elevated card.
  ///
  /// The [colorScheme] is used to style the card.
  /// @return A `CardThemeData` object.
  static CardThemeData cardThemeElevated(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 1.0,
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.r))),
    );
  }

  /// Creates a `CardThemeData` for an outlined card.
  ///
  /// The [colorScheme] is used to style the card.
  /// @return A `CardThemeData` object.
  static CardThemeData cardThemeOutlined(ColorScheme colorScheme) {
    return CardThemeData(
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

  /// Builds a `ThemeData` object from a `ColorScheme` and a base `TextTheme`.
  ///
  /// This is the main workhorse method for creating themes. It configures all
  /// the component themes based on the provided color scheme and text theme.
  ///
  /// The [colorScheme] defines the colors for the theme.
  /// The [baseTheme] defines the base typography for the theme.
  /// @return A fully configured `ThemeData` object.
  static ThemeData buildThemeDataFromScheme(
      ColorScheme colorScheme, TextTheme baseTheme) {
    // Brightness can be derived from the colorScheme
    final brightness = colorScheme.brightness;

    // The provided baseTheme is already a GoogleFonts.robotoTextTheme via MaterialTheme instance
    // or explicitly created in themeFromSeed.
    // So, m3BaseTextTheme is effectively the passed 'baseTheme'.
    final TextTheme m3TextTheme = baseTheme.copyWith(
      // Apply color scheme specific colors to the passed text theme
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
      labelLarge: baseTheme.labelLarge?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1.sp,
          height: 20.0 / 14.0,
          color: colorScheme.onPrimary),
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
              return colorScheme.onSurface.withAlpha(31);
            }
            return colorScheme.surface; // Enabled
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withAlpha(97);
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
              return colorScheme.onSurface.withAlpha(31);
            }
            return colorScheme.primary; // Enabled
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withAlpha(97);
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
              return colorScheme.onSurface.withAlpha(97);
            }
            return colorScheme.primary; // Enabled
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(
                  color: colorScheme.onSurface.withAlpha(31));
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
              return colorScheme.onSurface.withAlpha(97);
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
              color: colorScheme.onSurface.withAlpha(31), width: 1.0),
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
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(28.0)) // M3 "ExtraLarge" top corners
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
            return colorScheme.onSurface.withAlpha(97);
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
        dialTextColor: colorScheme.onSurface,
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
/// A class that holds a set of related colors for a custom color scheme.
class ExtendedColor {
  /// The seed color used to generate the other colors.
  final Color seed;
  /// A vibrant color.
  final Color vibrant;
  /// A tonal variant of the vibrant color.
  final Color vibrantTonal;
  /// A color that is easy to see on top of [vibrant].
  final Color onVibrant;
  /// A color that is easy to see on top of [vibrantTonal].
  final Color onVibrantTonal;

  /// Creates an `ExtendedColor` object.
  ExtendedColor({
    required this.seed,
    required this.vibrant,
    required this.vibrantTonal,
    required this.onVibrant,
    required this.onVibrantTonal,
  });
}

/// A class that holds a color and its corresponding "on" color, container color,
/// and "on container" color.
class ColorFamily {
  /// The main color.
  final Color color;
  /// A color that is easy to see on top of [color].
  final Color onColor;
  /// A container color derived from [color].
  final Color container;
  /// A color that is easy to see on top of [container].
  final Color onContainer;

  /// Creates a `ColorFamily` object.
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.container,
    required this.onContainer,
  });
}

// --- MaterialTheme Class ---
/// A class that creates `ThemeData` objects from a `TextTheme`.
class MaterialTheme {
  /// The base `TextTheme` for the theme.
  final TextTheme textTheme;

  /// Creates a `MaterialTheme` object.
  const MaterialTheme(this.textTheme);

  /// The default light `ColorScheme`.
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1b6585),
      surfaceTint: Color(0xff1b6585),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffc3e8ff),
      onPrimaryContainer: Color(0xff004c68),
      secondary: Color(0xff4e616d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd1e5f4),
      onSecondaryContainer: Color(0xff364955),
      tertiary: Color(0xff605a7d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe6deff),
      onTertiaryContainer: Color(0xff484264),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff181c1f),
      onSurfaceVariant: Color(0xff41484d),
      outline: Color(0xff71787d),
      outlineVariant: Color(0xffc0c7cd),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff8fcef3),
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff001e2c),
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant: Color(0xff004c68),
      secondaryFixed: Color(0xffd1e5f4),
      onSecondaryFixed: Color(0xff091e28),
      secondaryFixedDim: Color(0xffb5c9d7),
      onSecondaryFixedVariant: Color(0xff364955),
      tertiaryFixed: Color(0xffe6deff),
      onTertiaryFixed: Color(0xff1c1736),
      tertiaryFixedDim: Color(0xffcac1ea),
      onTertiaryFixedVariant: Color(0xff484264),
      surfaceDim: Color(0xffd6dadf),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffeaeef2),
      surfaceContainerHigh: Color(0xffe5e9ed),
      surfaceContainerHighest: Color(0xffdfe3e7),
    );
  }

  /// Creates a light `ThemeData`.
  ThemeData light() => theme(lightScheme());

  /// A medium contrast light `ColorScheme`.
  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003b51),
      surfaceTint: Color(0xff1b6585),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff307495),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff263943),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5c707c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff373252),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6f688c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff0d1215),
      onSurfaceVariant: Color(0xff30373c),
      outline: Color(0xff4c5358),
      outlineVariant: Color(0xff676e73),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff8fcef3),
      primaryFixed: Color(0xff307495),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff075b7b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5c707c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff445763),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6f688c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff565073),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc3c7cb),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffe5e9ed),
      surfaceContainerHigh: Color(0xffd9dde1),
      surfaceContainerHighest: Color(0xffced2d6),
    );
  }

  /// Creates a medium contrast light `ThemeData`.
  ThemeData lightMediumContrast() => theme(lightMediumContrastScheme());

  /// A high contrast light `ColorScheme`.
  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003043),
      surfaceTint: Color(0xff1b6585),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004f6c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1b2e39),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff394c57),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2d2847),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4b4566),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff262d32),
      outlineVariant: Color(0xff434a4f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff8fcef3),
      primaryFixed: Color(0xff004f6c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00374c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff394c57),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff223540),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4b4566),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff342e4e),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb5b9bd),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffedf1f5),
      surfaceContainer: Color(0xffdfe3e7),
      surfaceContainerHigh: Color(0xffd1d5d9),
      surfaceContainerHighest: Color(0xffc3c7cb),
    );
  }

  /// Creates a high contrast light `ThemeData`.
  ThemeData lightHighContrast() => theme(lightHighContrastScheme());

  /// The default dark `ColorScheme`.
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8fcef3),
      surfaceTint: Color(0xff8fcef3),
      onPrimary: Color(0xff003549),
      primaryContainer: Color(0xff004c68),
      onPrimaryContainer: Color(0xffc3e8ff),
      secondary: Color(0xffb5c9d7),
      onSecondary: Color(0xff20333e),
      secondaryContainer: Color(0xff364955),
      onSecondaryContainer: Color(0xffd1e5f4),
      tertiary: Color(0xffcac1ea),
      onTertiary: Color(0xff322c4c),
      tertiaryContainer: Color(0xff484264),
      onTertiaryContainer: Color(0xffe6deff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffdfe3e7),
      onSurfaceVariant: Color(0xffc0c7cd),
      outline: Color(0xff8a9297),
      outlineVariant: Color(0xff41484d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff1b6585),
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff001e2c),
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant: Color(0xff004c68),
      secondaryFixed: Color(0xffd1e5f4),
      onSecondaryFixed: Color(0xff091e28),
      secondaryFixedDim: Color(0xffb5c9d7),
      onSecondaryFixedVariant: Color(0xff364955),
      tertiaryFixed: Color(0xffe6deff),
      onTertiaryFixed: Color(0xff1c1736),
      tertiaryFixedDim: Color(0xffcac1ea),
      onTertiaryFixedVariant: Color(0xff484264),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff353a3d),
      surfaceContainerLowest: Color(0xff0a0f12),
      surfaceContainerLow: Color(0xff181c1f),
      surfaceContainer: Color(0xff1c2023),
      surfaceContainerHigh: Color(0xff262b2e),
      surfaceContainerHighest: Color(0xff313539),
    );
  }

  /// Creates a dark `ThemeData`.
  ThemeData dark() => theme(darkScheme());

  /// A medium contrast dark `ColorScheme`.
  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(
          0xffb5e3ff), // This was 8fcef3, user provided b5e3ff for medium contrast primary
      surfaceTint: Color(0xff8fcef3),
      onPrimary: Color(0xff00293a),
      primaryContainer: Color(
          0xff5898bb), // This was 004c68, user provided 5898bb for medium contrast primaryContainer
      onPrimaryContainer: Color(
          0xff000000), // This was c3e8ff, user provided 000000 for medium contrast onPrimaryContainer
      secondary: Color(
          0xffcbdfed), // This was b5c9d7, user provided cbdfed for medium contrast secondary
      onSecondary: Color(
          0xff152832), // This was 20333e, user provided 152832 for medium contrast onSecondary
      secondaryContainer: Color(
          0xff8093a0), // This was 364955, user provided 8093a0 for medium contrast secondaryContainer
      onSecondaryContainer: Color(
          0xff000000), // This was d1e5f4, user provided 000000 for medium contrast onSecondaryContainer
      tertiary: Color(
          0xffe0d7ff), // This was cac1ea, user provided e0d7ff for medium contrast tertiary
      onTertiary: Color(
          0xff272140), // This was 322c4c, user provided 272140 for medium contrast onTertiary
      tertiaryContainer: Color(
          0xff938cb2), // This was 484264, user provided 938cb2 for medium contrast tertiaryContainer
      onTertiaryContainer: Color(
          0xff000000), // This was e6deff, user provided 000000 for medium contrast onTertiaryContainer
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd6dde3),
      outline: Color(0xffacb3b9),
      outlineVariant: Color(0xff8a9197),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff004e6a), // This was 1b6585, user provided 004e6a
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff00131d),
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant:
          Color(0xff003b51), // This was 004c68, user provided 003b51
      secondaryFixed: Color(0xffd1e5f4),
      onSecondaryFixed:
          Color(0xff01131d), // This was 091e28, user provided 01131d
      secondaryFixedDim: Color(0xffb5c9d7),
      onSecondaryFixedVariant:
          Color(0xff263943), // This was 364955, user provided 263943
      tertiaryFixed: Color(0xffe6deff),
      onTertiaryFixed:
          Color(0xff120c2b), // This was 1c1736, user provided 120c2b
      tertiaryFixedDim: Color(0xffcac1ea),
      onTertiaryFixedVariant:
          Color(0xff373252), // This was 484264, user provided 373252
      surfaceDim: Color(0xff0f1417),
      surfaceBright:
          Color(0xff404549), // This was 353a3d, user provided 404549
      surfaceContainerLowest:
          Color(0xff04080b), // This was 0a0f12, user provided 04080b
      surfaceContainerLow:
          Color(0xff1a1e21), // This was 181c1f, user provided 1a1e21
      surfaceContainer:
          Color(0xff24282c), // This was 1c2023, user provided 24282c
      surfaceContainerHigh:
          Color(0xff2e3337), // This was 262b2e, user provided 2e3337
      surfaceContainerHighest:
          Color(0xff3a3e42), // This was 313539, user provided 3a3e42
    );
  }

  /// Creates a medium contrast dark `ThemeData`.
  ThemeData darkMediumContrast() => theme(darkMediumContrastScheme());

  /// A high contrast dark `ColorScheme`.
  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe1f2ff), // This was 8fcef3, user provided e1f2ff
      surfaceTint: Color(0xff8fcef3),
      onPrimary: Color(0xff000000), // This was 003549, user provided 000000
      primaryContainer:
          Color(0xff8bcbef), // This was 004c68, user provided 8bcbef
      onPrimaryContainer:
          Color(0xff000d15), // This was c3e8ff, user provided 000d15
      secondary: Color(0xffe1f2ff), // This was b5c9d7, user provided e1f2ff
      onSecondary: Color(0xff000000), // This was 20333e, user provided 000000
      secondaryContainer:
          Color(0xffb1c5d3), // This was 364955, user provided b1c5d3
      onSecondaryContainer:
          Color(0xff000d15), // This was d1e5f4, user provided 000d15
      tertiary: Color(0xfff3edff), // This was cac1ea, user provided f3edff
      onTertiary: Color(0xff000000), // This was 322c4c, user provided 000000
      tertiaryContainer:
          Color(0xffc6bde6), // This was 484264, user provided c6bde6
      onTertiaryContainer:
          Color(0xff0c0625), // This was e6deff, user provided 0c0625
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeaf1f7),
      outlineVariant: Color(0xffbcc3c9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff004e6a), // This was 1b6585, user provided 004e6a
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff000000), // This was 001e2c, user provided 000000
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant:
          Color(0xff00131d), // This was 004c68, user provided 00131d
      secondaryFixed: Color(0xffd1e5f4),
      onSecondaryFixed:
          Color(0xff000000), // This was 091e28, user provided 000000
      secondaryFixedDim: Color(0xffb5c9d7),
      onSecondaryFixedVariant:
          Color(0xff01131d), // This was 364955, user provided 01131d
      tertiaryFixed: Color(0xffe6deff),
      onTertiaryFixed:
          Color(0xff000000), // This was 1c1736, user provided 000000
      tertiaryFixedDim: Color(0xffcac1ea),
      onTertiaryFixedVariant:
          Color(0xff120c2b), // This was 484264, user provided 120c2b
      surfaceDim: Color(0xff0f1417),
      surfaceBright:
          Color(0xff4c5154), // This was 353a3d, user provided 4c5154
      surfaceContainerLowest:
          Color(0xff000000), // This was 0a0f12, user provided 000000
      surfaceContainerLow:
          Color(0xff1c2023), // This was 181c1f, user provided 1c2023
      surfaceContainer:
          Color(0xff2c3134), // This was 1c2023, user provided 2c3134
      surfaceContainerHigh:
          Color(0xff373c3f), // This was 262b2e, user provided 373c3f
      surfaceContainerHighest:
          Color(0xff43474b), // This was 313539, user provided 43474b
    );
  }

  /// Creates a high contrast dark `ThemeData`.
  ThemeData darkHighContrast() => theme(darkHighContrastScheme());

  /// Creates a `ThemeData` from a `ColorScheme`.
  ///
  /// This method uses `AppTheme.buildThemeDataFromScheme` to create the theme.
  /// @return A `ThemeData` object.
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
