import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/constants/app_constants.dart' show guestUserId;
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_bloc.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_event.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_state.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_history_cubit.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_history_state.dart';
import 'package:minum/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_state.dart';
import 'package:minum/src/features/hydration/presentation/widgets/history_bar_chart.dart';
import 'package:minum/src/features/hydration/presentation/widgets/history_summary_lists.dart';
import 'package:minum/src/core/utils/logger.dart';

/// A screen that displays the user's hydration history.
///
/// This screen provides weekly and monthly views of hydration data,
/// including a bar chart and a list of daily or weekly totals.
class HydrationHistoryScreen extends StatefulWidget {
  /// Creates a `HydrationHistoryScreen`.
  const HydrationHistoryScreen({super.key});

  @override
  State<HydrationHistoryScreen> createState() => _HydrationHistoryScreenState();
}

class _HydrationHistoryScreenState extends State<HydrationHistoryScreen> {
  StreamSubscription<HydrationState>? _hydrationBlocSubscription;

  @override
  void initState() {
    super.initState();
    logger.d("HydrationHistoryScreen: initState");

    _hydrationBlocSubscription = context
        .read<HydrationBloc>()
        .stream
        .listen(_onHydrationBlocStateChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userState = context.watch<UserBloc>().state;
    final newScopeId =
        userState is UserLoaded ? userState.user.id : guestUserId;

    context.read<HydrationHistoryCubit>().updateDataScope(newScopeId);
  }

  /// Called when the [HydrationBloc] emits a new state.
  void _onHydrationBlocStateChanged(HydrationState state) {
    if (!mounted) return;
    final providerStatus = state.actionStatus;
    if (providerStatus == HydrationActionStatus.success) {
      logger.d(
          "HydrationHistoryScreen: HydrationBloc reported success. Re-fetching history if not already loading.");
      final historyCubit = context.read<HydrationHistoryCubit>();
      if (!historyCubit.state.isLoading) {
        historyCubit.refreshData();
      }
      context.read<HydrationBloc>().add(ResetActionStatus());
    }
  }

  @override
  void dispose() {
    logger.d("HydrationHistoryScreen: dispose");
    _hydrationBlocSubscription?.cancel();
    super.dispose();
  }

  /// Builds the segmented button for selecting the view type (weekly or monthly).
  Widget _buildViewTypeSelector(HydrationHistoryState state) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: SegmentedButton<HistoryViewType>(
        segments: const <ButtonSegment<HistoryViewType>>[
          ButtonSegment<HistoryViewType>(
              value: HistoryViewType.weekly,
              label: Text('Weekly'),
              icon: Icon(Symbols.calendar_view_week)),
          ButtonSegment<HistoryViewType>(
              value: HistoryViewType.monthly,
              label: Text('Monthly'),
              icon: Icon(Symbols.calendar_today)),
        ],
        selected: {state.viewType},
        onSelectionChanged: (Set<HistoryViewType> newSelection) {
          context.read<HydrationHistoryCubit>().setViewType(newSelection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          selectedForegroundColor: theme.colorScheme.onSecondaryContainer,
          selectedBackgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSurfaceVariant,
          textStyle: theme.textTheme.labelLarge,
        ),
      ),
    );
  }

  /// Builds the date navigation header for changing the selected week or month.
  Widget _buildDateNavigation(HydrationHistoryState state) {
    final theme = Theme.of(context);
    String title = "";
    if (state.selectedDateRange != null) {
      if (state.viewType == HistoryViewType.weekly) {
        title =
            "${DateFormat.MMMd().format(state.selectedDateRange!.start)} - ${DateFormat.MMMd().format(state.selectedDateRange!.end)}";
      } else if (state.viewType == HistoryViewType.monthly) {
        title = DateFormat.yMMMM().format(state.selectedDateRange!.start);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Symbols.chevron_left,
                size: 28.sp, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () {
              if (state.viewType == HistoryViewType.weekly) {
                context.read<HydrationHistoryCubit>().changeWeek(-1);
              } else if (state.viewType == HistoryViewType.monthly) {
                context.read<HydrationHistoryCubit>().changeMonth(-1);
              }
            },
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Symbols.chevron_right,
                size: 28.sp, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () {
              if (state.viewType == HistoryViewType.weekly) {
                context.read<HydrationHistoryCubit>().changeWeek(1);
              } else if (state.viewType == HistoryViewType.monthly) {
                context.read<HydrationHistoryCubit>().changeMonth(1);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Builds a prompt for the user to log in to sync their data.
  Widget _buildLoginToSyncPrompt(BuildContext context, ThemeData theme) {
    return Container(
      color: theme.colorScheme.tertiaryContainer
          .withAlpha(128), // 0.5 opacity approx
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(Symbols.sync,
              color: theme.colorScheme.onTertiaryContainer, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "You have local data. Log in to sync and backup your history!",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            child: Text("Login",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary)),
          )
        ],
      ),
    );
  }

  /// Builds the empty state widget when there is no data to display.
  Widget _buildEmptyState(bool isLoggedIn, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.bar_chart_off,
                size: 64.sp, color: theme.colorScheme.onSurfaceVariant),
            SizedBox(height: 20.h),
            Text(
              AppStrings.noDataAvailable,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              isLoggedIn
                  ? 'No hydration logs found for the selected period.'
                  : 'Log some water to see your history here. Log in to sync across devices!',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (!isLoggedIn) SizedBox(height: 24.h),
            if (!isLoggedIn)
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.login),
                child: const Text("Login to Sync"),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userState = context.watch<UserBloc>().state;
    final UserModel? currentUser =
        userState is UserLoaded ? userState.user : null;
    final bool isLoggedIn =
        currentUser != null && !(userState is UserLoaded && userState.isGuest);
    final preferredUnit = currentUser?.preferredUnit ?? MeasurementUnit.ml;

    return Scaffold(
      body: BlocBuilder<HydrationHistoryCubit, HydrationHistoryState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildViewTypeSelector(state),
              _buildDateNavigation(state),
              if (!isLoggedIn && state.historyEntries.isNotEmpty)
                _buildLoginToSyncPrompt(context, theme),
              Expanded(
                child: state.isLoading && state.historyEntries.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                            color: theme.colorScheme.primary))
                    : (state.historyEntries.isEmpty)
                        ? _buildEmptyState(isLoggedIn, theme)
                        : CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: HistoryBarChart(
                                  unit: preferredUnit,
                                  state: state,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      16.w, 20.h, 16.w, 12.h),
                                  child: Text(
                                    state.viewType == HistoryViewType.weekly
                                        ? 'Daily Totals'
                                        : 'Weekly Totals',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.onSurface),
                                  ),
                                ),
                              ),
                              if (state.viewType == HistoryViewType.weekly)
                                WeeklySummaryList(
                                  unit: preferredUnit,
                                  state: state,
                                )
                              else if (state.viewType ==
                                  HistoryViewType.monthly)
                                MonthlySummaryList(
                                  unit: preferredUnit,
                                  state: state,
                                ),
                              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                            ],
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
