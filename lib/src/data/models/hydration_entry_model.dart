// lib/src/data/models/hydration_entry_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a single hydration entry record.
///
/// This model is used for both local SQLite storage and Firestore, with
/// fields to handle synchronization between them.
class HydrationEntry extends Equatable {
  /// The unique identifier from Firestore. Null for local-only entries.
  final String? id;

  /// The auto-incrementing primary key from the local SQLite database.
  final int? localDbId;

  /// The ID of the user who created this entry (Firebase UID or a local guest ID).
  final String userId;

  /// The amount of water consumed, always stored in milliliters for consistency.
  final double amountMl;

  /// The date and time when the water was consumed.
  final DateTime timestamp;

  /// Optional user-provided notes for the entry.
  final String? notes;

  /// The source of the entry (e.g., "manual", "quick_add_250ml", "google_fit").
  final String? source;

  /// A flag indicating if this entry has been successfully synced to Firestore.
  /// This field is for local use only and is not stored in Firestore.
  final bool isSynced;

  /// A flag indicating if this entry is marked for deletion locally.
  /// This field is for local use only and is not stored in Firestore.
  final bool isLocallyDeleted;

  /// Creates a `HydrationEntry` instance.
  const HydrationEntry({
    this.id,
    this.localDbId,
    required this.userId,
    required this.amountMl,
    required this.timestamp,
    this.notes,
    this.source,
    this.isSynced = false,
    this.isLocallyDeleted = false,
  });

  /// Creates a `HydrationEntry` from a Firestore document snapshot.
  ///
  /// The [localDbId] can be optionally provided if it's known.
  /// The [isSynced] flag defaults to `true` as the data comes from Firestore.
  factory HydrationEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      {int? localDbId,
      bool isSynced = true}) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Hydration entry data is null in Firestore document!");
    }
    return HydrationEntry(
      id: doc.id,
      localDbId: localDbId,
      userId: data['userId'] as String,
      amountMl: (data['amountMl'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      source: data['source'] as String?,
      isSynced: isSynced,
      isLocallyDeleted: false,
    );
  }

  /// Creates a `HydrationEntry` from a map retrieved from the local SQLite database.
  factory HydrationEntry.fromDbMap(Map<String, dynamic> map) {
    return HydrationEntry(
      id: map['firestore_id'] as String?,
      localDbId: map['_id'] as int?,
      userId: map['user_id'] as String,
      amountMl: map['amount_ml'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String?,
      source: map['source'] as String?,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      isLocallyDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }

  /// Converts the `HydrationEntry` instance to a map for storing in Firestore.
  ///
  /// Excludes local-only fields like [localDbId], [isSynced], and [isLocallyDeleted].
  /// @return A map representation of the object for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amountMl': amountMl,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'source': source,
    };
  }

  /// Converts the `HydrationEntry` instance to a map for storing in the local SQLite database.
  ///
  /// Includes all relevant fields for local storage and synchronization.
  /// @return A map representation of the object for the local database.
  Map<String, dynamic> toDbMap() {
    return {
      if (localDbId != null) '_id': localDbId,
      'firestore_id': id,
      'user_id': userId,
      'amount_ml': amountMl,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'source': source,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isLocallyDeleted ? 1 : 0,
    };
  }

  /// Creates a copy of this `HydrationEntry` but with the given fields replaced with the new values.
  HydrationEntry copyWith({
    String? id,
    int? localDbId,
    String? userId,
    double? amountMl,
    DateTime? timestamp,
    String? notes,
    String? source,
    bool? isSynced,
    bool? isLocallyDeleted,
  }) {
    return HydrationEntry(
      id: id ?? this.id,
      localDbId: localDbId ?? this.localDbId,
      userId: userId ?? this.userId,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      isSynced: isSynced ?? this.isSynced,
      isLocallyDeleted: isLocallyDeleted ?? this.isLocallyDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        localDbId,
        userId,
        amountMl,
        timestamp,
        notes,
        source,
        isSynced,
        isLocallyDeleted
      ];
}
