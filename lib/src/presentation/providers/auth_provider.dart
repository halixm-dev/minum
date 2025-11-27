// lib/src/presentation/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/main.dart'; // For logger

/// An enumeration of the possible authentication states.
enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
  authError,
}

/// A `ChangeNotifier` that manages the application's authentication state.
///
/// This provider interfaces with the [AuthService] to handle user authentication
/// and provides the current authentication status and user information to the UI.
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<UserModel?>? _authStateSubscription;

  UserModel? _currentUser;
  AuthStatus _authStatus = AuthStatus.uninitialized;
  String? _errorMessage;
  bool _isDisposed = false;

  /// The currently authenticated user. `null` if no user is signed in.
  UserModel? get currentUser => _currentUser;

  /// The current authentication status.
  AuthStatus get authStatus => _authStatus;

  /// The last authentication error message. `null` if there is no error.
  String? get errorMessage => _errorMessage;

  /// A boolean indicating if a user is currently authenticated.
  bool get isAuthenticated =>
      _authStatus == AuthStatus.authenticated && _currentUser != null;

  /// Creates an `AuthProvider` instance.
  ///
  /// Requires an [AuthService] and immediately starts listening to auth state changes.
  AuthProvider(this._authService) {
    _listenToAuthStateChanges();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    } else {
      logger.w(
          "AuthProvider: Attempted to call notifyListeners() after dispose.");
    }
  }

  void _listenToAuthStateChanges() {
    _authStateSubscription = _authService.authStateChanges.listen(
      (UserModel? user) {
        if (_isDisposed) return;

        _currentUser = user;
        if (user != null) {
          _authStatus = AuthStatus.authenticated;
          logger.i(
              "AuthProvider: User authenticated - ID: ${user.id}, Email: ${user.email}");
        } else {
          _authStatus = AuthStatus.unauthenticated;
          logger.i("AuthProvider: User unauthenticated.");
        }
        _errorMessage = null;
        _safeNotifyListeners();
      },
      onError: (error) {
        if (_isDisposed) return;

        logger.e("AuthProvider: Error in auth state stream: $error");
        _authStatus = AuthStatus.authError;
        _errorMessage = "Error in authentication stream.";
        _currentUser = null;
        _safeNotifyListeners();
      },
    );
  }

  /// Signs in a user with their email and password.
  Future<void> signInWithEmail(String email, String password) async {
    if (_isDisposed) return;
    _setAuthStatus(AuthStatus.authenticating);
    try {
      _currentUser =
          await _authService.signInWithEmailAndPassword(email, password);
      if (_isDisposed) return;
      _setAuthStatus(AuthStatus.authenticated);
    } on fb_auth.FirebaseAuthException catch (e) {
      if (_isDisposed) return;
      _handleAuthError(e.message ?? "Sign in failed.", e.code);
    } catch (e) {
      if (_isDisposed) return;
      _handleAuthError(e.toString(), "unknown-error");
    }
  }

  /// Signs up a new user with their email and password.
  Future<void> signUpWithEmail(String email, String password,
      {String? displayName}) async {
    if (_isDisposed) return;
    _setAuthStatus(AuthStatus.authenticating);
    try {
      _currentUser = await _authService.signUpWithEmailAndPassword(
          email, password,
          displayName: displayName);
      if (_isDisposed) return;
      _setAuthStatus(AuthStatus.authenticated);
    } on fb_auth.FirebaseAuthException catch (e) {
      if (_isDisposed) return;
      _handleAuthError(e.message ?? "Sign up failed.", e.code);
    } catch (e) {
      if (_isDisposed) return;
      _handleAuthError(e.toString(), "unknown-error");
    }
  }

  /// Initiates the Google Sign-In flow.
  ///
  /// @return A `Future` that completes with `true` if the sign-in was successful,
  /// `false` otherwise.
  Future<bool> signInWithGoogle() async {
    if (_isDisposed) return false;
    // _setAuthStatus(AuthStatus.authenticating); // Removed to keep LoginScreen mounted
    try {
      final UserModel? userFromService = await _authService.signInWithGoogle();
      if (_isDisposed) return false;

      if (userFromService != null) {
        _currentUser = userFromService;
        return true;
      } else {
        _setAuthStatus(AuthStatus.unauthenticated);
        _errorMessage = null;
        _safeNotifyListeners();
        return false;
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (_isDisposed) return false;
      _handleAuthError(e.message ?? "Google sign in failed.", e.code);
      return false;
    } catch (e) {
      if (_isDisposed) return false;
      _handleAuthError(e.toString(), "unknown-error");
      return false;
    }
  }

  /// Completes the Google Sign-In process by updating the auth status.
  ///
  /// This should be called after `signInWithGoogle` returns `true`.
  void completeGoogleSignIn() {
    if (_isDisposed) return;
    if (_currentUser != null) {
      _setAuthStatus(AuthStatus.authenticated);
    } else {
      _setAuthStatus(AuthStatus.unauthenticated);
      logger.w(
          "AuthProvider: completeGoogleSignIn called but _currentUser was null.");
    }
  }

  /// Sends a password reset email to the specified email address.
  Future<void> sendPasswordResetEmail(String email) async {
    if (_isDisposed) return;
    try {
      await _authService.sendPasswordResetEmail(email);
    } on fb_auth.FirebaseAuthException catch (e) {
      if (_isDisposed) return;
      _handleAuthError(e.message ?? "Password reset failed.", e.code,
          notify: false);
      rethrow;
    } catch (e) {
      if (_isDisposed) return;
      _handleAuthError(e.toString(), "unknown-error", notify: false);
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    if (_isDisposed) return;
    _setAuthStatus(AuthStatus.authenticating);
    try {
      await _authService.signOut();
      if (_isDisposed) return;
      _currentUser = null;
      _setAuthStatus(AuthStatus.unauthenticated);
    } catch (e) {
      if (_isDisposed) return;
      _handleAuthError(e.toString(), "sign-out-error");
    }
  }

  void _setAuthStatus(AuthStatus status) {
    if (_isDisposed) return;
    _authStatus = status;
    if (status != AuthStatus.authError) {
      _errorMessage = null;
    }
    _safeNotifyListeners();
  }

  void _handleAuthError(String message, String code, {bool notify = true}) {
    if (_isDisposed) return;
    logger.e("AuthProvider Error ($code): $message");
    _authStatus = AuthStatus.authError;
    _errorMessage = message;
    _currentUser = null;
    if (notify) _safeNotifyListeners();
  }

  @override
  void dispose() {
    logger.d("AuthProvider: dispose called.");
    _isDisposed = true;
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
