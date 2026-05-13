import 'package:equatable/equatable.dart';

import 'package:minum/src/features/hydration/data/models/hydration_entry_model.dart';

abstract class HydrationEvent extends Equatable {
  const HydrationEvent();

  @override
  List<Object?> get props => [];
}

class SelectDate extends HydrationEvent {
  final DateTime date;
  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class HydrationDataUpdated extends HydrationEvent {
  final List<HydrationEntry> entries;
  const HydrationDataUpdated(this.entries);

  @override
  List<Object?> get props => [entries];
}

class HydrationDataError extends HydrationEvent {
  final String message;
  const HydrationDataError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddHydrationEntryEvent extends HydrationEvent {
  final double amountMl;
  final DateTime? entryTime;
  final String? notes;
  final String? source;

  const AddHydrationEntryEvent({
    required this.amountMl,
    this.entryTime,
    this.notes,
    this.source,
  });

  @override
  List<Object?> get props => [amountMl, entryTime, notes, source];
}

class UpdateHydrationEntryEvent extends HydrationEvent {
  final HydrationEntry entry;
  const UpdateHydrationEntryEvent(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DeleteHydrationEntryEvent extends HydrationEvent {
  final HydrationEntry entry;
  const DeleteHydrationEntryEvent(this.entry);

  @override
  List<Object?> get props => [entry];
}

class ResetActionStatus extends HydrationEvent {}

class ProcessPendingWaterAddition extends HydrationEvent {}

class FetchHydrationDataRequested extends HydrationEvent {}

class SyncHealthDataEvent extends HydrationEvent {}
