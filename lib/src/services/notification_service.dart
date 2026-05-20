// lib/src/services/notification_service.dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minum/src/core/theme/app_theme.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/logger.dart';
import 'package:minum/src/core/calculators/reminder_schedule_calculator.dart';
import 'package:minum/src/core/di/injection_container.dart';
import 'package:minum/src/services/i_notification_service.dart';
import 'package:minum/src/services/prefs/i_prefs_service.dart';

class AwesomeNotificationService implements INotificationService {
  final IPrefsService _prefsService;

  AwesomeNotificationService({required IPrefsService prefsService})
      : _prefsService = prefsService;
  static const String _basicChannelKey = "basic_channel";
  static const String _basicChannelName = "Basic Notifications";
  static const String _basicChannelDescription =
      "Notification channel for basic alerts";

  static const String _scheduledChannelKey = "scheduled_hydration_channel";
  static const String _scheduledChannelName = "Hydration Reminders";
  static const String _scheduledChannelDescription =
      "Channel for Minum water intake reminders.";

  @override
  Future<void> init() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
          icon: 'resource://drawable/res_app_icon',
          channelKey: _basicChannelKey,
          channelName: _basicChannelName,
          channelDescription: _basicChannelDescription,
          defaultColor: MaterialTheme.lightScheme().primary,
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
          soundSource: 'resource://raw/res_custom_sound',
          playSound: true,
          channelShowBadge: true,
        ),
        NotificationChannel(
          icon: 'resource://drawable/res_app_icon',
          channelKey: _scheduledChannelKey,
          channelName: _scheduledChannelName,
          channelDescription: _scheduledChannelDescription,
          defaultColor: MaterialTheme.lightScheme().primary,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          soundSource: 'resource://raw/res_custom_sound',
          playSound: true,
          channelShowBadge: true,
        ),
      ],
      debug: true, // Set to false for production
    );

    await requestNotificationPermissions();

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );

    logger.i("AwesomeNotificationsService initialized.");
  }

  @override
  Future<bool> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications(
        channelKey: _scheduledChannelKey,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
        ],
      );
    }
    if (isAllowed) {
      logger.i("Notification permissions granted.");
    } else {
      logger.w("Notification permissions denied by user.");
    }
    return isAllowed;
  }

  @override
  Future<void> showSimpleNotification({
    int id = 0,
    String title = AppStrings.reminderTitle,
    String body = AppStrings.reminderBody,
    Map<String, String>? payload,
    List<String> favoriteVolumesMl = const [], // Added parameter
  }) async {
    List<NotificationActionButton> actionButtons = [];
    for (var i = 0; i < favoriteVolumesMl.length && i < 3; i++) {
      final volume = favoriteVolumesMl[i];
      actionButtons.add(NotificationActionButton(
        key: 'ADD_WATER_$volume',
        label: '+$volume ml',
      ));
    }
    actionButtons.add(NotificationActionButton(
        key: 'DISMISS',
        label: 'Dismiss',
        actionType: ActionType.DismissAction,
        isDangerousOption: true));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _scheduledChannelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      actionButtons: actionButtons, // Use dynamic buttons
    );
    logger.i(
        "Hydration Reminder Test: id=$id, title=$title, volumes: $favoriteVolumesMl");
  }

  @override
  Future<void> scheduleHydrationReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? payload,
    List<String> favoriteVolumesMl = const [], // Added parameter
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      logger.w(
          "Attempted to schedule notification in the past. ID: $id. Time: $scheduledTime");
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _scheduledChannelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledTime,
        allowWhileIdle: true,
        repeats: false,
      ),
      actionButtons: () {
        // Use dynamic buttons
        List<NotificationActionButton> actionButtons = [];
        for (var i = 0; i < favoriteVolumesMl.length && i < 3; i++) {
          final volume = favoriteVolumesMl[i];
          actionButtons.add(NotificationActionButton(
            key: 'ADD_WATER_$volume',
            label: '+$volume ml',
          ));
        }
        actionButtons.add(NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            actionType: ActionType.DismissAction,
            isDangerousOption: true));
        return actionButtons;
      }(),
    );
    logger.i(
        "Hydration Reminder scheduled: id=$id, title=$title, time=$scheduledTime, volumes: $favoriteVolumesMl");
  }

  @override
  Future<void> scheduleDailyRepeatingReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _scheduledChannelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true,
      ),
    );
    final String formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    logger.i(
        "Daily repeating reminder scheduled: id=$id, title=$title, time=$formattedTime");
  }

  @override
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
    logger.i("Notification cancelled: id=$id");
  }

  @override
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    logger.i("All notifications cancelled.");
  }

  @override
  Future<void> cancelScheduledNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
    logger.i("All scheduled notifications cancelled.");
  }

  @override
  Future<List<NotificationModel>> listScheduledNotifications() async {
    List<NotificationModel> scheduledNotifications =
        await AwesomeNotifications().listScheduledNotifications();
    logger.i(
        "Retrieved ${scheduledNotifications.length} scheduled notifications.");
    return scheduledNotifications;
  }

  @override
  Future<void> scheduleDailyRemindersIfNeeded(
      {bool forceReschedule = false}) async {
    logger.i(
        "NotificationService: scheduleDailyRemindersIfNeeded() called. forceReschedule: $forceReschedule");

    final bool remindersEnabled = await _prefsService.getBool(IPrefsService.keyRemindersEnabled);
    if (!remindersEnabled) {
      logger.i("Reminders are disabled. No scheduling will occur.");
      await AwesomeNotifications()
          .cancelAllSchedules(); // Cancel any existing just in case
      await _prefsService.remove(IPrefsService.keyLastScheduledDate); // Clear last scheduled date
      return;
    }

    final String? lastScheduledDateStr =
        await _prefsService.getString(IPrefsService.keyLastScheduledDate);
    final String todayDateStr =
        DateTime.now().toIso8601String().substring(0, 10);

    if (!forceReschedule && lastScheduledDateStr == todayDateStr) {
      // <-- Check !forceReschedule
      logger.i(
          "Notifications have already been scheduled for today ($todayDateStr) and forceReschedule is false. No rescheduling needed.");
      return;
    }

    if (forceReschedule) {
      logger.i(
          "forceReschedule is true. Proceeding with rescheduling for today ($todayDateStr).");
    }
    // This log is still useful
    logger.i(
        "Proceeding with notification scheduling check for today ($todayDateStr). Last scheduled: $lastScheduledDateStr, Force: $forceReschedule");

    final double intervalHours =
        await _prefsService.getDouble(IPrefsService.keyReminderIntervalHours, defaultValue: 1.0);
    final int startTimeHour = await _prefsService.getInt(IPrefsService.keyReminderStartTimeHour, defaultValue: 8);
    final int startTimeMinute = await _prefsService.getInt(IPrefsService.keyReminderStartTimeMinute, defaultValue: 0);
    final int endTimeHour = await _prefsService.getInt(IPrefsService.keyReminderEndTimeHour, defaultValue: 22);
    final int endTimeMinute = await _prefsService.getInt(IPrefsService.keyReminderEndTimeMinute, defaultValue: 0);
    final List<String> favoriteVolumes =
        await _prefsService.getStringList(IPrefsService.keyFavoriteVolumes, defaultValue: ['100', '250', '500']);

    await AwesomeNotifications()
        .cancelAllSchedules();
    logger.i("Cancelled all previously scheduled notifications.");

    final calculator = ReminderScheduleCalculator();
    final slots = calculator.calculateScheduleForToday(
      intervalHours: intervalHours,
      startTimeHour: startTimeHour,
      startTimeMinute: startTimeMinute,
      endTimeHour: endTimeHour,
      endTimeMinute: endTimeMinute,
    );

    int notificationId = 100;
    int scheduledCount = 0;
    logger.i(
        "Starting scheduling loop for today. Slots to schedule: ${slots.length}");

    for (final slot in slots) {
      scheduleHydrationReminder(
          id: notificationId++,
          title: AppStrings.reminderTitle,
          body: "Time for some water! Stay hydrated.",
          scheduledTime: slot,
          favoriteVolumesMl: favoriteVolumes,
          payload: {
            'type': 'hydration_reminder',
            'scheduled_at': slot.toIso8601String()
          });
      scheduledCount++;
    }

    if (scheduledCount > 0) {
      logger.i(
          "Successfully scheduled $scheduledCount reminders for today. Last ID used: ${notificationId - 1}. Favorite volumes: $favoriteVolumes");
    } else {
      logger.i(
          "No reminders were scheduled for today. This might be because the time window has passed or due to settings.");
    }
    await _prefsService.setString(IPrefsService.keyLastScheduledDate, todayDateStr);
  }

  @override
  Future<void> checkAndLogExactAlarmPermissionStatus() async {
    logger.i(
        "Note: For precise alarms (if `preciseAlarm: true` is used in scheduling), "
        "Android 12+ requires the 'Alarms & reminders' special app access. "
        "Awesome_notifications will attempt to use it if specified. "
        "Users may need to grant this via system settings if alarms are not precise.");
  }
}

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    logger.d(
        'Notification created: ${receivedNotification.id} - ${receivedNotification.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    logger.d(
        'Notification displayed: ${receivedNotification.id} - ${receivedNotification.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    logger.d(
        'Notification dismissed: ${receivedAction.id} - ${receivedAction.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    logger.d(
        'Action received: ${receivedAction.id} - ${receivedAction.title}, buttonKey: ${receivedAction.buttonKeyPressed}, payload: ${receivedAction.payload}');

    if (receivedAction.buttonKeyPressed.startsWith('ADD_WATER_')) {
      final parts = receivedAction.buttonKeyPressed.split('_');
      if (parts.length == 3) {
        final volumeStr = parts[2];
        final double? volumeMl = double.tryParse(volumeStr);
        if (volumeMl != null) {
          try {
            final prefsService = sl<IPrefsService>();
            double currentPendingAmount =
                await prefsService.getDouble(IPrefsService.keyPendingWaterAdditionMl);
            double newTotalPendingAmount = currentPendingAmount + volumeMl;
            await prefsService.setDouble(
                IPrefsService.keyPendingWaterAdditionMl, newTotalPendingAmount);
            logger.i(
                "ADD_WATER action: ${receivedAction.buttonKeyPressed}, volume $volumeMl ml. Total pending: $newTotalPendingAmount ml saved to SharedPreferences.");
          } catch (e) {
            logger.e("Error saving water addition to SharedPreferences: $e");
          }
        } else {
          logger.w(
              "Could not parse volume from button key: ${receivedAction.buttonKeyPressed}");
        }
      }
    }
  }
}
