import 'package:flutter_bloc/flutter_bloc.dart';

/// A `Cubit` used to signal that reminder settings have changed.
///
/// This cubit emits an incremented integer state whenever settings change.
/// Other parts of the app can listen to this state change to react to updates
/// in reminder settings, which are stored elsewhere (e.g., in `SharedPreferences`).
class ReminderSettingsCubit extends Cubit<int> {
  ReminderSettingsCubit() : super(0);

  /// Notifies listeners that reminder settings have been updated.
  void notifySettingsChanged() {
    emit(state + 1);
  }
}
