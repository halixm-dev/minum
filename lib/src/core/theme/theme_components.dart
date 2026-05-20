import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Builds a `ThemeData` object from a `ColorScheme` and a base `TextTheme`.
///
/// This is the main workhorse method for creating themes. It configures all
/// the component themes based on the provided color scheme and text theme.
///
/// The [colorScheme] defines the colors for the theme.
/// The [baseTheme] defines the base typography for the theme.
/// @return A fully configured `ThemeData` object.
ThemeData buildThemeDataFromScheme(
    ColorScheme colorScheme, TextTheme baseTheme) {
  final brightness = colorScheme.brightness;

  final TextTheme m3TextTheme = baseTheme.copyWith(
    displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: 57.sp,
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
    brightness: brightness,
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      titleTextStyle: m3TextTheme.titleLarge,
    ),
    textTheme: m3TextTheme,
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
          return colorScheme.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withAlpha(97);
          }
          return colorScheme.primary;
        }),
        surfaceTintColor: WidgetStateProperty.all(colorScheme.primary),
        elevation: WidgetStateProperty.resolveWith<double?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return 2.0;
          }
          if (states.contains(WidgetState.pressed)) {
            return 1.0;
          }
          return 1.0;
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
        textStyle: WidgetStateProperty.all(m3TextTheme.labelLarge),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withAlpha(31);
          }
          return colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withAlpha(97);
          }
          return colorScheme.onPrimary;
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
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withAlpha(97);
          }
          return colorScheme.primary;
        }),
        side: WidgetStateProperty.resolveWith<BorderSide?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: colorScheme.onSurface.withAlpha(31));
          }
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: colorScheme.primary, width: 1.0);
          }
          return BorderSide(color: colorScheme.outline);
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
          return colorScheme.primary;
        }),
      ),
    ),

    // --- InputDecorationTheme ---
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.r)),
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
        borderSide:
            BorderSide(color: colorScheme.onSurface.withAlpha(31), width: 1.0),
      ),
      labelStyle: m3TextTheme.bodyLarge
          ?.copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: m3TextTheme.bodyLarge
          ?.copyWith(color: colorScheme.onSurfaceVariant),
      errorStyle: m3TextTheme.bodySmall?.copyWith(color: colorScheme.error),
    ),

    // --- CardTheme ---
    cardTheme: CardThemeData(
      elevation: 0.0,
      color: colorScheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.r))),
    ),

    iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),

    // --- FloatingActionButton ---
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      extendedTextStyle: m3TextTheme.labelLarge
          ?.copyWith(color: colorScheme.onPrimaryContainer),
    ),

    // --- DialogTheme ---
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      elevation: 6.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r)),
      titleTextStyle: m3TextTheme.headlineSmall,
      contentTextStyle: m3TextTheme.bodyMedium,
    ),

    // --- BottomSheetTheme ---
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainer,
      modalBackgroundColor: colorScheme.surfaceContainer,
      elevation: 6.0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0))),
    ),

    // --- ChipTheme ---
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surface,
      labelStyle:
          m3TextTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
      side: BorderSide(color: colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      iconTheme:
          IconThemeData(color: colorScheme.primary, size: 18.sp),
      showCheckmark: false,
    ),

    // --- NavigationBarTheme ---
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainer,
      indicatorColor: colorScheme.secondaryContainer,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.onSecondaryContainer);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (Set<WidgetState> states) {
        final style = m3TextTheme.labelMedium!;
        if (states.contains(WidgetState.selected)) {
          return style.copyWith(color: colorScheme.onSurface);
        }
        return style.copyWith(color: colorScheme.onSurfaceVariant);
      }),
      height: 80.h,
      elevation: 2.0,
    ),

    // --- ListTileTheme ---
    listTileTheme: ListTileThemeData(
      iconColor: colorScheme.onSurfaceVariant,
      titleTextStyle: m3TextTheme.bodyLarge,
      subtitleTextStyle: m3TextTheme.bodyMedium
          ?.copyWith(color: colorScheme.onSurfaceVariant),
      dense: false,
      shape: null,
      contentPadding: null,
    ),

    // --- DropdownMenuTheme ---
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle:
          m3TextTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      menuStyle: MenuStyle(
        backgroundColor:
            WidgetStateProperty.all(colorScheme.surfaceContainer),
        elevation: WidgetStateProperty.all(3.0),
        shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r))),
      ),
    ),

    // --- DatePickerTheme ---
    datePickerTheme: DatePickerThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      headerBackgroundColor: colorScheme.surfaceContainerHigh,
      headerForegroundColor: colorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r)),
      dayStyle: m3TextTheme.bodyMedium
          ?.copyWith(color: colorScheme.onSurface),
      weekdayStyle: m3TextTheme.bodySmall
          ?.copyWith(color: colorScheme.onSurfaceVariant),
      yearStyle: m3TextTheme.bodyMedium
          ?.copyWith(color: colorScheme.onSurface),
      todayBorder: BorderSide(color: colorScheme.primary),
      todayForegroundColor: WidgetStateProperty.all(colorScheme.primary),
      todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
      dayForegroundColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withAlpha(97);
        }
        return colorScheme.onSurface;
      }),
      dayBackgroundColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return Colors.transparent;
      }),
    ),

    // --- TimePickerTheme ---
    timePickerTheme: TimePickerThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r)),
      hourMinuteShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      hourMinuteColor: colorScheme.surfaceContainerHighest,
      hourMinuteTextColor: colorScheme.onSurface,
      dayPeriodShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      dayPeriodColor: colorScheme.surfaceContainerHighest,
      dayPeriodTextColor: colorScheme.onPrimaryContainer,
      dayPeriodBorderSide: BorderSide.none,
      dialHandColor: colorScheme.primary,
      dialBackgroundColor: colorScheme.surfaceContainerHighest,
      dialTextColor: colorScheme.onSurface,
      helpTextStyle: m3TextTheme.labelSmall
          ?.copyWith(color: colorScheme.onSurfaceVariant),
    ),
  );
}

/// Creates a `ButtonStyle` for a filled tonal button.
ButtonStyle filledButtonTonalStyle(
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
CardThemeData cardThemeElevated(ColorScheme colorScheme) {
  return CardThemeData(
    elevation: 1.0,
    color: colorScheme.surface,
    surfaceTintColor: colorScheme.surfaceTint,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.r))),
  );
}

/// Creates a `CardThemeData` for an outlined card.
CardThemeData cardThemeOutlined(ColorScheme colorScheme) {
  return CardThemeData(
    elevation: 0.0,
    color: colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.r)),
      side: BorderSide(color: colorScheme.outlineVariant),
    ),
  );
}
