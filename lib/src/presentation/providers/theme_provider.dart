// lib/src/presentation/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minum/main.dart'; // For logger
import 'package:minum/src/core/theme/app_theme.dart';

/// An enumeration of the possible sources for the application's theme.
enum ThemeSource {
  /// The standard baseline theme.
  baseline,

  /// A theme based on the system's dynamic colors (Android 12+).
  dynamicSystem,

  /// A theme based on a user-selected custom seed color.
  customSeed,
}

/// An enumeration of the contrast levels.
enum ContrastLevel {
  normal,
  medium,
  high,
}

/// A `ChangeNotifier` that manages the application's theme settings.
///
/// This provider handles loading and saving theme preferences, such as
/// light/dark mode, theme source (e.g., baseline, dynamic), custom
/// seed colors, and contrast levels.
class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'themePreference';
  static const String _themeSourceKey = 'themeSource';
  static const String _customSeedColorKey = 'customSeedColor';
  static const String _contrastLevelKey = 'contrastLevel';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeSource _themeSource = ThemeSource.baseline;
  ContrastLevel _contrastLevel = ContrastLevel.normal;

  ColorScheme? _lightDynamicScheme;
  ColorScheme? _darkDynamicScheme;
  Color? _customSeedColor;

  bool _isDisposed = false;

  // Caches to prevent unnecessary rebuilding
  ThemeData? _cachedLightThemeData;
  ThemeData? _cachedDarkThemeData;

  // Track dependencies for cache invalidation
  ThemeSource? _lastSourceForLight;
  ContrastLevel? _lastContrastForLight;
  Color? _lastSeedForLight;
  ColorScheme? _lastDynamicSchemeForLight;

  ThemeSource? _lastSourceForDark;
  ContrastLevel? _lastContrastForDark;
  Color? _lastSeedForDark;
  ColorScheme? _lastDynamicSchemeForDark;

  /// The current theme mode (light, dark, or system).
  ThemeMode get themeMode => _themeMode;

  /// The current theme source.
  ThemeSource get themeSource => _themeSource;

  /// The current contrast level.
  ContrastLevel get contrastLevel => _contrastLevel;

  /// The custom seed color selected by the user.
  Color? get customSeedColor => _customSeedColor;

  double get _contrastValue {
    switch (_contrastLevel) {
      case ContrastLevel.normal:
        return 0.0;
      case ContrastLevel.medium:
        return 0.5; // Medium contrast approximation
      case ContrastLevel.high:
        return 1.0;
    }
  }

  /// The currently active light theme data.
  ThemeData get currentLightThemeData {
    // Check cache
    if (_cachedLightThemeData != null &&
        _lastSourceForLight == _themeSource &&
        _lastContrastForLight == _contrastLevel &&
        (_themeSource != ThemeSource.customSeed ||
            _lastSeedForLight == _customSeedColor) &&
        (_themeSource != ThemeSource.dynamicSystem ||
            identical(_lastDynamicSchemeForLight, _lightDynamicScheme))) {
      return _cachedLightThemeData!;
    }

    ThemeData theme;
    switch (_themeSource) {
      case ThemeSource.baseline:
        if (_contrastLevel == ContrastLevel.high) {
          theme = AppTheme.lightHighContrastTheme;
        } else if (_contrastLevel == ContrastLevel.medium) {
          theme = AppTheme.lightMediumContrastTheme;
        } else {
          theme = AppTheme.lightTheme;
        }
        break;
      case ThemeSource.dynamicSystem:
        if (_lightDynamicScheme != null) {
          // If contrast is requested, we might need to re-generate from the seed of the dynamic scheme
          // because the raw scheme might be standard contrast.
          // However, if we simply want to follow system, we use the provided scheme.
          // To support "System Dynamic" + "High Contrast" override:
          if (_contrastLevel != ContrastLevel.normal) {
            // Re-seed from the primary color of the dynamic scheme to apply contrast
            theme = AppTheme.themeFromSeed(
                seedColor: _lightDynamicScheme!.primary,
                brightness: Brightness.light,
                contrastLevel: _contrastValue);
          } else {
            theme = AppTheme.buildThemeDataFromScheme(
                _lightDynamicScheme!, AppTheme.lightTheme.textTheme);
          }
        } else {
          // Fallback
          theme = AppTheme.lightTheme;
        }
        break;
      case ThemeSource.customSeed:
        final seed = _customSeedColor ?? Colors.blue;
        theme = AppTheme.themeFromSeed(
            seedColor: seed,
            brightness: Brightness.light,
            contrastLevel: _contrastValue);
        break;
    }

    _cachedLightThemeData = theme;
    _lastSourceForLight = _themeSource;
    _lastContrastForLight = _contrastLevel;
    _lastSeedForLight = _customSeedColor;
    _lastDynamicSchemeForLight = _lightDynamicScheme;

    return theme;
  }

  /// The currently active dark theme data.
  ThemeData get currentDarkThemeData {
    // Check cache
    if (_cachedDarkThemeData != null &&
        _lastSourceForDark == _themeSource &&
        _lastContrastForDark == _contrastLevel &&
        (_themeSource != ThemeSource.customSeed ||
            _lastSeedForDark == _customSeedColor) &&
        (_themeSource != ThemeSource.dynamicSystem ||
            identical(_lastDynamicSchemeForDark, _darkDynamicScheme))) {
      return _cachedDarkThemeData!;
    }

    ThemeData theme;
    switch (_themeSource) {
      case ThemeSource.baseline:
        if (_contrastLevel == ContrastLevel.high) {
          theme = AppTheme.darkHighContrastTheme;
        } else if (_contrastLevel == ContrastLevel.medium) {
          theme = AppTheme.darkMediumContrastTheme;
        } else {
          theme = AppTheme.darkTheme;
        }
        break;
      case ThemeSource.dynamicSystem:
        if (_darkDynamicScheme != null) {
          if (_contrastLevel != ContrastLevel.normal) {
            theme = AppTheme.themeFromSeed(
                seedColor: _darkDynamicScheme!.primary,
                brightness: Brightness.dark,
                contrastLevel: _contrastValue);
          } else {
            theme = AppTheme.buildThemeDataFromScheme(
                _darkDynamicScheme!, AppTheme.darkTheme.textTheme);
          }
        } else {
          theme = AppTheme.darkTheme;
        }
        break;
      case ThemeSource.customSeed:
        final seed = _customSeedColor ?? Colors.blue;
        theme = AppTheme.themeFromSeed(
            seedColor: seed,
            brightness: Brightness.dark,
            contrastLevel: _contrastValue);
        break;
    }

    _cachedDarkThemeData = theme;
    _lastSourceForDark = _themeSource;
    _lastContrastForDark = _contrastLevel;
    _lastSeedForDark = _customSeedColor;
    _lastDynamicSchemeForDark = _darkDynamicScheme;

    return theme;
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

      final themeSourceString = prefs.getString(_themeSourceKey);
      _themeSource = ThemeSource.values.firstWhere(
        (e) => e.name == themeSourceString,
        orElse: () => ThemeSource.baseline,
      );

      final contrastString = prefs.getString(_contrastLevelKey);
      _contrastLevel = ContrastLevel.values.firstWhere(
        (e) => e.name == contrastString,
        orElse: () => ContrastLevel.normal,
      );

      final seedColorValue = prefs.getInt(_customSeedColorKey);
      if (seedColorValue != null) {
        _customSeedColor = Color(seedColorValue);
      } else {
        _customSeedColor = null;
      }

      logger.i(
          "Theme prefs loaded: Mode=$_themeMode, Source=$_themeSource, Contrast=$_contrastLevel");
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
      _lightDynamicScheme = light;
      logger.i("New light dynamic scheme set.");
    }

    if (darkChanged) {
      _darkDynamicScheme = dark;
      logger.i("New dark dynamic scheme set.");
    }

    if ((lightChanged || darkChanged) &&
        _themeSource == ThemeSource.dynamicSystem) {
      logger.i(
          "Dynamic ColorSchemes updated and current source is dynamic. Notifying listeners.");
      _safeNotifyListeners();
    } else if (lightChanged || darkChanged) {
      logger.i(
          "Dynamic ColorSchemes updated but current source is not dynamic. No notification.");
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

  void setContrastLevel(ContrastLevel level) async {
    if (_contrastLevel == level || _isDisposed) return;
    _contrastLevel = level;
    _safeNotifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      await prefs.setString(_contrastLevelKey, level.name);
    } catch (e) {
      logger.e("Error saving contrast preference: $e");
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
