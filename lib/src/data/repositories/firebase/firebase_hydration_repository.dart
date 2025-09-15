// lib/src/data/repositories/firebase/firebase_hydration_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/repositories/hydration_repository.dart';
import 'package:minum/main.dart'; // For logger

/// A concrete implementation of [HydrationRepository] using Cloud Firestore.
class FirebaseHydrationRepository implements HydrationRepository {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';
  static const String _hydrationEntriesSubcollection = 'hydrationEntries';

  /// Creates a `FirebaseHydrationRepository` instance.
  ///
  /// If [firestore] is not provided, a default instance will be used.
  FirebaseHydrationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// A helper method to get a reference to the `hydrationEntries` subcollection
  /// for a specific user, with a type converter.
  CollectionReference<HydrationEntry> _hydrationEntriesRef(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_hydrationEntriesSubcollection)
        .withConverter<HydrationEntry>(
          fromFirestore: (snapshots, _) =>
              HydrationEntry.fromFirestore(snapshots),
          toFirestore: (entry, _) => entry.toFirestore(),
        );
  }

  @override
  Future<void> addHydrationEntry(String userId, HydrationEntry entry) async {
    try {
      final docRef =
          await _hydrationEntriesRef(userId).add(entry.copyWith(id: null));
      logger.i(
          "FirebaseHydrationRepo: Entry added for user $userId with new Firestore ID: ${docRef.id}");
    } catch (e) {
      logger.e(
          "FirebaseHydrationRepo: Error adding hydration entry for user $userId: $e");
      rethrow;
    }
  }

  /// Adds a new [HydrationEntry] and returns it with the new Firestore ID.
  ///
  /// This is useful for immediately updating the local model with its remote ID.
  /// @return A `Future` that completes with the new `HydrationEntry`.
  Future<HydrationEntry> addHydrationEntryReturnId(
      String userId, HydrationEntry entry) async {
    try {
      final DocumentReference<HydrationEntry> docRef =
          await _hydrationEntriesRef(userId).add(entry.copyWith(id: null));

      final HydrationEntry syncedEntry =
          entry.copyWith(id: docRef.id, userId: userId);
      logger.i(
          "FirebaseHydrationRepo: Entry added and returned for user $userId with Firestore ID: ${docRef.id}");
      return syncedEntry;
    } catch (e) {
      logger.e(
          "FirebaseHydrationRepo: Error adding hydration entry (and returning ID) for user $userId: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateHydrationEntry(String userId, HydrationEntry entry) async {
    if (entry.id == null) {
      logger.e(
          "FirebaseHydrationRepo: Cannot update entry without a Firestore ID for user $userId.");
      throw ArgumentError(
          "Entry ID cannot be null for an update operation to Firebase.");
    }
    try {
      await _hydrationEntriesRef(userId)
          .doc(entry.id)
          .update(entry.toFirestore());
      logger.i(
          "FirebaseHydrationRepo: Entry ${entry.id} updated for user $userId");
    } catch (e) {
      logger.e(
          "FirebaseHydrationRepo: Error updating entry ${entry.id} for user $userId: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteHydrationEntry(
      String userId, HydrationEntry entryToDelete) async {
    if (entryToDelete.id == null || entryToDelete.id!.isEmpty) {
      logger.w(
          "FirebaseHydrationRepo: Cannot delete entry from Firebase without a Firestore ID for user $userId. Entry might be local only.");
      return;
    }
    try {
      await _hydrationEntriesRef(userId).doc(entryToDelete.id).delete();
      logger.i(
          "FirebaseHydrationRepo: Entry ${entryToDelete.id} deleted for user $userId");
    } catch (e) {
      logger.e(
          "FirebaseHydrationRepo: Error deleting entry ${entryToDelete.id} for user $userId: $e");
      rethrow;
    }
  }

  @override
  Future<HydrationEntry?> getHydrationEntry(
      String userId, String entryId) async {
    try {
      final docSnapshot = await _hydrationEntriesRef(userId).doc(entryId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      logger.e(
          "FirebaseHydrationRepo: Error getting hydration entry $entryId for user $userId: $e");
      rethrow;
    }
  }

  @override
  Stream<List<HydrationEntry>> getHydrationEntriesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      final DateTime effectiveEndDate =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

      return _hydrationEntriesRef(userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp',
              isLessThanOrEqualTo: Timestamp.fromDate(effectiveEndDate))
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
        logger.e(
            "FirebaseHydrationRepo: Error streaming hydration entries for date range for user $userId: $error");
        return <HydrationEntry>[];
      });
    } catch (e) {
      logger.e(
          "FirebaseHydrationRepo: Error setting up stream for hydration entries (date range) for user $userId: $e");
      return Stream.value([]);
    }
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

  /// Fetches all hydration entries for a given user.
  ///
  /// This is useful for initial data synchronization.
  /// @return A `Future` that completes with a list of all `HydrationEntry` objects.
  Future<List<HydrationEntry>> getAllHydrationEntriesForUser(
      String userId) async {
    try {
      final querySnapshot = await _hydrationEntriesRef(userId)
          .orderBy('timestamp', descending: true)
          .get();
      logger.i(
          "FirebaseHydrationRepo: Fetched ${querySnapshot.docs.length} total entries for user $userId.");
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      logger.e(
          "FirebaseHydrationRepo: Error fetching all entries for user $userId: $e");
      return [];
    }
  }
}
