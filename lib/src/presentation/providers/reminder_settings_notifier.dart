// lib/src/presentation/providers/reminder_settings_notifier.dart
import 'package:flutter/foundation.dart';

/// A `ChangeNotifier` used to signal that reminder settings have changed.
///
/// This provider does not hold any state itself. It simply provides a
/// `notifyListeners` method that other parts of the app can listen to
/// in order to react to changes in reminder settings, which are stored
/// elsewhere (e.g., in `SharedPreferences`).
class ReminderSettingsNotifier with ChangeNotifier {
  /// Notifies listeners that reminder settings have been updated.
  void notifySettingsChanged() {
    notifyListeners();
  }
}
