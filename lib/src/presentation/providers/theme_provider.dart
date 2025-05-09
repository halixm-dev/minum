// lib/src/presentation/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minum/main.dart'; // For logger

class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'themePreference';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDisposed = false; // Flag to track disposal

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
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

      final themeString = prefs.getString(_themePrefKey);
      if (themeString == 'light') {
        _themeMode = ThemeMode.light;
      } else if (themeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      logger.i("Theme preference loaded: $_themeMode");
    } catch (e) {
      logger.e("Error loading theme preference: $e");
      _themeMode = ThemeMode.system;
    }
    _safeNotifyListeners();
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
