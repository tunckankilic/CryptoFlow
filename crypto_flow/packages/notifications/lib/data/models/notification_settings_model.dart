// ignore_for_file: overridden_fields

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
  final String? pushToken;

  @HiveField(7, defaultValue: false)
  @override
  final bool whaleAlerts;

  @HiveField(8, defaultValue: false)
  @override
  final bool fundingRateAlerts;

  @HiveField(9, defaultValue: false)
  @override
  final bool sentimentAlerts;

  const NotificationSettingsModel({
    required this.priceAlerts,
    required this.portfolioAlerts,
    required this.newsAlerts,
    required this.marketUpdates,
    required this.soundEnabled,
    required this.vibrationEnabled,
    this.whaleAlerts = false,
    this.fundingRateAlerts = false,
    this.sentimentAlerts = false,
    this.pushToken,
  }) : super(
          priceAlerts: priceAlerts,
          portfolioAlerts: portfolioAlerts,
          newsAlerts: newsAlerts,
          marketUpdates: marketUpdates,
          soundEnabled: soundEnabled,
          vibrationEnabled: vibrationEnabled,
          whaleAlerts: whaleAlerts,
          fundingRateAlerts: fundingRateAlerts,
          sentimentAlerts: sentimentAlerts,
          pushToken: pushToken,
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
      whaleAlerts: entity.whaleAlerts,
      fundingRateAlerts: entity.fundingRateAlerts,
      sentimentAlerts: entity.sentimentAlerts,
      pushToken: entity.pushToken,
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
      whaleAlerts: json['whaleAlerts'] as bool? ?? false,
      fundingRateAlerts: json['fundingRateAlerts'] as bool? ?? false,
      sentimentAlerts: json['sentimentAlerts'] as bool? ?? false,
      pushToken: json['pushToken'] as String?,
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
      'whaleAlerts': whaleAlerts,
      'fundingRateAlerts': fundingRateAlerts,
      'sentimentAlerts': sentimentAlerts,
      'pushToken': pushToken,
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
    bool? whaleAlerts,
    bool? fundingRateAlerts,
    bool? sentimentAlerts,
    String? pushToken,
  }) {
    return NotificationSettingsModel(
      priceAlerts: priceAlerts ?? this.priceAlerts,
      portfolioAlerts: portfolioAlerts ?? this.portfolioAlerts,
      newsAlerts: newsAlerts ?? this.newsAlerts,
      marketUpdates: marketUpdates ?? this.marketUpdates,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      whaleAlerts: whaleAlerts ?? this.whaleAlerts,
      fundingRateAlerts: fundingRateAlerts ?? this.fundingRateAlerts,
      sentimentAlerts: sentimentAlerts ?? this.sentimentAlerts,
      pushToken: pushToken ?? this.pushToken,
    );
  }
}
