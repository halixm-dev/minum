class ReminderScheduleCalculator {
  List<DateTime> calculateScheduleForToday({
    required double intervalHours,
    required int startTimeHour,
    required int startTimeMinute,
    required int endTimeHour,
    required int endTimeMinute,
    int maxNotifications = 120,
    DateTime? now,
  }) {
    now ??= DateTime.now();
    DateTime scheduleStart = DateTime(
        now.year, now.month, now.day, startTimeHour, startTimeMinute);
    DateTime scheduleEnd = DateTime(
        now.year, now.month, now.day, endTimeHour, endTimeMinute);

    if (scheduleEnd.isBefore(scheduleStart) &&
        scheduleEnd.day == scheduleStart.day) {
      scheduleEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    int intervalMinutes = (intervalHours * 60).toInt();
    if (intervalMinutes <= 0) return [];

    DateTime nextReminderTime = scheduleStart;
    if (now.isAfter(scheduleStart)) {
      while (nextReminderTime.isBefore(now)) {
        nextReminderTime =
            nextReminderTime.add(Duration(minutes: intervalMinutes));
      }
    }

    if (nextReminderTime.isBefore(scheduleStart)) {
      nextReminderTime = scheduleStart;
    }

    List<DateTime> slots = [];
    int notificationId = 0;

    while ((nextReminderTime.isBefore(scheduleEnd) ||
            nextReminderTime.isAtSameMomentAs(scheduleEnd)) &&
        nextReminderTime.day == now.day) {
      if (nextReminderTime.isAfter(now)) {
        if (notificationId >= maxNotifications) break;
        slots.add(nextReminderTime);
        notificationId++;
      }
      nextReminderTime =
          nextReminderTime.add(Duration(minutes: intervalMinutes));
    }

    return slots;
  }
}
