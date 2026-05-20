import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

abstract class INotificationService {
  Future<void> init();
  Future<bool> requestNotificationPermissions();
  Future<void> showSimpleNotification({
    int id = 0,
    String title = '',
    String body = '',
    Map<String, String>? payload,
    List<String> favoriteVolumesMl = const [],
  });
  Future<void> scheduleHydrationReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? payload,
    List<String> favoriteVolumesMl = const [],
  });
  Future<void> scheduleDailyRepeatingReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    Map<String, String>? payload,
  });
  Future<void> cancelNotification(int id);
  Future<void> cancelAllNotifications();
  Future<void> cancelScheduledNotifications();
  Future<List<NotificationModel>> listScheduledNotifications();
  Future<void> scheduleDailyRemindersIfNeeded({bool forceReschedule = false});
  Future<void> checkAndLogExactAlarmPermissionStatus();
}
