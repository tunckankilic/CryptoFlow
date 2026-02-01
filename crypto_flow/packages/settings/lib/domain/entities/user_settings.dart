import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// User settings entity
class UserSettings extends Equatable {
  final ThemeMode themeMode;
  final String currency;
  final String locale;
  final bool biometricEnabled;
  final bool lockOnBackground;
  final bool hasSeenOnboarding;

  const UserSettings({
    this.themeMode = ThemeMode.dark,
    this.currency = 'USD',
    this.locale = 'en',
    this.biometricEnabled = false,
    this.lockOnBackground = true,
    this.hasSeenOnboarding = false,
  });

  /// Default settings
  static const defaultSettings = UserSettings();

  /// Copy with method
  UserSettings copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? locale,
    bool? biometricEnabled,
    bool? lockOnBackground,
    bool? hasSeenOnboarding,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lockOnBackground: lockOnBackground ?? this.lockOnBackground,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        currency,
        locale,
        biometricEnabled,
        lockOnBackground,
        hasSeenOnboarding,
      ];
}
