import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Types of price alerts
enum AlertType {
  above,
  below,
  percentUp,
  percentDown,
}

/// Extension for AlertType display and operations
extension AlertTypeX on AlertType {
  String get displayName {
    switch (this) {
      case AlertType.above:
        return 'Above';
      case AlertType.below:
        return 'Below';
      case AlertType.percentUp:
        return 'Percent Up';
      case AlertType.percentDown:
        return 'Percent Down';
    }
  }

  String toJson() {
    switch (this) {
      case AlertType.above:
        return 'above';
      case AlertType.below:
        return 'below';
      case AlertType.percentUp:
        return 'percent_up';
      case AlertType.percentDown:
        return 'percent_down';
    }
  }

  static AlertType fromJson(String json) {
    switch (json) {
      case 'above':
        return AlertType.above;
      case 'below':
        return AlertType.below;
      case 'percent_up':
        return AlertType.percentUp;
      case 'percent_down':
        return AlertType.percentDown;
      default:
        throw ArgumentError('Unknown alert type: $json');
    }
  }

  /// Check if alert should trigger based on current price
  bool shouldTrigger({
    required double currentPrice,
    required double targetPrice,
    double? basePrice,
    double? percentChange,
  }) {
    switch (this) {
      case AlertType.above:
        return currentPrice >= targetPrice;
      case AlertType.below:
        return currentPrice <= targetPrice;
      case AlertType.percentUp:
        if (basePrice == null || percentChange == null) return false;
        final change = ((currentPrice - basePrice) / basePrice) * 100;
        return change >= percentChange;
      case AlertType.percentDown:
        if (basePrice == null || percentChange == null) return false;
        final change = ((currentPrice - basePrice) / basePrice) * 100;
        return change <= -percentChange;
    }
  }
}

/// Represents a price alert for a cryptocurrency
@immutable
class PriceAlert extends Equatable {
  /// Unique alert identifier
  final String id;

  /// Trading symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Type of alert
  final AlertType type;

  /// Target price for above/below alerts
  final double targetPrice;

  /// Percentage change for percent alerts
  final double? percentChange;

  /// Base price for percent change calculation
  final double? basePrice;

  /// Whether the alert is currently active
  final bool isActive;

  /// Whether the alert has been triggered
  final bool isTriggered;

  /// When the alert was created
  final DateTime createdAt;

  /// When the alert was triggered (if triggered)
  final DateTime? triggeredAt;

  /// Whether the alert should repeat after triggering
  final bool repeatEnabled;

  /// Optional note/description
  final String? note;

  const PriceAlert({
    required this.id,
    required this.symbol,
    required this.type,
    required this.targetPrice,
    this.percentChange,
    this.basePrice,
    required this.isActive,
    required this.isTriggered,
    required this.createdAt,
    this.triggeredAt,
    required this.repeatEnabled,
    this.note,
  });

  /// Check if this alert should trigger for the given price
  bool shouldTrigger(double currentPrice) {
    if (!isActive || isTriggered) return false;

    return type.shouldTrigger(
      currentPrice: currentPrice,
      targetPrice: targetPrice,
      basePrice: basePrice,
      percentChange: percentChange,
    );
  }

  /// Create a triggered version of this alert
  PriceAlert trigger() {
    return copyWith(
      isTriggered: true,
      triggeredAt: DateTime.now(),
      isActive: !repeatEnabled, // Deactivate if not repeating
    );
  }

  /// Reset a triggered alert (for repeat alerts)
  PriceAlert reset() {
    return copyWith(
      isTriggered: false,
      triggeredAt: null,
    );
  }

  /// Creates a copy of this PriceAlert with the given fields replaced
  PriceAlert copyWith({
    String? id,
    String? symbol,
    AlertType? type,
    double? targetPrice,
    double? percentChange,
    double? basePrice,
    bool? isActive,
    bool? isTriggered,
    DateTime? createdAt,
    DateTime? triggeredAt,
    bool? repeatEnabled,
    String? note,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      targetPrice: targetPrice ?? this.targetPrice,
      percentChange: percentChange ?? this.percentChange,
      basePrice: basePrice ?? this.basePrice,
      isActive: isActive ?? this.isActive,
      isTriggered: isTriggered ?? this.isTriggered,
      createdAt: createdAt ?? this.createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      repeatEnabled: repeatEnabled ?? this.repeatEnabled,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        type,
        targetPrice,
        percentChange,
        basePrice,
        isActive,
        isTriggered,
        createdAt,
        triggeredAt,
        repeatEnabled,
        note,
      ];
}
