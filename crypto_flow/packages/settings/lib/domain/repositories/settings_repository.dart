import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:core/error/failures.dart';
import '../entities/user_settings.dart';

/// Abstract repository for user settings
abstract class SettingsRepository {
  /// Get current user settings
  Future<Either<Failure, UserSettings>> getSettings();

  /// Update theme mode
  Future<Either<Failure, void>> updateTheme(ThemeMode themeMode);

  /// Update currency preference
  Future<Either<Failure, void>> updateCurrency(String currency);

  /// Update locale
  Future<Either<Failure, void>> updateLocale(String locale);

  /// Watch settings changes
  Stream<UserSettings> watchSettings();
}
