import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minum/main.dart'; // For logger
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:minum/src/features/auth/data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  StreamSubscription? _authSubscription;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);

    _authSubscription = authService.authStateChanges.listen(
      (user) => add(AuthStatusChanged(user)),
      onError: (error) {
        logger.e("AuthBloc: Error in auth state stream: $error");
        add(const AuthStatusChanged(null));
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      logger.i("AuthBloc: User authenticated - ID: ${event.user!.id}");
      emit(Authenticated(event.user!));
    } else {
      logger.i("AuthBloc: User unauthenticated.");
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInWithEmailRequested(
      SignInWithEmailRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authService.signInWithEmailAndPassword(event.email, event.password);
      // We don't need to emit Authenticated here because the stream will trigger AuthStatusChanged
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpWithEmailRequested(
      SignUpWithEmailRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authService.signUpWithEmailAndPassword(event.email, event.password,
          displayName: event.displayName);
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithGoogleRequested(
      SignInWithGoogleRequested event, Emitter<AuthState> emit) async {
    // We optionally emit AuthLoading, but keeping the current state (or specialized UI state) helps avoid unmounting the login form if preferred.
    // In BLoC, we usually emit Loading. We'll stick to a standard approach.
    emit(AuthLoading());
    try {
      final userFromService = await authService.signInWithGoogle();
      if (userFromService == null) {
        emit(Unauthenticated()); // Reset back if cancelled
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authService.signOut();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordResetRequested(
      PasswordResetRequested event, Emitter<AuthState> emit) async {
    // Password reset doesn't change overall auth status unless we want a dedicated state.
    // Keeping it simple: log and let UI handle success overlay.
    // This could also be a separate cubit/bloc for the reset form.
    try {
      await authService.sendPasswordResetEmail(event.email);
    } on AuthException catch (e) {
      emit(AuthError(e.message));
      emit(
          Unauthenticated()); // Reset to unauthenticated so another attempt can be made
      rethrow;
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
      rethrow;
    }
  }
}
