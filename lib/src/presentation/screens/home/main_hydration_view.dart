// lib/src/presentation/screens/home/main_hydration_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/presentation/providers/hydration_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/widgets/home/daily_progress_card.dart';
import 'package:minum/src/presentation/widgets/home/hydration_log_list_item.dart';
import 'package:minum/src/presentation/widgets/home/quick_add_buttons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:awesome_notifications/awesome_notifications.dart'; // For NotificationModel and NotificationCalendar
import 'package:minum/src/services/notification_service.dart'; // For NotificationService

// For logger - assuming it's available via another import or globally, if not, add:
// import 'package:minum/main.dart';


class MainHydrationView extends StatefulWidget {
  const MainHydrationView({super.key});

  @override
  State<MainHydrationView> createState() => _MainHydrationViewState();
}

class _MainHydrationViewState extends State<MainHydrationView> with WidgetsBindingObserver {
  NotificationModel? _nextReminder;
  bool _isLoadingReminder = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchNextReminder();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // logger.d("App resumed, fetching next reminder and processing pending water.");
      _fetchNextReminder();
      // Process any pending water additions from notification actions
      Provider.of<HydrationProvider>(context, listen: false).processPendingWaterAddition().then((_) {
        // logger.d("MainHydrationView: processPendingWaterAddition call completed on resume.");
      }).catchError((e) {
        // logger.e("MainHydrationView: Error calling processPendingWaterAddition on resume: $e");
      });
    }
  }

  Future<void> _fetchNextReminder() async {
    if (!mounted) return;
    setState(() {
      _isLoadingReminder = true;
    });

    try {
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      List<NotificationModel> scheduledNotifications = await notificationService.listScheduledNotifications();

      NotificationModel? soonestReminder;
      DateTime? soonestTime;

      DateTime now = DateTime.now();

      for (var notification in scheduledNotifications) {
        if (notification.schedule is NotificationCalendar) {
          final schedule = notification.schedule as NotificationCalendar;
          // Note: NotificationCalendar might not have year, month, day for repeating schedules.
          // We assume daily reminders are scheduled for the current day by NotificationService.
          // Thus, we construct DateTime for today using hour/minute from schedule.
          if (schedule.hour != null && schedule.minute != null) {
            DateTime scheduledDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              schedule.hour!,
              schedule.minute!,
              schedule.second ?? 0,
            );

            // If the scheduled time today is in the past, check if it's for a repeating daily alarm.
            // For simplicity here, we're just looking for the next one *today*.
            // A more robust solution might need to check if it repeats and calculate next occurrence.
            // The NotificationService.scheduleDailyRemindersIfNeeded ensures only today's are scheduled.
            if (scheduledDateTime.isAfter(now)) {
              if (soonestTime == null || scheduledDateTime.isBefore(soonestTime)) {
                soonestTime = scheduledDateTime;
                soonestReminder = notification;
              }
            }
          }
        }
      }
      if (mounted) {
        setState(() {
          _nextReminder = soonestReminder;
          _isLoadingReminder = false;
        });
      }
    } catch (e) {
      // logger.e("Error fetching next reminder: $e");
      if (mounted) {
        setState(() {
          _isLoadingReminder = false;
          _nextReminder = null; // Clear reminder on error
        });
      }
    }
  }

  Widget _buildNextReminderSection() {
    if (_isLoadingReminder) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2))),
      );
    }

    if (_nextReminder != null && _nextReminder!.schedule is NotificationCalendar) {
      final schedule = _nextReminder!.schedule as NotificationCalendar;
      if (schedule.hour != null && schedule.minute != null) {
        final DateTime now = DateTime.now();
        final DateTime reminderTime = DateTime(now.year, now.month, now.day, schedule.hour!, schedule.minute!);

        // Check if this reminder time is actually in the future (it should be due to _fetchNextReminder logic)
        if (reminderTime.isAfter(now)) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10.h),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.alarm_outlined, size: 24.sp, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 12.w),
                  Text("Next Reminder:", style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    DateFormat.jm().format(reminderTime),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
    // Optionally, show "No upcoming reminders" if _nextReminder is null and not loading
    // For now, returning an empty SizedBox if no reminder to display or if data is inconsistent.
    return const SizedBox.shrink();
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final hydrationProvider = Provider.of<HydrationProvider>(context);

    final UserModel? currentUser = userProvider.userProfile;
    final List<HydrationEntry> todaysEntries = hydrationProvider.dailyEntries;
    final double totalIntakeToday = hydrationProvider.totalIntakeToday;
    final double dailyGoal = currentUser?.dailyGoalMl ?? 2000.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hydrationProvider.actionStatus == HydrationActionStatus.error &&
          hydrationProvider.errorMessage != null) {
        AppUtils.showSnackBar(context, hydrationProvider.errorMessage!, isError: true);
        context.read<HydrationProvider>().resetActionStatus();
      } else if (hydrationProvider.actionStatus == HydrationActionStatus.success) {
        // AppUtils.showSnackBar(context, "Action successful!"); // Optional generic success
        context.read<HydrationProvider>().resetActionStatus();
      }
    });


    Widget buildLogList() {
      if (hydrationProvider.logStatus == HydrationLogStatus.loading && todaysEntries.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (hydrationProvider.logStatus == HydrationLogStatus.error) {
        return Center(child: Text(hydrationProvider.errorMessage ?? AppStrings.anErrorOccurred));
      }
      if (todaysEntries.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_drink_outlined, size: 60.sp, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round())), // Changed
                SizedBox(height: 16.h),
                Text(
                  'No water logged yet for today.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), // Changed
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap the (+) button to add your first drink!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.8).round())), // Changed
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
      // Changed from ListView.separated to ListView.builder
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todaysEntries.length,
        itemBuilder: (context, index) {
          final entry = todaysEntries[index];
          return HydrationLogListItem(
            entry: entry,
            unit: currentUser?.preferredUnit ?? MeasurementUnit.ml,
            onDismissed: () {
              context.read<HydrationProvider>().deleteHydrationEntry(entry);
            },
          );
        },
        // separatorBuilder: (context, index) => Divider(height: 1.h, indent: 16.w, endIndent: 16.w), // REMOVED
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, size: 28.sp),
                onPressed: () {
                  context.read<HydrationProvider>().setSelectedDate(
                    hydrationProvider.selectedDate.subtract(const Duration(days: 1)),
                  );
                },
              ),
              Text(
                DateFormat('EEEE, MMM d').format(hydrationProvider.selectedDate),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 28.sp,
                  color: DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now())
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color,
                ),
                onPressed: DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now())
                    ? null
                    : () {
                  context.read<HydrationProvider>().setSelectedDate(
                    hydrationProvider.selectedDate.add(const Duration(days: 1)),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),

          if (currentUser != null)
            DailyProgressCard(
              consumed: totalIntakeToday,
              goal: dailyGoal,
              unit: currentUser.preferredUnit,
            )
          else
            Card(child: Padding(padding: EdgeInsets.all(20.h), child: const Center(child: Text("Loading user data...")))),

          // Display Next Reminder Section
          if (DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now()))
            _buildNextReminderSection(),

          SizedBox(height: 10.h), // Adjusted spacing if reminder is shown

          if (currentUser != null && DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now()))
            QuickAddButtons(
              favoriteVolumes: currentUser.favoriteIntakeVolumes,
              unit: currentUser.preferredUnit,
              onQuickAdd: (volumeMl) {
                context.read<HydrationProvider>().addHydrationEntry(
                  volumeMl,
                  source: 'quick_add_${volumeMl}ml',
                );
                AppUtils.showSnackBar(context, "${AppUtils.formatAmount(volumeMl, decimalDigits: currentUser.preferredUnit == MeasurementUnit.oz ? 1 : 0)} ${currentUser.preferredUnitString} added!");
              },
            ),
          if (currentUser != null && DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now()))
            SizedBox(height: 24.h),

          if (todaysEntries.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
              child: Text(
                DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now())
                    ? "Today's Log"
                    : "Log for ${DateFormat.MMMd().format(hydrationProvider.selectedDate)}",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),

          buildLogList(),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
