// lib/src/data/local/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/main.dart'; // For logger

/// A singleton class to manage the local SQLite database.
///
/// This class handles database initialization, creation, and all CRUD
/// operations for the `hydration_entries` table. It supports offline
/// functionality and data synchronization with Firestore.
class DatabaseHelper {
  /// The name of the database file.
  static const _databaseName = "MinumApp.db";

  /// The version of the database schema.
  static const _databaseVersion =
      2; // Increment this if you change the schema in the future

  /// The name of the hydration entries table.
  static const tableHydrationEntries = 'hydration_entries';

  // Column names
  /// The local auto-incrementing primary key.
  static const columnId = '_id';

  /// The ID of the entry in Firestore.
  static const columnFirestoreId = 'firestore_id';

  /// The ID of the user who owns the entry.
  static const columnUserId = 'user_id';

  /// The amount of water consumed in milliliters.
  static const columnAmountMl = 'amount_ml';

  /// The timestamp of the entry, stored as an ISO 8601 string.
  static const columnTimestamp = 'timestamp';

  /// Optional notes for the entry.
  static const columnNotes = 'notes';

  /// The source of the entry (e.g., 'manual', 'google_fit').
  static const columnSource = 'source';

  /// The ID of the entry in Health Connect.
  static const columnHealthConnectId = 'health_connect_id';

  /// A flag indicating if the entry is synced with Firestore (0 or 1).
  static const columnIsSynced = 'is_synced';

  /// A flag indicating if the entry is marked for deletion (0 or 1).
  static const columnIsDeleted = 'is_deleted';

  // --- Singleton Pattern ---
  DatabaseHelper._privateConstructor();

  /// The single instance of the `DatabaseHelper`.
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// Returns the singleton `Database` instance, initializing it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database by opening it and creating the table if it doesn't exist.
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    logger.i("Database path: $path");
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Called when the database is created for the first time.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableHydrationEntries (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnFirestoreId TEXT, 
        $columnUserId TEXT NOT NULL, 
        $columnAmountMl REAL NOT NULL,
        $columnTimestamp TEXT NOT NULL, 
        $columnNotes TEXT,
        $columnSource TEXT,
        $columnHealthConnectId TEXT,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        $columnIsDeleted INTEGER NOT NULL DEFAULT 0 
      )
      ''');
    logger.i("Table $tableHydrationEntries created successfully.");
  }

  /// Called when the database needs to be upgraded.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    logger.i("Upgrading database from version $oldVersion to $newVersion");
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE $tableHydrationEntries ADD COLUMN $columnHealthConnectId TEXT');
      logger.i("Added column $columnHealthConnectId to $tableHydrationEntries");
    }
  }

  // --- CRUD Operations ---

  /// Inserts a [HydrationEntry] into the database.
  ///
  /// Returns the local ID of the newly inserted row.
  /// @return The local database ID of the inserted entry.
  Future<int> insertHydrationEntry(HydrationEntry entry) async {
    final db = await instance.database;
    final map = entry.toDbMap();
    map.remove(columnId); // Remove localDbId, as it's auto-generated
    logger.d("Inserting into local DB: $map");
    int localId = await db.insert(tableHydrationEntries, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
    logger.d("Inserted entry with local ID: $localId");
    return localId;
  }

  /// Retrieves a [HydrationEntry] by its local database ID.
  ///
  /// Returns the entry if found and not marked as deleted, otherwise null.
  /// @return A `Future` that completes with the `HydrationEntry` or null.
  Future<HydrationEntry?> getHydrationEntryByLocalId(int localId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableHydrationEntries,
      where:
          '$columnId = ? AND $columnIsDeleted = 0', // Only get non-deleted entries
      whereArgs: [localId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HydrationEntry.fromDbMap(maps.first);
    }
    return null;
  }

  /// Retrieves a [HydrationEntry] by its Health Connect ID.
  Future<HydrationEntry?> getHydrationEntryByHealthConnectId(
      String healthConnectId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableHydrationEntries,
      where: '$columnHealthConnectId = ? AND $columnIsDeleted = 0',
      whereArgs: [healthConnectId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HydrationEntry.fromDbMap(maps.first);
    }
    return null;
  }

  /// Retrieves all [HydrationEntry]s for a specific user within a date range.
  ///
  /// @return A list of `HydrationEntry` objects.
  Future<List<HydrationEntry>> getHydrationEntriesForUser(
      String userId, DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    final startOfDay =
        DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0, 0);
    final endOfDay =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
    final startIso = startOfDay.toIso8601String();
    final endIso = endOfDay.toIso8601String();

    logger.d("Querying local DB for user $userId, range: $startIso to $endIso");
    final List<Map<String, dynamic>> maps = await db.query(
      tableHydrationEntries,
      where:
          '$columnUserId = ? AND $columnTimestamp >= ? AND $columnTimestamp <= ? AND $columnIsDeleted = 0',
      whereArgs: [userId, startIso, endIso],
      orderBy: '$columnTimestamp DESC',
    );
    logger.d(
        "Found ${maps.length} entries in local DB for user $userId in range.");
    return maps.map((map) => HydrationEntry.fromDbMap(map)).toList();
  }

  /// Retrieves all entries for a user that are not yet synced to Firestore.
  ///
  /// This includes new or updated entries that are not marked for deletion.
  /// @return A list of unsynced `HydrationEntry` objects.
  Future<List<HydrationEntry>> getUnsyncedNewOrUpdatedEntries(
      String userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHydrationEntries,
      where:
          '$columnUserId = ? AND $columnIsSynced = 0 AND $columnIsDeleted = 0',
      whereArgs: [userId],
    );
    logger.d(
        "Found ${maps.length} unsynced new/updated entries for user $userId.");
    return maps.map((map) => HydrationEntry.fromDbMap(map)).toList();
  }

  /// Updates an existing [HydrationEntry] in the local database by its local ID.
  ///
  /// Returns the number of rows affected.
  /// @return The number of rows affected.
  Future<int> updateHydrationEntryByLocalId(
      int localId, HydrationEntry entry) async {
    final db = await instance.database;
    final map = entry.toDbMap();
    map.remove(columnId); // Do not try to update the primary key
    logger.d("Updating local DB entry (localId: $localId): $map");
    return await db.update(
      tableHydrationEntries,
      map,
      where: '$columnId = ?',
      whereArgs: [localId],
    );
  }

  /// Updates an entry's Firestore ID and marks it as synced.
  ///
  /// @return The number of rows affected.
  Future<int> markHydrationEntryAsSynced(
      int localId, String firestoreId) async {
    final db = await instance.database;
    logger.d(
        "Marking local entry (localId: $localId) as synced with Firestore ID: $firestoreId");
    return await db.update(
      tableHydrationEntries,
      {columnFirestoreId: firestoreId, columnIsSynced: 1},
      where: '$columnId = ?',
      whereArgs: [localId],
    );
  }

  /// Soft deletes an entry by marking it as deleted and needing sync.
  ///
  /// @return The number of rows affected.
  Future<int> markHydrationEntryAsDeletedByLocalId(int localId) async {
    final db = await instance.database;
    logger
        .d("Marking local entry (localId: $localId) as deleted and unsynced.");
    return await db.update(
      tableHydrationEntries,
      {
        columnIsDeleted: 1,
        columnIsSynced: 0
      }, // Mark as deleted and requires sync
      where: '$columnId = ?',
      whereArgs: [localId],
    );
  }

  /// Retrieves entries marked for deletion that have not yet been synced.
  ///
  /// @return A list of deleted, unsynced `HydrationEntry` objects.
  Future<List<HydrationEntry>> getDeletedUnsyncedEntries(String userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHydrationEntries,
      where:
          '$columnUserId = ? AND $columnIsDeleted = 1 AND $columnIsSynced = 0',
      whereArgs: [userId],
    );
    logger.d("Found ${maps.length} unsynced deleted entries for user $userId.");
    return maps.map((map) => HydrationEntry.fromDbMap(map)).toList();
  }

  /// Permanently removes an entry from the local database.
  ///
  /// This is typically called after its deletion has been synced with Firestore.
  /// @return The number of rows affected.
  Future<int> deleteHydrationEntryPermanentlyByLocalId(int localId) async {
    final db = await instance.database;
    logger.d("Permanently deleting local entry (localId: $localId).");
    return await db.delete(
      tableHydrationEntries,
      where: '$columnId = ?',
      whereArgs: [localId],
    );
  }

  /// Updates local entries from a guest ID to a new Firebase User ID.
  ///
  /// This is used when a guest user signs in. It also marks the entries as
  /// unsynced so they can be uploaded for the new user.
  /// @return The number of rows affected.
  Future<int> updateGuestEntriesToUser(
      String guestId, String firebaseUserId) async {
    final db = await instance.database;
    logger.i(
        "Updating local entries from guestId: $guestId to firebaseUserId: $firebaseUserId. Marking as unsynced.");
    return await db.update(
      tableHydrationEntries,
      {
        columnUserId: firebaseUserId,
        columnIsSynced: 0,
        columnFirestoreId: null
      }, // Reset Firestore ID and mark as unsynced
      where:
          '$columnUserId = ? AND $columnIsDeleted = 0', // Only update non-deleted guest entries
      whereArgs: [guestId],
    );
  }

  /// Retrieves the local database ID from a Firestore ID.
  ///
  /// @return The local ID, or null if not found.
  Future<int?> getLocalIdFromFirestoreId(
      String firestoreId, String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableHydrationEntries,
      columns: [columnId],
      where:
          '$columnFirestoreId = ? AND $columnUserId = ? AND $columnIsDeleted = 0',
      whereArgs: [firestoreId, userId], // Ensure it's for the correct user
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first[columnId] as int?;
    }
    return null;
  }

  /// Inserts or updates a [HydrationEntry].
  ///
  /// This is useful when pulling data from Firebase. If the entry (based on
  /// Firestore ID) exists locally, it's updated. Otherwise, it's inserted.
  /// @return The local ID of the inserted or updated row.
  Future<int> upsertHydrationEntry(HydrationEntry entry, String userId) async {
    final db = await instance.database;
    int? localId;

    if (entry.id != null) {
      // entry.id is Firestore ID
      localId = await getLocalIdFromFirestoreId(entry.id!, userId);
    }

    final entryWithUser = entry.copyWith(
        userId: userId,
        isSynced:
            true); // Mark as synced as it's coming from/aligned with Firebase
    final map = entryWithUser.toDbMap();
    map.remove(
        columnId); // Don't include localId in the map for insert/update values

    if (localId != null) {
      // Update existing local entry
      logger.d(
          "Upserting: Updating local entry (localId: $localId) for Firestore ID ${entry.id}");
      await db.update(tableHydrationEntries, map,
          where: '$columnId = ?', whereArgs: [localId]);
      return localId;
    } else {
      // Insert new local entry
      logger.d(
          "Upserting: Inserting new local entry for Firestore ID ${entry.id}");
      return await db.insert(tableHydrationEntries, map,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
