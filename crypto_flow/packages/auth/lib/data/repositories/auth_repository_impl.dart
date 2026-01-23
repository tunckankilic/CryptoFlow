import 'package:dartz/dartz.dart';
import 'package:core/core.dart' hide AuthException;

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/app_user_model.dart';

/// Implementation of AuthRepository using Firebase
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<AppUser?> get authStateChanges {
    return _dataSource.authStateChanges.map((user) {
      if (user == null) return null;
      return AppUserModel.fromFirebaseUser(user);
    });
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final user = await _dataSource.signInWithGoogle();
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
      final user = _dataSource.getCurrentUser();
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
