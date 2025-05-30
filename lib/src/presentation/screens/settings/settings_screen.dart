// lib/src/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_strings.dart'; // Assuming AppStrings class exists
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/data/models/user_model.dart'; // MeasurementUnit is here
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/providers/theme_provider.dart'; // ThemeProvider is here
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/providers/reminder_settings_notifier.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/src/services/notification_service.dart';
import 'package:minum/src/core/utils/unit_converter.dart' as unit_converter;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger
import 'package:shared_preferences/shared_preferences.dart';

const String prefsRemindersEnabled = 'prefs_reminders_enabled';
const String prefsReminderIntervalHours = 'prefs_reminder_interval_hours';
const String prefsReminderStartTimeHour = 'prefs_reminder_start_time_hour';
const String prefsReminderStartTimeMinute = 'prefs_reminder_start_time_minute';
const String prefsReminderEndTimeHour = 'prefs_reminder_end_time_hour';
const String prefsReminderEndTimeMinute = 'prefs_reminder_end_time_minute';

// Helper extension for ThemeProvider to get current theme name string
extension ThemeProviderName on ThemeProvider {
  String get currentThemeName {
    switch (themeMode) {
      case ThemeMode.light:
        return AppStrings.lightTheme; // Assuming AppStrings.lightTheme exists
      case ThemeMode.dark:
        return AppStrings.darkTheme; // Assuming AppStrings.darkTheme exists
      case ThemeMode.system:
        return AppStrings.systemTheme;
    }
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Loading...';

  // Helper to get display name for ThemeSource
  String _getThemeSourceName(ThemeSource source) {
    switch (source) {
      case ThemeSource.staticBaseline:
        return "Default"; // Placeholder for AppStrings.staticThemeName or similar
      case ThemeSource.dynamicSystem:
        return "System Dynamic"; // Placeholder for AppStrings.dynamicThemeName
      case ThemeSource.customSeed:
        return "Custom Color"; // Placeholder for AppStrings.customThemeName
    }
  }

  bool _enableReminders = true;
  double _selectedIntervalHours = 1.0;
  TimeOfDay _selectedStartTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 22, minute: 0);

  final TextEditingController _dailyGoalController = TextEditingController();
  MeasurementUnit _tempSelectedUnit = MeasurementUnit.ml;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadReminderSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateControllersFromProvider();
      }
    });
  }

  void _updateControllersFromProvider() {
    if (!mounted) return;
    final userProfile =
        Provider.of<UserProvider>(context, listen: false).userProfile;
    if (userProfile != null) {
      final String currentGoalText = userProfile.dailyGoalMl.toInt().toString();
      if (_dailyGoalController.text != currentGoalText) {
        _dailyGoalController.text = currentGoalText;
      }
      _tempSelectedUnit = userProfile.preferredUnit;
    } else {
      _dailyGoalController.text = "2000"; // Default goal if no profile
      _tempSelectedUnit = MeasurementUnit.ml; // Default unit
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _dailyGoalController.dispose();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion =
            '${packageInfo.version} (Build ${packageInfo.buildNumber})';
      });
    } catch (e) {
      logger.e("Error loading app version: $e");
      if (mounted) {
        setState(() {
          _appVersion = 'N/A';
        });
      }
    }
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enableReminders = prefs.getBool(prefsRemindersEnabled) ?? true;
      _selectedIntervalHours =
          prefs.getDouble(prefsReminderIntervalHours) ?? 1.0;
      _selectedStartTime = TimeOfDay(
        hour: prefs.getInt(prefsReminderStartTimeHour) ?? 8,
        minute: prefs.getInt(prefsReminderStartTimeMinute) ?? 0,
      );
      _selectedEndTime = TimeOfDay(
        hour: prefs.getInt(prefsReminderEndTimeHour) ?? 22,
        minute: prefs.getInt(prefsReminderEndTimeMinute) ?? 0,
      );
    });
  }

  Future<void> _saveReminderSettings({bool showSuccessSnackBar = true}) async {
    final prefs = await SharedPreferences.getInstance();
    // Capture context before await if it's to be used after for UI operations
    final currentContext = context;
    await prefs.setBool(prefsRemindersEnabled, _enableReminders);
    await prefs.setDouble(prefsReminderIntervalHours, _selectedIntervalHours);
    await prefs.setInt(prefsReminderStartTimeHour, _selectedStartTime.hour);
    await prefs.setInt(prefsReminderStartTimeMinute, _selectedStartTime.minute);
    await prefs.setInt(prefsReminderEndTimeHour, _selectedEndTime.hour);
    await prefs.setInt(prefsReminderEndTimeMinute, _selectedEndTime.minute);

    logger.i(
        "Reminder settings saved: Enabled: $_enableReminders, Interval: $_selectedIntervalHours hrs, Start: $_selectedStartTime, End: $_selectedEndTime");

    // Check mounted status of the captured context
    if (showSuccessSnackBar && currentContext.mounted) {
      // currentContext should be defined as before
      AppUtils.showSnackBar(currentContext, "Reminder settings saved!");
    }

    // _rescheduleNotifications(); // This will now be called by the service method triggered below.
    // Instead, directly call the new service method to handle scheduling logic.
    if (mounted) {
      // Ensure context is valid before using Provider
      Provider.of<NotificationService>(context, listen: false)
          .scheduleDailyRemindersIfNeeded(forceReschedule: true)
          .then((_) {
        // <-- forceReschedule: true
        logger.i(
            "SettingsScreen: scheduleDailyRemindersIfNeeded(forceReschedule: true) call completed after saving settings.");
        if (mounted) {
          // Ensure widget is still mounted
          Provider.of<ReminderSettingsNotifier>(context, listen: false)
              .notifySettingsChanged();
        }
      }).catchError((e) {
        logger.e(
            "SettingsScreen: Error calling scheduleDailyRemindersIfNeeded(forceReschedule: true): $e");
        if (mounted) {
          // Ensure widget is still mounted
          Provider.of<ReminderSettingsNotifier>(context, listen: false)
              .notifySettingsChanged();
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay initialTime =
        isStartTime ? _selectedStartTime : _selectedEndTime;
    // context (from method parameter) is captured before await
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isStartTime
          ? "Select Reminder Start Time"
          : "Select Reminder End Time",
    );

    if (!context.mounted) return;
    if (picked == null) return;

    bool isValidSelection = false;
    if (isStartTime) {
      if (_isTimeBeforeOrEqual(picked, _selectedEndTime)) {
        _selectedStartTime = picked;
        isValidSelection = true;
      } else {
        if (picked.hour > _selectedEndTime.hour ||
            (picked.hour == _selectedEndTime.hour &&
                picked.minute > _selectedEndTime.minute)) {
          _selectedStartTime = picked;
          isValidSelection = true;
        } else {
          // context is already checked for mounted status above
          AppUtils.showSnackBar(context,
              "Start time must be before end time for a same-day schedule.",
              isError: true);
        }
      }
    } else {
      if (_isTimeBeforeOrEqual(_selectedStartTime, picked)) {
        _selectedEndTime = picked;
        isValidSelection = true;
      } else {
        if (picked.hour < _selectedStartTime.hour ||
            (picked.hour == _selectedStartTime.hour &&
                picked.minute < _selectedStartTime.minute)) {
          _selectedEndTime = picked;
          isValidSelection = true;
        } else {
          // context is already checked for mounted status above
          AppUtils.showSnackBar(context,
              "End time must be after start time for a same-day schedule.",
              isError: true);
        }
      }
    }

    if (isValidSelection) {
      if (!mounted) return; // Check State's mounted status before setState
      setState(() {});
      _saveReminderSettings(); // This will use this.context, which is fine after mounted check
    }
  }

  bool _isTimeBeforeOrEqual(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute <= time2.minute) return true;
    return false;
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    logger.d("SettingsScreen: _showThemeDialog called");
    // context is used to show dialog, which is synchronous here.
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // dialogContext is fresh here
        return AlertDialog(
          title: const Text(AppStrings.theme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<ThemeMode>(
                title: const Text(AppStrings.lightTheme),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) themeProvider.setThemeMode(value);
                  // dialogContext is used to pop, check its mounted status
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text(AppStrings.darkTheme),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) themeProvider.setThemeMode(value);
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text(AppStrings.systemTheme),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) themeProvider.setThemeMode(value);
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDailyGoalManualDialog(
      BuildContext context, UserProvider userProvider) {
    // screenContext is captured here (it's the 'context' parameter)
    final BuildContext screenContext = context;

    showDialog<bool>(
      // Return type is bool: true if saved, false/null otherwise
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Set Daily Goal Manually"),
          content: _EditDailyGoalDialogContent(
            initialGoal:
                userProvider.userProfile?.dailyGoalMl.toInt().toString() ??
                    '2000',
            userProvider: userProvider,
          ),
          // Actions are now part of _EditDailyGoalDialogContent or handled via Navigator.pop
        );
      },
    ).then((saved) {
      if (saved == true) {
        if (screenContext.mounted) {
          AppUtils.showSnackBar(screenContext, "Daily goal updated!");
        }
      }
    });
  }

  Future<void> _handleCalculateSuggestion(BuildContext context,
      UserProvider userProvider, HydrationService hydrationService) async {
    final UserModel? currentUser = userProvider.userProfile;
    // Capture the initial context from the method parameter.
    final BuildContext initialContext = context;

    if (!initialContext.mounted) return;

    if (currentUser == null) {
      AppUtils.showSnackBar(
          initialContext, "User profile not available. Please try again later.",
          isError: true);
      return;
    }

    bool profileCompleteForCalc = currentUser.weightKg != null &&
        currentUser.weightKg! > 0 &&
        currentUser.age != null &&
        currentUser.gender != null &&
        currentUser.activityLevel != null;

    if (!profileCompleteForCalc) {
      // initialContext is used for showConfirmationDialog
      if (!initialContext.mounted) return;
      final bool? goToProfile = await AppUtils.showConfirmationDialog(
          initialContext,
          title: "Complete Profile",
          content:
              "To calculate a suggested goal, please complete your profile with Weight, Date of Birth, Gender, and Activity Level.\n\nWould you like to go to your profile now?",
          confirmText: "Go to Profile",
          cancelText: "Later");
      // After await, check initialContext.mounted again before navigation
      if (!initialContext.mounted) return;
      if (goToProfile == true) {
        Navigator.of(initialContext).pushNamed(AppRoutes.profile);
      }
      return;
    }

    if (!initialContext.mounted) return;
    AppUtils.showLoadingDialog(initialContext, message: "Calculating...");

    double suggestedGoal = 0;
    bool calculationSuccess = false;
    try {
      suggestedGoal = await hydrationService.calculateRecommendedDailyIntake(
          user: currentUser);
      calculationSuccess = true;
    } catch (e) {
      logger.e("Error calculating suggested goal: $e");
    }

    if (!initialContext.mounted) return;
    AppUtils.hideLoadingDialog(initialContext);

    if (!calculationSuccess) {
      AppUtils.showSnackBar(initialContext,
          "Could not calculate suggested goal. Please try again.",
          isError: true);
      return;
    }

    if (!initialContext.mounted) return;
    final bool? apply = await AppUtils.showConfirmationDialog(initialContext,
        title: "Suggested Goal",
        content:
            "Based on your profile, we suggest a daily goal of ${suggestedGoal.toInt()} ${AppStrings.ml}. Would you like to apply this goal?",
        confirmText: "Apply Goal",
        cancelText: "Not Now");

    if (!initialContext.mounted) return;
    if (apply == true) {
      await userProvider.updateDailyGoal(suggestedGoal);
      if (!initialContext.mounted) return;
      AppUtils.showSnackBar(
          initialContext, "Suggested goal applied and saved!");
    }
  }

  void _showDailyGoalOptionsDialog(BuildContext context,
      UserProvider userProvider, HydrationService hydrationService) {
    logger.d("SettingsScreen: _showDailyGoalOptionsDialog called");
    // screenContext is the 'context' parameter
    final BuildContext screenContext = context;

    showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        // dialogContext is fresh
        return AlertDialog(
          title: const Text(AppStrings.dailyWaterGoal),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text("Enter Manually"),
                onTap: () {
                  // screenContext is passed to the next dialog showing method
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showEditDailyGoalManualDialog(screenContext, userProvider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calculate_outlined),
                title: const Text("Calculate Suggestion"),
                onTap: () {
                  // screenContext is passed
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _handleCalculateSuggestion(
                      screenContext, userProvider, hydrationService);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text(AppStrings.cancel),
            )
          ],
        );
      },
    );
  }

  void _showEditMeasurementUnitDialog(
      BuildContext context, UserProvider userProvider) {
    logger.d("SettingsScreen: _showEditMeasurementUnitDialog called");
    _tempSelectedUnit =
        userProvider.userProfile?.preferredUnit ?? MeasurementUnit.ml;
    // screenContext is the 'context' parameter
    final BuildContext screenContext = context;

    showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        // dialogContext is fresh
        return StatefulBuilder(builder: (stfBuilderContext, setDialogState) {
          return AlertDialog(
            title: const Text(AppStrings.measurementUnit),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RadioListTile<MeasurementUnit>(
                  title: const Text(AppStrings.ml),
                  value: MeasurementUnit.ml,
                  groupValue: _tempSelectedUnit,
                  onChanged: (MeasurementUnit? value) {
                    if (value != null) {
                      setDialogState(() {
                        _tempSelectedUnit = value;
                      });
                    }
                  },
                ),
                RadioListTile<MeasurementUnit>(
                  title: const Text(AppStrings.oz),
                  value: MeasurementUnit.oz,
                  groupValue: _tempSelectedUnit,
                  onChanged: (MeasurementUnit? value) {
                    if (value != null) {
                      setDialogState(() {
                        _tempSelectedUnit = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text(AppStrings.cancel),
                  onPressed: () {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  }),
              TextButton(
                child: const Text(AppStrings.save),
                onPressed: () async {
                  await userProvider.updatePreferredUnit(_tempSelectedUnit);

                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();

                  if (!screenContext.mounted) return;
                  AppUtils.showSnackBar(
                      screenContext, "Measurement unit updated!");
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showEditFavoriteVolumesDialog(
      BuildContext context, UserProvider userProvider) {
    logger.d("SettingsScreen: _showEditFavoriteVolumesDialog called");
    List<TextEditingController> dialogControllers =
        (userProvider.userProfile?.favoriteIntakeVolumes ??
                ['250', '500', '750'])
            .map((vol) => TextEditingController(text: vol))
            .toList();

    if (dialogControllers.isEmpty) {
      dialogControllers.add(TextEditingController(text: '250'));
    }
    // screenContext is the 'context' parameter
    final BuildContext screenContext = context;

    showDialog<bool>(
      // Return type is bool: true if saved, false/null otherwise
      context: screenContext,
      barrierDismissible: false, // Usually good for multi-field dialogs
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
              "Edit Favorite Volumes (${userProvider.userProfile?.preferredUnit.displayName ?? AppStrings.ml})"),
          content:
              _EditFavoriteVolumesDialogContent(userProvider: userProvider),
          // Actions are now part of _EditFavoriteVolumesDialogContent or handled via Navigator.pop
        );
      },
    ).then((saved) {
      if (saved == true) {
        if (screenContext.mounted) {
          AppUtils.showSnackBar(screenContext, "Favorite volumes updated!");
        }
      }
    });
  }

  Future<void> _handleLogout() async {
    // screenContext is this.context
    final BuildContext screenContext = context;
    if (!screenContext.mounted) return;

    final authProvider =
        Provider.of<AuthProvider>(screenContext, listen: false);
    final bool? confirmed = await AppUtils.showConfirmationDialog(
      screenContext,
      title: AppStrings.logout,
      content: 'Are you sure you want to log out?',
      confirmText: AppStrings.logout,
    );

    if (!screenContext.mounted) return;
    if (confirmed == true) {
      await authProvider.signOut();
      // Assuming navigation to login is handled by an AuthWrapper or similar
    }
  }

  void _handleLogin() {
    // screenContext is this.context
    if (!context.mounted) return;
    // Pass the settings route as an argument so LoginScreen knows where to return.
    Navigator.of(context)
        .pushNamed(AppRoutes.login, arguments: AppRoutes.settings);
  }

  Future<void> _showIntervalPicker(BuildContext context) async {
    // Make it async
    logger.d(
        "SettingsScreen: _showIntervalPicker called (TimePicker M3 version)");

    // Convert current interval to TimeOfDay for picker's initialTime
    int currentTotalMinutes = (_selectedIntervalHours * 60).round();
    int initialPickerHours = currentTotalMinutes ~/ 60;
    int initialPickerMinutes = currentTotalMinutes % 60;

    // Cap initial hours for display if they exceed a typical interval range (e.g., 12 hours)
    // TimeOfDay itself supports 0-23. This is just for a more sensible initial display if desired.
    if (initialPickerHours > 12) initialPickerHours = 12;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: initialPickerHours, minute: initialPickerMinutes),
      helpText: "SELECT INTERVAL DURATION", // Crucial for user understanding
      initialEntryMode: TimePickerEntryMode.input, // <-- ADD THIS LINE
      builder: (BuildContext context, Widget? child) {
        // Using 24-hour format can be more intuitive for duration.
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    // Check if the State is still mounted before using its context or calling setState
    if (!mounted || picked == null) return;

    double newIntervalHours = picked.hour + (picked.minute / 60.0);

    bool adjustedToMinimum = false;
    // Enforce minimum interval of 15 minutes (0.25 hours).
    // Using a small epsilon for floating point comparison might be safer,
    // but typically direct comparison is fine for this scenario.
    // Let's ensure any value that would result in less than 15 minutes (e.g. 0h0m, 0h5m, 0h10m) triggers this.
    // 0 hours 0 minutes is 0.0. 0 hours 14 minutes is 14/60 = 0.233.
    // So newIntervalHours < 0.25 is the correct condition.
    if (newIntervalHours < 0.25) {
      newIntervalHours = 0.25;
      adjustedToMinimum = true;
    }

    // Update state and save settings
    setState(() {
      _selectedIntervalHours = newIntervalHours;
    });
    _saveReminderSettings(showSuccessSnackBar: !adjustedToMinimum); // New call

    // Show SnackBar if the value was adjusted
    // Ensure to use a context that is still valid and part of the main widget tree for SnackBar.
    // 'context' passed to _showIntervalPicker should be fine if 'mounted' check passed.
    if (adjustedToMinimum) {
      if (context.mounted) {
        // Explicit check on the context parameter
        AppUtils.showSnackBar(context,
            "Minimum reminder interval is 15 minutes. Setting to 15m.", // Simplified message
            isError: false // Or true, for emphasis
            );
      }
    }
  }

  void _sendTestNotification() {
    if (!mounted) return; // Ensure the widget is still mounted

    final notificationService =
        Provider.of<NotificationService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userProfile = userProvider.userProfile;

    List<String> favoriteVolumes;
    if (userProfile != null && userProfile.favoriteIntakeVolumes.isNotEmpty) {
      favoriteVolumes = userProfile.favoriteIntakeVolumes;
    } else {
      favoriteVolumes = ['100', '250', '500']; // Default values
      logger.i(
          "Test notification: Using default favorite volumes as user profile/volumes are not set.");
    }

    // Schedule an immediate notification with a unique ID for testing
    notificationService.showSimpleNotification(
      id: 99, // A unique ID for the test notification
      title: AppStrings.reminderTitle,
      body: "Time for some water! Stay hydrated.",
      favoriteVolumesMl: favoriteVolumes, // Pass the favorite volumes
      payload: {'type': 'hydration_reminder_test'}, // Updated payload
    );

    // Show a SnackBar to confirm the notification was sent
    AppUtils.showSnackBar(
        context, "Test notification sent with favorite volumes!");

    logger.i(
        "Test notification sent from settings screen with volumes: $favoriteVolumes.");
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final hydrationService =
        Provider.of<HydrationService>(context, listen: false);
    final theme = Theme.of(context); // For easy access

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: 16.w, vertical: 16.h), // M3 typical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildGeneralSettingsSection(
                context, theme, themeProvider, userProvider, hydrationService),
            _buildRemindersSection(context, theme),
            _buildAccountActionsSection(context, theme, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettingsSection(
      BuildContext context,
      ThemeData theme,
      ThemeProvider themeProvider,
      UserProvider userProvider,
      HydrationService hydrationService) {
    final userProfile = userProvider.userProfile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.general, theme),
        _buildSettingsTile(
          context: context,
          icon: Icons.person_outline,
          title: AppStrings.profile,
          subtitle: "Manage your personal details",
          onTap: () {
            if (!context.mounted) return;
            Navigator.of(context).pushNamed(AppRoutes.profile);
          },
        ),
        _buildSettingsTile(
          context: context,
          icon: Icons.color_lens_outlined,
          title: AppStrings.theme,
          subtitle:
              "${_getThemeSourceName(themeProvider.themeSource)} / ${themeProvider.currentThemeName}",
          onTap: () => _showThemeDialog(context, themeProvider),
        ),
        _buildSettingsTile(
          context: context,
          icon: Icons.water_drop_outlined,
          title: AppStrings.dailyWaterGoal,
          subtitle: userProfile != null
              ? unit_converter.formatVolume(
                  userProfile.dailyGoalMl, userProfile.preferredUnit)
              : 'N/A',
          onTap: () => _showDailyGoalOptionsDialog(
              context, userProvider, hydrationService),
        ),
        _buildSettingsTile(
          context: context,
          icon: Icons.straighten_outlined,
          title: AppStrings.measurementUnit,
          subtitle: userProfile?.preferredUnit.displayName ?? AppStrings.ml,
          onTap: () => _showEditMeasurementUnitDialog(context, userProvider),
        ),
        _buildSettingsTile(
          context: context,
          icon: Icons.format_list_numbered_outlined,
          title: "Favorite Quick Add Volumes",
          subtitle: userProfile != null &&
                  userProfile.favoriteIntakeVolumes.isNotEmpty
              ? '${userProfile.favoriteIntakeVolumes.map((volStr) {
                  double volMl = double.tryParse(volStr) ?? 0;
                  return unit_converter.formatVolume(
                      volMl, userProfile.preferredUnit,
                      includeUnitString: false);
                }).join(', ')} ${userProfile.preferredUnit.displayName}'
              : "N/A",
          onTap: () => _showEditFavoriteVolumesDialog(context, userProvider),
        ),
      ],
    );
  }

  Widget _buildRemindersSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.reminders, theme),
        SwitchListTile(
          title: Text(AppStrings.enableReminders,
              style: theme.textTheme.titleMedium),
          value: _enableReminders,
          onChanged: (bool value) {
            if (!mounted) return;
            setState(() {
              _enableReminders = value;
            });
            _saveReminderSettings();
          },
          secondary: Icon(Icons.notifications_active_outlined,
              color: theme.colorScheme.onSurfaceVariant),
          activeColor: theme.colorScheme.primary,
          inactiveThumbColor: theme.colorScheme.outline,
          inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
        ),
        if (_enableReminders) ...[
          _buildSettingsTile(
            context: context,
            icon: Icons.hourglass_empty_outlined,
            title: "Reminder Interval",
            subtitle: () {
              if (_selectedIntervalHours <= 0) return "N/A";
              int totalMinutes = (_selectedIntervalHours * 60).round();
              int hours = totalMinutes ~/ 60;
              int minutes = totalMinutes % 60;
              if (hours > 0 && minutes > 0) return "${hours}h ${minutes}m";
              if (hours > 0 && minutes == 0) return "${hours}h";
              if (hours == 0 && minutes > 0) return "${minutes}m";
              return "${minutes}m";
            }(),
            onTap: () => _showIntervalPicker(context),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.schedule_outlined,
            title: "Reminder Start Time",
            subtitle: _selectedStartTime.format(context),
            onTap: () => _selectTime(context, true),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.watch_later_outlined,
            title: "Reminder End Time",
            subtitle: _selectedEndTime.format(context),
            onTap: () => _selectTime(context, false),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.notifications_none,
            title: "Send Test Notification",
            subtitle:
                "Tap to send an immediate test notification to check if notifications are working.",
            onTap: _sendTestNotification,
          ),
        ],
      ],
    );
  }

  Widget _buildAccountActionsSection(
      BuildContext context, ThemeData theme, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
            height: 32.h,
            thickness: 1,
            color: theme.colorScheme.outlineVariant),
        if (authProvider.isAuthenticated)
          _buildSettingsTile(
            context: context,
            icon: Icons.logout_outlined,
            title: AppStrings.logout,
            onTap: _handleLogout,
            textColor: theme.colorScheme.error,
            iconColor: theme.colorScheme.error,
          )
        else
          _buildSettingsTile(
            context: context,
            icon: Icons.login_outlined,
            title: "Login / Sign Up",
            onTap: _handleLogin,
            textColor: theme.colorScheme.primary,
            iconColor: theme.colorScheme.primary,
          ),
        SizedBox(height: 24.h),
        Center(
          child: Text(
            '${AppStrings.appName} - Version: $_appVersion',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h), // M3 typical spacing
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor, // For specific cases like error or primary colored text
    Color? iconColor, // For specific cases like error or primary colored icon
  }) {
    final theme = Theme.of(context);

    // Determine colors based on M3 defaults and overrides
    final Color finalIconColor =
        iconColor ?? theme.colorScheme.onSurfaceVariant;
    final Color finalTitleColor = textColor ?? theme.colorScheme.onSurface;
    final Color finalSubtitleColor =
        textColor?.withValues(alpha: 0.7) ?? theme.colorScheme.onSurfaceVariant;

    return ListTile(
      leading: Icon(icon, color: finalIconColor),
      title: Text(title,
          style: theme.textTheme.titleMedium?.copyWith(color: finalTitleColor)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: finalSubtitleColor))
          : null,
      onTap: onTap,
    );
  }
}

// New StatefulWidget for the Favorite Volumes dialog content
class _EditFavoriteVolumesDialogContent extends StatefulWidget {
  final UserProvider userProvider;

  const _EditFavoriteVolumesDialogContent({required this.userProvider});

  @override
  State<_EditFavoriteVolumesDialogContent> createState() =>
      _EditFavoriteVolumesDialogContentState();
}

class _EditFavoriteVolumesDialogContentState
    extends State<_EditFavoriteVolumesDialogContent> {
  final List<TextEditingController> _volumeControllers = [];
  final List<FocusNode> _volumeFocusNodes = [];
  final _formKey = GlobalKey<FormState>(); // For validation across all fields

  @override
  void initState() {
    super.initState();
    final userProfile = widget.userProvider.userProfile;
    final initialVolumes =
        userProfile?.favoriteIntakeVolumes ?? ['250', '500', '750'];
    final displayUnit = userProfile?.preferredUnit ?? MeasurementUnit.ml;

    if (initialVolumes.isEmpty) {
      // Ensure at least one field
      _addVolumeField(
          text: displayUnit == MeasurementUnit.oz
              ? unit_converter.convertMlToOz(250).toStringAsFixed(1)
              : '250');
    } else {
      for (var volStr in initialVolumes) {
        double volMl = double.tryParse(volStr) ?? 0;
        String displayText;
        if (displayUnit == MeasurementUnit.oz) {
          displayText = unit_converter.convertMlToOz(volMl).toStringAsFixed(1);
        } else {
          displayText = volMl.toInt().toString();
        }
        _addVolumeField(text: displayText);
      }
    }
    // Request focus for the last added field after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _volumeFocusNodes.isNotEmpty) {
        _volumeFocusNodes.last.requestFocus();
      }
    });
  }

  void _addVolumeField({String? text}) {
    if (_volumeControllers.length < 3) {
      // Changed 5 to 3
      final controller = TextEditingController(text: text ?? '');
      final focusNode = FocusNode();
      setState(() {
        _volumeControllers.add(controller);
        _volumeFocusNodes.add(focusNode);
      });
      // Request focus for the new field after the frame renders
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          focusNode.requestFocus();
        }
      });
    }
  }

  void _removeVolumeField(int index) {
    if (_volumeControllers.length > 1) {
      // Ensure at least one field remains
      _volumeFocusNodes[index].dispose();
      _volumeControllers[index].dispose();
      setState(() {
        _volumeControllers.removeAt(index);
        _volumeFocusNodes.removeAt(index);
      });
    } else {
      AppUtils.showSnackBar(
          context, "At least one favorite volume is required.",
          isError: true);
    }
  }

  @override
  void dispose() {
    for (var controller in _volumeControllers) {
      controller.dispose();
    }
    for (var focusNode in _volumeFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _saveFavoriteVolumes() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final displayUnit =
        widget.userProvider.userProfile?.preferredUnit ?? MeasurementUnit.ml;
    final List<String> newVolumesInMl = _volumeControllers.map((controller) {
      String text = controller.text.trim();
      if (text.isEmpty) return ''; // Handle empty strings
      double? val = double.tryParse(text);
      if (val == null) return ''; // Handle unparseable strings

      if (displayUnit == MeasurementUnit.oz) {
        // Convert oz to mL and round to nearest whole number, then to string
        return unit_converter.convertOzToMl(val).round().toString();
      } else {
        // Ensure it's a whole number string for mL
        return val.round().toString();
      }
    }).where((text) {
      if (text.isEmpty) return false;
      final val = double.tryParse(text);
      // Basic validation for mL values
      return val != null && val > 0 && val < 5000;
    }).toList();

    // Ensure there's at least one volume, or use defaults if all are cleared/invalid
    final List<String> volumesToSave = newVolumesInMl.isNotEmpty
        ? newVolumesInMl
        : const ['250', '500', '750'];

    try {
      await widget.userProvider.updateFavoriteIntakeVolumes(volumesToSave);
      if (mounted) Navigator.of(context).pop(true); // Pop with true for success
    } catch (e) {
      logger.e("Error saving favorite volumes: $e");
      if (mounted) {
        AppUtils.showSnackBar(
            context, "Failed to save volumes. Please try again.",
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ...List.generate(_volumeControllers.length, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _volumeControllers[index],
                        focusNode: _volumeFocusNodes[index],
                        decoration: InputDecoration(
                          labelText: "Volume ${index + 1}",
                          hintText:
                              "e.g., ${widget.userProvider.userProfile?.preferredUnit == MeasurementUnit.oz ? unit_converter.convertMlToOz(250).toStringAsFixed(1) : '250'}",
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: widget
                                    .userProvider.userProfile?.preferredUnit ==
                                MeasurementUnit.oz),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(
                              widget.userProvider.userProfile?.preferredUnit ==
                                      MeasurementUnit.oz
                                  ? r'^\d*\.?\d*$'
                                  : r'^\d*'))
                        ],
                        validator: (val) => AppUtils.validateNumber(val,
                            allowDecimal: widget
                                    .userProvider.userProfile?.preferredUnit ==
                                MeasurementUnit.oz),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle,
                          color: Theme.of(context)
                              .colorScheme
                              .error), // Changed to filled
                      onPressed: _volumeControllers.length > 1
                          ? () => _removeVolumeField(index)
                          : null,
                    ),
                  ],
                ),
              );
            }),
            if (_volumeControllers.length < 3) // Changed 5 to 3
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _addVolumeField(),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Add Volume"),
                ),
              ),
            if (_volumeControllers
                .isEmpty) // Should not happen if logic is correct, but as a fallback UI
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text("Add at least one volume.",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    if (mounted) Navigator.of(context).pop(false);
                  },
                  child: const Text(AppStrings.cancel),
                ),
                TextButton(
                  onPressed: _saveFavoriteVolumes,
                  child: const Text(AppStrings.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// New StatefulWidget for the dialog content
class _EditDailyGoalDialogContent extends StatefulWidget {
  final String initialGoal;
  final UserProvider userProvider;

  const _EditDailyGoalDialogContent({
    required this.initialGoal,
    required this.userProvider,
  });

  @override
  State<_EditDailyGoalDialogContent> createState() =>
      _EditDailyGoalDialogContentState();
}

class _EditDailyGoalDialogContentState
    extends State<_EditDailyGoalDialogContent> {
  late TextEditingController _goalController;
  late FocusNode _goalFocusNode;
  final _formKey = GlobalKey<FormState>(); // For validation

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: widget.initialGoal);
    _goalFocusNode = FocusNode();
    // Request focus after the first frame to ensure the field is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _goalFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    _goalFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newGoal = double.tryParse(_goalController.text);
      if (newGoal != null && newGoal > 0) {
        await widget.userProvider.updateDailyGoal(newGoal);
        if (mounted) {
          Navigator.of(context).pop(true); // Pop with true to indicate success
        }
      } else {
        // This case should ideally be caught by the validator, but as a fallback:
        if (mounted) {
          AppUtils.showSnackBar(context, "Please enter a valid goal.",
              isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: _goalController,
            focusNode: _goalFocusNode,
            decoration: const InputDecoration(
              labelText: "Goal (${AppStrings.ml})",
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (val) => AppUtils.validateNumber(val),
            onFieldSubmitted: (_) => _saveGoal(), // Allow saving on submit
          ),
          SizedBox(height: 20.h), // Add some spacing before buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop(false); // Pop with false
                  }
                },
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: _saveGoal,
                child: const Text(AppStrings.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
