// lib/src/presentation/screens/home/main_hydration_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/presentation/providers/hydration_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/providers/reminder_settings_notifier.dart';
import 'package:minum/src/presentation/widgets/home/daily_progress_card.dart';
import 'package:minum/src/presentation/widgets/home/hydration_log_list_item.dart';
import 'package:minum/src/presentation/widgets/home/quick_add_buttons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:minum/src/services/notification_service.dart';
import 'package:minum/src/services/hydration_service.dart';

/// The main view displayed on the home screen, showing daily hydration progress,
/// quick-add buttons, and a log of the day's entries.
class MainHydrationView extends StatefulWidget {
  /// Creates a `MainHydrationView`.
  const MainHydrationView({super.key});

  @override
  State<MainHydrationView> createState() => _MainHydrationViewState();
}

class _MainHydrationViewState extends State<MainHydrationView>
    with WidgetsBindingObserver {
  NotificationModel? _nextReminder;
  bool _isLoadingReminder = true;
  ReminderSettingsNotifier? _reminderSettingsNotifier;

  void _onReminderSettingsChanged() {
    _fetchNextReminder();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchNextReminder();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _reminderSettingsNotifier =
            Provider.of<ReminderSettingsNotifier>(context, listen: false);
        _reminderSettingsNotifier?.addListener(_onReminderSettingsChanged);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderSettingsNotifier?.removeListener(_onReminderSettingsChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _fetchNextReminder();
      Provider.of<HydrationProvider>(context, listen: false)
          .processPendingWaterAddition();
    }
  }

  /// Fetches the next scheduled reminder and updates the UI.
  Future<void> _fetchNextReminder() async {
    if (!mounted) return;
    setState(() {
      _isLoadingReminder = true;
    });

    try {
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
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
      if (mounted) {
        setState(() {
          _nextReminder = soonestReminder;
          _isLoadingReminder = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReminder = false;
          _nextReminder = null;
        });
      }
    }
  }

  Widget _buildNextReminderSection() {
    if (_isLoadingReminder) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: const Center(
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2))),
      );
    }

    if (_nextReminder != null &&
        _nextReminder!.schedule is NotificationCalendar) {
      final schedule = _nextReminder!.schedule as NotificationCalendar;
      if (schedule.hour != null && schedule.minute != null) {
        final DateTime now = DateTime.now();
        final DateTime reminderTime = DateTime(
            now.year, now.month, now.day, schedule.hour!, schedule.minute!);

        if (reminderTime.isAfter(now)) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(Symbols.alarm,
                      size: 24.sp,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 12.w),
                  Text("Next Reminder:",
                      style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  Text(
                    DateFormat.jm().format(reminderTime),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final hydrationProvider = Provider.of<HydrationProvider>(context);

    final UserModel? currentUser = userProvider.userProfile;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hydrationProvider.actionStatus == HydrationActionStatus.error &&
          hydrationProvider.errorMessage != null) {
        AppUtils.showSnackBar(context, hydrationProvider.errorMessage!,
            isError: true);
        context.read<HydrationProvider>().resetActionStatus();
      } else if (hydrationProvider.actionStatus ==
          HydrationActionStatus.success) {
        context.read<HydrationProvider>().resetActionStatus();
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final hydrationProvider =
            Provider.of<HydrationProvider>(context, listen: false);
        final userId = userProvider.userProfile?.id;
        final selectedDate = hydrationProvider.selectedDate;

        if (userId != null) {
          await Provider.of<HydrationService>(context, listen: false)
              .syncHealthConnectData(userId, date: selectedDate);

          // Force refresh of the hydration provider to show any new synced entries
          if (context.mounted) {
            await hydrationProvider.fetchHydrationEntriesForDate(selectedDate);
          }
        }
      },
      child: CustomScrollView(
        // Optimization: Use CustomScrollView for better performance with lists
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateNavigationHeader(context, hydrationProvider),
                  SizedBox(height: 16.h),
                  _buildDailyProgressSection(
                      context, userProvider, hydrationProvider),
                  if (DateUtils.isSameDay(
                      hydrationProvider.selectedDate, DateTime.now()))
                    _buildNextReminderSection(),
                  SizedBox(
                      height: _nextReminder != null && !_isLoadingReminder
                          ? 8.h
                          : 16.h),
                  _buildQuickAddSection(
                      context, userProvider, hydrationProvider),
                  if (currentUser != null &&
                      DateUtils.isSameDay(
                          hydrationProvider.selectedDate, DateTime.now()))
                    SizedBox(height: 24.h),
                  _buildLogTitle(context, hydrationProvider),
                ],
              ),
            ),
          ),
          _buildSliverLogList(hydrationProvider, currentUser),
          SliverToBoxAdapter(
            child: SizedBox(height: 80.h),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigationHeader(
      BuildContext context, HydrationProvider hydrationProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Symbols.chevron_left,
              size: 28.sp), // Size can be themed via IconTheme
          onPressed: () {
            context.read<HydrationProvider>().setSelectedDate(
                  hydrationProvider.selectedDate
                      .subtract(const Duration(days: 1)),
                );
          },
        ),
        Text(
          DateFormat('EEEE, MMM d').format(hydrationProvider.selectedDate),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: Icon(Symbols.chevron_right, size: 28.sp),
          color: DateUtils.isSameDay(
                  hydrationProvider.selectedDate, DateTime.now())
              ? Theme.of(context).colorScheme.onSurface.withAlpha(97)
              : Theme.of(context).iconTheme.color,
          onPressed: DateUtils.isSameDay(
                  hydrationProvider.selectedDate, DateTime.now())
              ? null
              : () {
                  context.read<HydrationProvider>().setSelectedDate(
                        hydrationProvider.selectedDate
                            .add(const Duration(days: 1)),
                      );
                },
        ),
      ],
    );
  }

  Widget _buildDailyProgressSection(BuildContext context,
      UserProvider userProvider, HydrationProvider hydrationProvider) {
    final UserModel? currentUser = userProvider.userProfile;
    final double totalIntakeToday = hydrationProvider.totalIntakeToday;
    final double dailyGoal = currentUser?.dailyGoalMl ?? 2000.0;

    if (currentUser != null) {
      return DailyProgressCard(
        consumed: totalIntakeToday,
        goal: dailyGoal,
        unit: currentUser.preferredUnit,
      );
    } else {
      return Card(
          child: SizedBox(
              height: 150.h,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator.adaptive(),
                  SizedBox(height: 16.h),
                  Text("Loading user data...",
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ))));
    }
  }

  Widget _buildQuickAddSection(BuildContext context, UserProvider userProvider,
      HydrationProvider hydrationProvider) {
    final UserModel? currentUser = userProvider.userProfile;
    if (currentUser != null &&
        DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now())) {
      return QuickAddButtons(
        favoriteVolumes: currentUser.favoriteIntakeVolumes,
        unit: currentUser.preferredUnit,
        onQuickAdd: (volumeMl) {
          context.read<HydrationProvider>().addHydrationEntry(
                volumeMl,
                source: 'quick_add_${volumeMl}ml',
              );
          AppUtils.showSnackBar(context,
              "${AppUtils.formatAmount(AppUtils.convertToPreferredUnit(volumeMl, currentUser.preferredUnit), decimalDigits: currentUser.preferredUnit == MeasurementUnit.oz ? 1 : 0)} ${currentUser.preferredUnitString} added!");
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLogTitle(
      BuildContext context, HydrationProvider hydrationProvider) {
    final List<HydrationEntry> todaysEntries = hydrationProvider.dailyEntries;
    if (todaysEntries.isNotEmpty ||
        hydrationProvider.logStatus == HydrationLogStatus.loading) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h, left: 4.w, top: 8.h),
        child: Text(
          DateUtils.isSameDay(hydrationProvider.selectedDate, DateTime.now())
              ? "Today's Log"
              : "Log for ${DateFormat.MMMd().format(hydrationProvider.selectedDate)}",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSliverLogList(
      HydrationProvider hydrationProvider, UserModel? currentUser) {
    final List<HydrationEntry> todaysEntries = hydrationProvider.dailyEntries;

    if (hydrationProvider.logStatus == HydrationLogStatus.loading &&
        todaysEntries.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (hydrationProvider.logStatus == HydrationLogStatus.error) {
      return SliverToBoxAdapter(
        child: Center(
            child: Text(
                hydrationProvider.errorMessage ?? AppStrings.anErrorOccurred)),
      );
    }
    if (todaysEntries.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.water_full,
                    size: 56.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(height: 16.h),
                Text(
                  'No water logged yet for today.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap the (+) button to add your first drink!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = todaysEntries[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: HydrationLogListItem(
              entry: entry,
              unit: currentUser?.preferredUnit ?? MeasurementUnit.ml,
              onDismissed: () {
                context.read<HydrationProvider>().deleteHydrationEntry(entry);
              },
            ),
          );
        },
        childCount: todaysEntries.length,
      ),
    );
  }
}
