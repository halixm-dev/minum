// lib/src/presentation/providers/reminder_settings_notifier.dart
import 'package:flutter/foundation.dart';

class ReminderSettingsNotifier with ChangeNotifier {
  void notifySettingsChanged() {
    notifyListeners();
  }
}
