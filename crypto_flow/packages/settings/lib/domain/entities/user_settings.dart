import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// User settings entity
class UserSettings extends Equatable {
  final ThemeMode themeMode;
  final String currency;
  final String locale;

  const UserSettings({
    this.themeMode = ThemeMode.dark,
    this.currency = 'USD',
    this.locale = 'en',
  });

  /// Default settings
  static const defaultSettings = UserSettings();

  /// Copy with method
  UserSettings copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? locale,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, currency, locale];
}
