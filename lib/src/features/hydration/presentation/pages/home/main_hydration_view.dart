import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/features/hydration/data/models/hydration_entry_model.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_state.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_bloc.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_event.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_state.dart';
import 'package:minum/src/features/settings/presentation/bloc/reminder_settings_cubit.dart';
import 'package:minum/src/features/hydration/presentation/widgets/home/daily_progress_card.dart';
import 'package:minum/src/features/hydration/presentation/widgets/home/hydration_log_list_item.dart';
import 'package:minum/src/features/hydration/presentation/widgets/home/quick_add_buttons.dart';
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
  ReminderSettingsCubit? _reminderSettingsCubit;
  StreamSubscription? _reminderSubscription;

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
        _reminderSettingsCubit = context.read<ReminderSettingsCubit>();
        _reminderSubscription = _reminderSettingsCubit?.stream.listen((_) {
          _onReminderSettingsChanged();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _fetchNextReminder();
      context.read<HydrationBloc>().add(ProcessPendingWaterAddition());
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
                    TimeOfDay.fromDateTime(reminderTime).format(context),
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
    final userState = context.watch<UserBloc>().state;
    final hydrationState = context.watch<HydrationBloc>().state;

    final UserModel? currentUser = userState is UserLoaded ? userState.user : null;

    return BlocListener<HydrationBloc, HydrationState>(
      listenWhen: (previous, current) => previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == HydrationActionStatus.error && state.errorMessage != null) {
          AppUtils.showSnackBar(
            context,
            state.errorMessage!,
            isError: true,
          );
          context.read<HydrationBloc>().add(ResetActionStatus());
        } else if (state.actionStatus == HydrationActionStatus.success) {
          context.read<HydrationBloc>().add(ResetActionStatus());
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          final userState = context.read<UserBloc>().state;
          final hydrationState = context.read<HydrationBloc>().state;
          final userId = userState is UserLoaded ? userState.user.id : null;
          final selectedDate = hydrationState.selectedDate;

          if (userId != null) {
            await Provider.of<HydrationService>(
              context,
              listen: false,
            ).syncHealthConnectData(userId, date: selectedDate);

            // Force refresh of the hydration provider to show any new synced entries
            if (context.mounted) {
              context.read<HydrationBloc>().add(FetchHydrationDataRequested());
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
                  _buildDateNavigationHeader(context, hydrationState),
                  SizedBox(height: 16.h),
                  _buildDailyProgressSection(
                    context,
                    userState,
                    hydrationState,
                  ),
                  if (DateUtils.isSameDay(
                    hydrationState.selectedDate,
                    DateTime.now(),
                  ))
                    _buildNextReminderSection(),
                  SizedBox(
                    height: _nextReminder != null && !_isLoadingReminder
                        ? 8.h
                        : 16.h,
                  ),
                  _buildQuickAddSection(
                    context,
                    userState,
                    hydrationState,
                  ),
                  if (currentUser != null &&
                      DateUtils.isSameDay(
                        hydrationState.selectedDate,
                        DateTime.now(),
                      ))
                    SizedBox(height: 24.h),
                  _buildLogTitle(context, hydrationState),
                ],
              ),
            ),
          ),
          _buildSliverLogList(context, hydrationState, currentUser),
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
        ],
      ),
      ),
    );
  }

  Widget _buildDateNavigationHeader(
    BuildContext context,
    HydrationState hydrationState,
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
            context.read<HydrationBloc>().add(
                  SelectDate(
                    hydrationState.selectedDate
                        .subtract(const Duration(days: 1)),
                  ),
                );
          },
        ),
        Text(
          DateFormat('EEEE, MMM d').format(hydrationState.selectedDate),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: Icon(Symbols.chevron_right, size: 28.sp),
          color: DateUtils.isSameDay(
            hydrationState.selectedDate,
            DateTime.now(),
          )
              ? Theme.of(context).colorScheme.onSurface.withAlpha(97)
              : Theme.of(context).iconTheme.color,
          onPressed: DateUtils.isSameDay(
            hydrationState.selectedDate,
            DateTime.now(),
          )
              ? null
              : () {
                  context.read<HydrationBloc>().add(
                        SelectDate(
                          hydrationState.selectedDate
                              .add(const Duration(days: 1)),
                        ),
                      );
                },
        ),
      ],
    );
  }

  Widget _buildDailyProgressSection(
    BuildContext context,
    UserState userState,
    HydrationState hydrationState,
  ) {
    final UserModel? currentUser = userState is UserLoaded ? userState.user : null;
    final double totalIntakeToday = hydrationState.totalIntakeToday;
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
    UserState userState,
    HydrationState hydrationState,
  ) {
    final UserModel? currentUser = userState is UserLoaded ? userState.user : null;
    if (currentUser != null &&
        DateUtils.isSameDay(hydrationState.selectedDate, DateTime.now())) {
      return QuickAddButtons(
        favoriteVolumes: currentUser.favoriteIntakeVolumes,
        unit: currentUser.preferredUnit,
        onQuickAdd: (volumeMl) {
          context.read<HydrationBloc>().add(
                AddHydrationEntryEvent(
                  amountMl: volumeMl,
                  source: 'quick_add_${volumeMl}ml',
                ),
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
    HydrationState hydrationState,
  ) {
    final List<HydrationEntry> todaysEntries = hydrationState.dailyEntries;
    if (todaysEntries.isNotEmpty ||
        hydrationState.logStatus == HydrationLogStatus.loading) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h, left: 4.w, top: 8.h),
        child: Text(
          DateUtils.isSameDay(hydrationState.selectedDate, DateTime.now())
              ? "Today's Log"
              : "Log for ${DateFormat.MMMd().format(hydrationState.selectedDate)}",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSliverLogList(
    BuildContext context,
    HydrationState hydrationState,
    UserModel? currentUser,
  ) {
    final List<HydrationEntry> todaysEntries = hydrationState.dailyEntries;

    if (hydrationState.logStatus == HydrationLogStatus.loading &&
        todaysEntries.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (hydrationState.logStatus == HydrationLogStatus.error) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            hydrationState.errorMessage ?? AppStrings.anErrorOccurred,
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
              context.read<HydrationBloc>().add(DeleteHydrationEntryEvent(entry));
            },
          ),
        );
      }, childCount: todaysEntries.length),
    );
  }
}
