import 'package:flutter_test/flutter_test.dart';
import 'package:notifications/domain/entities/notification_settings.dart';
import 'package:notifications/domain/entities/app_notification.dart';

void main() {
  group('NotificationSettings', () {
    test('should create default settings with expected values', () {
      final settings = NotificationSettings.defaults();

      expect(settings.priceAlerts, true);
      expect(settings.portfolioAlerts, true);
      expect(settings.newsAlerts, false);
      expect(settings.marketUpdates, false);
      expect(settings.soundEnabled, true);
      expect(settings.vibrationEnabled, true);
      expect(settings.fcmToken, null);
    });

    test('should support copyWith', () {
      final settings = NotificationSettings.defaults();
      final updated = settings.copyWith(
        priceAlerts: false,
        soundEnabled: false,
        fcmToken: 'test-token',
      );

      expect(updated.priceAlerts, false);
      expect(updated.portfolioAlerts, true); // unchanged
      expect(updated.soundEnabled, false);
      expect(updated.fcmToken, 'test-token');
    });

    test('should be equatable', () {
      final settings1 = NotificationSettings.defaults();
      final settings2 = NotificationSettings.defaults();

      expect(settings1, equals(settings2));
    });
  });

  group('AppNotification', () {
    test('should create notification with required fields', () {
      final now = DateTime.now();
      final notification = AppNotification(
        id: 'test-id',
        type: NotificationType.priceAlert,
        title: 'BTC Alert',
        body: 'BTC reached \$50,000',
        receivedAt: now,
        isRead: false,
      );

      expect(notification.id, 'test-id');
      expect(notification.type, NotificationType.priceAlert);
      expect(notification.title, 'BTC Alert');
      expect(notification.body, 'BTC reached \$50,000');
      expect(notification.isRead, false);
      expect(notification.data, null);
    });

    test('should support all notification types', () {
      expect(NotificationType.values.length, 5);
      expect(NotificationType.values, contains(NotificationType.priceAlert));
      expect(
          NotificationType.values, contains(NotificationType.portfolioChange));
      expect(NotificationType.values, contains(NotificationType.news));
      expect(NotificationType.values, contains(NotificationType.marketUpdate));
      expect(NotificationType.values, contains(NotificationType.system));
    });
  });
}
