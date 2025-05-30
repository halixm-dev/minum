// lib/src/core/constants/app_colors.dart
import 'package:flutter/material.dart';
import 'package:minum/src/core/theme/app_theme.dart';

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
