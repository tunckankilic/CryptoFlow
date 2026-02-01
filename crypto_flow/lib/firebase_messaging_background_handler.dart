import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level function to handle background FCM messages.
///
/// This function is called when the app is in background or terminated state.
/// It MUST be a top-level function (not a class method) for iOS to work correctly.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase (required for background execution)
  await Firebase.initializeApp();

  // Show local notification for the received message
  await _showBackgroundNotification(message);
}

/// Show a local notification for the background message
Future<void> _showBackgroundNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  final plugin = FlutterLocalNotificationsPlugin();

  // Initialize with minimal settings for background
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  // Using named parameter 'settings:' as per flutter_local_notifications v20 API
  await plugin.initialize(settings: initSettings);

  // Show the notification with iOS details
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const notificationDetails = NotificationDetails(iOS: iosDetails);

  // Using named parameters as per flutter_local_notifications v20 API
  await plugin.show(
    id: message.hashCode,
    title: notification.title ?? 'CryptoFlow',
    body: notification.body ?? '',
    notificationDetails: notificationDetails,
    payload: message.data.toString(),
  );
}
