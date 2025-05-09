// lib/src/data/repositories/firebase/firebase_user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/repositories/user_repository.dart';
import 'package:minum/main.dart'; // For logger

// Concrete implementation of UserRepository using Cloud Firestore.
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
      rethrow; // Or handle more gracefully
    }
  }

  @override
  Future<void> createUser(UserModel user) async {
    try {
      // Use set with merge: false to ensure it creates or overwrites completely.
      // If you want to prevent overwriting an existing user by mistake,
      // you could first check if the document exists.
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
      // Use update for partial updates, or set with merge: true.
      // Using user.toFirestore() to ensure all fields are correctly mapped.
      await _usersRef.doc(user.id).update(user.toFirestore());
      logger.i("User document updated for ${user.id}");
    } catch (e) {
      logger.e("Error updating user document for ${user.id}: $e");
      rethrow;
    }
  }

// Optional: Stream for real-time user updates
// @override
// Stream<UserModel?> observeUser(String uid) {
//   return _usersRef.doc(uid).snapshots().map((snapshot) {
//     if (snapshot.exists) {
//       return snapshot.data();
//     }
//     return null;
//   }).handleError((error) {
//     logger.e("Error observing user $uid: $error");
//     // Depending on your error strategy, you might return null or rethrow.
//     // For a stream, it's often better to emit an error or a specific state.
//     return null;
//   });
// }
}
