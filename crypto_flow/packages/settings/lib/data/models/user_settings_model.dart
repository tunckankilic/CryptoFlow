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

  UserSettingsModel({
    required this.themeModeIndex,
    required this.currency,
    required this.locale,
  });

  /// Create from entity
  factory UserSettingsModel.fromEntity(UserSettings settings) {
    return UserSettingsModel(
      themeModeIndex: settings.themeMode.index,
      currency: settings.currency,
      locale: settings.locale,
    );
  }

  /// Convert to entity
  UserSettings toEntity() {
    return UserSettings(
      themeMode: ThemeMode.values[themeModeIndex],
      currency: currency,
      locale: locale,
    );
  }

  /// Default settings model
  static UserSettingsModel get defaultSettings => UserSettingsModel(
        themeModeIndex: ThemeMode.dark.index,
        currency: 'USD',
        locale: 'en',
      );
}
