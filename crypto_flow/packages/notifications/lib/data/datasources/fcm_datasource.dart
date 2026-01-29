import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import '../../domain/entities/notification_settings.dart' as domain;
import '../models/fcm_message_model.dart';

/// Datasource for Firebase Cloud Messaging operations
class FCMDatasource {
  final fcm.FirebaseMessaging _messaging;

  // Stream controllers for messages
  final _messageController = StreamController<FCMMessageModel>.broadcast();
  final _messageOpenedAppController =
      StreamController<FCMMessageModel>.broadcast();

  FCMDatasource(this._messaging) {
    _setupMessageHandlers();
  }

  /// Initialize FCM
  Future<void> initialize() async {
    // Set foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Request notification permission
  Future<domain.NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final authorized =
        settings.authorizationStatus == fcm.AuthorizationStatus.authorized ||
            settings.authorizationStatus == fcm.AuthorizationStatus.provisional;

    return domain.NotificationSettings(
      priceAlerts: authorized,
      portfolioAlerts: authorized,
      newsAlerts: false,
      marketUpdates: false,
      soundEnabled: true,
      vibrationEnabled: true,
      fcmToken: authorized ? await getToken() : null,
    );
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Token refresh stream
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Foreground message stream
  Stream<FCMMessageModel> get onMessage => _messageController.stream;

  /// Message opened app stream
  Stream<FCMMessageModel> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    fcm.FirebaseMessaging.onMessage.listen((fcm.RemoteMessage message) {
      _messageController.add(FCMMessageModel.fromRemoteMessage(message));
    });

    // Handle messages that opened the app
    fcm.FirebaseMessaging.onMessageOpenedApp
        .listen((fcm.RemoteMessage message) {
      _messageOpenedAppController
          .add(FCMMessageModel.fromRemoteMessage(message));
    });
  }

  /// Cleanup
  void dispose() {
    _messageController.close();
    _messageOpenedAppController.close();
  }
}
