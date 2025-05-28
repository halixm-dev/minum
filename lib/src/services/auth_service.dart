// lib/src/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart'
    as fb_auth; // For FirebaseAuthException
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/repositories/auth_repository.dart';
import 'package:minum/src/data/repositories/user_repository.dart';
import 'package:minum/main.dart'; // For logger

// Service layer for authentication and user management.
// It uses AuthRepository for authentication operations and
// UserRepository for managing user-specific data in Firestore.
class AuthService {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthService({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  // Stream of authentication state changes.
  // Emits UserModel if authenticated, null otherwise.
  Stream<UserModel?> get authStateChanges => _authRepository.authStateChanges;

  // Get the current authenticated user.
  UserModel? get currentUser => _authRepository.currentUser;

  // Sign in with email and password.
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      logger.i("AuthService: Attempting to sign in with email.");
      UserModel user =
          await _authRepository.signInWithEmailAndPassword(email, password);
      // Additional logic after sign-in can go here, e.g., updating last login.
      // The repository implementation already handles fetching/creating the UserModel.
      logger.i("AuthService: User ${user.id} signed in successfully.");
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e(
          "AuthService: FirebaseAuthException during email sign in - ${e.code}: ${e.message}");
      rethrow; // Re-throw to be handled by the UI/Provider
    } catch (e) {
      logger.e("AuthService: Unknown error during email sign in: $e");
      throw Exception("An unexpected error occurred during sign in.");
    }
  }

  // Register a new user with email and password.
  Future<UserModel> signUpWithEmailAndPassword(String email, String password,
      {String? displayName}) async {
    try {
      logger.i("AuthService: Attempting to register new user with email.");
      // The repository implementation handles creating the Firebase Auth user
      // AND the user document in Firestore.
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

  // Sign in with Google.
  Future<UserModel?> signInWithGoogle() async {
    try {
      logger.i("AuthService: Attempting Google Sign-In.");
      // The repository implementation handles Firebase Auth and Firestore user creation/update.
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

  // Send a password reset email.
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

  // Sign out the current user.
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

  // Fetch the full user profile data from UserRepository.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      logger.i("AuthService: Fetching user profile for $uid.");
      return await _userRepository.getUser(uid);
    } catch (e) {
      logger.e("AuthService: Error fetching user profile for $uid: $e");
      return null; // Or rethrow, depending on desired error handling
    }
  }

  // Update user profile data.
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
