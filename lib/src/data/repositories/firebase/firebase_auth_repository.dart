// lib/src/data/repositories/firebase/firebase_auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/repositories/auth_repository.dart';
import 'package:minum/src/data/repositories/user_repository.dart'; // For creating user doc after registration
import 'package:minum/main.dart'; // For logger

// Concrete implementation of AuthRepository using Firebase Authentication.
class FirebaseAuthRepository implements AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository; // To create user document in Firestore

  FirebaseAuthRepository({
    fb_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    required UserRepository userRepository,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _userRepository = userRepository;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) {
        return null;
      }
      // Fetch our UserModel from Firestore.
      // If it doesn't exist (e.g., first login with Google), it might be created here or by a dedicated UserProvider.
      UserModel? appUser = await _userRepository.getUser(fbUser.uid);
      if (appUser == null) {
        // This case can happen if a user was authenticated but their Firestore doc was deleted,
        // or if it's a new sign-up (e.g. Google) and the doc hasn't been created yet.
        // For Google Sign-In, we might create a basic user profile here.
        // For email/password, user creation is typically handled after registration.
        logger.w("authStateChanges: No UserModel found for uid ${fbUser.uid}, creating a basic one if it's a new social sign-in.");
        if (fbUser.providerData.any((userInfo) => userInfo.providerId == 'google.com')) {
          final newUser = UserModel(
            id: fbUser.uid,
            email: fbUser.email,
            displayName: fbUser.displayName,
            photoUrl: fbUser.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          try {
            await _userRepository.createUser(newUser);
            return newUser;
          } catch (e) {
            logger.e("Error creating user document during authStateChanges for Google user: $e");
            return null; // Or a default UserModel indicating an issue
          }
        }
        // If not a new social sign-in and no user doc, this might be an inconsistent state.
        return null;
      }
      return appUser.copyWith(lastLoginAt: DateTime.now()); // Update last login time conceptually
    });
  }

  @override
  UserModel? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      return null;
    }
    // This is tricky because we need to fetch from Firestore to get the full UserModel.
    // For simplicity here, we return a basic UserModel. A UserProvider would typically handle this.
    // Consider making this method async or relying on authStateChanges for the full UserModel.
    return UserModel(
        id: fbUser.uid,
        email: fbUser.email,
        displayName: fbUser.displayName,
        photoUrl: fbUser.photoURL,
        createdAt: fbUser.metadata.creationTime ?? DateTime.now()
    );
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final fb_auth.UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw fb_auth.FirebaseAuthException(code: 'user-not-found', message: 'User not found after sign in.');
      }
      // Fetch or create user document
      UserModel? appUser = await _userRepository.getUser(fbUser.uid);
      if (appUser == null) {
        // This shouldn't typically happen if registration creates the user doc.
        // However, as a fallback:
        logger.w("User document not found for ${fbUser.uid} after email/password sign in. This might indicate an issue.");
        // Potentially create a basic user document here or throw a more specific error.
        // For now, we'll assume the user document should exist.
        throw Exception('User profile not found in database.');
      }
      // Update last login time in Firestore (UserRepository should handle this ideally)
      await _userRepository.updateUser(appUser.copyWith(lastLoginAt: DateTime.now()));
      return appUser.copyWith(lastLoginAt: DateTime.now());
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e("FirebaseAuthException on signInWithEmailAndPassword: ${e.code} - ${e.message}");
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("Unknown error on signInWithEmailAndPassword: $e");
      rethrow;
    }
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(String email, String password, {String? displayName}) async {
    try {
      final fb_auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw fb_auth.FirebaseAuthException(code: 'user-creation-failed', message: 'User not created.');
      }
      if (displayName != null && displayName.isNotEmpty) {
        await fbUser.updateDisplayName(displayName);
      }
      // Create our user model and save to Firestore
      final newUser = UserModel(
        id: fbUser.uid,
        email: fbUser.email,
        displayName: displayName ?? fbUser.displayName,
        photoUrl: fbUser.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _userRepository.createUser(newUser);
      return newUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e("FirebaseAuthException on createUserWithEmailAndPassword: ${e.code} - ${e.message}");
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("Unknown error on createUserWithEmailAndPassword: $e");
      rethrow;
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final fb_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = userCredential.user;

      if (fbUser == null) {
        throw fb_auth.FirebaseAuthException(code: 'user-not-found', message: 'User not found after Google sign in.');
      }

      // Check if user exists in Firestore, if not, create them
      UserModel? appUser = await _userRepository.getUser(fbUser.uid);
      if (appUser == null) {
        final newUser = UserModel(
          id: fbUser.uid,
          email: fbUser.email,
          displayName: fbUser.displayName,
          photoUrl: fbUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _userRepository.createUser(newUser);
        return newUser;
      } else {
        // User exists, update last login time
        await _userRepository.updateUser(appUser.copyWith(lastLoginAt: DateTime.now(), photoUrl: fbUser.photoURL, displayName: fbUser.displayName));
        return appUser.copyWith(lastLoginAt: DateTime.now(), photoUrl: fbUser.photoURL, displayName: fbUser.displayName);
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e("FirebaseAuthException on signInWithGoogle: ${e.code} - ${e.message}");
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("Unknown error on signInWithGoogle: $e");
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e("FirebaseAuthException on sendPasswordResetEmail: ${e.code} - ${e.message}");
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("Unknown error on sendPasswordResetEmail: $e");
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await _firebaseAuth.signOut(); // Sign out from Firebase
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e("FirebaseAuthException on signOut: ${e.code} - ${e.message}");
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("Unknown error on signOut: $e");
      rethrow;
    }
  }

  // Helper to map Firebase exceptions to a more generic or app-specific exception if needed
  Exception _mapFirebaseAuthException(fb_auth.FirebaseAuthException e) {
    // You can customize this mapping based on your app's error handling strategy
    return Exception(e.message ?? 'An unknown authentication error occurred.');
  }
}
