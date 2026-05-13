import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minum/src/services/notification_service.dart';

class NextReminderState {
  final NotificationModel? nextReminder;
  final bool isLoading;

  const NextReminderState({
    this.nextReminder,
    this.isLoading = false,
  });

  NextReminderState copyWith({
    NotificationModel? nextReminder,
    bool? isLoading,
  }) {
    return NextReminderState(
      nextReminder: nextReminder ?? this.nextReminder,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NextReminderCubit extends Cubit<NextReminderState> {
  final NotificationService notificationService;

  NextReminderCubit({required this.notificationService})
      : super(const NextReminderState()) {
    fetchNextReminder();
  }

  Future<void> fetchNextReminder() async {
    emit(state.copyWith(isLoading: true));

    try {
      List<NotificationModel> scheduledNotifications =
          await notificationService.listScheduledNotifications();

      NotificationModel? soonestReminder;
      DateTime? soonestTime;

      DateTime now = DateTime.now();

      for (var notification in scheduledNotifications) {
        if (notification.schedule is NotificationCalendar) {
          final schedule = notification.schedule as NotificationCalendar;
          if (schedule.hour != null && schedule.minute != null) {
            DateTime scheduledDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              schedule.hour!,
              schedule.minute!,
              schedule.second ?? 0,
            );
            if (scheduledDateTime.isAfter(now)) {
              if (soonestTime == null ||
                  scheduledDateTime.isBefore(soonestTime)) {
                soonestTime = scheduledDateTime;
                soonestReminder = notification;
              }
            }
          }
        }
      }
      emit(state.copyWith(nextReminder: soonestReminder, isLoading: false));
    } catch (e) {
      emit(state.copyWith(nextReminder: null, isLoading: false));
    }
  }
}
