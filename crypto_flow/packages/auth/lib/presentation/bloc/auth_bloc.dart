import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/watch_auth_state.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for handling authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithApple _signInWithApple;
  final SignInAnonymously _signInAnonymously;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final WatchAuthState _watchAuthState;

  StreamSubscription<AppUser?>? _authStateSubscription;

  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required SignInWithApple signInWithApple,
    required SignInAnonymously signInAnonymously,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
    required WatchAuthState watchAuthState,
  })  : _signInWithGoogle = signInWithGoogle,
        _signInWithApple = signInWithApple,
        _signInAnonymously = signInAnonymously,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        _watchAuthState = watchAuthState,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthAppleSignInRequested>(_onAppleSignInRequested);
    on<AuthAnonymousSignInRequested>(_onAnonymousSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Subscribe to auth state changes
    _authStateSubscription = _watchAuthState().listen((user) {
      add(AuthStateChanged(user));
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _getCurrentUser(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signInWithGoogle(const NoParams());

    result.fold(
      (failure) {
        if (failure is AuthFailure &&
            failure.type == AuthFailureType.cancelled) {
          // User cancelled, return to unauthenticated
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAppleSignInRequested(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signInWithApple(const NoParams());

    result.fold(
      (failure) {
        if (failure is AuthFailure &&
            failure.type == AuthFailureType.cancelled) {
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAnonymousSignInRequested(
    AuthAnonymousSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signInAnonymously(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signOut(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Note: Delete account should be implemented in repository
    // For now, just sign out
    final result = await _signOut(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null && event.user is AppUser) {
      emit(AuthAuthenticated(event.user as AppUser));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
