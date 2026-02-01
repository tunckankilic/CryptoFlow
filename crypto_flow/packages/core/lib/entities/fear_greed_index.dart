import 'package:equatable/equatable.dart';

/// Crypto Fear & Greed Index from Alternative.me
///
/// Scale: 0-100
/// - 0-24: Extreme Fear
/// - 25-49: Fear
/// - 50-74: Greed
/// - 75-100: Extreme Greed
class FearGreedIndex extends Equatable {
  final int value;
  final String classification;
  final DateTime timestamp;
  final int timeUntilUpdate;

  const FearGreedIndex({
    required this.value,
    required this.classification,
    required this.timestamp,
    required this.timeUntilUpdate,
  });

  /// Get emoji for current sentiment
  String get emoji {
    if (value <= 24) return '😱'; // Extreme Fear
    if (value <= 49) return '😨'; // Fear
    if (value <= 74) return '😃'; // Greed
    return '🤑'; // Extreme Greed
  }

  /// Get color value for sentiment (0xAARRGGBB format)
  int get colorValue {
    if (value <= 24) return 0xFFD32F2F; // Red
    if (value <= 49) return 0xFFFF9800; // Orange
    if (value <= 74) return 0xFFFDD835; // Yellow
    return 0xFF4CAF50; // Green
  }

  @override
  List<Object?> get props =>
      [value, classification, timestamp, timeUntilUpdate];
}
