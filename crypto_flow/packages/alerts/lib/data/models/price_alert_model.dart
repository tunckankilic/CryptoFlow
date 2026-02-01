import 'package:hive/hive.dart';
import '../../domain/entities/price_alert.dart';

part 'price_alert_model.g.dart';

/// Data model for PriceAlert entity with Hive storage
@HiveType(typeId: 1)
class PriceAlertModel extends PriceAlert {
  @HiveField(0)
  final String hiveId;

  @HiveField(1)
  final String hiveSymbol;

  @HiveField(2)
  final String hiveType;

  @HiveField(3)
  final double hiveTargetPrice;

  @HiveField(4)
  final double? hivePercentChange;

  @HiveField(5)
  final double? hiveBasePrice;

  @HiveField(6)
  final bool hiveIsActive;

  @HiveField(7)
  final bool hiveIsTriggered;

  @HiveField(8)
  final int hiveCreatedAt;

  @HiveField(9)
  final int? hiveTriggeredAt;

  @HiveField(10)
  final bool hiveRepeatEnabled;

  @HiveField(11)
  final String? hiveNote;

  @HiveField(12)
  final bool hiveNotificationEnabled;

  @HiveField(13)
  final bool hivePushEnabled;

  PriceAlertModel({
    required this.hiveId,
    required this.hiveSymbol,
    required this.hiveType,
    required this.hiveTargetPrice,
    this.hivePercentChange,
    this.hiveBasePrice,
    required this.hiveIsActive,
    required this.hiveIsTriggered,
    required this.hiveCreatedAt,
    this.hiveTriggeredAt,
    required this.hiveRepeatEnabled,
    this.hiveNote,
    required this.hiveNotificationEnabled,
    required this.hivePushEnabled,
  }) : super(
          id: hiveId,
          symbol: hiveSymbol,
          type: AlertTypeX.fromJson(hiveType),
          targetPrice: hiveTargetPrice,
          percentChange: hivePercentChange,
          basePrice: hiveBasePrice,
          isActive: hiveIsActive,
          isTriggered: hiveIsTriggered,
          createdAt: DateTime.fromMillisecondsSinceEpoch(hiveCreatedAt),
          triggeredAt: hiveTriggeredAt != null
              ? DateTime.fromMillisecondsSinceEpoch(hiveTriggeredAt)
              : null,
          repeatEnabled: hiveRepeatEnabled,
          note: hiveNote,
          notificationEnabled: hiveNotificationEnabled,
          pushEnabled: hivePushEnabled,
        );

  /// Create from domain entity
  factory PriceAlertModel.fromEntity(PriceAlert alert) {
    return PriceAlertModel(
      hiveId: alert.id,
      hiveSymbol: alert.symbol,
      hiveType: alert.type.toJson(),
      hiveTargetPrice: alert.targetPrice,
      hivePercentChange: alert.percentChange,
      hiveBasePrice: alert.basePrice,
      hiveIsActive: alert.isActive,
      hiveIsTriggered: alert.isTriggered,
      hiveCreatedAt: alert.createdAt.millisecondsSinceEpoch,
      hiveTriggeredAt: alert.triggeredAt?.millisecondsSinceEpoch,
      hiveRepeatEnabled: alert.repeatEnabled,
      hiveNote: alert.note,
      hiveNotificationEnabled: alert.notificationEnabled,
      hivePushEnabled: alert.pushEnabled,
    );
  }

  /// Convert to domain entity
  PriceAlert toEntity() {
    return PriceAlert(
      id: hiveId,
      symbol: hiveSymbol,
      type: AlertTypeX.fromJson(hiveType),
      targetPrice: hiveTargetPrice,
      percentChange: hivePercentChange,
      basePrice: hiveBasePrice,
      isActive: hiveIsActive,
      isTriggered: hiveIsTriggered,
      createdAt: DateTime.fromMillisecondsSinceEpoch(hiveCreatedAt),
      triggeredAt: hiveTriggeredAt != null
          ? DateTime.fromMillisecondsSinceEpoch(hiveTriggeredAt!)
          : null,
      repeatEnabled: hiveRepeatEnabled,
      note: hiveNote,
      notificationEnabled: hiveNotificationEnabled,
      pushEnabled: hivePushEnabled,
    );
  }

  /// Create from JSON
  factory PriceAlertModel.fromJson(Map<String, dynamic> json) {
    return PriceAlertModel(
      hiveId: json['id'] as String,
      hiveSymbol: json['symbol'] as String,
      hiveType: json['type'] as String,
      hiveTargetPrice: (json['targetPrice'] as num).toDouble(),
      hivePercentChange: json['percentChange'] != null
          ? (json['percentChange'] as num).toDouble()
          : null,
      hiveBasePrice: json['basePrice'] != null
          ? (json['basePrice'] as num).toDouble()
          : null,
      hiveIsActive: json['isActive'] as bool,
      hiveIsTriggered: json['isTriggered'] as bool,
      hiveCreatedAt: json['createdAt'] as int,
      hiveTriggeredAt: json['triggeredAt'] as int?,
      hiveRepeatEnabled: json['repeatEnabled'] as bool,
      hiveNote: json['note'] as String?,
      hiveNotificationEnabled: json['notificationEnabled'] as bool? ?? true,
      hivePushEnabled: json['pushEnabled'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': hiveId,
      'symbol': hiveSymbol,
      'type': hiveType,
      'targetPrice': hiveTargetPrice,
      'percentChange': hivePercentChange,
      'basePrice': hiveBasePrice,
      'isActive': hiveIsActive,
      'isTriggered': hiveIsTriggered,
      'createdAt': hiveCreatedAt,
      'triggeredAt': hiveTriggeredAt,
      'repeatEnabled': hiveRepeatEnabled,
      'note': hiveNote,
      'notificationEnabled': hiveNotificationEnabled,
      'pushEnabled': hivePushEnabled,
    };
  }
}
