// lib/src/features/settings/presentation/pages/settings_screen.dart
import 'package:flutter/material.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:minum/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_event.dart';
import 'package:minum/src/features/user/presentation/bloc/user_state.dart';
import 'package:minum/src/presentation/providers/theme_provider.dart';
import 'package:minum/src/features/settings/presentation/bloc/reminder_settings_cubit.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/src/services/i_notification_service.dart';
import 'package:minum/src/services/i_health_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:minum/src/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minum/src/core/di/injection_container.dart';
import 'package:minum/src/features/settings/presentation/widgets/theme_selector.dart';
import 'package:minum/src/features/settings/presentation/widgets/daily_goal_slider_dialog.dart';
import 'package:minum/src/features/settings/presentation/widgets/edit_favorite_volumes_dialog.dart';

/// SharedPreferences key for enabling/disabling reminders.
const String prefsRemindersEnabled = 'prefs_reminders_enabled';

/// SharedPreferences key for Health Connect integration.
const String prefsHealthConnectEnabled = 'prefs_health_connect_enabled';

/// SharedPreferences key for the reminder interval in hours.
const String prefsReminderIntervalHours = 'prefs_reminder_interval_hours';

/// SharedPreferences key for the reminder start time hour.
const String prefsReminderStartTimeHour = 'prefs_reminder_start_time_hour';

/// SharedPreferences key for the reminder start time minute.
const String prefsReminderStartTimeMinute = 'prefs_reminder_start_time_minute';

/// SharedPreferences key for the reminder end time hour.
const String prefsReminderEndTimeHour = 'prefs_reminder_end_time_hour';

/// SharedPreferences key for the reminder end time minute.
const String prefsReminderEndTimeMinute = 'prefs_reminder_end_time_minute';

/// An extension on [ThemeProvider] to get a displayable string for the current theme mode.
extension ThemeProviderName on ThemeProvider {
  /// Returns a user-friendly string representation of the current [ThemeMode].
  String get currentThemeName {
    switch (themeMode) {
      case ThemeMode.light:
        return AppStrings.lightTheme;
      case ThemeMode.dark:
        return AppStrings.darkTheme;
      case ThemeMode.system:
        return AppStrings.systemTheme;
    }
  }
}

/// A screen that allows the user to configure various application settings.
///
/// This includes general settings like profile and theme, reminder settings,
/// and account actions like logging in or out.
class SettingsScreen extends StatefulWidget {
  /// Creates a `SettingsScreen`.
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Loading...';

  bool _enableReminders = true;
  bool _healthConnectEnabled = false;
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
    _loadHealthConnectSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateControllersFromProvider();
      }
    });
  }

  /// Updates the text controllers with data from the [UserProvider].
  void _updateControllersFromProvider() {
    if (!mounted) return;
    final userState = context.read<UserBloc>().state;
    final userProfile = userState is UserLoaded ? userState.user : null;
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
  void dispose() {
    _dailyGoalController.dispose();
    super.dispose();
  }

  /// Loads the application's version and build number from [PackageInfo].
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

  /// Loads reminder settings from [SharedPreferences].
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

  /// Loads Health Connect settings from [SharedPreferences].
  Future<void> _loadHealthConnectSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _healthConnectEnabled = prefs.getBool(prefsHealthConnectEnabled) ?? false;
    });
  }

  /// Toggles Health Connect integration.
  Future<void> _toggleHealthConnect(bool value) async {
    if (value) {
      final healthService = sl<IHealthService>();
      bool granted = await healthService.requestPermissions();
      if (!granted) {
        if (mounted) {
          AppUtils.showSnackBar(context, AppStrings.googleFitPermissionsDenied,
              isError: true);
        }
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsHealthConnectEnabled, value);
    if (!mounted) return;
    setState(() {
      _healthConnectEnabled = value;
    });

    if (value) {
      AppUtils.showSnackBar(context, AppStrings.googleFitEnabled);
    } else {
      AppUtils.showSnackBar(context, AppStrings.googleFitDisabled);
    }
  }

  /// Saves the current reminder settings to [SharedPreferences] and reschedules notifications.
  Future<void> _saveReminderSettings({bool showSuccessSnackBar = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentContext = context;
    await prefs.setBool(prefsRemindersEnabled, _enableReminders);
    await prefs.setDouble(prefsReminderIntervalHours, _selectedIntervalHours);
    await prefs.setInt(prefsReminderStartTimeHour, _selectedStartTime.hour);
    await prefs.setInt(prefsReminderStartTimeMinute, _selectedStartTime.minute);
    await prefs.setInt(prefsReminderEndTimeHour, _selectedEndTime.hour);
    await prefs.setInt(prefsReminderEndTimeMinute, _selectedEndTime.minute);

    logger.i(
        "Reminder settings saved: Enabled: $_enableReminders, Interval: $_selectedIntervalHours hrs, Start: $_selectedStartTime, End: $_selectedEndTime");

    if (showSuccessSnackBar && currentContext.mounted) {
      AppUtils.showSnackBar(currentContext, AppStrings.reminderSettingsSaved);
    }

    if (mounted) {
      Provider.of<INotificationService>(context, listen: false)
          .scheduleDailyRemindersIfNeeded(forceReschedule: true)
          .then((_) {
        logger.i(
            "SettingsScreen: scheduleDailyRemindersIfNeeded(forceReschedule: true) call completed after saving settings.");
        if (mounted) {
          context.read<ReminderSettingsCubit>().notifySettingsChanged();
        }
      }).catchError((e) {
        logger.e(
            "SettingsScreen: Error calling scheduleDailyRemindersIfNeeded(forceReschedule: true): $e");
        if (mounted) {
          context.read<ReminderSettingsCubit>().notifySettingsChanged();
        }
      });
    }
  }

  /// Shows a time picker to select the start or end time for reminders.
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay initialTime =
        isStartTime ? _selectedStartTime : _selectedEndTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isStartTime
          ? AppStrings.selectReminderStartTime
          : AppStrings.selectReminderEndTime,
    );

    if (!context.mounted || picked == null) return;

    bool isValidSelection = false;
    if (isStartTime) {
      if (_isTimeBeforeOrEqual(picked, _selectedEndTime)) {
        _selectedStartTime = picked;
        isValidSelection = true;
      } else {
        AppUtils.showSnackBar(context,
            AppStrings.startTimeBeforeEndTime,
            isError: true);
      }
    } else {
      if (_isTimeBeforeOrEqual(_selectedStartTime, picked)) {
        _selectedEndTime = picked;
        isValidSelection = true;
      } else {
        AppUtils.showSnackBar(context,
            AppStrings.endTimeAfterStartTime,
            isError: true);
      }
    }

    if (isValidSelection) {
      if (!mounted) return;
      setState(() {});
      _saveReminderSettings();
    }
  }

  /// Checks if [time1] is before or equal to [time2].
  bool _isTimeBeforeOrEqual(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute <= time2.minute) return true;
    return false;
  }

  /// Shows a bottom sheet for selecting the app's theme mode and color scheme.
  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    logger.d("SettingsScreen: _showThemeDialog called (BottomSheet)");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const ThemeSelector();
      },
    );
  }

  /// Shows a dialog with a slider for setting the daily goal, including a snap-to-suggestion feature.
  Future<void> _showDailyGoalSliderDialog(BuildContext context,
      UserModel? currentUser, HydrationService hydrationService) async {
    if (currentUser == null) return;

    final BuildContext screenContext = context;

    // We can show a loading state in the dialog or pre-calculate.
    // Let's pre-calculate quickly or show a spinner inside.
    // Better UX: Show dialog immediately with current goal, update suggestion when ready.

    await showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return DailyGoalSliderDialog(
          initialGoal: currentUser.dailyGoalMl,
          userBloc: context.read<UserBloc>(),
          currentUser: currentUser,
          hydrationService: hydrationService,
        );
      },
    );
  }

  /// Shows a dialog for editing the user's preferred measurement unit (mL or oz).
  void _showEditMeasurementUnitDialog(
      BuildContext context, UserModel? currentUser) {
    logger.d("SettingsScreen: _showEditMeasurementUnitDialog called");
    _tempSelectedUnit = currentUser?.preferredUnit ?? MeasurementUnit.ml;
    final BuildContext screenContext = context;

    showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (stfBuilderContext, setDialogState) {
          return AlertDialog(
            title: const Text(AppStrings.measurementUnit),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RadioGroup<MeasurementUnit>(
                  groupValue: _tempSelectedUnit,
                  onChanged: (MeasurementUnit? value) {
                    if (value != null) {
                      setDialogState(() {
                        _tempSelectedUnit = value;
                      });
                    }
                  },
                  child: Column(
                    children: [
                      RadioListTile<MeasurementUnit>(
                        title: const Text(AppStrings.ml),
                        value: MeasurementUnit.ml,
                      ),
                      RadioListTile<MeasurementUnit>(
                        title: const Text(AppStrings.oz),
                        value: MeasurementUnit.oz,
                      ),
                    ],
                  ),
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
                  if (currentUser != null) {
                    final updatedUser =
                        currentUser.copyWith(preferredUnit: _tempSelectedUnit);
                    screenContext
                        .read<UserBloc>()
                        .add(UpdateUserProfile(updatedUser));
                  }

                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();

                  if (!screenContext.mounted) return;
                  AppUtils.showSnackBar(
                      screenContext, AppStrings.measurementUnitUpdated);
                },
              ),
            ],
          );
        });
      },
    );
  }

  /// Shows a dialog for editing the user's favorite intake volumes for quick adds.
  void _showEditFavoriteVolumesDialog(
      BuildContext context, UserModel? currentUser) {
    logger.d("SettingsScreen: _showEditFavoriteVolumesDialog called");
    final BuildContext screenContext = context;

    showDialog<bool>(
      context: screenContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
              AppStrings.editFavoriteVolumesTitle(currentUser?.preferredUnit.displayName ?? AppStrings.ml)),
          content: EditFavoriteVolumesDialogContent(
              currentUser: currentUser,
              userBloc: screenContext.read<UserBloc>()),
        );
      },
    ).then((saved) {
      if (saved == true) {
        if (screenContext.mounted) {
          AppUtils.showSnackBar(screenContext, AppStrings.favoriteVolumesUpdated);
        }
      }
    });
  }

  /// Handles the user logout process.
  Future<void> _handleLogout() async {
    final BuildContext screenContext = context;
    if (!screenContext.mounted) return;

    final authBloc = screenContext.read<AuthBloc>();
    final bool? confirmed = await AppUtils.showConfirmationDialog(
      screenContext,
      title: AppStrings.logout,
      content: AppStrings.logoutConfirmation,
      confirmText: AppStrings.logout,
    );

    if (!screenContext.mounted) return;
    if (confirmed == true) {
      authBloc.add(SignOutRequested());
    }
  }

  /// Navigates to the login screen.
  void _handleLogin() {
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamed(AppRoutes.login, arguments: AppRoutes.settings);
  }

  /// Shows a proper duration picker dialog for selecting the reminder interval.
  Future<void> _showIntervalPicker(BuildContext context) async {
    logger.d("SettingsScreen: _showIntervalPicker called (Duration Picker)");

    int currentTotalMinutes = (_selectedIntervalHours * 60).round();
    int selectedHours = currentTotalMinutes ~/ 60;
    int selectedMinutes = currentTotalMinutes % 60;

    final result = await showDialog<Duration>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, setDialogState) {
            return AlertDialog(
              title: const Text(AppStrings.selectIntervalDuration),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hours spinner
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppStrings.hours,
                          style: Theme.of(stfContext).textTheme.labelMedium),
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: 80.w,
                        height: 150.h,
                        child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                              initialItem: selectedHours),
                          itemExtent: 40.h,
                          physics: const FixedExtentScrollPhysics(),
                          perspective: 0.005,
                          onSelectedItemChanged: (index) {
                            setDialogState(() => selectedHours = index);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index > 12) return null;
                              return Center(
                                child: Text(
                                  '$index',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: index == selectedHours
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                        fontWeight: index == selectedHours
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                ),
                              );
                            },
                            childCount: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(':',
                        style:
                            Theme.of(stfContext).textTheme.headlineMedium),
                  ),
                  // Minutes spinner
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppStrings.minutes,
                          style: Theme.of(stfContext).textTheme.labelMedium),
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: 80.w,
                        height: 150.h,
                        child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                              initialItem: selectedMinutes ~/ 15),
                          itemExtent: 40.h,
                          physics: const FixedExtentScrollPhysics(),
                          perspective: 0.005,
                          onSelectedItemChanged: (index) {
                            setDialogState(
                                () => selectedMinutes = index * 15);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index > 3) return null;
                              final val = index * 15;
                              return Center(
                                child: Text(
                                  val.toString().padLeft(2, '0'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: val == selectedMinutes
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                        fontWeight: val == selectedMinutes
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                ),
                              );
                            },
                            childCount: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(
                      Duration(
                          hours: selectedHours, minutes: selectedMinutes),
                    );
                  },
                  child: const Text(AppStrings.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;

    double newIntervalHours =
        result.inHours + (result.inMinutes.remainder(60) / 60.0);

    bool adjustedToMinimum = false;
    if (newIntervalHours < 0.25) {
      newIntervalHours = 0.25;
      adjustedToMinimum = true;
    }

    setState(() {
      _selectedIntervalHours = newIntervalHours;
    });
    _saveReminderSettings(showSuccessSnackBar: !adjustedToMinimum);

    if (adjustedToMinimum) {
      if (context.mounted) {
        AppUtils.showSnackBar(context, AppStrings.minimumIntervalMessage,
            isError: false);
      }
    }
  }

  // Test notification method removed from production build.

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userState = context.watch<UserBloc>().state;
    final authState = context.watch<AuthBloc>().state;
    final currentUser = userState is UserLoaded ? userState.user : null;
    final isAuthenticated = authState is Authenticated;
    final hydrationService =
        Provider.of<HydrationService>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildGeneralSettingsSection(
                context, theme, themeProvider, currentUser, hydrationService),
            _buildIntegrationsSection(context, theme),
            _buildRemindersSection(context, theme),
            _buildAccountActionsSection(context, theme, isAuthenticated),
          ],
        ),
      ),
    );
  }

  /// Builds the integrations settings section.
  Widget _buildIntegrationsSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.integrations, theme),
        SwitchListTile(
          title: const Text(AppStrings.googleFitSync),
          subtitle: const Text(AppStrings.syncWaterIntakeData),
          value: _healthConnectEnabled,
          onChanged: _toggleHealthConnect,
          secondary: Icon(Symbols.ecg_heart,
              color: theme.colorScheme.onSurfaceVariant),
          activeTrackColor: theme.colorScheme.primary,
          inactiveThumbColor: theme.colorScheme.outline,
          inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  /// Builds the general settings section of the screen.
  Widget _buildGeneralSettingsSection(
      BuildContext context,
      ThemeData theme,
      ThemeProvider themeProvider,
      UserModel? currentUser,
      HydrationService hydrationService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.general, theme),
        _buildSettingsTile(
          context: context,
          icon: Symbols.person,
          title: AppStrings.profile,
          subtitle: AppStrings.managePersonalDetails,
          onTap: () {
            if (!context.mounted) return;
            Navigator.of(context).pushNamed(AppRoutes.profile);
          },
        ),
        _buildSettingsTile(
          context: context,
          icon: Symbols.color_lens,
          title: AppStrings.theme,
          subtitle: themeProvider.currentThemeName,
          onTap: () => _showThemeDialog(context, themeProvider),
        ),
        _buildSettingsTile(
          context: context,
          icon: Symbols.water_drop,
          title: AppStrings.dailyWaterGoal,
          subtitle:
              "${currentUser?.dailyGoalMl.toInt() ?? 2000} ${currentUser?.preferredUnit.displayName ?? AppStrings.ml}",
          onTap: () => _showDailyGoalSliderDialog(
              context, currentUser, hydrationService),
        ),
        _buildSettingsTile(
          context: context,
          icon: Symbols.straighten,
          title: AppStrings.measurementUnit,
          subtitle: currentUser?.preferredUnit.displayName ?? AppStrings.ml,
          onTap: () => _showEditMeasurementUnitDialog(context, currentUser),
        ),
        _buildSettingsTile(
          context: context,
          icon: Symbols.favorite,
          title: AppStrings.favoriteVolumes,
          subtitle: AppStrings.customizeQuickAdd,
          onTap: () => _showEditFavoriteVolumesDialog(context, currentUser),
        ),
      ],
    );
  }

  /// Builds the reminders settings section.
  Widget _buildRemindersSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.reminders, theme),
        SwitchListTile(
          title: const Text(AppStrings.enableReminders),
          value: _enableReminders,
          onChanged: (bool value) {
            setState(() {
              _enableReminders = value;
            });
            _saveReminderSettings();
          },
          secondary: Icon(Symbols.notifications,
              color: theme.colorScheme.onSurfaceVariant),
          activeTrackColor: theme.colorScheme.primary,
          inactiveThumbColor: theme.colorScheme.outline,
          inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
        ),
        if (_enableReminders) ...[
          _buildSettingsTile(
            context: context,
            icon: Symbols.timer,
            title: AppStrings.reminderInterval,
            subtitle: _formatInterval(_selectedIntervalHours),
            onTap: () => _showIntervalPicker(context),
          ),
          _buildSettingsTile(
            context: context,
            icon: Symbols.schedule,
            title: AppStrings.startTime,
            subtitle: _selectedStartTime.format(context),
            onTap: () => _selectTime(context, true),
          ),
          _buildSettingsTile(
            context: context,
            icon: Symbols.bedtime,
            title: AppStrings.endTime,
            subtitle: _selectedEndTime.format(context),
            onTap: () => _selectTime(context, false),
          ),
          // "Send Test Notification" removed from production UI.
        ],
      ],
    );
  }

  /// Builds the account actions section.
  Widget _buildAccountActionsSection(
      BuildContext context, ThemeData theme, bool isAuthenticated) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppStrings.account, theme),
        if (isAuthenticated)
          ListTile(
            leading: Icon(Symbols.logout, color: theme.colorScheme.error),
            title: Text(AppStrings.logout,
                style: TextStyle(color: theme.colorScheme.error)),
            onTap: _handleLogout,
          )
        else
          ListTile(
            leading: Icon(Symbols.login, color: theme.colorScheme.primary),
            title: Text(AppStrings.login,
                style: TextStyle(color: theme.colorScheme.primary)),
            onTap: _handleLogin,
          ),
        ListTile(
          leading:
              Icon(Symbols.info, color: theme.colorScheme.onSurfaceVariant),
          title: const Text(AppStrings.appVersion),
          subtitle: Text(_appVersion),
        ),
      ],
    );
  }

  /// Helper widget to build a section title.
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 8.h, left: 16.w),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Helper widget to build a settings tile.
  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  /// Formats the interval hours into a readable string.
  String _formatInterval(double hours) {
    if (hours < 1.0) {
      int mins = (hours * 60).round();
      return "$mins ${AppStrings.minutes}";
    } else {
      // Handle cases like 1.5 hours
      if (hours % 1 == 0) {
        return "${hours.toInt()} ${hours.toInt() > 1 ? AppStrings.hours : AppStrings.hour}";
      } else {
        int h = hours.floor();
        int m = ((hours - h) * 60).round();
        return "$h ${AppStrings.hrAbbr} $m ${AppStrings.minAbbr}";
      }
    }
  }
}
