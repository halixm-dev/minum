// lib/src/data/repositories/firebase/firebase_auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/repositories/auth_repository.dart';
import 'package:minum/src/data/repositories/user_repository.dart';
import 'package:minum/main.dart'; // For logger

/// A concrete implementation of [AuthRepository] using Firebase Authentication.
class FirebaseAuthRepository implements AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository;

  /// Creates a `FirebaseAuthRepository` instance.
  ///
  /// If [firebaseAuth] or [googleSignIn] are not provided, default instances
  /// will be used. A [userRepository] is required to manage user data in
  /// Firestore.
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
      UserModel? appUser = await _userRepository.getUser(fbUser.uid);
      if (appUser == null) {
        // This can happen if a user was authenticated but their Firestore doc was deleted,
        // or if it's a new sign-up (e.g., Google) and the doc hasn't been created yet.
        logger.w(
            "authStateChanges: No UserModel found for uid ${fbUser.uid}, creating a basic one if it's a new social sign-in.");
        if (fbUser.providerData
            .any((userInfo) => userInfo.providerId == 'google.com')) {
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
            logger.e(
                "Error creating user document during authStateChanges for Google user: $e");
            return null;
          }
        }
        return null;
      }
      return appUser.copyWith(lastLoginAt: DateTime.now());
    });
  }

  @override
  UserModel? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      return null;
    }
    // This provides a basic UserModel synchronously. For the full, up-to-date
    // model from Firestore, rely on the `authStateChanges` stream.
    return UserModel(
        id: fbUser.uid,
        email: fbUser.email,
        displayName: fbUser.displayName,
        photoUrl: fbUser.photoURL,
        createdAt: fbUser.metadata.creationTime ?? DateTime.now());
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final fb_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw fb_auth.FirebaseAuthException(
            code: 'user-not-found', message: 'User not found after sign in.');
      }
      UserModel? appUser = await _userRepository.getUser(fbUser.uid);
      if (appUser == null) {
        logger.w(
            "User document not found for ${fbUser.uid} after email/password sign in. This might indicate an issue.");
        throw Exception('User profile not found in database.');
      }
      await _userRepository
          .updateUser(appUser.copyWith(lastLoginAt: DateTime.now()));
      return appUser.copyWith(lastLoginAt: DateTime.now());
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e(
          "FirebaseAuthException on signInWithEmailAndPassword: ${e.code} - ${e.message}");
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("Unknown error on signInWithEmailAndPassword: $e");
      rethrow;
    }
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(
      String email, String password,
      {String? displayName}) async {
    try {
      final fb_auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw fb_auth.FirebaseAuthException(
            code: 'user-creation-failed', message: 'User not created.');
      }
      if (displayName != null && displayName.isNotEmpty) {
        await fbUser.updateDisplayName(displayName);
      }
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
      logger.e(
          "FirebaseAuthException on createUserWithEmailAndPassword: ${e.code} - ${e.message}");
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
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final fb_auth.AuthCredential credential =
          fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final fb_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final fbUser = userCredential.user;

      if (fbUser == null) {
        throw fb_auth.FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found after Google sign in.');
      }

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
        await _userRepository.updateUser(appUser.copyWith(
            lastLoginAt: DateTime.now(),
            photoUrl: fbUser.photoURL,
            displayName: fbUser.displayName));
        return appUser.copyWith(
            lastLoginAt: DateTime.now(),
            photoUrl: fbUser.photoURL,
            displayName: fbUser.displayName);
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e(
          "FirebaseAuthException on signInWithGoogle: ${e.code} - ${e.message}");
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
      logger.e(
          "FirebaseAuthException on sendPasswordResetEmail: ${e.code} - ${e.message}");
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("Unknown error on sendPasswordResetEmail: $e");
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } on fb_auth.FirebaseAuthException catch (e) {
      logger.e("FirebaseAuthException on signOut: ${e.code} - ${e.message}");
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("Unknown error on signOut: $e");
      rethrow;
    }
  }

  /// Maps a [fb_auth.FirebaseAuthException] to a more generic [Exception].
  Exception _mapFirebaseAuthException(fb_auth.FirebaseAuthException e) {
    return Exception(e.message ?? 'An unknown authentication error occurred.');
  }
}
