// lib/src/data/repositories/auth_repository.dart
// Alias to avoid name clash
import 'package:minum/src/data/models/user_model.dart'; // We'll use our UserModel

// Abstract class defining the contract for authentication operations.
// Implementations of this class (e.g., FirebaseAuthRepository) will provide
// the concrete logic for interacting with an authentication service like Firebase.
abstract class AuthRepository {
  // Stream to listen to authentication state changes.
  // Emits a UserModel if a user is signed in, otherwise null.
  Stream<UserModel?> get authStateChanges;

  // Get the current authenticated user, if any.
  // Returns null if no user is currently signed in.
  UserModel? get currentUser;

  // Sign in with email and password.
  // Returns a UserModel on success, throws an exception on failure.
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  // Register a new user with email and password.
  // Returns a UserModel on success, throws an exception on failure.
  Future<UserModel> createUserWithEmailAndPassword(
      String email, String password,
      {String? displayName});

  // Sign in with Google.
  // Returns a UserModel on success, throws an exception on failure or if the user cancels.
  Future<UserModel?> signInWithGoogle();

  // Send a password reset email to the given email address.
  Future<void> sendPasswordResetEmail(String email);

  // Sign out the current user.
  Future<void> signOut();

// (Optional) Link an anonymous account with a permanent one, e.g. Google
// Future<UserModel> linkAnonymousAccount(fb_auth.AuthCredential credential);

// (Optional) Update user's email
// Future<void> updateUserEmail(String newEmail);

// (Optional) Update user's password
// Future<void> updateUserPassword(String newPassword);

// (Optional) Delete user account
// Future<void> deleteUserAccount();
}
