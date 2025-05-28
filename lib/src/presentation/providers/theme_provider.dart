// lib/src/presentation/providers/theme_provider.dart
// dynamic_color import removed as CorePalette is no longer used.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minum/main.dart'; // For logger
import 'package:minum/src/core/theme/app_theme.dart';

enum ThemeSource { staticBaseline, dynamicSystem, customSeed }

class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'themePreference'; // For ThemeMode (light/dark/system)
  static const String _themeSourceKey = 'themeSource';
  static const String _customSeedColorKey = 'customSeedColor';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeSource _themeSource = ThemeSource.staticBaseline;
  ColorScheme? _lightDynamicScheme; // Changed from CorePalette
  ColorScheme? _darkDynamicScheme;  // Changed from CorePalette
  Color? _customSeedColor; // Store the user's custom seed color

  bool _isDisposed = false; // Flag to track disposal

  ThemeMode get themeMode => _themeMode;
  ThemeSource get themeSource => _themeSource; // Expose for UI if needed
  Color? get customSeedColor => _customSeedColor; // Expose for UI if needed

  ThemeData get currentLightThemeData {
    switch (_themeSource) {
      case ThemeSource.dynamicSystem:
        if (_lightDynamicScheme != null) {
          logger.i("Using dynamic system scheme for light theme.");
          return AppTheme.buildThemeDataFromScheme(_lightDynamicScheme!, Brightness.light);
        }
        logger.w("Dynamic system source selected for light theme, but _lightDynamicScheme is null. Falling back to static baseline.");
        return AppTheme.lightTheme; 
      case ThemeSource.customSeed:
        if (_customSeedColor != null) {
          logger.i("Using custom seed color for light theme: $_customSeedColor");
          return AppTheme.themeFromSeed(seedColor: _customSeedColor!, brightness: Brightness.light);
        }
        logger.w("Custom seed source selected for light theme, but customSeedColor is null. Falling back to static baseline.");
        return AppTheme.lightTheme;
      case ThemeSource.staticBaseline:
        logger.i("Using static baseline light theme.");
        return AppTheme.lightTheme;
    }
  }

  ThemeData get currentDarkThemeData {
    switch (_themeSource) {
      case ThemeSource.dynamicSystem:
        if (_darkDynamicScheme != null) {
          logger.i("Using dynamic system scheme for dark theme.");
          return AppTheme.buildThemeDataFromScheme(_darkDynamicScheme!, Brightness.dark);
        }
        logger.w("Dynamic system source selected for dark theme, but _darkDynamicScheme is null. Falling back to static baseline.");
        return AppTheme.darkTheme;
      case ThemeSource.customSeed:
        if (_customSeedColor != null) {
          logger.i("Using custom seed color for dark theme: $_customSeedColor");
          return AppTheme.themeFromSeed(seedColor: _customSeedColor!, brightness: Brightness.dark);
        }
        logger.w("Custom seed source selected for dark theme, but customSeedColor is null. Falling back to static baseline.");
        return AppTheme.darkTheme;
      case ThemeSource.staticBaseline:
        logger.i("Using static baseline dark theme.");
        return AppTheme.darkTheme;
    }
  }

  ThemeProvider() {
    _loadThemePreference(); // This will now load ThemeMode, ThemeSource, and CustomSeedColor
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    } else {
      logger.w("ThemeProvider: Attempted to call notifyListeners() after dispose.");
    }
  }

  Future<void> _loadThemePreference() async {
    if (_isDisposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return; // Check again after await

      // Load ThemeMode
      final themeModeString = prefs.getString(_themePrefKey);
      if (themeModeString == 'light') {
        _themeMode = ThemeMode.light;
      } else if (themeModeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system; // Default
      }
      logger.i("ThemeMode loaded: $_themeMode");

      // Load ThemeSource
      final themeSourceString = prefs.getString(_themeSourceKey);
      _themeSource = ThemeSource.values.firstWhere(
        (e) => e.name == themeSourceString,
        orElse: () => ThemeSource.staticBaseline, // Default
      );
      logger.i("ThemeSource loaded: $_themeSource");

      // Load CustomSeedColor
      final seedColorValue = prefs.getInt(_customSeedColorKey);
      if (seedColorValue != null) {
        _customSeedColor = Color(seedColorValue);
        logger.i("CustomSeedColor loaded: $_customSeedColor");
      } else {
        _customSeedColor = null; // Ensure it's null if not found
        logger.i("CustomSeedColor not found, set to null.");
      }

    } catch (e) {
      logger.e("Error loading theme preferences: $e");
      // Defaults are already set at declaration
    }
    _safeNotifyListeners();
  }

  void setDynamicColorSchemes(ColorScheme? light, ColorScheme? dark) {
    if (_isDisposed) return;
    _lightDynamicScheme = light;
    _darkDynamicScheme = dark;
    if (_themeSource == ThemeSource.dynamicSystem) {
      logger.i("Dynamic ColorSchemes updated. Notifying listeners as current source is dynamic.");
      _safeNotifyListeners();
    } else {
      logger.i("Dynamic ColorSchemes updated. Current source is not dynamic, no immediate notification.");
    }
  }

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

  Future<void> setCustomSeedColor(Color color) async {
    if (_customSeedColor == color || _isDisposed) return;

    _customSeedColor = color;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      await prefs.setInt(_customSeedColorKey, color.toARGB32()); // Changed from color.value
      logger.i("CustomSeedColor preference saved: $_customSeedColor");
      if (_themeSource == ThemeSource.customSeed) {
        logger.i("Current source is custom. Notifying listeners for seed color change.");
        _safeNotifyListeners();
      } else {
        logger.i("Current source is not custom. Seed color saved, no immediate notification.");
      }
    } catch (e) {
      logger.e("Error saving CustomSeedColor preference: $e");
    }
    // No notifyListeners here if not custom, as it's a preference for future use
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode || _isDisposed) return;

    _themeMode = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return; // Check again after await

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
