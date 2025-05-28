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
        errorContainer: AppColors.errorContainerLight,
        onErrorContainer: AppColors.onErrorContainerLight,
        surface:
            AppColors.lightScaffoldBackground, // Typically the main background
        onSurface: AppColors.lightText,
        surfaceDim: AppColors.surfaceDimLight,
        surfaceBright: AppColors.surfaceBrightLight,
        surfaceContainerLowest: AppColors.surfaceContainerLowestLight,
        surfaceContainerLow: AppColors
            .surfaceContainerLowLight, // Existing lightScaffoldBackground
        surfaceContainer: AppColors
            .surfaceContainerLight, // Existing lightSurface (for cards)
        surfaceContainerHigh: AppColors.surfaceContainerHighLight,
        // Assigning the color previously used for 'surfaceVariant' (AppColors.surfaceVariantLight)
        // to 'surfaceContainerHighest' as per the deprecation message's suggestion.
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        // The 'surfaceVariant' parameter itself is removed from this constructor call.
        // The ColorScheme will still have a 'surfaceVariant' property, but it will be Flutter's default.
        onSurfaceVariant: AppColors
            .onSurfaceVariantLight, // This will pair with Flutter's default surfaceVariant.
        outline: AppColors.outlineLight,
        outlineVariant: AppColors.outlineVariantLight, // M3 Outline Variant
        inverseSurface: AppColors.darkScaffoldBackground, // M3 Inverse Surface
        onInverseSurface: AppColors.darkText, // M3 On Inverse Surface
        inversePrimary: AppColors.primaryColorDark, // M3 Inverse Primary
        shadow: AppColors.shadowColor, // M3 Shadow
        scrim: Colors.black.withAlpha(82), // Replaced withValues(alpha: 0.32)
        surfaceTint:
            AppColors.primaryColor, // M3 Surface Tint (usually primary)
      ),
      Brightness.light);

  static final ThemeData darkTheme = buildThemeDataFromScheme(
      ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primaryColorDark, // M3 Primary
        onPrimary: AppColors.onPrimaryDark, // M3 On Primary
        primaryContainer:
            AppColors.primaryContainerDark, // M3 Primary Container
        onPrimaryContainer:
            AppColors.onPrimaryContainerDark, // M3 On Primary Container
        secondary: AppColors.secondaryDark, // M3 Secondary
        onSecondary: AppColors.onSecondaryDark, // M3 On Secondary
        secondaryContainer:
            AppColors.secondaryContainerDark, // M3 Secondary Container
        onSecondaryContainer: AppColors.onSecondaryContainerDark,
        tertiary: AppColors.tertiaryDark,
        onTertiary: AppColors.onTertiaryDark,
        tertiaryContainer: AppColors.tertiaryContainerDark,
        onTertiaryContainer: AppColors.onTertiaryContainerDark,
        error: AppColors.errorDarkM3, // Using M3 standard dark error color
        onError:
            AppColors.onErrorDarkM3, // Using M3 standard dark onError color
        errorContainer:
            AppColors.errorContainerDark, // This is already M3 compliant
        onErrorContainer:
            AppColors.onErrorContainerDark, // This is already M3 compliant
        surface:
            AppColors.darkScaffoldBackground, // Typically the main background
        onSurface: AppColors.darkText,
        surfaceDim: AppColors.surfaceDimDark,
        surfaceBright: AppColors.surfaceBrightDark,
        surfaceContainerLowest: AppColors
            .surfaceContainerLowestDark, // Existing darkScaffoldBackground
        surfaceContainerLow:
            AppColors.surfaceContainerLowDark, // Existing darkBackground
        surfaceContainer:
            AppColors.surfaceContainerDark, // Existing darkSurface (for cards)
        surfaceContainerHigh: AppColors.surfaceContainerHighDark,
        surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        outline: AppColors.outlineDark,
        outlineVariant: AppColors.outlineVariantDark,
        inverseSurface: AppColors
            .lightScaffoldBackground, // M3 Inverse Surface (using light theme's scaffold)
        onInverseSurface: AppColors
            .lightText, // M3 On Inverse Surface (using light theme's text)
        inversePrimary: AppColors.primaryColor, // M3 Inverse Primary
        shadow: AppColors
            .shadowColor, // M3 Shadow (might need adjustment for dark theme)
        scrim: Colors.black.withAlpha(102), // Replaced withValues(alpha: 0.4)
        surfaceTint: AppColors
            .primaryColorDark, // M3 Surface Tint (usually primary for dark)
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
    final m3BaseTextTheme =
        GoogleFonts.robotoTextTheme(baseTextTheme); // Using Roboto as specified

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
        titleTextStyle: m3BaseTextTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface), // M3 titleLarge, color onSurface
      ),
      textTheme: m3BaseTextTheme.copyWith(
        // M3 Type Scale (approximated where specific Flutter values differ slightly or due to lack of direct access to specs)
        // Values from https://m3.material.io/styles/typography/type-scale-tokens
        // Note: letterSpacing and lineHeight are often critical for M3 feel but are omitted here due to access constraints.
        // ScreenUtil (.sp) is used for font sizes.
        displayLarge: m3BaseTextTheme.displayLarge?.copyWith(
            fontSize: 57.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        displayMedium: m3BaseTextTheme.displayMedium?.copyWith(
            fontSize: 45.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        displaySmall: m3BaseTextTheme.displaySmall?.copyWith(
            fontSize: 36.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        headlineLarge: m3BaseTextTheme.headlineLarge?.copyWith(
            fontSize: 32.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        headlineMedium: m3BaseTextTheme.headlineMedium?.copyWith(
            fontSize: 28.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        headlineSmall: m3BaseTextTheme.headlineSmall?.copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        titleLarge: m3BaseTextTheme.titleLarge?.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface), // Often used for AppBars
        titleMedium: m3BaseTextTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            letterSpacing: 0.15.sp),
        titleSmall: m3BaseTextTheme.titleSmall?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            letterSpacing: 0.1.sp),
        bodyLarge: m3BaseTextTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
            letterSpacing: 0.5.sp),
        bodyMedium: m3BaseTextTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.25.sp), // M3 bodyMedium is often onSurfaceVariant
        bodySmall: m3BaseTextTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.4.sp), // M3 bodySmall is often onSurfaceVariant
        labelLarge: m3BaseTextTheme.labelLarge?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onPrimary,
            letterSpacing: 0.1.sp), // Used in ElevatedButtons
        labelMedium: m3BaseTextTheme.labelMedium?.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5.sp),
        labelSmall: m3BaseTextTheme.labelSmall?.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5.sp),
      ),
      // --- Button Themes ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        // M3 ElevatedButton: surface background, primary text
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          surfaceTintColor: colorScheme.primary, // For elevation tint
          elevation: 1, // M3 Elevated buttons have a small shadow
          textStyle:
              m3BaseTextTheme.labelLarge?.copyWith(color: colorScheme.primary),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20.r)), // M3 "Full" or large radius
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        // M3 FilledButton: primary background, onPrimary text
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor:
              colorScheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor:
              colorScheme.onSurface.withValues(alpha: 0.38),
          textStyle: m3BaseTextTheme.labelLarge,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        ),
      ),
      // For Filled Tonal Button (secondary container background)
      // A common way to do this is to define a style and apply it where needed,
      // or create a custom widget. For now, this is how you'd define the style:
      // filledButtonTonalStyle: FilledButton.styleFrom(
      //   backgroundColor: colorScheme.secondaryContainer,
      //   foregroundColor: colorScheme.onSecondaryContainer,
      //   textStyle: m3BaseTextTheme.labelLarge,
      //   padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      // ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          backgroundColor: Colors.transparent,
          disabledForegroundColor:
              colorScheme.onSurface.withValues(alpha: 0.38),
          textStyle:
              m3BaseTextTheme.labelLarge?.copyWith(color: colorScheme.primary),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
          side: BorderSide(color: colorScheme.outline),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor:
              colorScheme.onSurface.withValues(alpha: 0.38),
          textStyle:
              m3BaseTextTheme.labelLarge?.copyWith(color: colorScheme.primary),
          padding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 12.w), // M3 text buttons have less horizontal padding
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        ),
      ),

      // --- InputDecorationTheme (for TextFields) ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // M3 Filled TextFields are the default
        fillColor: colorScheme
            .surfaceContainerHighest, // M3 Filled TextField fill color
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w, vertical: 12.h), // Padding inside the TextField
        border: OutlineInputBorder(
          // Default border (usually not visible for enabled state)
          borderRadius:
              BorderRadius.all(Radius.circular(4.r)), // M3 "ExtraSmall" radius
          borderSide:
              BorderSide.none, // No border for enabled filled text fields
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide:
              BorderSide.none, // No border for enabled filled text fields
        ),
        // M3 uses an underline for active indicator on Filled, but Outline is also acceptable.
        // Sticking to Outline for consistency with previous setup, but with specific M3 styling.
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2.0), // Primary color, 2px width
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide: BorderSide(
              color: colorScheme.error, width: 2.0), // Error color, 2px width
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder(
          // Filled text field has different look when disabled
          borderRadius: BorderRadius.all(Radius.circular(4.r)),
          borderSide: BorderSide.none,
        ),
        labelStyle: m3BaseTextTheme.bodyLarge
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: m3BaseTextTheme.bodyLarge
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle: m3BaseTextTheme.bodySmall
            ?.copyWith(color: colorScheme.error), // M3 error text style
      ),

      // --- CardTheme ---
      cardTheme: CardThemeData(
        // Defaulting to M3 Filled Card style
        elevation: 0.0, // M3 Filled cards have no elevation
        color: colorScheme.surfaceContainerLow, // M3 Filled Card color
        surfaceTintColor: Colors.transparent, // M3 Filled cards don't show tint
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(12.r))), // M3 "Medium" radius
      ),
      // For M3 Elevated Card style, you'd use:
      // cardThemeElevated: CardTheme(
      //   elevation: 1.0,
      //   color: colorScheme.surface, // M3 Elevated Card color is surface
      //   surfaceTintColor: colorScheme.surfaceTint,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.r))),
      // ),
      // For M3 Outlined Card style, you'd use:
      // cardThemeOutlined: CardTheme(
      //   elevation: 0.0,
      //   color: colorScheme.surface,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(12.r)),
      //     side: BorderSide(color: colorScheme.outlineVariant)
      //   ),
      // ),

      iconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant), // Default icon color

      // --- FloatingActionButton ---
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3.0, // M3 FABs standard elevation
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                16.r)), // M3 "Medium" shape category for standard FAB
        // smallFabShape and largeFabShape are not direct properties of FloatingActionButtonThemeData.
        // Different FAB sizes (small, large) are handled by using different constructors like
        // FloatingActionButton.small() or FloatingActionButton.large() which then might
        // consult theme extensions or have their own default shapes if not overridden by 'shape'.
        // The 'shape' here applies to the default FAB.
        extendedTextStyle: m3BaseTextTheme.labelLarge
            ?.copyWith(color: colorScheme.onPrimaryContainer),
      ),

      // --- DialogTheme ---
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: 3.0, // M3 standard elevation for dialogs
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r)), // M3 "ExtraLarge" shape
        titleTextStyle: m3BaseTextTheme.headlineSmall
            ?.copyWith(color: colorScheme.onSurface),
        contentTextStyle: m3BaseTextTheme.bodyMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
      ),

      // --- BottomSheetTheme ---
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        modalBackgroundColor: colorScheme.surfaceContainer,
        elevation: 3.0, // M3 standard elevation
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(28.r)) // M3 "ExtraLarge" top corners
            ),
        // surfaceTintColor: colorScheme.surfaceTint, // If you want a tint
      ),

      // --- ChipTheme --- (Defaulting to M3 Assist chip - outlined style)
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface, // M3 Assist chip background
        labelStyle: m3BaseTextTheme.labelLarge!.copyWith(
            color:
                colorScheme.onSurface), // M3 uses onSurface for outlined assist
        side: BorderSide(color: colorScheme.outline), // M3 Outlined Assist chip
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r)), // M3 "Small" shape
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        iconTheme: IconThemeData(
            color: colorScheme.primary,
            size: 18.sp), // Leading icon for assist chip
        // selectedColor: colorScheme.secondaryContainer, // For Filter chips
        // selectedColor: colorScheme.primary, // For Input chips (when selected)
        // showCheckmark: true, // For Filter/Input chips
      ),

      // --- NavigationBarTheme ---
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor:
            colorScheme.secondaryContainer, // Indicator for selected item
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
                color: colorScheme
                    .onSecondaryContainer); // Icon color for selected
          }
          return IconThemeData(
              color: colorScheme.onSurfaceVariant); // Icon color for unselected
        }),
        labelTextStyle:
            WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final style = m3BaseTextTheme.labelMedium!; // M3 uses labelMedium
          if (states.contains(WidgetState.selected)) {
            return style.copyWith(
                color: colorScheme.onSurface); // Text color for selected
          }
          return style.copyWith(
              color: colorScheme.onSurfaceVariant); // Text color for unselected
        }),
        height: 80.h, // M3 standard height
        elevation: 2.0, // M3 standard elevation
      ),
      // Add other component themes as needed...
    );
  }
}
