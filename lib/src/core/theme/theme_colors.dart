import 'package:flutter/material.dart';
import 'package:minum/src/core/theme/theme_components.dart';

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
      primary: Color(0xffb5e3ff),
      surfaceTint: Color(0xff8fcef3),
      onPrimary: Color(0xff00293a),
      primaryContainer: Color(0xff5898bb),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffcbdfed),
      onSecondary: Color(0xff152832),
      secondaryContainer: Color(0xff8093a0),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffe0d7ff),
      onTertiary: Color(0xff272140),
      tertiaryContainer: Color(0xff938cb2),
      onTertiaryContainer: Color(0xff000000),
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
      inversePrimary: Color(0xff004e6a),
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff00131d),
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant: Color(0xff003b51),
      secondaryFixed: Color(0xffd1e5f4),
      onSecondaryFixed: Color(0xff01131d),
      secondaryFixedDim: Color(0xffb5c9d7),
      onSecondaryFixedVariant: Color(0xff263943),
      tertiaryFixed: Color(0xffe6deff),
      onTertiaryFixed: Color(0xff120c2b),
      tertiaryFixedDim: Color(0xffcac1ea),
      onTertiaryFixedVariant: Color(0xff373252),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff404549),
      surfaceContainerLowest: Color(0xff04080b),
      surfaceContainerLow: Color(0xff1a1e21),
      surfaceContainer: Color(0xff24282c),
      surfaceContainerHigh: Color(0xff2e3337),
      surfaceContainerHighest: Color(0xff3a3e42),
    );
  }

  /// Creates a medium contrast dark `ThemeData`.
  ThemeData darkMediumContrast() => theme(darkMediumContrastScheme());

  /// A high contrast dark `ColorScheme`.
  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe1f2ff),
      surfaceTint: Color(0xff8fcef3),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff8bcbef),
      onPrimaryContainer: Color(0xff000d15),
      secondary: Color(0xffe1f2ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffb1c5d3),
      onSecondaryContainer: Color(0xff000d15),
      tertiary: Color(0xfff3edff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffc6bde6),
      onTertiaryContainer: Color(0xff0c0625),
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
      inversePrimary: Color(0xff004e6a),
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant: Color(0xff00131d),
      secondaryFixed: Color(0xffd1e5f4),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb5c9d7),
      onSecondaryFixedVariant: Color(0xff01131d),
      tertiaryFixed: Color(0xffe6deff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffcac1ea),
      onTertiaryFixedVariant: Color(0xff120c2b),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff4c5154),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1c2023),
      surfaceContainer: Color(0xff2c3134),
      surfaceContainerHigh: Color(0xff373c3f),
      surfaceContainerHighest: Color(0xff43474b),
    );
  }

  /// Creates a high contrast dark `ThemeData`.
  ThemeData darkHighContrast() => theme(darkHighContrastScheme());

  /// Creates a `ThemeData` from a `ColorScheme`.
  ThemeData theme(ColorScheme colorScheme) {
    return buildThemeDataFromScheme(colorScheme, textTheme);
  }
}
