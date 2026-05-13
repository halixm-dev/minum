import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:minum/src/core/utils/app_utils.dart';

import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_history_state.dart';

class HistoryBarChart extends StatelessWidget {
  final MeasurementUnit unit;
  final HydrationHistoryState state;

  const HistoryBarChart({
    super.key,
    required this.unit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.historyEntries.isEmpty && state.selectedDateRange == null) {
      return const SizedBox.shrink();
    }

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    if (state.viewType == HistoryViewType.weekly &&
        state.selectedDateRange != null) {
      for (int i = 0; i < 7; i++) {
        final day = state.selectedDateRange!.start.add(Duration(days: i));
        final totalForDay = state.dailyTotals[day] ?? 0.0;
        if (totalForDay > maxY) maxY = totalForDay;
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: AppUtils.convertToPreferredUnit(totalForDay, unit),
                  color: theme.colorScheme.primary,
                  width: 16.w,
                  borderRadius: BorderRadius.circular(4.r))
            ],
          ),
        );
      }
    } else if (state.viewType == HistoryViewType.monthly &&
        state.selectedDateRange != null) {
      final List<DateTime> weekStartDays = [];
      DateTime currentDay = state.selectedDateRange!.start;
      while (currentDay.isBefore(state.selectedDateRange!.end) ||
          currentDay.isAtSameMomentAs(state.selectedDateRange!.end)) {
        if (currentDay.weekday == DateTime.monday || weekStartDays.isEmpty) {
          weekStartDays.add(currentDay);
        }
        currentDay = currentDay.add(const Duration(days: 1));
      }
      if (weekStartDays.isEmpty && state.historyEntries.isNotEmpty) {
        weekStartDays.add(state.selectedDateRange!.start);
      }

      for (int i = 0; i < weekStartDays.length; i++) {
        double totalForWeek = 0;
        DateTime weekStart = weekStartDays[i];
        DateTime weekEnd = weekStart.add(const Duration(days: 6));
        if (weekEnd.isAfter(state.selectedDateRange!.end)) {
          weekEnd = state.selectedDateRange!.end;
        }

        state.dailyTotals.forEach((day, total) {
          if (!day.isBefore(weekStart) && !day.isAfter(weekEnd)) {
            totalForWeek += total;
          }
        });
        if (totalForWeek > maxY) maxY = totalForWeek;
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: AppUtils.convertToPreferredUnit(totalForWeek, unit),
                  color: theme.colorScheme.primary,
                  width: 16.w,
                  borderRadius: BorderRadius.circular(4.r))
            ],
          ),
        );
      }
    }

    if (barGroups.isEmpty) {
      return Padding(
          padding: EdgeInsets.all(16.w),
          child: Text("Not enough data to plot for this period.",
              style: theme.textTheme.bodyMedium));
    }
    maxY = (maxY == 0)
        ? (unit == MeasurementUnit.ml ? 2000 : 64)
        : AppUtils.convertToPreferredUnit(maxY, unit);
    maxY = (maxY * 1.2).ceilToDouble();

    return AspectRatio(
      aspectRatio: 1.6,
      child: Padding(
        padding:
            EdgeInsets.only(top: 24.h, bottom: 12.h, left: 8.w, right: 24.w),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (BarChartGroupData group) =>
                    theme.colorScheme.secondaryContainer,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String label;
                  if (state.viewType == HistoryViewType.weekly) {
                    label = DateFormat.E().format(state.selectedDateRange!.start
                        .add(Duration(days: group.x.toInt())));
                  } else {
                    label = 'Week ${group.x.toInt() + 1}';
                  }
                  final unitString = unit == MeasurementUnit.ml ? 'mL' : 'oz';
                  return BarTooltipItem(
                    '$label\n',
                    theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            "${AppUtils.formatAmount(rod.toY, decimalDigits: 1)} $unitString",
                        style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSecondaryContainer),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48.w,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value == 0 || value == meta.max) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      space: 8.0,
                      child: Text(
                          AppUtils.formatAmount(value, decimalDigits: 0),
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    );
                  },
                  interval: (maxY / 4).ceilToDouble() > 0
                      ? (maxY / 4).ceilToDouble()
                      : 1,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32.h,
                  getTitlesWidget: (value, meta) =>
                      _bottomTitleWidgets(value, meta, theme),
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval:
                  (maxY / 4).ceilToDouble() > 0 ? (maxY / 4).ceilToDouble() : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  strokeWidth: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta, ThemeData theme) {
    String text = '';
    final TextStyle style = theme.textTheme.labelSmall!
        .copyWith(color: theme.colorScheme.onSurfaceVariant);

    if (state.viewType == HistoryViewType.weekly &&
        state.selectedDateRange != null) {
      if (value.toInt() >= 0 && value.toInt() < 7) {
        final day =
            state.selectedDateRange!.start.add(Duration(days: value.toInt()));
        text = DateFormat.E().format(day).substring(0, 1);
      }
    } else if (state.viewType == HistoryViewType.monthly) {
      text = 'W${value.toInt() + 1}';
    }
    return SideTitleWidget(
      meta: meta,
      space: 4.0,
      child: Text(text, style: style),
    );
  }
}
