// lib/src/data/repositories/hydration_repository.dart
import 'package:minum/src/data/models/hydration_entry_model.dart';

abstract class HydrationRepository {
  Future<void> addHydrationEntry(String userId, HydrationEntry entry);

  Future<void> updateHydrationEntry(String userId, HydrationEntry entry);

  // Updated signature to accept HydrationEntry object
  Future<void> deleteHydrationEntry(
      String userId, HydrationEntry entryToDelete);

  Future<HydrationEntry?> getHydrationEntry(
      String userId, String entryId); // entryId here is Firestore ID

  Stream<List<HydrationEntry>> getHydrationEntriesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  Stream<List<HydrationEntry>> getHydrationEntriesForDay(
      String userId, DateTime date);
}
