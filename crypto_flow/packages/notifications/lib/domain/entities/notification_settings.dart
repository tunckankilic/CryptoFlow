import 'package:equatable/equatable.dart';

/// Settings for push notifications
class NotificationSettings extends Equatable {
  /// Whether price alert notifications are enabled
  final bool priceAlerts;

  /// Whether portfolio change notifications are enabled
  final bool portfolioAlerts;

  /// Whether news notifications are enabled
  final bool newsAlerts;

  /// Whether market update notifications are enabled
  final bool marketUpdates;

  /// Whether notification sound is enabled
  final bool soundEnabled;

  /// Whether notification vibration is enabled
  final bool vibrationEnabled;

  /// FCM token for this device
  final String? fcmToken;

  const NotificationSettings({
    required this.priceAlerts,
    required this.portfolioAlerts,
    required this.newsAlerts,
    required this.marketUpdates,
    required this.soundEnabled,
    required this.vibrationEnabled,
    this.fcmToken,
  });

  /// Default notification settings
  factory NotificationSettings.defaults() {
    return const NotificationSettings(
      priceAlerts: true,
      portfolioAlerts: true,
      newsAlerts: false,
      marketUpdates: false,
      soundEnabled: true,
      vibrationEnabled: true,
      fcmToken: null,
    );
  }

  /// Creates a copy with the given fields replaced
  NotificationSettings copyWith({
    bool? priceAlerts,
    bool? portfolioAlerts,
    bool? newsAlerts,
    bool? marketUpdates,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? fcmToken,
  }) {
    return NotificationSettings(
      priceAlerts: priceAlerts ?? this.priceAlerts,
      portfolioAlerts: portfolioAlerts ?? this.portfolioAlerts,
      newsAlerts: newsAlerts ?? this.newsAlerts,
      marketUpdates: marketUpdates ?? this.marketUpdates,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  List<Object?> get props => [
        priceAlerts,
        portfolioAlerts,
        newsAlerts,
        marketUpdates,
        soundEnabled,
        vibrationEnabled,
        fcmToken,
      ];
}
