// lib/src/presentation/providers/hydration_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/services/notification_service.dart';
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/main.dart'; // For logger
import 'package:minum/src/data/repositories/local/local_hydration_repository.dart'
    show guestUserId;

/// An enumeration of the possible statuses for loading hydration logs.
enum HydrationLogStatus { idle, loading, loaded, error }

/// An enumeration of the possible statuses for hydration actions (add, update, delete).
enum HydrationActionStatus { idle, processing, success, error }

/// A `ChangeNotifier` that manages hydration data for the UI.
///
/// This provider interfaces with [HydrationService] and [AuthService] to
/// fetch, display, and manipulate hydration data based on the current user
/// and selected date.
class HydrationProvider with ChangeNotifier {
  final HydrationService _hydrationService;
  final AuthService _authService;

  List<HydrationEntry> _dailyEntries = [];
  HydrationLogStatus _logStatus = HydrationLogStatus.idle;
  HydrationActionStatus _actionStatus = HydrationActionStatus.idle;
  String? _errorMessage;
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  StreamSubscription<List<HydrationEntry>>? _entriesSubscription;
  StreamSubscription<UserModel?>? _authSubscription;
  String? _currentUserId;
  bool _isDisposed = false;

  /// A list of hydration entries for the currently selected date.
  List<HydrationEntry> get dailyEntries => _dailyEntries;

  /// The current status of loading hydration logs.
  HydrationLogStatus get logStatus => _logStatus;

  /// The current status of the last hydration action (add, update, delete).
  HydrationActionStatus get actionStatus => _actionStatus;

  /// The last error message.
  String? get errorMessage => _errorMessage;

  /// The currently selected date for displaying hydration entries.
  DateTime get selectedDate => _selectedDate;

  /// The total water intake for the currently selected date.
  double get totalIntakeToday =>
      _hydrationService.calculateTotalIntake(_dailyEntries);

  /// Creates a `HydrationProvider` instance.
  HydrationProvider(
      {required HydrationService hydrationService,
      required AuthService authService})
      : _hydrationService = hydrationService,
        _authService = authService {
    _subscribeToAuthChanges();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    } else {
      logger.w(
          "HydrationProvider: Attempted to call notifyListeners() after dispose.");
    }
  }

  void _subscribeToAuthChanges() {
    _authSubscription =
        _authService.authStateChanges.listen((UserModel? authUser) async {
      if (_isDisposed) return;
      final newUserId = authUser?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        logger.i(
            "HydrationProvider: User changed to ${_currentUserId ?? 'guest'}. Fetching entries for $_selectedDate.");
        _cancelEntriesSubscription();
        final userIdForFetch = _currentUserId ?? guestUserId;
        if (userIdForFetch.isNotEmpty) {
          await fetchHydrationEntriesForDate(_selectedDate);
        } else {
          _dailyEntries = [];
          _logStatus = HydrationLogStatus.idle;
          _safeNotifyListeners();
        }
      } else if (_currentUserId == null &&
          guestUserId.isNotEmpty &&
          _dailyEntries.isEmpty &&
          _logStatus == HydrationLogStatus.idle) {
        _currentUserId = guestUserId;
        logger.i(
            "HydrationProvider: Initializing for guest user. Fetching entries for $_selectedDate.");
        await fetchHydrationEntriesForDate(_selectedDate);
      }
    });
  }

  void _cancelEntriesSubscription() {
    _entriesSubscription?.cancel();
    _entriesSubscription = null;
  }

  /// Sets the selected date and fetches the hydration entries for that date.
  void setSelectedDate(DateTime date) async {
    if (_isDisposed) return;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (_selectedDate == normalizedDate) {
      return;
    }
    _selectedDate = normalizedDate;
    logger.i("HydrationProvider: Selected date changed to $_selectedDate.");
    _cancelEntriesSubscription();
    final userIdForFetch = _currentUserId ?? guestUserId;
    if (userIdForFetch.isNotEmpty) {
      await fetchHydrationEntriesForDate(_selectedDate);
    } else {
      _dailyEntries = [];
      _logStatus = HydrationLogStatus.idle;
      _safeNotifyListeners();
    }
  }

  /// Fetches hydration entries for a specific date.
  Future<void> fetchHydrationEntriesForDate(DateTime date) async {
    if (_isDisposed) return;
    final userIdForFetch = _currentUserId ?? guestUserId;
    if (userIdForFetch.isEmpty && userIdForFetch != guestUserId) {
      _logStatus = HydrationLogStatus.idle;
      _dailyEntries = [];
      _safeNotifyListeners();
      logger.w(
          "HydrationProvider: Cannot fetch daily entries, no valid user/guest ID.");
      return;
    }

    _logStatus = HydrationLogStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    _cancelEntriesSubscription();

    logger.d(
        "HydrationProvider: Fetching entries for date $date, user/scope: $userIdForFetch");
    _entriesSubscription = _hydrationService
        .getHydrationEntriesForDay(userIdForFetch, date)
        .listen(
      (entries) {
        if (_isDisposed) return;
        _dailyEntries = entries;
        _logStatus = HydrationLogStatus.loaded;
        _errorMessage = null;
        logger.i(
            "HydrationProvider: Daily entries loaded for $date. Count: ${entries.length}");
        _safeNotifyListeners();
      },
      onError: (error) {
        if (_isDisposed) return;
        _logStatus = HydrationLogStatus.error;
        _errorMessage =
            "Failed to load daily hydration logs: ${error.toString()}";
        _dailyEntries = [];
        logger.e(
            "HydrationProvider: Error loading daily entries for $date: $error");
        _safeNotifyListeners();
      },
    );
  }

  /// Retrieves a stream of hydration entries for a date range.
  Stream<List<HydrationEntry>> getEntriesForDateRangeStream(
      String userId, DateTime startDate, DateTime endDate) {
    if (_isDisposed) return Stream.value([]);
    final userIdForFetch = userId.isEmpty ? guestUserId : userId;
    if (userIdForFetch.isEmpty && userIdForFetch != guestUserId) {
      logger.w(
          "HydrationProvider: User ID is empty for date range stream, returning empty stream.");
      return Stream.value([]);
    }
    logger.i(
        "HydrationProvider: Getting entries stream for date range: $startDate to $endDate for user/scope $userIdForFetch");
    return _hydrationService.getHydrationEntriesForDateRange(
        userIdForFetch, startDate, endDate);
  }

  /// Adds a new hydration entry.
  Future<void> addHydrationEntry(double amountMl,
      {DateTime? entryTime, String? notes, String? source}) async {
    if (_isDisposed) return;
    final userIdForAction = _currentUserId ?? guestUserId;
    if (userIdForAction.isEmpty && userIdForAction != guestUserId) {
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
          source: source);
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.success;
      _errorMessage = null;
      logger.i(
          "HydrationProvider: Entry added successfully for $userIdForAction.");
      if (DateUtils.isSameDay(_selectedDate, effectiveEntryTime)) {
        logger.d(
            "HydrationProvider: Added entry is for selected date. Refreshing daily entries.");
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

  /// Updates an existing hydration entry.
  Future<void> updateHydrationEntry(HydrationEntry entry) async {
    if (_isDisposed) return;
    final userIdForAction = _currentUserId ?? guestUserId;
    if (userIdForAction.isEmpty && userIdForAction != guestUserId) {
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "User not authenticated or guest scope not identified.";
      _safeNotifyListeners();
      logger
          .w("HydrationProvider: Cannot update entry, no valid user/guest ID.");
      return;
    }
    _actionStatus = HydrationActionStatus.processing;
    _errorMessage = null;
    _safeNotifyListeners();
    try {
      final entryWithCorrectUser = entry.copyWith(userId: userIdForAction);
      await _hydrationService.updateHydrationEntry(
          userIdForAction, entryWithCorrectUser);
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.success;
      _errorMessage = null;
      logger.i(
          "HydrationProvider: Entry ${entry.id ?? entry.localDbId} updated for $userIdForAction.");
      if (DateUtils.isSameDay(_selectedDate, entry.timestamp)) {
        logger.d(
            "HydrationProvider: Updated entry is for selected date. Refreshing daily entries.");
        await fetchHydrationEntriesForDate(_selectedDate);
      }
    } catch (e) {
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "Failed to update entry: ${e.toString()}";
      logger.e(
          "HydrationProvider: Error updating entry ${entry.id ?? entry.localDbId}: $e");
    }
    _safeNotifyListeners();
  }

  /// Deletes a hydration entry with an optimistic UI update.
  Future<void> deleteHydrationEntry(HydrationEntry entryToDelete) async {
    if (_isDisposed) return;
    final userIdForAction = _currentUserId ?? guestUserId;
    if (userIdForAction.isEmpty && userIdForAction != guestUserId) {
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "User not authenticated or guest scope not identified.";
      _safeNotifyListeners();
      logger
          .w("HydrationProvider: Cannot delete entry, no valid user/guest ID.");
      return;
    }

    final originalEntries = List<HydrationEntry>.from(_dailyEntries);
    final int entryIndex = _dailyEntries.indexWhere((e) =>
        (e.id != null && e.id == entryToDelete.id) ||
        (e.localDbId != null && e.localDbId == entryToDelete.localDbId));

    if (entryIndex != -1) {
      _dailyEntries.removeAt(entryIndex);
      _actionStatus = HydrationActionStatus.processing;
      _errorMessage = null;
      _safeNotifyListeners();
      logger.d(
          "HydrationProvider: Optimistically removed entry (ID: ${entryToDelete.id ?? entryToDelete.localDbId}) from UI.");
    } else {
      logger.w(
          "HydrationProvider: Entry to delete not found in current daily list. Proceeding with backend delete attempt.");
      _actionStatus = HydrationActionStatus.processing;
      _errorMessage = null;
      _safeNotifyListeners();
    }

    try {
      await _hydrationService.deleteHydrationEntry(
          userIdForAction, entryToDelete);
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.success;
      _errorMessage = null;
      logger.i(
          "HydrationProvider: Entry ${entryToDelete.id ?? entryToDelete.localDbId} delete successful for $userIdForAction.");

      if (entryIndex != -1 &&
          !DateUtils.isSameDay(_selectedDate, entryToDelete.timestamp)) {
      } else if (entryIndex == -1) {
        logger.d(
            "HydrationProvider: Entry deleted from backend, wasn't in current daily list. Refreshing for $_selectedDate.");
        await fetchHydrationEntriesForDate(_selectedDate);
      }
    } catch (e) {
      if (_isDisposed) return;
      _actionStatus = HydrationActionStatus.error;
      _errorMessage = "Failed to delete entry: ${e.toString()}";
      logger.e(
          "HydrationProvider: Error deleting entry ${entryToDelete.id ?? entryToDelete.localDbId}: $e");
      if (entryIndex != -1) {
        _dailyEntries = originalEntries;
        logger.w(
            "HydrationProvider: Reverted optimistic removal due to backend error.");
      }
    }
    _safeNotifyListeners();
  }

  /// Resets the action status to idle.
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

  /// Processes any pending water additions that were triggered from a notification action.
  Future<void> processPendingWaterAddition() async {
    if (_isDisposed) {
      logger.w(
          "HydrationProvider: processPendingWaterAddition called after dispose.");
      return;
    }
    logger.d(
        "HydrationProvider: Checking for pending water additions from notifications...");
    try {
      final prefs = await SharedPreferences.getInstance();
      final double? pendingAmountMl =
          prefs.getDouble(prefsPendingWaterAdditionMl);

      if (pendingAmountMl != null && pendingAmountMl > 0) {
        logger.i(
            "HydrationProvider: Found pending water addition of $pendingAmountMl ml.");
        if (_currentUserId == null) {
          logger.w(
              "HydrationProvider: User ID not yet available. Waiting a moment to process pending water.");
          await Future.delayed(const Duration(seconds: 2));
          if (_currentUserId == null) {
            logger.e(
                "HydrationProvider: User ID still not available after delay. Cannot process pending water addition.");
            return;
          }
        }

        await addHydrationEntry(pendingAmountMl, source: 'notification_action');
        await prefs.remove(prefsPendingWaterAdditionMl);
        logger.i(
            "HydrationProvider: Successfully processed and cleared pending water addition of $pendingAmountMl ml.");
      } else {
        logger.d("HydrationProvider: No pending water additions found.");
      }
    } catch (e) {
      logger
          .e("HydrationProvider: Error processing pending water addition: $e");
    }
  }
}
