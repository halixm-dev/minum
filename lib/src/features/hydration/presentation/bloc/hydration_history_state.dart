import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:minum/src/features/hydration/data/models/hydration_entry_model.dart';

enum HistoryViewType { weekly, monthly }

class HydrationHistoryState extends Equatable {
  final HistoryViewType viewType;
  final DateTimeRange? selectedDateRange;
  final DateTime selectedMonth;
  final DateTime selectedWeekStart;
  final List<HydrationEntry> historyEntries;
  final Map<DateTime, double> dailyTotals;
  final bool isLoading;
  final String? error;

  const HydrationHistoryState({
    this.viewType = HistoryViewType.weekly,
    this.selectedDateRange,
    required this.selectedMonth,
    required this.selectedWeekStart,
    this.historyEntries = const [],
    this.dailyTotals = const {},
    this.isLoading = false,
    this.error,
  });

  HydrationHistoryState copyWith({
    HistoryViewType? viewType,
    DateTimeRange? selectedDateRange,
    DateTime? selectedMonth,
    DateTime? selectedWeekStart,
    List<HydrationEntry>? historyEntries,
    Map<DateTime, double>? dailyTotals,
    bool? isLoading,
    String? error,
  }) {
    return HydrationHistoryState(
      viewType: viewType ?? this.viewType,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedWeekStart: selectedWeekStart ?? this.selectedWeekStart,
      historyEntries: historyEntries ?? this.historyEntries,
      dailyTotals: dailyTotals ?? this.dailyTotals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        viewType,
        selectedDateRange,
        selectedMonth,
        selectedWeekStart,
        historyEntries,
        dailyTotals,
        isLoading,
        error,
      ];
}
