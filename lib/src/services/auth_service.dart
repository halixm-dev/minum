// lib/src/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart'
    as fb_auth; // For FirebaseAuthException
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/repositories/auth_repository.dart';
import 'package:minum/src/data/repositories/user_repository.dart';
import 'package:minum/main.dart'; // For logger

/// A service layer for authentication and user management.
///
/// This class uses an [AuthRepository] for authentication operations and a
/// [UserRepository] for managing user-specific data in a database.
class AuthService {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  /// Creates an `AuthService` instance.
  ///
  /// Requires an [authRepository] and a [userRepository].
  AuthService({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  /// A stream that provides real-time updates on the authentication state.
  ///
  /// Emits a [UserModel] if a user is authenticated, otherwise `null`.
  Stream<UserModel?> get authStateChanges => _authRepository.authStateChanges;

  /// Gets the currently authenticated user synchronously.
  ///
  /// This may not have the most up-to-date user profile information.
  /// For real-time updates, use [authStateChanges].
  UserModel? get currentUser => _authRepository.currentUser;

  /// Signs in a user with their email and password.
  ///
  /// @return A `Future` that completes with the signed-in `UserModel`.
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      logger.i("AuthService: Attempting to sign in with email.");
      UserModel user =
          await _authRepository.signInWithEmailAndPassword(email, password);
      logger.i("AuthService: User ${user.id} signed in successfully.");
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e(
          "AuthService: FirebaseAuthException during email sign in - ${e.code}: ${e.message}");
      rethrow;
    } catch (e) {
      logger.e("AuthService: Unknown error during email sign in: $e");
      throw Exception("An unexpected error occurred during sign in.");
    }
  }

  /// Registers a new user with an email and password.
  ///
  /// An optional [displayName] can be provided.
  /// @return A `Future` that completes with the newly created `UserModel`.
  Future<UserModel> signUpWithEmailAndPassword(String email, String password,
      {String? displayName}) async {
    try {
      logger.i("AuthService: Attempting to register new user with email.");
      UserModel newUser = await _authRepository.createUserWithEmailAndPassword(
        email,
        password,
        displayName: displayName,
      );
      logger.i(
          "AuthService: User ${newUser.id} registered and profile created successfully.");
      return newUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e(
          "AuthService: FirebaseAuthException during email sign up - ${e.code}: ${e.message}");
      rethrow;
    } catch (e) {
      logger.e("AuthService: Unknown error during email sign up: $e");
      throw Exception("An unexpected error occurred during sign up.");
    }
  }

  /// Signs in a user using their Google account.
  ///
  /// @return A `Future` that completes with the `UserModel` or `null` if the
  /// sign-in was cancelled.
  Future<UserModel?> signInWithGoogle() async {
    try {
      logger.i("AuthService: Attempting Google Sign-In.");
      UserModel? user = await _authRepository.signInWithGoogle();
      if (user != null) {
        logger.i(
            "AuthService: User ${user.id} signed in with Google successfully.");
      } else {
        logger.i("AuthService: Google Sign-In cancelled by user or failed.");
      }
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e(
          "AuthService: FirebaseAuthException during Google sign in - ${e.code}: ${e.message}");
      rethrow;
    } catch (e) {
      logger.e("AuthService: Unknown error during Google sign in: $e");
      throw Exception("An unexpected error occurred during Google Sign-In.");
    }
  }

  /// Sends a password reset email to the specified [email] address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      logger.i("AuthService: Sending password reset email to $email.");
      await _authRepository.sendPasswordResetEmail(email);
      logger.i("AuthService: Password reset email sent successfully.");
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e(
          "AuthService: FirebaseAuthException during password reset - ${e.code}: ${e.message}");
      rethrow;
    } catch (e) {
      logger.e("AuthService: Unknown error sending password reset email: $e");
      throw Exception(
          "An unexpected error occurred while sending password reset email.");
    }
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    try {
      logger.i("AuthService: Signing out user.");
      await _authRepository.signOut();
      logger.i("AuthService: User signed out successfully.");
    } catch (e) {
      logger.e("AuthService: Error during sign out: $e");
      throw Exception("An unexpected error occurred during sign out.");
    }
  }

  /// Fetches the user profile data for the given [uid].
  ///
  /// @return A `Future` that completes with the `UserModel` or `null`.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      logger.i("AuthService: Fetching user profile for $uid.");
      return await _userRepository.getUser(uid);
    } catch (e) {
      logger.e("AuthService: Error fetching user profile for $uid: $e");
      return null;
    }
  }

  /// Updates the user's profile data.
  Future<void> updateUserProfile(UserModel user) async {
    try {
      logger.i("AuthService: Updating user profile for ${user.id}.");
      await _userRepository.updateUser(user);
      logger
          .i("AuthService: User profile for ${user.id} updated successfully.");
    } catch (e) {
      logger.e("AuthService: Error updating user profile for ${user.id}: $e");
      throw Exception("Failed to update profile. Please try again.");
    }
  }
}
