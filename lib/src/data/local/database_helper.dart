// lib/src/data/local/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/main.dart'; // For logger

class DatabaseHelper {
  static const _databaseName = "MinumApp.db";
  static const _databaseVersion =
      1; // Increment this if you change the schema in the future

  static const tableHydrationEntries = 'hydration_entries';

  // Column names (matching HydrationEntry.toDbMap() keys and HydrationEntry.fromDbMap() expectations)
  static const columnId = '_id'; // Local auto-incrementing primary key
  static const columnFirestoreId = 'firestore_id';
  static const columnUserId = 'user_id';
  static const columnAmountMl = 'amount_ml';
  static const columnTimestamp = 'timestamp'; // Stored as ISO8601 String
  static const columnNotes = 'notes';
  static const columnSource = 'source';
  static const columnIsSynced = 'is_synced'; // INTEGER: 0 for false, 1 for true
  static const columnIsDeleted =
      'is_deleted'; // INTEGER: 0 for false, 1 for true

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    logger.i("Database path: $path");
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade, // Define this for future schema migrations
    );
  }

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
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        $columnIsDeleted INTEGER NOT NULL DEFAULT 0 
      )
      ''');
    // You can add an index for faster queries if needed, e.g., on userId and timestamp
    // await db.execute('CREATE INDEX idx_user_timestamp ON $tableHydrationEntries ($columnUserId, $columnTimestamp)');
    logger.i("Table $tableHydrationEntries created successfully.");
  }

  // Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     // Example: await db.execute("ALTER TABLE $tableHydrationEntries ADD COLUMN new_column TEXT;");
  //   }
  // }

  // Insert a HydrationEntry into the database.
  // Returns the ID of the last inserted row (localDbId).
  Future<int> insertHydrationEntry(HydrationEntry entry) async {
    final db = await instance.database;
    final map = entry.toDbMap();
    // Remove localDbId from map if present, as it's auto-generated on insert
    map.remove(columnId);
    logger.d("Inserting into local DB: $map");
    int localId = await db.insert(tableHydrationEntries, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
    logger.d("Inserted entry with local ID: $localId");
    return localId;
  }

  // Get a specific HydrationEntry by its local DB ID.
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

  // Get all HydrationEntrys for a specific user ID and date range.
  Future<List<HydrationEntry>> getHydrationEntriesForUser(
      String userId, DateTime startDate, DateTime endDate) async {
    final db = await instance.database;
    // Normalize dates to ensure consistent querying at day boundaries
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

  // Get all entries for a user that are not yet synced to Firestore and not marked for deletion.
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

  // Update an existing HydrationEntry in the local DB using its localDbId.
  // Returns the number of rows affected.
  Future<int> updateHydrationEntryByLocalId(
      int localId, HydrationEntry entry) async {
    final db = await instance.database;
    final map = entry.toDbMap();
    map.remove(columnId); // Do not try to update the primary key itself
    logger.d("Updating local DB entry (localId: $localId): $map");
    return await db.update(
      tableHydrationEntries,
      map,
      where: '$columnId = ?',
      whereArgs: [localId],
    );
  }

  // Update an entry's Firestore ID and mark it as synced.
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

  // Soft delete: mark an entry as deleted locally and needing sync for deletion.
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

  // Get entries marked for deletion that have not yet been synced to Firestore.
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

  // Hard delete: permanently remove an entry from the local DB.
  // Typically called after its deletion has been synced with Firestore.
  Future<int> deleteHydrationEntryPermanentlyByLocalId(int localId) async {
    final db = await instance.database;
    logger.d("Permanently deleting local entry (localId: $localId).");
    return await db.delete(
      tableHydrationEntries,
      where: '$columnId = ?',
      whereArgs: [localId],
    );
  }

  // Update local entries that were associated with a guest ID to the new Firebase User ID.
  // Also marks them as unsynced so they will be uploaded for the new user.
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

  // Get the local DB ID (_id) from a Firestore ID.
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

  // Upsert: Insert if new (based on firestoreId for a given userId), or update if exists.
  // Useful when pulling data from Firebase to local.
  // Returns the local ID of the inserted/updated row.
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
