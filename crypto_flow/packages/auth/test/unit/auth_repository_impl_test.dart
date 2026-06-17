import 'package:auth/auth.dart';
import 'package:core/core.dart' hide AuthException;
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  late MockAuthDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = MockAuthDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  final tUser = AppUserModel(
    uid: 'cognito-sub-123',
    email: 'tester@example.com',
    displayName: 'Tester',
    provider: AuthProvider.apple,
    createdAt: DateTime(2026, 1, 1),
    lastLoginAt: DateTime(2026, 1, 2),
  );

  group('signInWithApple', () {
    test('returns Right(user) when datasource succeeds', () async {
      when(() => dataSource.signInWithApple())
          .thenAnswer((_) async => tUser);

      final result = await repository.signInWithApple();

      expect(result, Right<Failure, AppUser>(tUser));
      verify(() => dataSource.signInWithApple()).called(1);
    });

    test('maps AuthException(cancelled) to AuthFailure.cancelled', () async {
      when(() => dataSource.signInWithApple()).thenThrow(
        const AuthException('Sign in was cancelled', code: 'cancelled'),
      );

      final result = await repository.signInWithApple();

      final failure = result.fold((l) => l, (_) => null);
      expect(failure, isA<AuthFailure>());
      expect((failure as AuthFailure).type, AuthFailureType.cancelled);
      expect(failure.message, 'Sign in was cancelled');
    });

    test('maps non-cancelled AuthException to AuthFailure.unknown', () async {
      when(() => dataSource.signInWithApple()).thenThrow(
        const AuthException('Sign in failed', code: 'not-authorized'),
      );

      final result = await repository.signInWithApple();

      final failure = result.fold((l) => l, (_) => null) as AuthFailure;
      expect(failure.type, AuthFailureType.unknown);
      expect(failure.message, 'Sign in failed');
    });

    test('maps unexpected error to AuthFailure.unknown', () async {
      when(() => dataSource.signInWithApple())
          .thenThrow(Exception('boom'));

      final result = await repository.signInWithApple();

      final failure = result.fold((l) => l, (_) => null) as AuthFailure;
      expect(failure.type, AuthFailureType.unknown);
    });
  });

  group('signOut', () {
    test('returns Right(null) on success', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right<Failure, void>(null));
      verify(() => dataSource.signOut()).called(1);
    });

    test('maps AuthException to AuthFailure.unknown', () async {
      when(() => dataSource.signOut())
          .thenThrow(const AuthException('sign out failed'));

      final result = await repository.signOut();

      final failure = result.fold((l) => l, (_) => null) as AuthFailure;
      expect(failure.type, AuthFailureType.unknown);
      expect(failure.message, 'sign out failed');
    });
  });

  group('getCurrentUser', () {
    test('returns Right(user) when signed in', () async {
      when(() => dataSource.getCurrentUser())
          .thenAnswer((_) async => tUser);

      final result = await repository.getCurrentUser();

      expect(result, Right<Failure, AppUser?>(tUser));
    });

    test('returns Right(null) when signed out', () async {
      when(() => dataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result, const Right<Failure, AppUser?>(null));
    });

    test('maps thrown error to AuthFailure.unknown', () async {
      when(() => dataSource.getCurrentUser())
          .thenThrow(const AuthException('fetch failed'));

      final result = await repository.getCurrentUser();

      final failure = result.fold((l) => l, (_) => null) as AuthFailure;
      expect(failure.type, AuthFailureType.unknown);
    });
  });

  group('deleteAccount', () {
    test('returns Right(null) on success', () async {
      when(() => dataSource.deleteAccount()).thenAnswer((_) async {});

      final result = await repository.deleteAccount();

      expect(result, const Right<Failure, void>(null));
    });

    test('maps requires-recent-login to AuthFailure.requiresRecentLogin',
        () async {
      when(() => dataSource.deleteAccount()).thenThrow(
        const AuthException('re-auth needed', code: 'requires-recent-login'),
      );

      final result = await repository.deleteAccount();

      final failure = result.fold((l) => l, (_) => null) as AuthFailure;
      expect(failure.type, AuthFailureType.requiresRecentLogin);
    });

    test('maps other AuthException to AuthFailure.unknown', () async {
      when(() => dataSource.deleteAccount())
          .thenThrow(const AuthException('delete failed', code: 'unknown'));

      final result = await repository.deleteAccount();

      final failure = result.fold((l) => l, (_) => null) as AuthFailure;
      expect(failure.type, AuthFailureType.unknown);
    });
  });

  group('authStateChanges', () {
    test('forwards the datasource stream', () {
      final stream = Stream<AppUserModel?>.fromIterable([tUser, null]);
      when(() => dataSource.authStateChanges).thenAnswer((_) => stream);

      expect(
        repository.authStateChanges,
        emitsInOrder([tUser, null]),
      );
    });
  });
}
