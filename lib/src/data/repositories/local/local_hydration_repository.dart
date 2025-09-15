// lib/src/data/repositories/local/local_hydration_repository.dart
import 'dart:async'; // For Stream.fromFuture
import 'package:minum/src/data/local/database_helper.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/repositories/hydration_repository.dart';
import 'package:minum/main.dart'; // For logger

/// A constant user ID for entries made when not logged in (guest mode).
const String guestUserId = "local_guest_user";

/// A concrete implementation of [HydrationRepository] using a local SQLite database.
///
/// This repository handles all hydration data operations for the local cache,
/// supporting offline functionality and guest mode.
class LocalHydrationRepository implements HydrationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> addHydrationEntry(String userId, HydrationEntry entry) async {
    final String effectiveUserId = userId.isEmpty ? guestUserId : userId;

    final HydrationEntry entryToSave = entry.copyWith(
        userId: effectiveUserId,
        isSynced: false,
        isLocallyDeleted: false,
        localDbId: null,
        id: entry.id);

    int localId = await _dbHelper.insertHydrationEntry(entryToSave);
    logger.i(
        "LocalHydrationRepo: Entry added for user/scope: $effectiveUserId with local ID: $localId");
  }

  @override
  Future<void> updateHydrationEntry(String userId, HydrationEntry entry) async {
    int? localIdToUpdate = entry.localDbId;
    final effectiveUserId = userId.isEmpty ? guestUserId : userId;

    if (localIdToUpdate == null && entry.id != null) {
      localIdToUpdate =
          await _dbHelper.getLocalIdFromFirestoreId(entry.id!, effectiveUserId);
    }

    if (localIdToUpdate != null) {
      final HydrationEntry entryToUpdate = entry.copyWith(
          userId: effectiveUserId, isSynced: false, isLocallyDeleted: false);
      await _dbHelper.updateHydrationEntryByLocalId(
          localIdToUpdate, entryToUpdate);
      logger.i(
          "LocalHydrationRepo: Entry with local ID $localIdToUpdate updated for user $effectiveUserId.");
    } else {
      logger.w(
          "LocalHydrationRepo: Could not update entry. Local ID not found for entry with Firestore ID: ${entry.id} or entry has no ID for user $effectiveUserId. Attempting to add as new.");
      await addHydrationEntry(effectiveUserId, entry);
    }
  }

  @override
  Future<void> deleteHydrationEntry(
      String userId, HydrationEntry entryToDelete) async {
    final effectiveUserId = userId.isEmpty ? guestUserId : userId;

    if (entryToDelete.localDbId != null) {
      await _dbHelper
          .markHydrationEntryAsDeletedByLocalId(entryToDelete.localDbId!);
      logger.i(
          "LocalHydrationRepo: Entry (local ID ${entryToDelete.localDbId}) marked as deleted for user $effectiveUserId.");
    } else if (entryToDelete.id != null) {
      int? localId = await _dbHelper.getLocalIdFromFirestoreId(
          entryToDelete.id!, effectiveUserId);
      if (localId != null) {
        await _dbHelper.markHydrationEntryAsDeletedByLocalId(localId);
        logger.i(
            "LocalHydrationRepo: Entry (Firestore ID ${entryToDelete.id}, local ID $localId) marked as deleted for user $effectiveUserId.");
      } else {
        logger.w(
            "LocalHydrationRepo: Entry with Firestore ID ${entryToDelete.id} not found locally to mark as deleted for user $effectiveUserId.");
      }
    } else {
      logger.e(
          "LocalHydrationRepo: Cannot mark entry for deletion - no localDbId or FirestoreId provided in entryToDelete object for user $effectiveUserId.");
    }
  }

  @override
  Future<HydrationEntry?> getHydrationEntry(
      String userId, String entryId) async {
    final effectiveUserId = userId.isEmpty ? guestUserId : userId;
    int? localId =
        await _dbHelper.getLocalIdFromFirestoreId(entryId, effectiveUserId);
    if (localId != null) {
      return await _dbHelper.getHydrationEntryByLocalId(localId);
    }
    return null;
  }

  /// Retrieves a [HydrationEntry] by its local database ID.
  ///
  /// This method is not part of the `HydrationRepository` interface but is
  /// useful for internal operations.
  /// @return A `Future` that completes with the `HydrationEntry` or null.
  Future<HydrationEntry?> getHydrationEntryByLocalDbId(int localDbId) async {
    return _dbHelper.getHydrationEntryByLocalId(localDbId);
  }

  @override
  Stream<List<HydrationEntry>> getHydrationEntriesForDateRange(
      String userId, DateTime startDate, DateTime endDate) {
    final effectiveUserId = userId.isEmpty ? guestUserId : userId;
    logger.d(
        "LocalHydrationRepo: Getting entries for user/scope: $effectiveUserId, range: $startDate - $endDate");

    return Stream.fromFuture(_dbHelper.getHydrationEntriesForUser(
        effectiveUserId, startDate, endDate));
  }

  @override
  Stream<List<HydrationEntry>> getHydrationEntriesForDay(
      String userId, DateTime date) {
    final DateTime startDate =
        DateTime(date.year, date.month, date.day, 0, 0, 0);
    final DateTime endDate =
        DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return getHydrationEntriesForDateRange(userId, startDate, endDate);
  }

  /// Retrieves all new or updated entries for a user that are not yet synced.
  ///
  /// @return A list of unsynced `HydrationEntry` objects.
  Future<List<HydrationEntry>> getUnsyncedNewOrUpdatedEntries(
      String userId) async {
    final effectiveUserId = userId.isEmpty ? guestUserId : userId;
    return _dbHelper.getUnsyncedNewOrUpdatedEntries(effectiveUserId);
  }

  /// Marks a local entry as synced with Firestore.
  Future<void> markAsSynced(int localId, String firestoreId) async {
    await _dbHelper.markHydrationEntryAsSynced(localId, firestoreId);
  }

  /// Retrieves all entries marked for deletion that have not yet been synced.
  ///
  /// @return A list of deleted, unsynced `HydrationEntry` objects.
  Future<List<HydrationEntry>> getDeletedUnsyncedEntries(String userId) async {
    final effectiveUserId = userId.isEmpty ? guestUserId : userId;
    return _dbHelper.getDeletedUnsyncedEntries(effectiveUserId);
  }

  /// Permanently deletes an entry from the local database by its local ID.
  Future<void> deletePermanentlyByLocalId(int localId) async {
    await _dbHelper.deleteHydrationEntryPermanentlyByLocalId(localId);
  }

  /// Updates local entries from a guest ID to a new Firebase User ID.
  ///
  /// @return The number of rows affected.
  Future<int> updateGuestEntriesToUser(
      String guestId, String firebaseUserId) async {
    return await _dbHelper.updateGuestEntriesToUser(guestId, firebaseUserId);
  }

  /// Retrieves the local database ID from a Firestore ID.
  ///
  /// @return The local ID, or null if not found.
  Future<int?> getLocalIdFromFirestoreId(
      String firestoreId, String userId) async {
    final effectiveUserId = userId.isEmpty ? guestUserId : userId;
    return _dbHelper.getLocalIdFromFirestoreId(firestoreId, effectiveUserId);
  }

  /// Inserts or updates a [HydrationEntry] in the local database.
  ///
  /// @return The local ID of the inserted or updated row.
  Future<int> upsertHydrationEntry(HydrationEntry entry, String userId) async {
    final effectiveUserId = userId.isEmpty ? guestUserId : userId;
    final entryToUpsert = entry.copyWith(
        userId: effectiveUserId, isSynced: true, isLocallyDeleted: false);
    return _dbHelper.upsertHydrationEntry(entryToUpsert, effectiveUserId);
  }
}
