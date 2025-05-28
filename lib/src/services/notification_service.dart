// lib/src/services/notification_service.dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minum/src/core/constants/app_colors.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences Keys for Reminder Settings
const String prefsRemindersEnabled = 'prefs_reminders_enabled';
const String prefsReminderIntervalHours = 'prefs_reminder_interval_hours';
const String prefsReminderStartTimeHour = 'prefs_reminder_start_time_hour';
const String prefsReminderStartTimeMinute = 'prefs_reminder_start_time_minute';
const String prefsReminderEndTimeHour = 'prefs_reminder_end_time_hour';
const String prefsReminderEndTimeMinute = 'prefs_reminder_end_time_minute';
const String prefsLastScheduledDate = 'prefs_last_scheduled_date';
const String prefsFavoriteVolumes = 'prefs_favorite_volumes'; // Assuming UserProvider saves this

class NotificationService {
  static const String _basicChannelKey = "basic_channel";
  static const String _basicChannelName = "Basic Notifications";
  static const String _basicChannelDescription = "Notification channel for basic alerts";

  static const String _scheduledChannelKey = "scheduled_hydration_channel";
  static const String _scheduledChannelName = "Hydration Reminders";
  static const String _scheduledChannelDescription = "Channel for Minum water intake reminders.";

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
          icon: 'resource://drawable/res_app_icon',
          channelKey: _basicChannelKey,
          channelName: _basicChannelName,
          channelDescription: _basicChannelDescription,
          defaultColor: AppColors.primaryColor,
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
          defaultColor: AppColors.primaryColor,
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
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );

    logger.i("AwesomeNotificationsService initialized.");
  }

  Future<bool> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications(
        channelKey: _scheduledChannelKey,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
        ],
      );
    }
    if(isAllowed){
      logger.i("Notification permissions granted.");
    } else {
      logger.w("Notification permissions denied by user.");
    }
    return isAllowed;
  }

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
    actionButtons.add(NotificationActionButton(key: 'DISMISS', label: 'Dismiss', actionType: ActionType.DismissAction, isDangerousOption: true));

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
    logger.i("Hydration Reminder Test: id=$id, title=$title, volumes: $favoriteVolumesMl");
  }

  Future<void> scheduleHydrationReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? payload,
    List<String> favoriteVolumesMl = const [], // Added parameter
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      logger.w("Attempted to schedule notification in the past. ID: $id. Time: $scheduledTime");
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
      actionButtons: () { // Use dynamic buttons
        List<NotificationActionButton> actionButtons = [];
        for (var i = 0; i < favoriteVolumesMl.length && i < 3; i++) {
          final volume = favoriteVolumesMl[i];
          actionButtons.add(NotificationActionButton(
            key: 'ADD_WATER_$volume',
            label: '+$volume ml',
          ));
        }
        actionButtons.add(NotificationActionButton(key: 'DISMISS', label: 'Dismiss', actionType: ActionType.DismissAction, isDangerousOption: true));
        return actionButtons;
      }(),
    );
    logger.i("Hydration Reminder scheduled: id=$id, title=$title, time=$scheduledTime, volumes: $favoriteVolumesMl");
  }

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
    final String formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    logger.i("Daily repeating reminder scheduled: id=$id, title=$title, time=$formattedTime");
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
    logger.i("Notification cancelled: id=$id");
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    logger.i("All notifications cancelled.");
  }

  Future<void> cancelScheduledNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
    logger.i("All scheduled notifications cancelled.");
  }

  Future<List<NotificationModel>> listScheduledNotifications() async {
    List<NotificationModel> scheduledNotifications = await AwesomeNotifications().listScheduledNotifications();
    logger.i("Retrieved ${scheduledNotifications.length} scheduled notifications.");
    return scheduledNotifications;
  }

  Future<void> scheduleDailyRemindersIfNeeded({bool forceReschedule = false}) async {
    logger.i("NotificationService: scheduleDailyRemindersIfNeeded() called. forceReschedule: $forceReschedule");
    final prefs = await SharedPreferences.getInstance();

    final bool remindersEnabled = prefs.getBool(prefsRemindersEnabled) ?? false;
    if (!remindersEnabled) {
      logger.i("Reminders are disabled. No scheduling will occur.");
      await AwesomeNotifications().cancelAllSchedules(); // Cancel any existing just in case
      await prefs.remove(prefsLastScheduledDate); // Clear last scheduled date
      return;
    }

    final String todayDateStr = DateTime.now().toIso8601String().substring(0, 10);

    if (forceReschedule) {
      logger.i("forceReschedule is true. Proceeding with rescheduling for today ($todayDateStr).");
    }
    logger.i("Proceeding with notification scheduling for today ($todayDateStr). Force reschedule: $forceReschedule");

    final double intervalHours = prefs.getDouble(prefsReminderIntervalHours) ?? 1.0;
    final int startTimeHour = prefs.getInt(prefsReminderStartTimeHour) ?? 8;
    final int startTimeMinute = prefs.getInt(prefsReminderStartTimeMinute) ?? 0;
    final int endTimeHour = prefs.getInt(prefsReminderEndTimeHour) ?? 22;
    final int endTimeMinute = prefs.getInt(prefsReminderEndTimeMinute) ?? 0;
    final List<String> favoriteVolumes = prefs.getStringList(prefsFavoriteVolumes) ?? ['100', '250', '500'];

    await AwesomeNotifications().cancelAllSchedules(); // Clear previous day's schedules
    logger.i("Cancelled all previously scheduled notifications.");

    DateTime currentTime = DateTime.now();
    DateTime scheduleStart = DateTime(currentTime.year, currentTime.month, currentTime.day, startTimeHour, startTimeMinute);
    DateTime scheduleEnd = DateTime(currentTime.year, currentTime.month, currentTime.day, endTimeHour, endTimeMinute);

    // If scheduleEnd is before scheduleStart (e.g. end time is 2 AM, start time is 8 AM for previous day),
    // and we are scheduling for *today*, this implies an overnight schedule that should end today.
    // However, our logic aims to schedule *within* today.
    // If current time has already passed scheduleEnd for *today*, then no scheduling for today.
    if (scheduleEnd.isBefore(scheduleStart) && scheduleEnd.day == scheduleStart.day) {
      // This case implies an overnight schedule ending on the same calendar day it started, which is unusual for this logic.
      // For simplicity, if end time is "before" start time on the same day, assume it means "next day".
      // But since we are only scheduling for *today*, if scheduleEnd (e.g. 2AM today) is before scheduleStart (e.g. 8AM today)
      // it actually means the period has not started or is an invalid range for "today".
      // More robust: if end time is 'earlier' than start time, it means it crosses midnight.
      // For "today-only" scheduling, if scheduleEnd (e.g. 02:00) is before scheduleStart (e.g. 08:00),
      // it means the active period is overnight. We only care about the part that falls on *today*.
      // If start is 22:00 and end is 02:00:
      // - Schedule from 22:00 today to 23:59 today.
      // - Schedule from 00:00 today to 02:00 today (if current logic were for *next* day's end part).
      // This simplified version doesn't split overnight schedules perfectly across two `scheduleDailyRemindersIfNeeded` calls.
      // It will schedule from startTime to endTime *within the current day*.
      // If endTimeHour < startTimeHour, it effectively means schedule until end of day if current time is past startTime.
      // Or from start of day until endTime if current time is before endTime. This needs care.

      // Let's simplify: If scheduleEnd is on the same day but earlier than scheduleStart,
      // it implies the "active" period might be overnight.
      // For "today-only" scheduling:
      // if _selectedStartTime = 22:00 and _selectedEndTime = 02:00
      // scheduleStart = today@22:00, scheduleEnd = today@02:00. scheduleEnd is before scheduleStart.
      // This means the effective period for *today* is from 22:00 to 23:59:59.
      // And for *tomorrow* it would be 00:00 to 02:00.
      // The current logic of `scheduleEnd.add(Duration(days:1))` is for continuous rescheduling.
      // For `scheduleDailyRemindersIfNeeded`, we *only* care about today.
      // If scheduleEnd (today @ 02:00) is before scheduleStart (today @ 22:00),
      // it means the user intends an overnight schedule.
      // For *today*, we only schedule between scheduleStart (22:00) and midnight.
      // And if it's past midnight, we schedule between midnight and scheduleEnd (02:00).

      // Simpler interpretation for "today only":
      // If endTime < startTime, it means the period crosses midnight.
      // For today, this means two potential blocks: 00:00 to endTime, AND startTime to 23:59.
      // The current loop `while (nextReminderTime.isBefore(scheduleEnd))` will not run if scheduleEnd < scheduleStart.
      // Let's adjust scheduleEnd if it's for an overnight period that *ends* today.
      if (scheduleEnd.hour < scheduleStart.hour && scheduleEnd.day == scheduleStart.day) {
        // This means the period started yesterday and ends today. e.g. Start 22:00, End 02:00.
        // For today, we are interested in 00:00 up to 02:00.
        // So, scheduleStart for *today's segment* should be midnight.
        scheduleStart = DateTime(currentTime.year, currentTime.month, currentTime.day, 0, 0);
        // scheduleEnd is already correctly today @ 02:00
        logger.i("Adjusted for overnight schedule ending today. Effective range for today: ${scheduleStart.toIso8601String()} to ${scheduleEnd.toIso8601String()}");
      }
      // If it's an overnight schedule starting today and ending tomorrow (e.g. start 22:00, end 02:00)
      // then for *today* scheduleEnd should effectively be end of day.
      else if (scheduleStart.hour > scheduleEnd.hour && scheduleStart.day == scheduleEnd.day) {
        scheduleEnd = DateTime(currentTime.year, currentTime.month, currentTime.day, 23, 59, 59);
        logger.i("Adjusted for overnight schedule starting today. Effective range for today: ${scheduleStart.toIso8601String()} to ${scheduleEnd.toIso8601String()}");
      }
    }


    int notificationIdBase = 100;
    int notificationId = notificationIdBase;
    int maxNotificationsPerDay = 120; // Max 120 notifications (IDs 100-219)
    DateTime nextReminderTime = scheduleStart;

    // If current time is already past the scheduleStart, find the next valid reminder time from now.
    if (currentTime.isAfter(scheduleStart)) {
      int intervalInMinutes = (intervalHours * 60).toInt();
      if (intervalInMinutes <= 0) {
        logger.w("Interval is <= 0 minutes. Cannot schedule. Interval Hours: $intervalHours");
        // Removed: await prefs.setString(prefsLastScheduledDate, todayDateStr); 
        return;
      }
      nextReminderTime = scheduleStart;
      while(nextReminderTime.isBefore(currentTime)){
        nextReminderTime = nextReminderTime.add(Duration(minutes: intervalInMinutes));
      }
    }

    // Ensure nextReminderTime is not before scheduleStart (e.g. if current time was before scheduleStart)
    if(nextReminderTime.isBefore(scheduleStart)){
      nextReminderTime = scheduleStart;
    }

    int scheduledCount = 0;
    logger.i("Starting scheduling loop for today: Start=${scheduleStart.toIso8601String()}, End=${scheduleEnd.toIso8601String()}, NextReminderStart=${nextReminderTime.toIso8601String()}");

    while ((nextReminderTime.isBefore(scheduleEnd) || nextReminderTime.isAtSameMomentAs(scheduleEnd)) && nextReminderTime.day == currentTime.day) {
      if (nextReminderTime.isAfter(DateTime.now())) { // Ensure we only schedule for the future
        if (notificationId >= notificationIdBase + maxNotificationsPerDay) {
          logger.w("Reached maximum notification limit for today ($maxNotificationsPerDay). Stopping further scheduling for today. Last ID: $notificationId");
          break;
        }
        scheduleHydrationReminder( // Use the class method
            id: notificationId++,
            title: AppStrings.reminderTitle, // Assuming AppStrings is accessible or pass as param
            body: "Time for some water! Stay hydrated.",
            scheduledTime: nextReminderTime,
            favoriteVolumesMl: favoriteVolumes,
            payload: {'type': 'hydration_reminder', 'scheduled_at': nextReminderTime.toIso8601String()}
        );
        scheduledCount++;
      }
      int intervalMinutes = (intervalHours * 60).toInt();
      if (intervalMinutes <= 0) { // Should have been caught earlier, but as a safeguard
        logger.e("Critical: Interval is <= 0 minutes inside loop. Breaking. Interval Hours: $intervalHours");
        break;
      }
      nextReminderTime = nextReminderTime.add(Duration(minutes: intervalMinutes));
    }

    if (scheduledCount > 0) {
      logger.i("Successfully scheduled $scheduledCount reminders for today ($todayDateStr). Last ID used: ${notificationId -1}. Favorite volumes: $favoriteVolumes");
    } else {
      logger.i("No reminders were scheduled for today ($todayDateStr). This might be because the time window has passed or due to settings.");
    }
    // Removed: await prefs.setString(prefsLastScheduledDate, todayDateStr);
  }


  Future<void> checkAndLogExactAlarmPermissionStatus() async {
    logger.i("Note: For precise alarms (if `preciseAlarm: true` is used in scheduling), "
        "Android 12+ requires the 'Alarms & reminders' special app access. "
        "Awesome_notifications will attempt to use it if specified. "
        "Users may need to grant this via system settings if alarms are not precise.");
  }
}

const String prefsPendingWaterAdditionMl = 'prefs_pending_water_addition_ml';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    logger.d('Notification created: ${receivedNotification.id} - ${receivedNotification.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    logger.d('Notification displayed: ${receivedNotification.id} - ${receivedNotification.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    logger.d('Notification dismissed: ${receivedAction.id} - ${receivedAction.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    logger.d('Action received: ${receivedAction.id} - ${receivedAction.title}, buttonKey: ${receivedAction.buttonKeyPressed}, payload: ${receivedAction.payload}');

    // if (receivedAction.buttonKeyPressed == 'MARK_AS_DONE') {
    //   logger.i("Notification ${receivedAction.id} marked as done by user.");
    // }

    if (receivedAction.buttonKeyPressed.startsWith('ADD_WATER_')) {
      final parts = receivedAction.buttonKeyPressed.split('_');
      if (parts.length == 3) {
        final volumeStr = parts[2];
        final double? volumeMl = double.tryParse(volumeStr);
        if (volumeMl != null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            double currentPendingAmount = prefs.getDouble(prefsPendingWaterAdditionMl) ?? 0.0;
            double newTotalPendingAmount = currentPendingAmount + volumeMl;
            await prefs.setDouble(prefsPendingWaterAdditionMl, newTotalPendingAmount);
            logger.i("ADD_WATER action: ${receivedAction.buttonKeyPressed}, volume $volumeMl ml. Total pending: $newTotalPendingAmount ml saved to SharedPreferences.");
          } catch (e) {
            logger.e("Error saving water addition to SharedPreferences: $e");
          }
        } else {
          logger.w("Could not parse volume from button key: ${receivedAction.buttonKeyPressed}");
        }
      }
    }
  }
}
