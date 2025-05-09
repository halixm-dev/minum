// lib/src/presentation/providers/hydration_provider.dart
import 'dart:async';
import 'package:flutter/material.dart'; // For DateUtils
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/main.dart'; // For logger
import 'package:minum/src/data/repositories/local/local_hydration_repository.dart' show GUEST_USER_ID;

enum HydrationLogStatus { idle, loading, loaded, error }
enum HydrationActionStatus { idle, processing, success, error }

class HydrationProvider with ChangeNotifier {
  final HydrationService _hydrationService;
  final AuthService _authService;

  List<HydrationEntry> _dailyEntries = [];
  HydrationLogStatus _logStatus = HydrationLogStatus.idle;
  HydrationActionStatus _actionStatus = HydrationActionStatus.idle;
  String? _errorMessage;
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  StreamSubscription<List<HydrationEntry>>? _entriesSubscription;
  StreamSubscription<UserModel?>? _authSubscription;
  String? _currentUserId;
  bool _isDisposed = false;

  List<HydrationEntry> get dailyEntries => _dailyEntries;
  HydrationLogStatus get logStatus => _logStatus;
  HydrationActionStatus get actionStatus => _actionStatus;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  double get totalIntakeToday => _hydrationService.calculateTotalIntake(_dailyEntries);

  HydrationProvider({required HydrationService hydrationService, required AuthService authService})
      : _hydrationService = hydrationService, _authService = authService {
    _subscribeToAuthChanges();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    } else {
      logger.w("HydrationProvider: Attempted to call notifyListeners() after dispose.");
    }
  }

  void _subscribeToAuthChanges() {
    _authSubscription = _authService.authStateChanges.listen((UserModel? authUser) async {
      if (_isDisposed) return;
      final newUserId = authUser?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        logger.i("HydrationProvider: User changed to ${_currentUserId ?? 'guest'}. Fetching entries for $_selectedDate.");
        _cancelEntriesSubscription();
        final userIdForFetch = _currentUserId ?? GUEST_USER_ID;
        if (userIdForFetch.isNotEmpty) {
          await fetchHydrationEntriesForDate(_selectedDate);
        } else {
          _dailyEntries = [];
          _logStatus = HydrationLogStatus.idle;
          _safeNotifyListeners();
        }
      } else if (_currentUserId == null && GUEST_USER_ID.isNotEmpty && _dailyEntries.isEmpty && _logStatus == HydrationLogStatus.idle) {
        _currentUserId = GUEST_USER_ID;
        logger.i("HydrationProvider: Initializing for guest user. Fetching entries for $_selectedDate.");
        await fetchHydrationEntriesForDate(_selectedDate);
      }
    });
  }

  void _cancelEntriesSubscription() {
    _entriesSubscription?.cancel();
    _entriesSubscription = null;
  }

  void setSelectedDate(DateTime date) async {
    if (_isDisposed) return;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (_selectedDate == normalizedDate) {
      return;
    }
    _selectedDate = normalizedDate;
    logger.i("HydrationProvider: Selected date changed to $_selectedDate.");
    _cancelEntriesSubscription();
    final userIdForFetch = _currentUserId ?? GUEST_USER_ID;
    if (userIdForFetch.isNotEmpty) {
      await fetchHydrationEntriesForDate(_selectedDate);
    } else {
      _dailyEntries = [];
      _logStatus = HydrationLogStatus.idle;
      _safeNotifyListeners();
    }
  }

  Future<void> fetchHydrationEntriesForDate(DateTime date) async {
    if (_isDisposed) return;
    final userIdForFetch = _currentUserId ?? GUEST_USER_ID;
    if (userIdForFetch.isEmpty && userIdForFetch != GUEST_USER_ID) {
      _logStatus = HydrationLogStatus.idle;
      _dailyEntries = [];
      _safeNotifyListeners();
      logger.w("HydrationProvider: Cannot fetch daily entries, no valid user/guest ID.");
      return;
    }

    _logStatus = HydrationLogStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    _cancelEntriesSubscription();

    logger.d("HydrationProvider: Fetching entries for date $date, user/scope: $userIdForFetch");
    _entriesSubscription = _hydrationService
        .getHydrationEntriesForDay(userIdForFetch, date)
        .listen(
          (entries) {
        if (_isDisposed) return;
        _dailyEntries = entries;
        _logStatus = HydrationLogStatus.loaded;
        _errorMessage = null;
        logger.i("HydrationProvider: Daily entries loaded for $date. Count: ${entries.length}");
        _safeNotifyListeners();
      },
      onError: (error) {
        if (_isDisposed) return;
        _logStatus = HydrationLogStatus.error;
        _errorMessage = "Failed to load daily hydration logs: ${error.toString()}";
        _dailyEntries = [];
        logger.e("HydrationProvider: Error loading daily entries for $date: $error");
        _safeNotifyListeners();
      },
    );
  }

  Stream<List<HydrationEntry>> getEntriesForDateRangeStream(String userId, DateTime startDate, DateTime endDate) {
    if (_isDisposed) return Stream.value([]);
    final userIdForFetch = userId.isEmpty ? GUEST_USER_ID : userId;
    if (userIdForFetch.isEmpty && userIdForFetch != GUEST_USER_ID) {
      logger.w("HydrationProvider: User ID is empty for date range stream, returning empty stream.");
      return Stream.value([]);
    }
    logger.i("HydrationProvider: Getting entries stream for date range: $startDate to $endDate for user/scope $userIdForFetch");
    return _hydrationService.getHydrationEntriesForDateRange(userIdForFetch, startDate, endDate);
  }


  Future<void> addHydrationEntry(double amountMl, {DateTime? entryTime, String? notes, String? source}) async {
    if (_isDisposed) return;
    final userIdForAction = _currentUserId ?? GUEST_USER_ID;
    if (userIdForAction.isEmpty && userIdForAction != GUEST_USER_ID) {
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "User not authenticated or guest scope not identified.";
      _safeNotifyListeners();
      logger.w("HydrationProvider: Cannot add entry, no valid user/guest ID.");
      return;
    }
    _actionStatus = HydrationActionStatus.processing;
    _errorMessage = null;
    _safeNotifyListeners();

    final DateTime effectiveEntryTime = entryTime ?? DateTime.now();

    try {
      await _hydrationService.addHydrationEntry(
          userId: userIdForAction,
          amountMl: amountMl,
          timestamp: effectiveEntryTime,
          notes: notes,
          source: source
      );
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.success;
      _errorMessage = null;
      logger.i("HydrationProvider: Entry added successfully for $userIdForAction.");
      if (DateUtils.isSameDay(_selectedDate, effectiveEntryTime)) {
        logger.d("HydrationProvider: Added entry is for selected date. Refreshing daily entries.");
        await fetchHydrationEntriesForDate(_selectedDate);
      }
    } catch (e) {
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "Failed to add water intake: ${e.toString()}";
      logger.e("HydrationProvider: Error adding entry: $e");
    }
    _safeNotifyListeners();
  }

  Future<void> updateHydrationEntry(HydrationEntry entry) async {
    if (_isDisposed) return;
    final userIdForAction = _currentUserId ?? GUEST_USER_ID;
    if (userIdForAction.isEmpty && userIdForAction != GUEST_USER_ID) {
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "User not authenticated or guest scope not identified.";
      _safeNotifyListeners();
      logger.w("HydrationProvider: Cannot update entry, no valid user/guest ID.");
      return;
    }
    _actionStatus = HydrationActionStatus.processing;
    _errorMessage = null;
    _safeNotifyListeners();
    try {
      final entryWithCorrectUser = entry.copyWith(userId: userIdForAction);
      await _hydrationService.updateHydrationEntry(userIdForAction, entryWithCorrectUser);
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.success;
      _errorMessage = null;
      logger.i("HydrationProvider: Entry ${entry.id ?? entry.localDbId} updated for $userIdForAction.");
      if (DateUtils.isSameDay(_selectedDate, entry.timestamp)) {
        logger.d("HydrationProvider: Updated entry is for selected date. Refreshing daily entries.");
        await fetchHydrationEntriesForDate(_selectedDate);
      }
    } catch (e) {
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "Failed to update entry: ${e.toString()}";
      logger.e("HydrationProvider: Error updating entry ${entry.id ?? entry.localDbId}: $e");
    }
    _safeNotifyListeners();
  }

  Future<void> deleteHydrationEntry(HydrationEntry entryToDelete) async {
    if (_isDisposed) return;
    final userIdForAction = _currentUserId ?? GUEST_USER_ID;
    if (userIdForAction.isEmpty && userIdForAction != GUEST_USER_ID) {
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "User not authenticated or guest scope not identified.";
      _safeNotifyListeners();
      logger.w("HydrationProvider: Cannot delete entry, no valid user/guest ID.");
      return;
    }

    // **Optimistic UI Update**
    final originalEntries = List<HydrationEntry>.from(_dailyEntries);
    final int entryIndex = _dailyEntries.indexWhere((e) =>
    (e.id != null && e.id == entryToDelete.id) ||
        (e.localDbId != null && e.localDbId == entryToDelete.localDbId)
    );

    if (entryIndex != -1) {
      _dailyEntries.removeAt(entryIndex);
      _actionStatus = HydrationActionStatus.processing; // Still processing backend
      _errorMessage = null;
      _safeNotifyListeners(); // Notify UI immediately of the removal
      logger.d("HydrationProvider: Optimistically removed entry (ID: ${entryToDelete.id ?? entryToDelete.localDbId}) from UI.");
    } else {
      logger.w("HydrationProvider: Entry to delete not found in current daily list. Proceeding with backend delete attempt.");
      _actionStatus = HydrationActionStatus.processing;
      _errorMessage = null;
      _safeNotifyListeners();
    }

    try {
      await _hydrationService.deleteHydrationEntry(userIdForAction, entryToDelete);
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.success;
      _errorMessage = null;
      logger.i("HydrationProvider: Entry ${entryToDelete.id ?? entryToDelete.localDbId} delete successful for $userIdForAction.");

      // If the optimistic removal was for the selected date, the UI is already updated.
      // If the backend deletion succeeded, we don't need to re-fetch unless there's a mismatch.
      // However, if the deletion affected a different day than _selectedDate (less likely for this method's typical use)
      // or to ensure absolute consistency after backend op, a selective re-fetch could be done.
      // For now, the optimistic removal handles the immediate UI.
      // If the entry was on the selected date and removed, the list is already correct.
      // If it wasn't on the selected date (unlikely for this call path), no UI change needed here.
      if (entryIndex != -1 && !DateUtils.isSameDay(_selectedDate, entryToDelete.timestamp)) {
        // This case is less likely if deleteHydrationEntry is called for items on _selectedDate.
        // But if it could happen, consider if a fetch for entryToDelete.timestamp is needed.
      } else if (entryIndex == -1) {
        // If it wasn't in the daily list but deleted from backend, refresh current day
        // in case it was an old entry from today that wasn't in the list due to pagination (if we had it)
        logger.d("HydrationProvider: Entry deleted from backend, wasn't in current daily list. Refreshing for $_selectedDate.");
        await fetchHydrationEntriesForDate(_selectedDate);
      }
      // If deletion failed, the optimistic removal needs to be reverted.
    } catch (e) {
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "Failed to delete entry: ${e.toString()}";
      logger.e("HydrationProvider: Error deleting entry ${entryToDelete.id ?? entryToDelete.localDbId}: $e");
      // **Revert Optimistic UI Update on Failure**
      if (entryIndex != -1) {
        _dailyEntries = originalEntries; // Restore the original list
        logger.w("HydrationProvider: Reverted optimistic removal due to backend error.");
      }
      // No need to call fetchHydrationEntriesForDate here as we reverted.
    }
    _safeNotifyListeners(); // Notify final status
  }

  void resetActionStatus() {
    if (_isDisposed) return;
    if (_actionStatus != HydrationActionStatus.idle) {
      _actionStatus = HydrationActionStatus.idle;
      _errorMessage = null;
      _safeNotifyListeners();
      logger.d("HydrationProvider: Action status reset to idle.");
    }
  }

  @override
  void dispose() {
    logger.d("HydrationProvider: dispose called.");
    _isDisposed = true;
    _cancelEntriesSubscription();
    _authSubscription?.cancel();
    super.dispose();
  }
}
