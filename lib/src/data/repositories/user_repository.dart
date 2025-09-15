// lib/src/data/repositories/user_repository.dart
import 'package:minum/src/data/models/user_model.dart';

/// An abstract class defining the contract for user data operations.
///
/// This involves CRUD (Create, Read, Update, Delete) operations for user
/// profiles and settings stored in a database like Firestore.
abstract class UserRepository {
  /// Fetches a user's profile data by their unique ID [uid].
  ///
  /// Returns a [UserModel] if the user document exists, otherwise `null`.
  /// @return A `Future` that completes with the `UserModel` or null.
  Future<UserModel?> getUser(String uid);

  /// Creates a new user document in the database.
  ///
  /// This is often called after successful registration.
  /// The [user] object contains the data for the new user.
  Future<void> createUser(UserModel user);

  /// Updates an existing user's profile data.
  ///
  /// The [user] object should contain the updated fields.
  Future<void> updateUser(UserModel user);
}
