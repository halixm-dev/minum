// lib/src/data/repositories/firebase/firebase_user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/repositories/user_repository.dart';
import 'package:minum/main.dart'; // For logger

/// A concrete implementation of [UserRepository] using Cloud Firestore.
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  /// Creates a `FirebaseUserRepository` instance.
  ///
  /// If [firestore] is not provided, a default instance will be used.
  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// A helper to get a reference to the `users` collection with a type converter.
  CollectionReference<UserModel> get _usersRef =>
      _firestore.collection(_usersCollection).withConverter<UserModel>(
            fromFirestore: (snapshots, _) => UserModel.fromFirestore(snapshots),
            toFirestore: (user, _) => user.toFirestore(),
          );

  @override
  Future<UserModel?> getUser(String uid) async {
    try {
      final docSnapshot = await _usersRef.doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      logger.e("Error getting user $uid: $e");
      rethrow;
    }
  }

  @override
  Future<void> createUser(UserModel user) async {
    try {
      await _usersRef.doc(user.id).set(user, SetOptions(merge: false));
      logger.i("User document created for ${user.id}");
    } catch (e) {
      logger.e("Error creating user document for ${user.id}: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersRef.doc(user.id).update(user.toFirestore());
      logger.i("User document updated for ${user.id}");
    } catch (e) {
      logger.e("Error updating user document for ${user.id}: $e");
      rethrow;
    }
  }
}
