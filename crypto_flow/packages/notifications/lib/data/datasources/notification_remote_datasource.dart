import 'dart:io' show Platform;

import 'package:core/core.dart';

/// Remote data source for notification-related AWS backend calls.
///
/// Handles device token registration with SNS and syncing notification
/// preferences to the backend.
abstract class NotificationRemoteDataSource {
  /// Register a push-notification device token with the backend.
  Future<void> registerDevice({
    required String deviceId,
    required String token,
  });

  /// Un-register a device token from the backend.
  Future<void> unregisterDevice({required String deviceId});

  /// Fetch notification preferences from the backend.
  Future<Map<String, bool>> getPreferences();

  /// Update notification preferences on the backend.
  Future<void> updatePreferences(Map<String, bool> prefs);
}

/// Implementation backed by the CryptoFlow REST API.
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final AwsApiClient _api;
  NotificationRemoteDataSourceImpl({required AwsApiClient apiClient})
      : _api = apiClient;

  @override
  Future<void> registerDevice({
    required String deviceId,
    required String token,
  }) async {
    await _api.post(AwsEndpoints.registerDevice, data: {
      'deviceId': deviceId,
      'token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
    });
  }

  @override
  Future<void> unregisterDevice({required String deviceId}) async {
    await _api.delete(AwsEndpoints.unregisterDevice, data: {
      'deviceId': deviceId,
    });
  }

  @override
  Future<Map<String, bool>> getPreferences() async {
    final response = await _api.get(AwsEndpoints.notificationPreferences);
    final data = response.data as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, v as bool));
  }

  @override
  Future<void> updatePreferences(Map<String, bool> prefs) async {
    await _api.put(AwsEndpoints.notificationPreferences, data: prefs);
  }
}
