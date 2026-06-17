import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Types of detected chart patterns
enum PatternType {
  doubleTop,
  doubleBottom,
  headAndShoulders,
  inverseHeadAndShoulders,
  ascendingTriangle,
  descendingTriangle,
  symmetricalTriangle,
  support,
  resistance,
}

/// Signal direction for a pattern
enum SignalDirection { bullish, bearish, neutral }

/// A detected chart pattern on price data
@immutable
class ChartPattern extends Equatable {
  final PatternType patternType;
  final String symbol;
  final int startIndex;
  final int endIndex;
  final double confidence;
  final SignalDirection direction;
  final List<double> keyLevels;
  final String description;

  const ChartPattern({
    required this.patternType,
    required this.symbol,
    required this.startIndex,
    required this.endIndex,
    required this.confidence,
    required this.direction,
    required this.keyLevels,
    required this.description,
  });

  @override
  List<Object?> get props => [
        patternType,
        symbol,
        startIndex,
        endIndex,
        confidence,
        direction,
        keyLevels,
        description,
      ];
}

/// A trading signal derived from pattern analysis
@immutable
class TradingSignal extends Equatable {
  final String symbol;
  final SignalDirection direction;
  final PatternType patternType;
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit;
  final double confidence;
  final String description;

  const TradingSignal({
    required this.symbol,
    required this.direction,
    required this.patternType,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    required this.confidence,
    required this.description,
  });

  @override
  List<Object?> get props => [
        symbol,
        direction,
        patternType,
        entryPrice,
        stopLoss,
        takeProfit,
        confidence,
        description,
      ];
}
