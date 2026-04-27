import 'package:dartz/dartz.dart';
import 'package:core/core.dart' hide AuthException;

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

/// Implementation of [AuthRepository] backed by an injected [AuthDataSource].
///
/// The datasource is wired up in `lib/di/auth_module.dart` and is currently
/// always [CognitoAuthDataSource] (AWS Amplify Auth).
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<AppUser?> get authStateChanges => _dataSource.authStateChanges;

  @override
  Future<Either<Failure, AppUser>> signInWithApple() async {
    try {
      final user = await _dataSource.signInWithApple();
      return Right(user);
    } on AuthException catch (e) {
      if (e.code == 'cancelled') {
        return Left(AuthFailure(
          type: AuthFailureType.cancelled,
          message: e.message,
        ));
      }
      return Left(AuthFailure(
        type: AuthFailureType.unknown,
        message: e.message,
      ));
    } catch (e) {
      return Left(AuthFailure(
        type: AuthFailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInAnonymously() async {
    try {
      final user = await _dataSource.signInAnonymously();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        type: AuthFailureType.unknown,
        message: e.message,
      ));
    } catch (e) {
      return Left(AuthFailure(
        type: AuthFailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        type: AuthFailureType.unknown,
        message: e.message,
      ));
    } catch (e) {
      return Left(AuthFailure(
        type: AuthFailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(
        type: AuthFailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _dataSource.deleteAccount();
      return const Right(null);
    } on AuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return Left(AuthFailure(
          type: AuthFailureType.requiresRecentLogin,
          message: e.message,
        ));
      }
      return Left(AuthFailure(
        type: AuthFailureType.unknown,
        message: e.message,
      ));
    } catch (e) {
      return Left(AuthFailure(
        type: AuthFailureType.unknown,
        message: e.toString(),
      ));
    }
  }
}
