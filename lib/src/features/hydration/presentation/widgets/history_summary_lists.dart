import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:minum/src/core/utils/app_utils.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_bloc.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_event.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_history_cubit.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_history_state.dart';
import 'package:minum/src/presentation/providers/bottom_nav_provider.dart';
import 'package:provider/provider.dart';
import 'package:minum/src/core/utils/logger.dart';

class WeeklySummaryList extends StatelessWidget {
  final MeasurementUnit unit;
  final HydrationHistoryState state;

  const WeeklySummaryList({
    super.key,
    required this.unit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.selectedDateRange == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    List<Widget> dayTiles = [];
    for (int i = 0; i < 7; i++) {
      final day = state.selectedDateRange!.start.add(Duration(days: i));
      final totalForDay = state.dailyTotals[day] ?? 0.0;
      final displayTotal = AppUtils.formatAmount(
          AppUtils.convertToPreferredUnit(totalForDay, unit),
          decimalDigits: unit == MeasurementUnit.oz ? 1 : 0);
      final unitString = unit == MeasurementUnit.ml ? "mL" : "oz";

      dayTiles.add(ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(DateFormat.E().format(day).substring(0, 1),
              style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold)),
        ),
        title: Text(DateFormat('EEEE, MMM d').format(day),
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurface)),
        trailing: Text('$displayTotal $unitString',
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        onTap: () {
          context.read<HydrationBloc>().add(SelectDate(day));
          Provider.of<BottomNavProvider>(context, listen: false)
              .setCurrentIndex(0);
          logger.i(
              "Tapped on day ${DateFormat.yMd().format(day)}. Switched to Home tab and set date.");
        },
        dense: true,
      ));
    }
    return SliverList(delegate: SliverChildListDelegate(dayTiles));
  }
}

class MonthlySummaryList extends StatelessWidget {
  final MeasurementUnit unit;
  final HydrationHistoryState state;

  const MonthlySummaryList({
    super.key,
    required this.unit,
    required this.state,
  });

  List<DateTimeRange> _getWeeksInMonth(DateTime monthStart, DateTime monthEnd) {
    List<DateTimeRange> weeks = [];
    DateTime currentWeekStart = monthStart;
    while (currentWeekStart.isBefore(monthEnd) ||
        currentWeekStart.isAtSameMomentAs(monthEnd)) {
      DateTime currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
      if (currentWeekEnd.isAfter(monthEnd)) currentWeekEnd = monthEnd;
      weeks.add(DateTimeRange(start: currentWeekStart, end: currentWeekEnd));
      currentWeekStart = DateTime(
              currentWeekEnd.year, currentWeekEnd.month, currentWeekEnd.day)
          .add(const Duration(days: 1));
      if (currentWeekStart.month != monthStart.month &&
          currentWeekStart.isAfter(monthEnd)) {
        break;
      }
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.selectedDateRange == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final List<DateTimeRange> weeksInMonth = _getWeeksInMonth(
        state.selectedDateRange!.start, state.selectedDateRange!.end);
    List<Widget> weekTiles = [];

    for (int i = 0; i < weeksInMonth.length; i++) {
      final weekRange = weeksInMonth[i];
      double totalForWeek = 0;
      state.dailyTotals.forEach((day, total) {
        if (!day.isBefore(weekRange.start) &&
            (day.isBefore(weekRange.end) ||
                day.isAtSameMomentAs(weekRange.end))) {
          totalForWeek += total;
        }
      });

      final displayTotal = AppUtils.formatAmount(
          AppUtils.convertToPreferredUnit(totalForWeek, unit),
          decimalDigits: unit == MeasurementUnit.oz ? 1 : 0);
      final unitString = unit == MeasurementUnit.ml ? "mL" : "oz";
      final weekLabel =
          "Week ${i + 1} (${DateFormat.MMMd().format(weekRange.start)} - ${DateFormat.MMMd().format(weekRange.end)})";

      weekTiles.add(ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Text('W${i + 1}',
              style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold)),
        ),
        title: Text(weekLabel,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurface)),
        trailing: Text('$displayTotal $unitString',
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        onTap: () {
          context.read<HydrationHistoryCubit>().selectWeek(weekRange.start);
        },
        dense: true,
      ));
    }
    return SliverList(delegate: SliverChildListDelegate(weekTiles));
  }
}
