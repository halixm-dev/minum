// lib/src/presentation/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minum/main.dart'; // For logger
import 'package:minum/src/core/theme/app_theme.dart';

/// An enumeration of the possible sources for the application's theme.
enum ThemeSource {
  /// The standard baseline theme.
  baseline,
  /// A medium contrast theme.
  mediumContrast,
  /// A high contrast theme.
  highContrast,
  /// A theme based on the system's dynamic colors (Android 12+).
  dynamicSystem,
  /// A theme based on a user-selected custom seed color.
  customSeed,
}

/// A `ChangeNotifier` that manages the application's theme settings.
///
/// This provider handles loading and saving theme preferences, such as
/// light/dark mode, theme source (e.g., baseline, dynamic), and custom
/// seed colors.
class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'themePreference';
  static const String _themeSourceKey = 'themeSource';
  static const String _customSeedColorKey = 'customSeedColor';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeSource _themeSource = ThemeSource.baseline;
  ColorScheme? _lightDynamicScheme;
  ColorScheme? _darkDynamicScheme;
  Color? _customSeedColor;

  bool _isDisposed = false;

  ThemeData? _cachedLightDynamicThemeData;
  ColorScheme? _lastLightDynamicScheme;

  ThemeData? _cachedDarkDynamicThemeData;
  ColorScheme? _lastDarkDynamicScheme;

  /// The current theme mode (light, dark, or system).
  ThemeMode get themeMode => _themeMode;

  /// The current theme source.
  ThemeSource get themeSource => _themeSource;

  /// The custom seed color selected by the user.
  Color? get customSeedColor => _customSeedColor;

  /// The currently active light theme data, based on the selected theme source.
  ThemeData get currentLightThemeData {
    switch (_themeSource) {
      case ThemeSource.baseline:
        logger.i("Using baseline light theme.");
        return AppTheme.lightTheme;
      case ThemeSource.mediumContrast:
        logger.i("Using medium contrast light theme.");
        return AppTheme.lightMediumContrastTheme;
      case ThemeSource.highContrast:
        logger.i("Using high contrast light theme.");
        return AppTheme.lightHighContrastTheme;
      case ThemeSource.dynamicSystem:
        if (_lightDynamicScheme != null) {
          if (identical(_lightDynamicScheme, _lastLightDynamicScheme) &&
              _cachedLightDynamicThemeData != null) {
            logger.i("Using cached dynamic system light theme.");
            return _cachedLightDynamicThemeData!;
          }
          logger.i("Rebuilding dynamic system light theme.");
          _lastLightDynamicScheme = _lightDynamicScheme;
          _cachedLightDynamicThemeData = AppTheme.buildThemeDataFromScheme(
              _lightDynamicScheme!, AppTheme.lightTheme.textTheme);
          return _cachedLightDynamicThemeData!;
        }
        logger.w(
            "Dynamic system source selected for light theme, but _lightDynamicScheme is null. Falling back to baseline.");
        return AppTheme.lightTheme;
      case ThemeSource.customSeed:
        if (_customSeedColor != null) {
          logger
              .i("Using custom seed color for light theme: $_customSeedColor");
          return AppTheme.themeFromSeed(
              seedColor: _customSeedColor!, brightness: Brightness.light);
        }
        logger.w(
            "Custom seed source selected for light theme, but customSeedColor is null. Falling back to baseline.");
        return AppTheme.lightTheme;
    }
  }

  /// The currently active dark theme data, based on the selected theme source.
  ThemeData get currentDarkThemeData {
    switch (_themeSource) {
      case ThemeSource.baseline:
        logger.i("Using baseline dark theme.");
        return AppTheme.darkTheme;
      case ThemeSource.mediumContrast:
        logger.i("Using medium contrast dark theme.");
        return AppTheme.darkMediumContrastTheme;
      case ThemeSource.highContrast:
        logger.i("Using high contrast dark theme.");
        return AppTheme.darkHighContrastTheme;
      case ThemeSource.dynamicSystem:
        if (_darkDynamicScheme != null) {
          if (identical(_darkDynamicScheme, _lastDarkDynamicScheme) &&
              _cachedDarkDynamicThemeData != null) {
            logger.i("Using cached dynamic system dark theme.");
            return _cachedDarkDynamicThemeData!;
          }
          logger.i("Rebuilding dynamic system dark theme.");
          _lastDarkDynamicScheme = _darkDynamicScheme;
          _cachedDarkDynamicThemeData = AppTheme.buildThemeDataFromScheme(
              _darkDynamicScheme!, AppTheme.darkTheme.textTheme);
          return _cachedDarkDynamicThemeData!;
        }
        logger.w(
            "Dynamic system source selected for dark theme, but _darkDynamicScheme is null. Falling back to baseline.");
        return AppTheme.darkTheme;
      case ThemeSource.customSeed:
        if (_customSeedColor != null) {
          logger.i("Using custom seed color for dark theme: $_customSeedColor");
          return AppTheme.themeFromSeed(
              seedColor: _customSeedColor!, brightness: Brightness.dark);
        }
        logger.w(
            "Custom seed source selected for dark theme, but customSeedColor is null. Falling back to baseline.");
        return AppTheme.darkTheme;
    }
  }

  /// Creates a `ThemeProvider` instance and loads the theme preferences.
  ThemeProvider() {
    _loadThemePreference();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    } else {
      logger.w(
          "ThemeProvider: Attempted to call notifyListeners() after dispose.");
    }
  }

  Future<void> _loadThemePreference() async {
    if (_isDisposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;

      final themeModeString = prefs.getString(_themePrefKey);
      if (themeModeString == 'light') {
        _themeMode = ThemeMode.light;
      } else if (themeModeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      logger.i("ThemeMode loaded: $_themeMode");

      final themeSourceString = prefs.getString(_themeSourceKey);
      _themeSource = ThemeSource.values.firstWhere(
        (e) => e.name == themeSourceString,
        orElse: () => ThemeSource.baseline,
      );
      logger.i("ThemeSource loaded: $_themeSource");

      final seedColorValue = prefs.getInt(_customSeedColorKey);
      if (seedColorValue != null) {
        _customSeedColor = Color(seedColorValue);
        logger.i("CustomSeedColor loaded: $_customSeedColor");
      } else {
        _customSeedColor = null;
        logger.i("CustomSeedColor not found, set to null.");
      }
    } catch (e) {
      logger.e("Error loading theme preferences: $e");
    }
    _safeNotifyListeners();
  }

  /// Sets the dynamic color schemes obtained from the system.
  void setDynamicColorSchemes(ColorScheme? light, ColorScheme? dark) {
    if (_isDisposed) return;

    bool lightChanged = !identical(light, _lightDynamicScheme);
    bool darkChanged = !identical(dark, _darkDynamicScheme);

    if (lightChanged) {
      _cachedLightDynamicThemeData = null;
      _lightDynamicScheme = light;
      logger.i("New light dynamic scheme set. Cache invalidated.");
    }

    if (darkChanged) {
      _cachedDarkDynamicThemeData = null;
      _darkDynamicScheme = dark;
      logger.i("New dark dynamic scheme set. Cache invalidated.");
    }

    if ((lightChanged || darkChanged) &&
        _themeSource == ThemeSource.dynamicSystem) {
      logger.i(
          "Dynamic ColorSchemes updated and current source is dynamic. Notifying listeners.");
      _safeNotifyListeners();
    } else if (lightChanged || darkChanged) {
      logger.i(
          "Dynamic ColorSchemes updated but current source is not dynamic, no immediate notification unless source changes.");
    } else {
      logger.i(
          "Dynamic ColorSchemes received, but identical to current. No changes made, no notification.");
    }
  }

  /// Sets the theme source and persists the choice.
  Future<void> setThemeSource(ThemeSource source) async {
    if (_themeSource == source || _isDisposed) return;

    _themeSource = source;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      await prefs.setString(_themeSourceKey, source.name);
      logger.i("ThemeSource preference saved: $_themeSource");
    } catch (e) {
      logger.e("Error saving ThemeSource preference: $e");
    }
    _safeNotifyListeners();
  }

  /// Sets the custom seed color and persists the choice.
  Future<void> setCustomSeedColor(Color color) async {
    if (_customSeedColor == color || _isDisposed) return;

    _customSeedColor = color;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      await prefs.setInt(_customSeedColorKey, color.toARGB32());
      logger.i("CustomSeedColor preference saved: $_customSeedColor");
      if (_themeSource == ThemeSource.customSeed) {
        logger.i(
            "Current source is custom. Notifying listeners for seed color change.");
        _safeNotifyListeners();
      } else {
        logger.i(
            "Current source is not custom. Seed color saved, no immediate notification.");
      }
    } catch (e) {
      logger.e("Error saving CustomSeedColor preference: $e");
    }
  }

  /// Sets the theme mode (light, dark, or system) and persists the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode || _isDisposed) return;

    _themeMode = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;

      String themeString;
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      await prefs.setString(_themePrefKey, themeString);
      logger.i("Theme preference saved: $_themeMode");
    } catch (e) {
      logger.e("Error saving theme preference: $e");
    }
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    logger.d("ThemeProvider: dispose called.");
    _isDisposed = true;
    super.dispose();
  }
}
