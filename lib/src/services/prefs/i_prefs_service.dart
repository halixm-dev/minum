abstract class IPrefsService {
  // --- Reminder Settings ---
  static const String keyRemindersEnabled = 'prefs_reminders_enabled';
  static const String keyReminderIntervalHours = 'prefs_reminder_interval_hours';
  static const String keyReminderStartTimeHour = 'prefs_reminder_start_time_hour';
  static const String keyReminderStartTimeMinute = 'prefs_reminder_start_time_minute';
  static const String keyReminderEndTimeHour = 'prefs_reminder_end_time_hour';
  static const String keyReminderEndTimeMinute = 'prefs_reminder_end_time_minute';
  static const String keyLastScheduledDate = 'prefs_last_scheduled_date';
  static const String keyFavoriteVolumes = 'prefs_favorite_volumes';

  // --- Pending Actions ---
  static const String keyPendingWaterAdditionMl = 'prefs_pending_water_addition_ml';

  // --- Health Connect ---
  static const String keyHealthConnectEnabled = 'prefs_health_connect_enabled';

  // --- Guest User Settings ---
  static const String keyGuestDailyGoalMl = 'prefs_guest_daily_goal_ml';
  static const String keyGuestPreferredUnit = 'prefs_guest_preferred_unit';
  static const String keyGuestFavoriteVolumes = 'prefs_guest_favorite_volumes';
  static const String keyGuestDateOfBirth = 'prefs_guest_date_of_birth';
  static const String keyGuestGender = 'prefs_guest_gender';
  static const String keyGuestWeightKg = 'prefs_guest_weight_kg';
  static const String keyGuestHeightCm = 'prefs_guest_height_cm';
  static const String keyGuestActivityLevel = 'prefs_guest_activity_level';
  static const String keyGuestHealthConditions = 'prefs_guest_health_conditions';
  static const String keyGuestSelectedWeather = 'prefs_guest_selected_weather';

  // --- Onboarding ---
  static const String keyOnboardingComplete = 'prefs_onboarding_complete';

  // --- Theme ---
  static const String keyThemeMode = 'prefs_theme_mode';
  static const String keyThemeSeedColor = 'prefs_theme_seed_color';
  static const String keyUseDynamicColor = 'prefs_use_dynamic_color';

  Future<void> init();

  // Typed getters
  Future<bool> getBool(String key, {bool defaultValue = false});
  Future<int> getInt(String key, {int defaultValue = 0});
  Future<double> getDouble(String key, {double defaultValue = 0.0});
  Future<String> getString(String key, {String defaultValue = ''});
  Future<List<String>> getStringList(String key, {List<String> defaultValue = const []});

  // Typed setters
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> setDouble(String key, double value);
  Future<void> setString(String key, String value);
  Future<void> setStringList(String key, List<String> value);

  // Removal
  Future<void> remove(String key);
}
