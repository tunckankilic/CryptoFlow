import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/trade_emotion.dart';
import '../../../domain/entities/trade_side.dart';

/// Filter criteria for journal entries
class JournalFilter extends Equatable {
  /// Filter by trading symbol
  final String? symbol;

  /// Filter by trade side (long/short)
  final TradeSide? side;

  /// Filter by emotional state
  final TradeEmotion? emotion;

  /// Filter by date range
  final DateTimeRange? dateRange;

  /// Filter by tags
  final List<String> tags;

  /// Show only winning trades
  final bool onlyWins;

  /// Show only losing trades
  final bool onlyLosses;

  const JournalFilter({
    this.symbol,
    this.side,
    this.emotion,
    this.dateRange,
    this.tags = const [],
    this.onlyWins = false,
    this.onlyLosses = false,
  });

  /// Empty filter (no filtering applied)
  const JournalFilter.empty()
      : symbol = null,
        side = null,
        emotion = null,
        dateRange = null,
        tags = const [],
        onlyWins = false,
        onlyLosses = false;

  /// Predefined filter values for common use cases
  static const JournalFilter all = JournalFilter.empty();

  static const JournalFilter wins = JournalFilter(
    onlyWins: true,
  );

  static const JournalFilter losses = JournalFilter(
    onlyLosses: true,
  );

  static const JournalFilter long = JournalFilter(
    side: TradeSide.long,
  );

  static const JournalFilter short = JournalFilter(
    side: TradeSide.short,
  );

  /// Check if any filters are applied
  bool get isEmpty =>
      symbol == null &&
      side == null &&
      emotion == null &&
      dateRange == null &&
      tags.isEmpty &&
      !onlyWins &&
      !onlyLosses;

  /// Create a copy with updated fields
  JournalFilter copyWith({
    String? symbol,
    TradeSide? side,
    TradeEmotion? emotion,
    DateTimeRange? dateRange,
    List<String>? tags,
    bool? onlyWins,
    bool? onlyLosses,
  }) {
    return JournalFilter(
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      emotion: emotion ?? this.emotion,
      dateRange: dateRange ?? this.dateRange,
      tags: tags ?? this.tags,
      onlyWins: onlyWins ?? this.onlyWins,
      onlyLosses: onlyLosses ?? this.onlyLosses,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        side,
        emotion,
        dateRange,
        tags,
        onlyWins,
        onlyLosses,
      ];
}
