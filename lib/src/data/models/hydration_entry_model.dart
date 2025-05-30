// lib/src/data/models/hydration_entry_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HydrationEntry extends Equatable {
  final String? id; // Firestore document ID
  final int? localDbId; // Local SQLite DB auto-increment ID (optional)
  final String userId; // Firebase UID or local guest ID
  final double amountMl; // Amount consumed, always in mL for consistency
  final DateTime timestamp; // When the water was consumed
  final String? notes; // Optional notes
  final String?
      source; // e.g., "manual", "quick_add_250ml", "synced_google_fit"
  final bool
      isSynced; // True if synced with Firestore (not part of Firestore doc)
  final bool
      isLocallyDeleted; // True if marked for deletion locally (not part of Firestore doc)

  const HydrationEntry({
    this.id,
    this.localDbId,
    required this.userId,
    required this.amountMl,
    required this.timestamp,
    this.notes,
    this.source,
    this.isSynced =
        false, // Default to false when creating new entries programmatically
    this.isLocallyDeleted = false,
  });

  // Factory constructor from Firestore document
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
      localDbId:
          localDbId, // Can be passed if known when creating from Firestore snapshot
      userId: data['userId'] as String,
      amountMl: (data['amountMl'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      source: data['source'] as String?,
      isSynced: isSynced, // Typically true when coming from Firestore
      isLocallyDeleted:
          false, // Should not be locally deleted if fetched from Firestore
    );
  }

  // Factory constructor from Local DB Map
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

  // Method to convert to Map for Firestore (excludes local-only fields)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amountMl': amountMl,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'source': source,
      // Do not include localDbId, isSynced, isLocallyDeleted in Firestore document
    };
  }

  // Method to convert to Map for Local DB (includes all relevant fields)
  Map<String, dynamic> toDbMap() {
    return {
      // '_id' is auto-generated by SQLite, so not included here for inserts unless updating
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

  // CopyWith method
  HydrationEntry copyWith({
    String? id, // Nullable if clearing Firestore ID
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
