import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base class for settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings event
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Update theme event
class UpdateThemeEvent extends SettingsEvent {
  final ThemeMode themeMode;

  const UpdateThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Update currency event
class UpdateCurrencyEvent extends SettingsEvent {
  final String currency;

  const UpdateCurrencyEvent(this.currency);

  @override
  List<Object?> get props => [currency];
}

/// Settings updated from storage
class SettingsUpdated extends SettingsEvent {
  const SettingsUpdated();
}
