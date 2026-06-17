import 'dart:async';

import 'package:auth/auth.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  final tUser = AppUser(
    uid: 'cognito-sub-123',
    email: 'tester@example.com',
    displayName: 'Tester',
    provider: AuthProvider.apple,
    createdAt: DateTime(2026, 1, 1),
    lastLoginAt: DateTime(2026, 1, 2),
  );

  // Builds a real AuthBloc wired to real use cases over the mock repository.
  AuthBloc buildBloc() => AuthBloc(
        signInWithApple: SignInWithApple(repository),
        signInAnonymously: SignInAnonymously(repository),
        signOut: SignOut(repository),
        getCurrentUser: GetCurrentUser(repository),
        watchAuthState: WatchAuthState(repository),
        deleteAccount: DeleteAccount(repository),
      );

  setUp(() {
    repository = MockAuthRepository();
    // Default: a quiet auth-state stream so the constructor subscription
    // does not emit during event-driven tests.
    when(() => repository.authStateChanges)
        .thenAnswer((_) => const Stream<AppUser?>.empty());
  });

  test('initial state is AuthInitial', () {
    expect(buildBloc().state, const AuthInitial());
  });

  group('AuthAppleSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] on success',
      build: () {
        when(() => repository.signInWithApple())
            .thenAnswer((_) async => Right(tUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthAppleSignInRequested()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when user cancels',
      build: () {
        when(() => repository.signInWithApple()).thenAnswer(
          (_) async => Left(AuthFailure(type: AuthFailureType.cancelled)),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthAppleSignInRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Error] on non-cancel failure',
      build: () {
        when(() => repository.signInWithApple()).thenAnswer(
          (_) async => Left(
            AuthFailure(type: AuthFailureType.unknown, message: 'nope'),
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthAppleSignInRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError('nope'),
      ],
    );
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] when a user exists',
      build: () {
        when(() => repository.getCurrentUser())
            .thenAnswer((_) async => Right(tUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when no user',
      build: () {
        when(() => repository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  group('AuthSignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] on success',
      build: () {
        when(() => repository.signOut())
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  group('AuthDeleteAccountRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] on success',
      build: () {
        when(() => repository.deleteAccount())
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthDeleteAccountRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits re-auth Error when requiresRecentLogin',
      build: () {
        when(() => repository.deleteAccount()).thenAnswer(
          (_) async =>
              Left(AuthFailure(type: AuthFailureType.requiresRecentLogin)),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthDeleteAccountRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError('Please sign in again to delete your account'),
      ],
    );
  });

  group('auth state stream subscription', () {
    // The constructor subscribes to repository.authStateChanges and turns
    // each emission into an AuthStateChanged event; verify that the bloc
    // reacts to the live stream end-to-end.
    blocTest<AuthBloc, AuthState>(
      'emits Authenticated then Unauthenticated as the stream emits',
      build: () {
        final controller = StreamController<AppUser?>();
        when(() => repository.authStateChanges)
            .thenAnswer((_) => controller.stream);
        addTearDown(controller.close);
        _streamController = controller;
        return buildBloc();
      },
      act: (_) async {
        _streamController.add(tUser);
        await Future<void>.delayed(Duration.zero);
        _streamController.add(null);
      },
      expect: () => [
        AuthAuthenticated(tUser),
        const AuthUnauthenticated(),
      ],
    );
  });
}

late StreamController<AppUser?> _streamController;
