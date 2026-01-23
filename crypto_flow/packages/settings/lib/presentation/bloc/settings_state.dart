import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user_settings.dart';

/// Base class for settings states
abstract class SettingsState extends Equatable {
  const SettingsState();

  /// Get current theme mode (defaults to dark)
  ThemeMode get themeMode => ThemeMode.dark;

  @override
  List<Object?> get props => [];
}

/// Initial state
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Loading state
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Loaded state with settings
class SettingsLoaded extends SettingsState {
  final UserSettings settings;

  const SettingsLoaded({required this.settings});

  @override
  ThemeMode get themeMode => settings.themeMode;

  String get currency => settings.currency;

  String get locale => settings.locale;

  @override
  List<Object?> get props => [settings];

  SettingsLoaded copyWith({UserSettings? settings}) {
    return SettingsLoaded(settings: settings ?? this.settings);
  }
}

/// Error state
class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}
