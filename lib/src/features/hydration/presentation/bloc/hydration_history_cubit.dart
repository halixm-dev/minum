import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_history_state.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/src/core/utils/logger.dart';

class HydrationHistoryCubit extends Cubit<HydrationHistoryState> {
  final HydrationService hydrationService;
  StreamSubscription? _historySubscription;
  String? _currentDataScopeId;

  HydrationHistoryCubit({required this.hydrationService})
      : super(HydrationHistoryState(
          selectedMonth: DateTime(DateTime.now().year, DateTime.now().month),
          selectedWeekStart: DateTime.now().subtract(
              Duration(days: DateTime.now().weekday - DateTime.monday)),
        )) {
    _updateSelectedDateRange();
  }

  void updateDataScope(String scopeId) {
    if (_currentDataScopeId != scopeId) {
      _currentDataScopeId = scopeId;
      _fetchHistoryData();
    }
  }

  void setViewType(HistoryViewType viewType) {
    if (state.viewType == viewType) return;
    DateTime newWeekStart = state.selectedWeekStart;
    DateTime newMonth = state.selectedMonth;

    if (viewType == HistoryViewType.weekly) {
      newWeekStart = DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - DateTime.monday));
    } else {
      newMonth = DateTime(DateTime.now().year, DateTime.now().month);
    }

    emit(state.copyWith(
      viewType: viewType,
      selectedWeekStart: newWeekStart,
      selectedMonth: newMonth,
    ));
    _updateSelectedDateRange();
    _fetchHistoryData();
  }

  void changeWeek(int direction) {
    emit(state.copyWith(
      selectedWeekStart:
          state.selectedWeekStart.add(Duration(days: 7 * direction)),
    ));
    _updateSelectedDateRange();
    _fetchHistoryData();
  }

  void changeMonth(int direction) {
    emit(state.copyWith(
      selectedMonth: DateTime(
          state.selectedMonth.year, state.selectedMonth.month + direction, 1),
    ));
    _updateSelectedDateRange();
    _fetchHistoryData();
  }

  void selectWeek(DateTime weekStart) {
    emit(state.copyWith(
      viewType: HistoryViewType.weekly,
      selectedWeekStart: weekStart,
    ));
    _updateSelectedDateRange();
    _fetchHistoryData();
  }

  void refreshData() {
    _fetchHistoryData();
  }

  void _updateSelectedDateRange() {
    DateTimeRange? range;
    if (state.viewType == HistoryViewType.weekly) {
      range = DateTimeRange(
        start: DateTime(state.selectedWeekStart.year,
            state.selectedWeekStart.month, state.selectedWeekStart.day),
        end: DateTime(state.selectedWeekStart.year,
                state.selectedWeekStart.month, state.selectedWeekStart.day)
            .add(const Duration(days: 6)),
      );
    } else {
      range = DateTimeRange(
        start: DateTime(state.selectedMonth.year, state.selectedMonth.month, 1),
        end: DateTime(
            state.selectedMonth.year, state.selectedMonth.month + 1, 0),
      );
    }
    emit(state.copyWith(selectedDateRange: range));
  }

  void _fetchHistoryData() {
    _historySubscription?.cancel();

    if (_currentDataScopeId == null ||
        _currentDataScopeId!.isEmpty ||
        state.selectedDateRange == null) {
      emit(state.copyWith(
          historyEntries: [], isLoading: false, dailyTotals: {}));
      return;
    }

    emit(state.copyWith(isLoading: true, historyEntries: [], dailyTotals: {}));

    _historySubscription = hydrationService
        .getHydrationEntriesForDateRange(_currentDataScopeId!,
            state.selectedDateRange!.start, state.selectedDateRange!.end)
        .listen((entries) {
      final totals = <DateTime, double>{};
      for (var entry in entries) {
        final entryDay = DateTime(
            entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
        totals[entryDay] = (totals[entryDay] ?? 0) + entry.amountMl;
      }
      emit(state.copyWith(
          historyEntries: entries, dailyTotals: totals, isLoading: false));
    }, onError: (error, stackTrace) {
      logger.e("Error fetching history data: $error",
          error: error, stackTrace: stackTrace);
      emit(state.copyWith(
          historyEntries: [],
          isLoading: false,
          dailyTotals: {},
          error: error.toString()));
    });
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}
