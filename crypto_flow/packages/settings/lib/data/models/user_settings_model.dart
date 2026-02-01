import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/user_settings.dart';

part 'user_settings_model.g.dart';

/// Hive model for user settings
@HiveType(typeId: 10)
class UserSettingsModel extends HiveObject {
  @HiveField(0)
  final int themeModeIndex;

  @HiveField(1)
  final String currency;

  @HiveField(2)
  final String locale;

  @HiveField(3)
  final bool biometricEnabled;

  @HiveField(4)
  final bool lockOnBackground;

  @HiveField(5)
  final bool hasSeenOnboarding;

  UserSettingsModel({
    required this.themeModeIndex,
    required this.currency,
    required this.locale,
    this.biometricEnabled = false,
    this.lockOnBackground = true,
    this.hasSeenOnboarding = false,
  });

  /// Create from entity
  factory UserSettingsModel.fromEntity(UserSettings settings) {
    return UserSettingsModel(
      themeModeIndex: settings.themeMode.index,
      currency: settings.currency,
      locale: settings.locale,
      biometricEnabled: settings.biometricEnabled,
      lockOnBackground: settings.lockOnBackground,
      hasSeenOnboarding: settings.hasSeenOnboarding,
    );
  }

  /// Convert to entity
  UserSettings toEntity() {
    return UserSettings(
      themeMode: ThemeMode.values[themeModeIndex],
      currency: currency,
      locale: locale,
      biometricEnabled: biometricEnabled,
      lockOnBackground: lockOnBackground,
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  /// Copy with method
  UserSettingsModel copyWith({
    int? themeModeIndex,
    String? currency,
    String? locale,
    bool? biometricEnabled,
    bool? lockOnBackground,
    bool? hasSeenOnboarding,
  }) {
    return UserSettingsModel(
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lockOnBackground: lockOnBackground ?? this.lockOnBackground,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  /// Default settings model
  static UserSettingsModel get defaultSettings => UserSettingsModel(
        themeModeIndex: ThemeMode.dark.index,
        currency: 'USD',
        locale: 'en',
        biometricEnabled: false,
        lockOnBackground: true,
        hasSeenOnboarding: false,
      );
}
