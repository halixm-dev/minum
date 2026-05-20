import 'package:flutter/material.dart';
import 'package:minum/src/core/theme/theme_colors.dart';
import 'package:minum/src/core/theme/theme_components.dart' as components;

export 'package:minum/src/core/theme/theme_colors.dart';
export 'package:minum/src/core/theme/theme_components.dart'
    show buildThemeDataFromScheme, filledButtonTonalStyle, cardThemeElevated, cardThemeOutlined;
export 'package:minum/src/core/theme/theme_extensions.dart';

/// A utility class for creating and managing Material 3 themes.
///
/// This class provides static methods to generate `ThemeData` for light, dark,
/// and contrast themes, as well as themes from a seed color. It encapsulates
/// the logic for color schemes, text themes, and component styles.
class AppTheme {
  /// Private constructor to prevent instantiation.
  AppTheme._();

  // Define base TextThemes
  static final TextTheme _lightTextTheme = ThemeData.light().textTheme;
  static final TextTheme _darkTextTheme = ThemeData.dark().textTheme;

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
  /// The [contrastLevel] adjusts the contrast of the generated scheme.
  ///   0.0 is standard, -1.0 is low, 1.0 is high.
  /// @return A `ThemeData` object.
  static ThemeData themeFromSeed(
      {required Color seedColor,
      required Brightness brightness,
      double contrastLevel = 0.0}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: contrastLevel,
    );
    final baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    return buildThemeDataFromScheme(colorScheme, baseTextTheme);
  }

  /// Builds a `ThemeData` object from a `ColorScheme` and a base `TextTheme`.
  ///
  /// Delegates to the top-level [buildThemeDataFromScheme] function in
  /// `theme_components.dart`.
  static ThemeData buildThemeDataFromScheme(
      ColorScheme colorScheme, TextTheme baseTheme) {
    return components.buildThemeDataFromScheme(colorScheme, baseTheme);
  }
}
