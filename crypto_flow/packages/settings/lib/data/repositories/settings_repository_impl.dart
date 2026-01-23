import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:core/error/failures.dart';
import 'package:core/error/exceptions.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Implementation of settings repository
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserSettings>> getSettings() async {
    try {
      final model = await localDataSource.getSettings();
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTheme(ThemeMode themeMode) async {
    try {
      await localDataSource.updateTheme(themeMode);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCurrency(String currency) async {
    try {
      await localDataSource.updateCurrency(currency);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocale(String locale) async {
    try {
      await localDataSource.updateLocale(locale);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserSettings> watchSettings() {
    return localDataSource.watchSettings().map((model) => model.toEntity());
  }
}
