// lib/src/data/repositories/auth_repository.dart
import 'package:minum/src/data/models/user_model.dart';

/// An abstract class defining the contract for authentication operations.
///
/// Implementations of this class (e.g., `FirebaseAuthRepository`) will provide
/// the concrete logic for interacting with an authentication service like Firebase.
abstract class AuthRepository {
  /// A stream that emits the currently authenticated [UserModel] when the
  /// authentication state changes. Emits `null` if the user is signed out.
  Stream<UserModel?> get authStateChanges;

  /// Gets the currently authenticated user.
  ///
  /// Returns the [UserModel] if a user is signed in, otherwise `null`.
  UserModel? get currentUser;

  /// Signs in a user with the given [email] and [password].
  ///
  /// Returns a [UserModel] on success. Throws an exception on failure.
  /// @return A `Future` that completes with the signed-in `UserModel`.
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  /// Creates a new user account with the given [email] and [password].
  ///
  /// An optional [displayName] can be provided.
  /// Returns a [UserModel] on success. Throws an exception on failure.
  /// @return A `Future` that completes with the created `UserModel`.
  Future<UserModel> createUserWithEmailAndPassword(
      String email, String password,
      {String? displayName});

  /// Signs in a user using Google Sign-In.
  ///
  /// Returns a [UserModel] on success. Returns `null` if the user cancels
  /// the sign-in process. Throws an exception on failure.
  /// @return A `Future` that completes with the signed-in `UserModel` or null.
  Future<UserModel?> signInWithGoogle();

  /// Sends a password reset email to the given [email] address.
  Future<void> sendPasswordResetEmail(String email);

  /// Signs out the current user.
  Future<void> signOut();
}
