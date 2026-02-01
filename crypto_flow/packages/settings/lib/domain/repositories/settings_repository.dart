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

  /// Update biometric enabled
  Future<Either<Failure, void>> updateBiometricEnabled(bool enabled);

  /// Update lock on background
  Future<Either<Failure, void>> updateLockOnBackground(bool enabled);

  /// Mark onboarding as seen
  Future<Either<Failure, void>> markOnboardingAsSeen();

  /// Watch settings changes
  Stream<UserSettings> watchSettings();
}
