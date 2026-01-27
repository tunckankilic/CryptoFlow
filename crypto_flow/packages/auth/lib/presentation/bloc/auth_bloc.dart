import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../../domain/usecases/delete_account.dart';
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
  final DeleteAccount _deleteAccount;

  StreamSubscription<AppUser?>? _authStateSubscription;

  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required SignInWithApple signInWithApple,
    required SignInAnonymously signInAnonymously,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
    required WatchAuthState watchAuthState,
    required DeleteAccount deleteAccount,
  })  : _signInWithGoogle = signInWithGoogle,
        _signInWithApple = signInWithApple,
        _signInAnonymously = signInAnonymously,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        _watchAuthState = watchAuthState,
        _deleteAccount = deleteAccount,
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

    // Delete account from Firebase
    final result = await _deleteAccount(const NoParams());

    await result.fold(
      (failure) async {
        if (failure is AuthFailure &&
            failure.type == AuthFailureType.requiresRecentLogin) {
          emit(const AuthError('Please sign in again to delete your account'));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (_) async {
        // Clear all local data
        await _clearLocalData();
        emit(const AuthUnauthenticated());
      },
    );
  }

  /// Clear all local Hive data when account is deleted
  Future<void> _clearLocalData() async {
    try {
      // Close and delete all Hive boxes
      if (Hive.isBoxOpen('watchlist')) await Hive.box('watchlist').clear();
      if (Hive.isBoxOpen('portfolio')) await Hive.box('portfolio').clear();
      if (Hive.isBoxOpen('transactions'))
        await Hive.box('transactions').clear();
      if (Hive.isBoxOpen('alerts')) await Hive.box('alerts').clear();
      if (Hive.isBoxOpen('settings')) await Hive.box('settings').clear();
    } catch (_) {
      // Ignore errors during cleanup
    }
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
