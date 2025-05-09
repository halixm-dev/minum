// lib/src/data/repositories/local/local_hydration_repository.dart
import 'dart:async'; // For Stream.fromFuture
import 'package:minum/src/data/local/database_helper.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/repositories/hydration_repository.dart';
import 'package:minum/main.dart'; // For logger

// This constant can be defined globally or passed around.
// It represents the user ID for entries made when not logged in.
const String GUEST_USER_ID = "local_guest_user";

class LocalHydrationRepository implements HydrationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> addHydrationEntry(String userId, HydrationEntry entry) async {
    final String effectiveUserId = userId.isEmpty ? GUEST_USER_ID : userId;

    final HydrationEntry entryToSave = entry.copyWith(
        userId: effectiveUserId,
        isSynced: false,
        isLocallyDeleted: false,
        localDbId: null,
        id: entry.id
    );

    int localId = await _dbHelper.insertHydrationEntry(entryToSave);
    logger.i("LocalHydrationRepo: Entry added for user/scope: $effectiveUserId with local ID: $localId");
  }

  @override
  Future<void> updateHydrationEntry(String userId, HydrationEntry entry) async {
    int? localIdToUpdate = entry.localDbId;
    final effectiveUserId = userId.isEmpty ? GUEST_USER_ID : userId; // Ensure effectiveUserId is used

    if (localIdToUpdate == null && entry.id != null) {
      // Use effectiveUserId when looking up by Firestore ID
      localIdToUpdate = await _dbHelper.getLocalIdFromFirestoreId(entry.id!, effectiveUserId);
    }

    if (localIdToUpdate != null) {
      final HydrationEntry entryToUpdate = entry.copyWith(
          userId: effectiveUserId, // Ensure this is the effectiveUserId
          isSynced: false,
          isLocallyDeleted: false
      );
      await _dbHelper.updateHydrationEntryByLocalId(localIdToUpdate, entryToUpdate);
      logger.i("LocalHydrationRepo: Entry with local ID $localIdToUpdate updated for user $effectiveUserId.");
    } else {
      logger.w("LocalHydrationRepo: Could not update entry. Local ID not found for entry with Firestore ID: ${entry.id} or entry has no ID for user $effectiveUserId. Attempting to add as new.");
      await addHydrationEntry(effectiveUserId, entry); // Pass effectiveUserId
    }
  }

  // Updated method signature to match interface (will be HydrationEntry entryToDelete)
  @override
  Future<void> deleteHydrationEntry(String userId, HydrationEntry entryToDelete) async {
    final effectiveUserId = userId.isEmpty ? GUEST_USER_ID : userId;

    if (entryToDelete.localDbId != null) {
      await _dbHelper.markHydrationEntryAsDeletedByLocalId(entryToDelete.localDbId!);
      logger.i("LocalHydrationRepo: Entry (local ID ${entryToDelete.localDbId}) marked as deleted for user $effectiveUserId.");
    } else if (entryToDelete.id != null) {
      int? localId = await _dbHelper.getLocalIdFromFirestoreId(entryToDelete.id!, effectiveUserId);
      if (localId != null) {
        await _dbHelper.markHydrationEntryAsDeletedByLocalId(localId);
        logger.i("LocalHydrationRepo: Entry (Firestore ID ${entryToDelete.id}, local ID $localId) marked as deleted for user $effectiveUserId.");
      } else {
        logger.w("LocalHydrationRepo: Entry with Firestore ID ${entryToDelete.id} not found locally to mark as deleted for user $effectiveUserId.");
      }
    } else {
      logger.e("LocalHydrationRepo: Cannot mark entry for deletion - no localDbId or FirestoreId provided in entryToDelete object for user $effectiveUserId.");
    }
  }

  @override
  Future<HydrationEntry?> getHydrationEntry(String userId, String entryId) async {
    // entryId is assumed to be Firestore ID
    final effectiveUserId = userId.isEmpty ? GUEST_USER_ID : userId;
    int? localId = await _dbHelper.getLocalIdFromFirestoreId(entryId, effectiveUserId);
    if(localId != null) {
      return await _dbHelper.getHydrationEntryByLocalId(localId);
    }
    return null;
  }

  // New method specifically to get by localDbId if needed elsewhere (not part of HydrationRepository interface currently)
  Future<HydrationEntry?> getHydrationEntryByLocalDbId(int localDbId) async {
    return _dbHelper.getHydrationEntryByLocalId(localDbId);
  }

  @override
  Stream<List<HydrationEntry>> getHydrationEntriesForDateRange(
      String userId, DateTime startDate, DateTime endDate) {
    final effectiveUserId = userId.isEmpty ? GUEST_USER_ID : userId;
    logger.d("LocalHydrationRepo: Getting entries for user/scope: $effectiveUserId, range: $startDate - $endDate");

    return Stream.fromFuture(
        _dbHelper.getHydrationEntriesForUser(effectiveUserId, startDate, endDate));
  }

  @override
  Stream<List<HydrationEntry>> getHydrationEntriesForDay(String userId, DateTime date) {
    final DateTime startDate = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return getHydrationEntriesForDateRange(userId, startDate, endDate);
  }

  Future<List<HydrationEntry>> getUnsyncedNewOrUpdatedEntries(String userId) async {
    final effectiveUserId = userId.isEmpty ? GUEST_USER_ID : userId;
    return _dbHelper.getUnsyncedNewOrUpdatedEntries(effectiveUserId);
  }

  Future<void> markAsSynced(int localId, String firestoreId) async {
    await _dbHelper.markHydrationEntryAsSynced(localId, firestoreId);
  }

  Future<List<HydrationEntry>> getDeletedUnsyncedEntries(String userId) async {
    final effectiveUserId = userId.isEmpty ? GUEST_USER_ID : userId;
    return _dbHelper.getDeletedUnsyncedEntries(effectiveUserId);
  }

  Future<void> deletePermanentlyByLocalId(int localId) async {
    await _dbHelper.deleteHydrationEntryPermanentlyByLocalId(localId);
  }

  Future<int> updateGuestEntriesToUser(String guestId, String firebaseUserId) async {
    return await _dbHelper.updateGuestEntriesToUser(guestId, firebaseUserId);
  }

  Future<int?> getLocalIdFromFirestoreId(String firestoreId, String userId) async {
    final effectiveUserId = userId.isEmpty ? GUEST_USER_ID : userId;
    return _dbHelper.getLocalIdFromFirestoreId(firestoreId, effectiveUserId);
  }

  Future<int> upsertHydrationEntry(HydrationEntry entry, String userId) async {
    final effectiveUserId = userId.isEmpty ? GUEST_USER_ID : userId;
    final entryToUpsert = entry.copyWith(userId: effectiveUserId, isSynced: true, isLocallyDeleted: false);
    return _dbHelper.upsertHydrationEntry(entryToUpsert, effectiveUserId);
  }
}
