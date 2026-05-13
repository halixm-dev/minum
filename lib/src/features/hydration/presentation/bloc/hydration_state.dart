import 'package:equatable/equatable.dart';
import 'package:minum/src/features/hydration/data/models/hydration_entry_model.dart';

enum HydrationLogStatus { idle, loading, loaded, error }

enum HydrationActionStatus { idle, processing, success, error }

class HydrationState extends Equatable {
  final DateTime selectedDate;
  final List<HydrationEntry> dailyEntries;
  final HydrationLogStatus logStatus;
  final HydrationActionStatus actionStatus;
  final String? errorMessage;
  final double totalIntakeToday;

  const HydrationState({
    required this.selectedDate,
    this.dailyEntries = const [],
    this.logStatus = HydrationLogStatus.idle,
    this.actionStatus = HydrationActionStatus.idle,
    this.errorMessage,
    this.totalIntakeToday = 0.0,
  });

  HydrationState copyWith({
    DateTime? selectedDate,
    List<HydrationEntry>? dailyEntries,
    HydrationLogStatus? logStatus,
    HydrationActionStatus? actionStatus,
    String? errorMessage,
    double? totalIntakeToday,
  }) {
    return HydrationState(
      selectedDate: selectedDate ?? this.selectedDate,
      dailyEntries: dailyEntries ?? this.dailyEntries,
      logStatus: logStatus ?? this.logStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      totalIntakeToday: totalIntakeToday ?? this.totalIntakeToday,
    );
  }

  /// Helper to get a clean state when switching dates or users
  HydrationState reset() {
    return HydrationState(
      selectedDate: selectedDate,
      dailyEntries: const [],
      logStatus: HydrationLogStatus.idle,
      actionStatus: HydrationActionStatus.idle,
      errorMessage: null,
      totalIntakeToday: 0.0,
    );
  }

  @override
  List<Object?> get props => [
        selectedDate,
        dailyEntries,
        logStatus,
        actionStatus,
        errorMessage,
        totalIntakeToday,
      ];
}
