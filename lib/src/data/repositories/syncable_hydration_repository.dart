// lib/src/data/repositories/syncable_hydration_repository.dart
import 'dart:async';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/repositories/hydration_repository.dart';
import 'package:minum/src/data/repositories/local/local_hydration_repository.dart';
import 'package:minum/src/data/repositories/firebase/firebase_hydration_repository.dart';
import 'package:minum/src/services/auth_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:minum/main.dart'; // For logger

class SyncableHydrationRepository implements HydrationRepository {
  final LocalHydrationRepository _localRepository;
  final FirebaseHydrationRepository _firebaseRepository;
  final AuthService _authService;
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  Timer? _syncDebounceTimer;

  SyncableHydrationRepository({
    required LocalHydrationRepository localRepository,
    required FirebaseHydrationRepository firebaseRepository,
    required AuthService authService,
  })  : _localRepository = localRepository,
        _firebaseRepository = firebaseRepository,
        _authService = authService {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        logger.i(
            "SyncableHydrationRepo: User logged in (${user.id}). Migrating guest data and triggering full sync.");
        migrateGuestDataToUser(user.id).then((_) {
          _debouncedSyncAllData(currentUserId: user.id);
        });
      } else {
        logger.i(
            "SyncableHydrationRepo: User logged out. Future operations will be local-only for guest.");
      }
    });
    if (_isUserLoggedIn) {
      _debouncedSyncAllData(currentUserId: _effectiveUserId);
    }
  }

  String get _effectiveUserId => _authService.currentUser?.id ?? guestUserId;
  bool get _isUserLoggedIn => _authService.currentUser != null;

  void _debouncedSyncAllData({String? currentUserId}) {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(const Duration(seconds: 5), () {
      syncAllData(currentUserId: currentUserId);
    });
  }

  @override
  Future<void> addHydrationEntry(
      String userIdParam, HydrationEntry entry) async {
    final String currentScopeId = _effectiveUserId;
    final HydrationEntry entryToSaveLocally = entry.copyWith(
        userId: currentScopeId,
        isSynced: false,
        isLocallyDeleted: false,
        localDbId: null,
        id: entry.id);

    logger.d(
        "SyncableRepo: Adding entry for scope $currentScopeId. Amount: ${entryToSaveLocally.amountMl}");
    await _localRepository.addHydrationEntry(
        currentScopeId, entryToSaveLocally);

    if (_isUserLoggedIn && currentScopeId != guestUserId) {
      logger.d(
          "SyncableRepo: User $currentScopeId logged in. Debouncing sync after add.");
      _debouncedSyncAllData(currentUserId: currentScopeId);
    }
  }

  @override
  Future<void> updateHydrationEntry(
      String userIdParam, HydrationEntry entry) async {
    final String currentScopeId = _effectiveUserId;
    logger.d(
        "SyncableRepo: Updating entry (Firestore ID: ${entry.id}, Local DB ID: ${entry.localDbId}) for scope $currentScopeId.");

    final HydrationEntry entryToUpdateLocally = entry.copyWith(
        userId: currentScopeId, isSynced: false, isLocallyDeleted: false);

    await _localRepository.updateHydrationEntry(
        currentScopeId, entryToUpdateLocally);

    if (_isUserLoggedIn && currentScopeId != guestUserId) {
      logger.d(
          "SyncableRepo: User $currentScopeId logged in. Debouncing sync after update.");
      _debouncedSyncAllData(currentUserId: currentScopeId);
    }
  }

  // Updated method signature
  @override
  Future<void> deleteHydrationEntry(
      String userIdParam, HydrationEntry entryToDelete) async {
    final String currentScopeId = _effectiveUserId;
    logger.d(
        "SyncableRepo: Initiating delete for entry (Firestore ID: ${entryToDelete.id}, Local DB ID: ${entryToDelete.localDbId}) for scope $currentScopeId.");

    // 1. If it's a purely local entry (no Firestore ID but has localDbId), delete it permanently from local.
    if (entryToDelete.id == null && entryToDelete.localDbId != null) {
      logger.i(
          "SyncableRepo: Permanently deleting purely local entry (localId: ${entryToDelete.localDbId}).");
      await _localRepository
          .deletePermanentlyByLocalId(entryToDelete.localDbId!);
      // No need to sync this deletion to Firebase as it never existed there.
    } else {
      // 2. For entries that might be on Firebase (have a Firestore ID or were intended to be synced):
      //    Mark as deleted in local DB (soft delete). This will also mark it as unsynced.
      await _localRepository.deleteHydrationEntry(
          currentScopeId, entryToDelete);

      // 3. If logged in, attempt to sync this deletion to Firebase.
      if (_isUserLoggedIn && currentScopeId != guestUserId) {
        logger.d(
            "SyncableRepo: User $currentScopeId logged in. Debouncing sync after delete initiation for (potentially) synced entry.");
        _debouncedSyncAllData(currentUserId: currentScopeId);
      }
    }
  }

  @override
  Future<HydrationEntry?> getHydrationEntry(String userId, String entryId) {
    // This method expects entryId to be Firestore ID.
    // LocalHydrationRepository handles finding by Firestore ID.
    return _localRepository.getHydrationEntry(_effectiveUserId, entryId);
  }

  @override
  Stream<List<HydrationEntry>> getHydrationEntriesForDateRange(
      String userId, DateTime startDate, DateTime endDate) {
    logger.d(
        "SyncableRepo: Getting stream for date range for scope $_effectiveUserId (param userId: $userId was contextually ignored)");
    return _localRepository.getHydrationEntriesForDateRange(
        _effectiveUserId, startDate, endDate);
  }

  @override
  Stream<List<HydrationEntry>> getHydrationEntriesForDay(
      String userId, DateTime date) {
    final DateTime startDate =
        DateTime(date.year, date.month, date.day, 0, 0, 0);
    final DateTime endDate =
        DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return getHydrationEntriesForDateRange(
        _effectiveUserId, startDate, endDate);
  }

  Future<bool> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet) ||
          connectivityResult.contains(ConnectivityResult.vpn)) {
        logger.d("Connectivity check: Online");
        return true;
      }
      logger.d("Connectivity check: Offline (Results: $connectivityResult)");
      return false;
    } catch (e) {
      logger.e("Connectivity check failed: $e");
      return false;
    }
  }

  Future<void> syncAllData({String? currentUserId}) async {
    if (_isSyncing) {
      logger.i(
          "SyncableRepo: Sync already in progress. Skipping subsequent call.");
      return;
    }
    _isSyncing = true;

    final String userIdToSync = currentUserId ?? _effectiveUserId;

    if (userIdToSync == guestUserId) {
      logger.i("SyncableRepo: User is guestUserId. Skipping Firebase sync.");
      _isSyncing = false;
      return;
    }

    if (_authService.currentUser == null ||
        _authService.currentUser!.id != userIdToSync) {
      logger.w(
          "SyncableRepo: Sync called for user '$userIdToSync', but current authenticated user is '${_authService.currentUser?.id}'. Aborting sync.");
      _isSyncing = false;
      return;
    }

    bool isOnline = await _checkConnectivity();
    if (!isOnline) {
      logger.i(
          "SyncableRepo: Device offline. Sync postponed for user $userIdToSync.");
      _isSyncing = false;
      return;
    }

    logger.i("SyncableRepo: Starting data sync for user $userIdToSync...");

    try {
      // --- Step 1: Upload local changes to Firebase ---
      final List<HydrationEntry> unsyncedLocalEntries =
          await _localRepository.getUnsyncedNewOrUpdatedEntries(userIdToSync);
      logger.i(
          "SyncableRepo: Found ${unsyncedLocalEntries.length} local unsynced entries to upload for user $userIdToSync.");

      for (final localEntry in unsyncedLocalEntries) {
        if (localEntry.localDbId == null) {
          logger.e(
              "SyncableRepo: CRITICAL - Unsynced local entry missing localDbId! Cannot process sync for this item. Entry: ${localEntry.notes ?? 'No notes'}. Firestore ID: ${localEntry.id}");
          continue;
        }

        try {
          if (localEntry.id == null) {
            logger.d(
                "SyncableRepo: Uploading new local entry (localId: ${localEntry.localDbId}) to Firebase.");
            final HydrationEntry syncedEntryFromFirebase =
                await _firebaseRepository.addHydrationEntryReturnId(
                    userIdToSync, localEntry);
            await _localRepository.markAsSynced(
                localEntry.localDbId!, syncedEntryFromFirebase.id!);
            logger.d(
                "SyncableRepo: Synced new local entry (local ID ${localEntry.localDbId}) to Firebase (${syncedEntryFromFirebase.id}) and updated local status.");
          } else {
            logger.d(
                "SyncableRepo: Uploading updated local entry (localId: ${localEntry.localDbId}, FirestoreId: ${localEntry.id}) to Firebase.");
            await _firebaseRepository.updateHydrationEntry(
                userIdToSync, localEntry);
            await _localRepository.markAsSynced(
                localEntry.localDbId!, localEntry.id!);
            logger.d(
                "SyncableRepo: Synced updated local entry (local ID ${localEntry.localDbId}, Firestore ID ${localEntry.id}) to Firebase and updated local status.");
          }
        } catch (e) {
          logger.e(
              "SyncableRepo: Error syncing individual local entry (localId ${localEntry.localDbId}, FirestoreId: ${localEntry.id}) to Firebase: $e. It remains unsynced.");
        }
      }

      // Process local deletions
      final List<HydrationEntry> deletedLocallyEntries =
          await _localRepository.getDeletedUnsyncedEntries(userIdToSync);
      logger.i(
          "SyncableRepo: Found ${deletedLocallyEntries.length} local unsynced deletions to process for user $userIdToSync.");
      for (final deletedEntry in deletedLocallyEntries) {
        if (deletedEntry.localDbId == null) {
          logger.e(
              "SyncableRepo: CRITICAL - Locally deleted entry missing localDbId! Cannot process sync for this deletion. Entry: ${deletedEntry.notes ?? 'No notes'}. Firestore ID: ${deletedEntry.id}");
          continue;
        }
        try {
          if (deletedEntry.id != null) {
            logger.d(
                "SyncableRepo: Deleting entry from Firebase (FirestoreId: ${deletedEntry.id}) for local deletion (localId: ${deletedEntry.localDbId}).");
            await _firebaseRepository.deleteHydrationEntry(
                userIdToSync, deletedEntry);
          }
          await _localRepository
              .deletePermanentlyByLocalId(deletedEntry.localDbId!);
          logger.d(
              "SyncableRepo: Processed and permanently removed local deletion (local ID ${deletedEntry.localDbId}, Firestore ID ${deletedEntry.id})");
        } catch (e) {
          logger.e(
              "SyncableRepo: Error syncing deletion of local entry (localId ${deletedEntry.localDbId}, FirestoreId: ${deletedEntry.id}) to Firebase: $e. It remains marked for deletion locally.");
        }
      }

      // --- Step 2: Download Firebase changes to local (Simplified: Fetch all and upsert) ---
      logger.i(
          "SyncableRepo: Fetching remote data for user $userIdToSync to update local store (upsert strategy).");
      final List<HydrationEntry> remoteEntries =
          await _firebaseRepository.getAllHydrationEntriesForUser(userIdToSync);
      logger.i(
          "SyncableRepo: Found ${remoteEntries.length} entries on Firebase for user $userIdToSync.");
      for (final remoteEntry in remoteEntries) {
        await _localRepository.upsertHydrationEntry(remoteEntry, userIdToSync);
      }
      logger.i(
          "SyncableRepo: Processed ${remoteEntries.length} remote entries into local store via upsert.");

      logger.i(
          "SyncableRepo: Data sync completed successfully for user $userIdToSync.");
    } catch (e, stackTrace) {
      logger.e(
          "SyncableRepo: CRITICAL error during data sync process for user $userIdToSync: $e",
          error: e,
          stackTrace: stackTrace);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> migrateGuestDataToUser(String firebaseUserId) async {
    if (guestUserId == firebaseUserId) {
      logger.w(
          "SyncableRepo: migrateGuestDataToUser called with guestUserId. This should not happen if user is truly logging in.");
      return;
    }

    logger.i(
        "SyncableRepo: Attempting to migrate guest data (from scope '$guestUserId') to user '$firebaseUserId'.");
    try {
      int updatedRows = await _localRepository.updateGuestEntriesToUser(
          guestUserId, firebaseUserId);
      logger.i(
          "SyncableRepo: Migrated $updatedRows guest entries to user $firebaseUserId locally (marked as unsynced, Firestore ID cleared).");

      if (updatedRows > 0) {
        await syncAllData(currentUserId: firebaseUserId);
      }
      logger.i(
          "SyncableRepo: Guest data migration and sync process completed for user $firebaseUserId.");
    } catch (e, stackTrace) {
      logger.e(
          "SyncableRepo: Error during guest data migration for $firebaseUserId: $e",
          error: e,
          stackTrace: stackTrace);
    }
  }
}
