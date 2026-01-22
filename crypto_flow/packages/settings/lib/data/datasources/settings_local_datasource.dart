import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:core/error/exceptions.dart';
import '../models/user_settings_model.dart';

/// Local data source for settings using Hive
abstract class SettingsLocalDataSource {
  /// Get current settings
  Future<UserSettingsModel> getSettings();

  /// Update theme mode
  Future<void> updateTheme(ThemeMode themeMode);

  /// Update currency
  Future<void> updateCurrency(String currency);

  /// Update locale
  Future<void> updateLocale(String locale);

  /// Watch settings changes
  Stream<UserSettingsModel> watchSettings();
}

/// Hive implementation of settings local data source
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'user_settings';

  Box<UserSettingsModel>? _box;

  /// Initialize the data source (call in DI setup)
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(UserSettingsModelAdapter());
    }
    _box = await Hive.openBox<UserSettingsModel>(_boxName);
  }

  Box<UserSettingsModel> get _settingsBox {
    if (_box == null) {
      throw CacheException(message: 'Settings box not initialized');
    }
    return _box!;
  }

  @override
  Future<UserSettingsModel> getSettings() async {
    final settings = _settingsBox.get(_settingsKey);
    return settings ?? UserSettingsModel.defaultSettings;
  }

  @override
  Future<void> updateTheme(ThemeMode themeMode) async {
    final current = await getSettings();
    final updated = UserSettingsModel(
      themeModeIndex: themeMode.index,
      currency: current.currency,
      locale: current.locale,
    );
    await _settingsBox.put(_settingsKey, updated);
  }

  @override
  Future<void> updateCurrency(String currency) async {
    final current = await getSettings();
    final updated = UserSettingsModel(
      themeModeIndex: current.themeModeIndex,
      currency: currency,
      locale: current.locale,
    );
    await _settingsBox.put(_settingsKey, updated);
  }

  @override
  Future<void> updateLocale(String locale) async {
    final current = await getSettings();
    final updated = UserSettingsModel(
      themeModeIndex: current.themeModeIndex,
      currency: current.currency,
      locale: locale,
    );
    await _settingsBox.put(_settingsKey, updated);
  }

  @override
  Stream<UserSettingsModel> watchSettings() {
    return _settingsBox.watch(key: _settingsKey).map((event) =>
        event.value as UserSettingsModel? ?? UserSettingsModel.defaultSettings);
  }
}
