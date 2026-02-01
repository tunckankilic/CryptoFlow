import 'package:hive/hive.dart';
import '../../domain/entities/notification_settings.dart';

part 'notification_settings_model.g.dart';

/// Model for notification settings with Hive persistence
@HiveType(typeId: 13)
class NotificationSettingsModel extends NotificationSettings {
  @HiveField(0)
  @override
  final bool priceAlerts;

  @HiveField(1)
  @override
  final bool portfolioAlerts;

  @HiveField(2)
  @override
  final bool newsAlerts;

  @HiveField(3)
  @override
  final bool marketUpdates;

  @HiveField(4)
  @override
  final bool soundEnabled;

  @HiveField(5)
  @override
  final bool vibrationEnabled;

  @HiveField(6)
  @override
  final String? fcmToken;

  const NotificationSettingsModel({
    required this.priceAlerts,
    required this.portfolioAlerts,
    required this.newsAlerts,
    required this.marketUpdates,
    required this.soundEnabled,
    required this.vibrationEnabled,
    this.fcmToken,
  }) : super(
          priceAlerts: priceAlerts,
          portfolioAlerts: portfolioAlerts,
          newsAlerts: newsAlerts,
          marketUpdates: marketUpdates,
          soundEnabled: soundEnabled,
          vibrationEnabled: vibrationEnabled,
          fcmToken: fcmToken,
        );

  /// From domain entity
  factory NotificationSettingsModel.fromEntity(NotificationSettings entity) {
    return NotificationSettingsModel(
      priceAlerts: entity.priceAlerts,
      portfolioAlerts: entity.portfolioAlerts,
      newsAlerts: entity.newsAlerts,
      marketUpdates: entity.marketUpdates,
      soundEnabled: entity.soundEnabled,
      vibrationEnabled: entity.vibrationEnabled,
      fcmToken: entity.fcmToken,
    );
  }

  /// From JSON
  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      priceAlerts: json['priceAlerts'] as bool? ?? true,
      portfolioAlerts: json['portfolioAlerts'] as bool? ?? true,
      newsAlerts: json['newsAlerts'] as bool? ?? false,
      marketUpdates: json['marketUpdates'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      fcmToken: json['fcmToken'] as String?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'priceAlerts': priceAlerts,
      'portfolioAlerts': portfolioAlerts,
      'newsAlerts': newsAlerts,
      'marketUpdates': marketUpdates,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'fcmToken': fcmToken,
    };
  }

  /// Create copy with updated fields
  @override
  NotificationSettingsModel copyWith({
    bool? priceAlerts,
    bool? portfolioAlerts,
    bool? newsAlerts,
    bool? marketUpdates,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? fcmToken,
  }) {
    return NotificationSettingsModel(
      priceAlerts: priceAlerts ?? this.priceAlerts,
      portfolioAlerts: portfolioAlerts ?? this.portfolioAlerts,
      newsAlerts: newsAlerts ?? this.newsAlerts,
      marketUpdates: marketUpdates ?? this.marketUpdates,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
