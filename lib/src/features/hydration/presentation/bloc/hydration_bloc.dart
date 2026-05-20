import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:minum/src/core/utils/logger.dart';
import 'package:minum/src/features/hydration/data/models/hydration_entry_model.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/src/services/prefs/i_prefs_service.dart';
import 'package:minum/src/core/utils/user_id_resolver.dart';
import 'package:minum/src/core/constants/app_constants.dart' show guestUserId;
import 'package:minum/src/features/hydration/presentation/bloc/hydration_event.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_state.dart';

class HydrationBloc extends Bloc<HydrationEvent, HydrationState> {
  final HydrationService hydrationService;
  final AuthBloc authBloc;
  final IPrefsService prefsService;
  final UserIdResolver userIdResolver;

  StreamSubscription<List<HydrationEntry>>? _entriesSubscription;
  StreamSubscription<AuthState>? _authSubscription;
  String? _currentUserId;

  HydrationBloc({
    required this.hydrationService,
    required this.authBloc,
    required this.prefsService,
    required this.userIdResolver,
  }) : super(HydrationState(
          selectedDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
        )) {
    on<SelectDate>(_onSelectDate);
    on<HydrationDataUpdated>(_onHydrationDataUpdated);
    on<HydrationDataError>(_onHydrationDataError);
    on<AddHydrationEntryEvent>(_onAddHydrationEntry);
    on<UpdateHydrationEntryEvent>(_onUpdateHydrationEntry);
    on<DeleteHydrationEntryEvent>(_onDeleteHydrationEntry);
    on<ResetActionStatus>(_onResetActionStatus);
    on<ProcessPendingWaterAddition>(_onProcessPendingWaterAddition);
    on<FetchHydrationDataRequested>(_onFetchHydrationDataRequested);
    on<SyncHealthDataEvent>(_onSyncHealthDataEvent);

    _subscribeToAuthChanges();
  }

  @override
  Future<void> close() {
    _entriesSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }

  void _subscribeToAuthChanges() {
    // Handle initial auth state
    final currentState = authBloc.state;
    if (currentState is Authenticated) {
      _currentUserId = currentState.user.id;
      logger.i("HydrationBloc: Initial auth state - user $_currentUserId.");
      add(FetchHydrationDataRequested());
    } else if (currentState is Unauthenticated) {
      if (guestUserId.isNotEmpty) {
        _currentUserId = guestUserId;
        logger.i("HydrationBloc: Initial auth state - guest user.");
        add(FetchHydrationDataRequested());
      }
    }

    // Listen for future changes
    _authSubscription = authBloc.stream.listen((authState) {
      final newUserId =
          authState is Authenticated ? authState.user.id : null;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        logger
            .i("HydrationBloc: User changed to ${_currentUserId ?? 'guest'}.");
        add(FetchHydrationDataRequested());
      } else if (_currentUserId == null &&
          guestUserId.isNotEmpty &&
          state.dailyEntries.isEmpty &&
          state.logStatus == HydrationLogStatus.idle) {
        _currentUserId = guestUserId;
        logger.i("HydrationBloc: Initializing for guest user.");
        add(FetchHydrationDataRequested());
      }
    });
  }

  void _cancelEntriesSubscription() {
    _entriesSubscription?.cancel();
    _entriesSubscription = null;
  }

  Future<void> _onFetchHydrationDataRequested(
      FetchHydrationDataRequested event, Emitter<HydrationState> emit) async {
    final userIdForFetch = userIdResolver.effectiveUserId;
    if (userIdForFetch.isEmpty && userIdForFetch != guestUserId) {
      logger.w(
          "HydrationBloc: Cannot fetch daily entries, no valid user/guest ID.");
      emit(state.reset());
      return;
    }

    emit(state.copyWith(
        logStatus: HydrationLogStatus.loading, errorMessage: null));
    _cancelEntriesSubscription();

    logger.d(
        "HydrationBloc: Fetching entries for date ${state.selectedDate}, user/scope: $userIdForFetch");
    _entriesSubscription = hydrationService
        .getHydrationEntriesForDay(userIdForFetch, state.selectedDate)
        .listen(
      (entries) {
        add(HydrationDataUpdated(entries));
      },
      onError: (error) {
        add(HydrationDataError("Failed to load daily hydration logs: $error"));
      },
    );
  }

  void _onSelectDate(SelectDate event, Emitter<HydrationState> emit) {
    final normalizedDate =
        DateTime(event.date.year, event.date.month, event.date.day);
    if (state.selectedDate == normalizedDate) return;

    logger.i("HydrationBloc: Selected date changed to $normalizedDate.");
    emit(state.copyWith(selectedDate: normalizedDate));
    add(FetchHydrationDataRequested());
  }

  void _onHydrationDataUpdated(
      HydrationDataUpdated event, Emitter<HydrationState> emit) {
    logger.i(
        "HydrationBloc: Daily entries loaded. Count: ${event.entries.length}");
    final totalIntake = hydrationService.calculateTotalIntake(event.entries);
    emit(state.copyWith(
      dailyEntries: event.entries,
      logStatus: HydrationLogStatus.loaded,
      totalIntakeToday: totalIntake,
      errorMessage: null,
    ));
  }

  void _onHydrationDataError(
      HydrationDataError event, Emitter<HydrationState> emit) {
    logger.e("HydrationBloc: Error loading daily entries: ${event.message}");
    emit(state.copyWith(
      logStatus: HydrationLogStatus.error,
      errorMessage: event.message,
      dailyEntries: const [],
      totalIntakeToday: 0.0,
    ));
  }

  Future<void> _onAddHydrationEntry(
      AddHydrationEntryEvent event, Emitter<HydrationState> emit) async {
    final userIdForAction = userIdResolver.effectiveUserId;
    if (userIdForAction.isEmpty && userIdForAction != guestUserId) {
      logger.w("HydrationBloc: Cannot add entry, no valid user/guest ID.");
      emit(state.copyWith(
          actionStatus: HydrationActionStatus.error,
          errorMessage: "User not authenticated."));
      return;
    }

    emit(state.copyWith(
        actionStatus: HydrationActionStatus.processing, errorMessage: null));
    final effectiveEntryTime = event.entryTime ?? DateTime.now();

    try {
      await hydrationService.addHydrationEntry(
        userId: userIdForAction,
        amountMl: event.amountMl,
        timestamp: effectiveEntryTime,
        notes: event.notes,
        source: event.source,
      );

      logger.i("HydrationBloc: Entry added successfully.");
      emit(state.copyWith(actionStatus: HydrationActionStatus.success));

      if (DateUtils.isSameDay(state.selectedDate, effectiveEntryTime)) {
        add(FetchHydrationDataRequested());
      }
    } catch (e) {
      logger.e("HydrationBloc: Error adding entry: $e");
      emit(state.copyWith(
          actionStatus: HydrationActionStatus.error,
          errorMessage: "Failed to add water intake: $e"));
    }
  }

  Future<void> _onUpdateHydrationEntry(
      UpdateHydrationEntryEvent event, Emitter<HydrationState> emit) async {
    final userIdForAction = userIdResolver.effectiveUserId;
    if (userIdForAction.isEmpty && userIdForAction != guestUserId) {
      emit(state.copyWith(
          actionStatus: HydrationActionStatus.error,
          errorMessage: "User not authenticated."));
      return;
    }

    emit(state.copyWith(
        actionStatus: HydrationActionStatus.processing, errorMessage: null));
    try {
      final entryWithCorrectUser =
          event.entry.copyWith(userId: userIdForAction);
      await hydrationService.updateHydrationEntry(
          userIdForAction, entryWithCorrectUser);

      emit(state.copyWith(actionStatus: HydrationActionStatus.success));

      if (DateUtils.isSameDay(state.selectedDate, event.entry.timestamp)) {
        add(FetchHydrationDataRequested());
      }
    } catch (e) {
      logger.e("HydrationBloc: Error updating entry: $e");
      emit(state.copyWith(
          actionStatus: HydrationActionStatus.error,
          errorMessage: "Failed to update entry: $e"));
    }
  }

  Future<void> _onDeleteHydrationEntry(
      DeleteHydrationEntryEvent event, Emitter<HydrationState> emit) async {
    final userIdForAction = userIdResolver.effectiveUserId;
    if (userIdForAction.isEmpty && userIdForAction != guestUserId) {
      emit(state.copyWith(
          actionStatus: HydrationActionStatus.error,
          errorMessage: "User not authenticated."));
      return;
    }

    final entryToDelete = event.entry;
    final originalEntries = List<HydrationEntry>.from(state.dailyEntries);
    final int entryIndex = state.dailyEntries.indexWhere((e) =>
        (e.id != null && e.id == entryToDelete.id) ||
        (e.localDbId != null && e.localDbId == entryToDelete.localDbId));

    if (entryIndex != -1) {
      final newEntries = List<HydrationEntry>.from(state.dailyEntries)
        ..removeAt(entryIndex);
      emit(state.copyWith(
          dailyEntries: newEntries,
          actionStatus: HydrationActionStatus.processing,
          totalIntakeToday: hydrationService.calculateTotalIntake(newEntries)));
    } else {
      emit(state.copyWith(actionStatus: HydrationActionStatus.processing));
    }

    try {
      await hydrationService.deleteHydrationEntry(
          userIdForAction, entryToDelete);
      emit(state.copyWith(actionStatus: HydrationActionStatus.success));

      if (entryIndex == -1 ||
          !DateUtils.isSameDay(state.selectedDate, entryToDelete.timestamp)) {
        add(FetchHydrationDataRequested());
      }
    } catch (e) {
      logger.e("HydrationBloc: Error deleting entry: $e");
      emit(state.copyWith(
        actionStatus: HydrationActionStatus.error,
        errorMessage: "Failed to delete entry: $e",
        dailyEntries: originalEntries, // Revert optimistic UI
        totalIntakeToday:
            hydrationService.calculateTotalIntake(originalEntries),
      ));
    }
  }

  void _onResetActionStatus(
      ResetActionStatus event, Emitter<HydrationState> emit) {
    if (state.actionStatus != HydrationActionStatus.idle) {
      emit(state.copyWith(
          actionStatus: HydrationActionStatus.idle, errorMessage: null));
    }
  }

  Future<void> _onProcessPendingWaterAddition(
      ProcessPendingWaterAddition event, Emitter<HydrationState> emit) async {
    try {
      final double? pendingAmountMl =
          await prefsService.getDouble(IPrefsService.keyPendingWaterAdditionMl);

      if (pendingAmountMl != null && pendingAmountMl > 0) {
        if (!userIdResolver.isUserLoggedIn) {
          await Future.delayed(const Duration(seconds: 2));
          if (!userIdResolver.isUserLoggedIn) return;
        }

        add(AddHydrationEntryEvent(
            amountMl: pendingAmountMl, source: 'notification_action'));
        await prefsService.remove(IPrefsService.keyPendingWaterAdditionMl);
      }
    } catch (e) {
      logger.e("HydrationBloc: Error processing pending water addition: $e");
    }
  }

  Future<void> _onSyncHealthDataEvent(
      SyncHealthDataEvent event, Emitter<HydrationState> emit) async {
    final userIdForAction = userIdResolver.effectiveUserId;
    if (userIdForAction.isEmpty || userIdForAction == guestUserId) return;

    try {
      await hydrationService.syncHealthConnectData(userIdForAction,
          date: state.selectedDate);
      add(FetchHydrationDataRequested());
    } catch (e) {
      logger.e("HydrationBloc: Error syncing health data: $e");
    }
  }
}
