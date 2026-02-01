import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/notification_settings.dart';
import '../models/notification_settings_model.dart';

/// Datasource for local notification settings storage
class NotificationSettingsLocalDatasource {
  static const String _boxName = 'notification_settings';
  Box<NotificationSettingsModel>? _box;

  /// Initialize Hive box
  Future<void> initialize() async {
    _box = await Hive.openBox<NotificationSettingsModel>(_boxName);
  }

  /// Get notification settings
  Future<NotificationSettings> getSettings() async {
    if (_box == null) await initialize();

    final model = _box!.get('settings');
    if (model == null) {
      // Return defaults if not found
      return NotificationSettings.defaults();
    }
    return model;
  }

  /// Save notification settings
  Future<void> saveSettings(NotificationSettings settings) async {
    if (_box == null) await initialize();

    final model = NotificationSettingsModel.fromEntity(settings);
    await _box!.put('settings', model);
  }

  /// Watch settings changes
  Stream<NotificationSettings> watchSettings() {
    return _box!.watch(key: 'settings').map((event) {
      final model = event.value as NotificationSettingsModel?;
      return model ?? NotificationSettings.defaults();
    });
  }
}
