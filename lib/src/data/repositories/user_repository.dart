// lib/src/data/repositories/user_repository.dart
import 'package:minum/src/data/models/user_model.dart';

// Abstract class defining the contract for user data operations.
// This typically involves CRUD (Create, Read, Update, Delete) operations
// for user profiles and settings stored in a database like Firestore.
abstract class UserRepository {
  // Fetch a user's profile data by their UID.
  // Returns null if the user document doesn't exist.
  Future<UserModel?> getUser(String uid);

  // Create a new user document in the database.
  // This is often called after successful registration.
  Future<void> createUser(UserModel user);

  // Update an existing user's profile data.
  // Takes the UID and a UserModel containing the updated fields.
  Future<void> updateUser(UserModel user);

// (Optional) Delete a user's data from the database.
// This might be called if a user deletes their account.
// Future<void> deleteUser(String uid);

// (Optional) Stream to listen for real-time updates to a user's profile.
// Stream<UserModel?> observeUser(String uid);
}
