import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/notification_settings.dart' as domain;
import '../models/push_message_model.dart';

/// Native bridge for APNs token + push delivery on iOS.
///
/// The Swift side (AppDelegate) registers with APNs, forwards the device
/// token here over `cryptoflow/apns`, and posts foreground / cold-launch
/// payloads. Permission requests are delegated to
/// `flutter_local_notifications` which uses
/// `UNUserNotificationCenter` under the hood (same dialog as APNs).
class ApnsDatasource {
  static const _channel = MethodChannel('cryptoflow/apns');

  ApnsDatasource(this._localNotifications) {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  final FlutterLocalNotificationsPlugin _localNotifications;

  final _messageController = StreamController<PushMessageModel>.broadcast();
  final _messageOpenedAppController =
      StreamController<PushMessageModel>.broadcast();
  final _tokenRefreshController = StreamController<String>.broadcast();

  String? _cachedToken;
  PushMessageModel? _initialMessage;

  Stream<PushMessageModel> get onMessage => _messageController.stream;
  Stream<PushMessageModel> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  Future<void> initialize() async {
    if (!Platform.isIOS) return;
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    try {
      _cachedToken = await _channel.invokeMethod<String>('getApnsToken');
    } on PlatformException {
      _cachedToken = null;
    }
  }

  Future<domain.NotificationSettings> requestPermission() async {
    final iosImpl = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;

    final token = granted ? await getToken() : null;
    return domain.NotificationSettings(
      priceAlerts: granted,
      portfolioAlerts: granted,
      newsAlerts: false,
      marketUpdates: false,
      soundEnabled: true,
      vibrationEnabled: true,
      pushToken: token,
    );
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    if (!Platform.isIOS) return null;
    try {
      _cachedToken = await _channel.invokeMethod<String>('getApnsToken');
    } on PlatformException {
      _cachedToken = null;
    }
    return _cachedToken;
  }

  Future<PushMessageModel?> getInitialMessage() async => _initialMessage;

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTokenReceived':
        final token = call.arguments as String?;
        if (token != null && token.isNotEmpty) {
          _cachedToken = token;
          _tokenRefreshController.add(token);
        }
        return null;
      case 'onForegroundMessage':
        final payload = _coerceMap(call.arguments);
        if (payload != null) {
          _messageController.add(PushMessageModel(payload));
        }
        return null;
      case 'onMessageOpenedApp':
        final payload = _coerceMap(call.arguments);
        if (payload != null) {
          _messageOpenedAppController.add(PushMessageModel(payload));
        }
        return null;
      case 'onLaunchMessage':
        final payload = _coerceMap(call.arguments);
        if (payload != null) {
          _initialMessage = PushMessageModel(payload);
        }
        return null;
    }
    return null;
  }

  Map<String, dynamic>? _coerceMap(Object? raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  void dispose() {
    _messageController.close();
    _messageOpenedAppController.close();
    _tokenRefreshController.close();
  }
}
