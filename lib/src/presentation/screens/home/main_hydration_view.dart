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
        _reminderSettingsNotifier = Provider.of<ReminderSettingsNotifier>(
          context,
          listen: false,
        );
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
      Provider.of<HydrationProvider>(
        context,
        listen: false,
      ).processPendingWaterAddition();
    }
  }

  /// Fetches the next scheduled reminder and updates the UI.
  Future<void> _fetchNextReminder() async {
    if (!mounted) return;
    setState(() {
      _isLoadingReminder = true;
    });

    try {
      final notificationService = Provider.of<NotificationService>(
        context,
        listen: false,
      );
      List<NotificationModel> scheduledNotifications = await notificationService
          .listScheduledNotifications();

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
    // This section depends on local state (_nextReminder) and time.
    // It is called within build, so it updates when setState is called
    // or parent rebuilds. Since we optimizing parent rebuilds, this relies
    // on _fetchNextReminder calling setState to update.
    if (_isLoadingReminder) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_nextReminder != null &&
        _nextReminder!.schedule is NotificationCalendar) {
      final schedule = _nextReminder!.schedule as NotificationCalendar;
      if (schedule.hour != null && schedule.minute != null) {
        final DateTime now = DateTime.now();
        final DateTime reminderTime = DateTime(
          now.year,
          now.month,
          now.day,
          schedule.hour!,
          schedule.minute!,
        );

        if (reminderTime.isAfter(now)) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(
                    Symbols.alarm,
                    size: 24.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Next Reminder:",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  Text(
                    DateFormat.jm().format(reminderTime),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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
    // Optimization: Removed top-level Provider.of calls to prevent
    // full screen rebuilds on any provider change.
    // Using granular Selectors/Consumers instead.

    return RefreshIndicator(
      onRefresh: () async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final hydrationProvider = Provider.of<HydrationProvider>(
          context,
          listen: false,
        );
        final userId = userProvider.userProfile?.id;
        final selectedDate = hydrationProvider.selectedDate;

        if (userId != null) {
          await Provider.of<HydrationService>(
            context,
            listen: false,
          ).syncHealthConnectData(userId, date: selectedDate);

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
          // Side Effect Handler
          SliverToBoxAdapter(
            child: Selector<HydrationProvider,
                (HydrationActionStatus, String?)>(
              selector: (_, p) => (p.actionStatus, p.errorMessage),
              builder: (context, data, child) {
                final status = data.$1;
                final errorMessage = data.$2;

                if (status == HydrationActionStatus.error &&
                    errorMessage != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    AppUtils.showSnackBar(
                      context,
                      errorMessage,
                      isError: true,
                    );
                    context.read<HydrationProvider>().resetActionStatus();
                  });
                } else if (status == HydrationActionStatus.success) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<HydrationProvider>().resetActionStatus();
                  });
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Selector<HydrationProvider, DateTime>(
                    selector: (_, p) => p.selectedDate,
                    builder: (context, selectedDate, _) {
                      return _buildDateNavigationHeader(context, selectedDate);
                    },
                  ),
                  SizedBox(height: 16.h),
                  Consumer2<UserProvider, HydrationProvider>(
                    builder: (context, userProvider, hydrationProvider, _) {
                      return _buildDailyProgressSection(
                        context,
                        userProvider.userProfile,
                        hydrationProvider.totalIntakeToday,
                      );
                    },
                  ),
                  // This section relies on local state and time.
                  // By passing _buildNextReminderSection() as child to Selector,
                  // it gets built whenever MainHydrationView rebuilds (which happens on setState).
                  // The Selector then only rebuilds the visibility logic if selectedDate changes,
                  // but effectively uses the *freshly built child*.
                  // However, Selector optimization works by *not calling builder* if value matches.
                  // If builder is not called, the *old child* (from previous build) is reused?
                  // No, the `child` argument to builder is the one passed to Constructor.
                  // BUT if builder is NOT called, the Element tree doesn't update?
                  // Wait, if Selector doesn't rebuild, it returns the *previous Widget*?
                  // No, Selector is a Widget. It calls build.
                  // Inside Selector.build:
                  // if (value == oldVal) return oldWidget;
                  // If it returns oldWidget, then the *new child* passed to constructor is IGNORED.
                  // So `_buildNextReminderSection()` (the new one with updated state) is discarded.
                  //
                  // CORRECTION:
                  // To fix this, we must NOT use Selector to wrap the child if the child depends on
                  // updates that are NOT in the Selector's value.
                  //
                  // We should use Consumer here, OR allow Selector to rebuild when parent rebuilds?
                  // Selector is designed specifically to AVOID rebuilds.
                  //
                  // So we use Consumer<HydrationProvider>. It rebuilds when provider changes.
                  // And since it's a new widget instance on parent rebuild, it will call builder.
                  // Inside builder we check date.
                  Consumer<HydrationProvider>(
                    builder: (context, provider, _) {
                       if (DateUtils.isSameDay(provider.selectedDate, DateTime.now())) {
                          return _buildNextReminderSection();
                       }
                       return const SizedBox.shrink();
                    },
                  ),
                  SizedBox(
                    height: _nextReminder != null && !_isLoadingReminder
                        ? 8.h
                        : 16.h,
                  ),
                  Consumer2<UserProvider, HydrationProvider>(
                    builder: (context, userProvider, hydrationProvider, _) {
                      return _buildQuickAddSection(
                        context,
                        userProvider.userProfile,
                        hydrationProvider.selectedDate,
                      );
                    },
                  ),
                  Consumer2<UserProvider, HydrationProvider>(
                      builder: (context, userProvider, hydrationProvider, _) {
                    if (userProvider.userProfile != null &&
                        DateUtils.isSameDay(
                          hydrationProvider.selectedDate,
                          DateTime.now(),
                        )) {
                      return SizedBox(height: 24.h);
                    }
                    return const SizedBox.shrink();
                  }),
                  Selector<HydrationProvider,
                      (List<HydrationEntry>, HydrationLogStatus, DateTime)>(
                    selector: (_, p) =>
                        (p.dailyEntries, p.logStatus, p.selectedDate),
                    builder: (context, data, _) {
                      return _buildLogTitle(
                        context,
                        data.$1,
                        data.$2,
                        data.$3,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Consumer2<HydrationProvider, UserProvider>(
            builder: (context, hydrationProvider, userProvider, _) {
              return _buildSliverLogList(
                hydrationProvider,
                userProvider.userProfile,
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
        ],
      ),
    );
  }

  Widget _buildDateNavigationHeader(
    BuildContext context,
    DateTime selectedDate,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Symbols.chevron_left,
            size: 28.sp,
          ), // Size can be themed via IconTheme
          onPressed: () {
            context.read<HydrationProvider>().setSelectedDate(
                  selectedDate.subtract(const Duration(days: 1)),
                );
          },
        ),
        Text(
          DateFormat('EEEE, MMM d').format(selectedDate),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: Icon(Symbols.chevron_right, size: 28.sp),
          color: DateUtils.isSameDay(
            selectedDate,
            DateTime.now(),
          )
              ? Theme.of(context).colorScheme.onSurface.withAlpha(97)
              : Theme.of(context).iconTheme.color,
          onPressed: DateUtils.isSameDay(
            selectedDate,
            DateTime.now(),
          )
              ? null
              : () {
                  context.read<HydrationProvider>().setSelectedDate(
                        selectedDate.add(const Duration(days: 1)),
                      );
                },
        ),
      ],
    );
  }

  Widget _buildDailyProgressSection(
    BuildContext context,
    UserModel? currentUser,
    double totalIntakeToday,
  ) {
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
                Text(
                  "Loading user data...",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildQuickAddSection(
    BuildContext context,
    UserModel? currentUser,
    DateTime selectedDate,
  ) {
    if (currentUser != null &&
        DateUtils.isSameDay(selectedDate, DateTime.now())) {
      return QuickAddButtons(
        favoriteVolumes: currentUser.favoriteIntakeVolumes,
        unit: currentUser.preferredUnit,
        onQuickAdd: (volumeMl) {
          context.read<HydrationProvider>().addHydrationEntry(
                volumeMl,
                source: 'quick_add_${volumeMl}ml',
              );
          AppUtils.showSnackBar(
            context,
            "${AppUtils.formatAmount(AppUtils.convertToPreferredUnit(volumeMl, currentUser.preferredUnit), decimalDigits: currentUser.preferredUnit == MeasurementUnit.oz ? 1 : 0)} ${currentUser.preferredUnitString} added!",
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLogTitle(
    BuildContext context,
    List<HydrationEntry> todaysEntries,
    HydrationLogStatus logStatus,
    DateTime selectedDate,
  ) {
    if (todaysEntries.isNotEmpty ||
        logStatus == HydrationLogStatus.loading) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h, left: 4.w, top: 8.h),
        child: Text(
          DateUtils.isSameDay(selectedDate, DateTime.now())
              ? "Today's Log"
              : "Log for ${DateFormat.MMMd().format(selectedDate)}",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSliverLogList(
    HydrationProvider hydrationProvider,
    UserModel? currentUser,
  ) {
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
            hydrationProvider.errorMessage ?? AppStrings.anErrorOccurred,
          ),
        ),
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
                Icon(
                  Symbols.water_full,
                  size: 56.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No water logged yet for today.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap the (+) button to add your first drink!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      key: const Key('hydration_log_list'),
      delegate: SliverChildBuilderDelegate((context, index) {
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
      }, childCount: todaysEntries.length),
    );
  }
}
