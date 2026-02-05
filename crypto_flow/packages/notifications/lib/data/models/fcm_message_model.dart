import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import '../../domain/entities/app_notification.dart';

/// Model for FCM messages
class FCMMessageModel {
  final fcm.RemoteMessage message;

  FCMMessageModel(this.message);

  /// Convert to AppNotification entity
  AppNotification toEntity() {
    final notification = message.notification;
    final data = message.data;

    // Determine notification type from data
    final typeString = data['type'] as String? ?? 'system';
    final type = NotificationTypeX.fromJson(typeString);

    return AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: notification?.title ?? data['title'] as String? ?? 'CryptoWave',
      body: notification?.body ?? data['body'] as String? ?? '',
      data: data,
      receivedAt: message.sentTime ?? DateTime.now(),
      isRead: false,
    );
  }

  /// Create from RemoteMessage
  factory FCMMessageModel.fromRemoteMessage(fcm.RemoteMessage message) {
    return FCMMessageModel(message);
  }
}
