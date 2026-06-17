import '../../domain/entities/chart_pattern.dart';

class ChartPatternModel {
  final String patternType;
  final String symbol;
  final int startIndex;
  final int endIndex;
  final double confidence;
  final String direction;
  final List<double> keyLevels;
  final String description;

  const ChartPatternModel({
    required this.patternType,
    required this.symbol,
    required this.startIndex,
    required this.endIndex,
    required this.confidence,
    required this.direction,
    required this.keyLevels,
    required this.description,
  });

  factory ChartPatternModel.fromJson(Map<String, dynamic> json) {
    return ChartPatternModel(
      patternType: json['pattern_type'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      startIndex: (json['start_index'] as num?)?.toInt() ?? 0,
      endIndex: (json['end_index'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      direction: json['direction'] as String? ?? 'neutral',
      keyLevels: (json['key_levels'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      description: json['description'] as String? ?? '',
    );
  }

  static PatternType _mapPatternType(String raw) {
    switch (raw) {
      case 'double_top':
        return PatternType.doubleTop;
      case 'double_bottom':
        return PatternType.doubleBottom;
      case 'head_and_shoulders':
        return PatternType.headAndShoulders;
      case 'inverse_head_and_shoulders':
        return PatternType.inverseHeadAndShoulders;
      case 'ascending_triangle':
        return PatternType.ascendingTriangle;
      case 'descending_triangle':
        return PatternType.descendingTriangle;
      case 'symmetrical_triangle':
        return PatternType.symmetricalTriangle;
      case 'support':
        return PatternType.support;
      case 'resistance':
        return PatternType.resistance;
      default:
        return PatternType.support;
    }
  }

  static SignalDirection _mapDirection(String raw) {
    switch (raw) {
      case 'bullish':
        return SignalDirection.bullish;
      case 'bearish':
        return SignalDirection.bearish;
      default:
        return SignalDirection.neutral;
    }
  }

  ChartPattern toEntity() => ChartPattern(
        patternType: _mapPatternType(patternType),
        symbol: symbol,
        startIndex: startIndex,
        endIndex: endIndex,
        confidence: confidence,
        direction: _mapDirection(direction),
        keyLevels: keyLevels,
        description: description,
      );
}
