// lib/src/presentation/providers/bottom_nav_provider.dart
import 'package:flutter/material.dart';

/// A `ChangeNotifier` that manages the state of the bottom navigation bar.
class BottomNavProvider with ChangeNotifier {
  int _currentIndex = 0;

  /// The currently selected index of the bottom navigation bar.
  int get currentIndex => _currentIndex;

  /// Sets the current index of the bottom navigation bar and notifies listeners.
  ///
  /// If the new [index] is the same as the current index, no action is taken.
  void setCurrentIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }
}
