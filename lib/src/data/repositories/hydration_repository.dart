// lib/src/data/repositories/hydration_repository.dart
import 'package:minum/src/data/models/hydration_entry_model.dart';

/// An abstract class defining the contract for hydration data operations.
///
/// Implementations of this class will provide the concrete logic for
/// interacting with data sources like Firestore or a local database.
abstract class HydrationRepository {
  /// Adds a new [HydrationEntry] for a given [userId].
  Future<void> addHydrationEntry(String userId, HydrationEntry entry);

  /// Updates an existing [HydrationEntry] for a given [userId].
  Future<void> updateHydrationEntry(String userId, HydrationEntry entry);

  /// Deletes a [HydrationEntry].
  Future<void> deleteHydrationEntry(
      String userId, HydrationEntry entryToDelete);

  /// Retrieves a specific [HydrationEntry] by its ID.
  ///
  /// The [entryId] is the Firestore document ID.
  /// @return A `Future` that completes with the `HydrationEntry` or null.
  Future<HydrationEntry?> getHydrationEntry(String userId, String entryId);

  /// Retrieves a stream of [HydrationEntry]s for a given [userId] and date range.
  ///
  /// @return A stream of lists of `HydrationEntry` objects.
  Stream<List<HydrationEntry>> getHydrationEntriesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Retrieves a stream of [HydrationEntry]s for a given [userId] and a specific [date].
  ///
  /// @return A stream of lists of `HydrationEntry` objects.
  Stream<List<HydrationEntry>> getHydrationEntriesForDay(
      String userId, DateTime date);
}
