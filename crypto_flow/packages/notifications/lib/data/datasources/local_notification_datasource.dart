import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/entities/app_notification.dart';

/// Datasource for local notifications
class LocalNotificationDatasource {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationDatasource() : _plugin = FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  Future<void> initialize() async {
    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We handle this via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);

    // Create Android notification channels
    await _createNotificationChannels();
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Price alerts channel (high priority)
    const priceAlertsChannel = AndroidNotificationChannel(
      'price_alerts',
      'Price Alerts',
      description: 'Notifications when price targets are reached',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Portfolio channel (default priority)
    const portfolioChannel = AndroidNotificationChannel(
      'portfolio',
      'Portfolio Updates',
      description: 'Notifications about portfolio changes',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    // News channel (low priority)
    const newsChannel = AndroidNotificationChannel(
      'news',
      'News',
      description: 'Crypto news notifications',
      importance: Importance.low,
      playSound: false,
    );

    // System channel (default priority)
    const systemChannel = AndroidNotificationChannel(
      'system',
      'System',
      description: 'System notifications',
      importance: Importance.defaultImportance,
    );

    // Register channels
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(priceAlertsChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(portfolioChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(newsChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(systemChannel);
  }

  /// Show a notification
  Future<void> showNotification(AppNotification notification) async {
    final channelId = _getChannelIdForType(notification.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: notification.data.toString(),
    );
  }

  /// Show a price alert notification
  Future<void> showPriceAlertNotification({
    required String symbol,
    required double currentPrice,
    required double targetPrice,
    required String alertType,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'price_alerts',
      'Price Alerts',
      channelDescription: 'Notifications when price targets are reached',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = '🚀 $symbol Price Alert';
    final body =
        '$symbol reached \$${currentPrice.toStringAsFixed(2)}! ($alertType \$${targetPrice.toStringAsFixed(2)})';

    await _plugin.show(
      id: symbol.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: symbol,
    );
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Get channel ID for notification type
  String _getChannelIdForType(NotificationType type) {
    switch (type) {
      case NotificationType.priceAlert:
        return 'price_alerts';
      case NotificationType.portfolioChange:
        return 'portfolio';
      case NotificationType.news:
        return 'news';
      case NotificationType.marketUpdate:
      case NotificationType.system:
        return 'system';
    }
  }
}
