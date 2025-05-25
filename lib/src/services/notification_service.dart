// lib/src/services/notification_service.dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minum/src/core/constants/app_colors.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/main.dart';

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
  }) async {
    final int currentBadgeCount = await AwesomeNotifications().getGlobalBadgeCounter();
    final effectiveId = (id == 0) ? currentBadgeCount + 1 : id;

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
        actionButtons: [
          NotificationActionButton(key: 'MARK_AS_DONE', label: 'Mark as Done'),
          NotificationActionButton(key: 'DISMISS', label: 'Dismiss', actionType: ActionType.DismissAction, isDangerousOption: true)
        ]
    );
    logger.i("Hydration Reminder Test: id=$id, title=$title");
  }

  Future<void> scheduleHydrationReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? payload,
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
        actionButtons: [
          NotificationActionButton(key: 'MARK_AS_DONE', label: 'Mark as Done'),
          NotificationActionButton(key: 'DISMISS', label: 'Dismiss', actionType: ActionType.DismissAction, isDangerousOption: true)
        ]
    );
    logger.i("Hydration Reminder scheduled: id=$id, title=$title, time=$scheduledTime");
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

  Future<void> checkAndLogExactAlarmPermissionStatus() async {
    logger.i("Note: For precise alarms (if `preciseAlarm: true` is used in scheduling), "
        "Android 12+ requires the 'Alarms & reminders' special app access. "
        "Awesome_notifications will attempt to use it if specified. "
        "Users may need to grant this via system settings if alarms are not precise.");
  }
}

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

    if (receivedAction.buttonKeyPressed == 'MARK_AS_DONE') {
      logger.i("Notification ${receivedAction.id} marked as done by user.");
    }
  }
}
