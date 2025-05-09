// lib/src/presentation/providers/bottom_nav_provider.dart
import 'package:flutter/material.dart';

class BottomNavProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    if (_currentIndex == index) return; // No change
    _currentIndex = index;
    notifyListeners();
  }
}
