import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'trade_side.dart';
import 'trade_emotion.dart';

/// Represents a trading journal entry
@immutable
class JournalEntry extends Equatable {
  /// Unique identifier
  final int id;

  /// Optional reference to transaction ID
  final String? transactionId;

  /// Trading symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Trade side (long or short)
  final TradeSide side;

  /// Entry price
  final double entryPrice;

  /// Exit price (null for open positions)
  final double? exitPrice;

  /// Quantity traded
  final double quantity;

  /// Profit/Loss (calculated)
  final double? pnl;

  /// P&L as percentage
  final double? pnlPercentage;

  /// Risk/Reward ratio
  final double? riskRewardRatio;

  /// Strategy name
  final String? strategy;

  /// Emotional state during trade
  final TradeEmotion emotion;

  /// Trade notes
  final String? notes;

  /// Tags for categorization
  final List<String> tags;

  /// Path to chart screenshot
  final String? screenshotPath;

  /// Entry date/time
  final DateTime entryDate;

  /// Exit date/time (null for open positions)
  final DateTime? exitDate;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    this.transactionId,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    this.exitPrice,
    required this.quantity,
    this.pnl,
    this.pnlPercentage,
    this.riskRewardRatio,
    this.strategy,
    required this.emotion,
    this.notes,
    this.tags = const [],
    this.screenshotPath,
    required this.entryDate,
    this.exitDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if position is still open
  bool get isOpen => exitDate == null;

  /// Calculate trade duration
  Duration? get duration {
    if (exitDate == null) return null;
    return exitDate!.difference(entryDate);
  }

  /// Calculate P&L if not already set
  double? calculatePnl() {
    if (exitPrice == null) return null;

    final difference = exitPrice! - entryPrice;
    if (side == TradeSide.long) {
      return difference * quantity;
    } else {
      // Short position: profit when price goes down
      return -difference * quantity;
    }
  }

  /// Calculate P&L percentage if not already set
  double? calculatePnlPercentage() {
    if (exitPrice == null) return null;

    final difference = exitPrice! - entryPrice;
    if (side == TradeSide.long) {
      return (difference / entryPrice) * 100;
    } else {
      // Short position
      return -(difference / entryPrice) * 100;
    }
  }

  /// Creates a copy with the given fields replaced
  JournalEntry copyWith({
    int? id,
    String? transactionId,
    String? symbol,
    TradeSide? side,
    double? entryPrice,
    double? exitPrice,
    double? quantity,
    double? pnl,
    double? pnlPercentage,
    double? riskRewardRatio,
    String? strategy,
    TradeEmotion? emotion,
    String? notes,
    List<String>? tags,
    String? screenshotPath,
    DateTime? entryDate,
    DateTime? exitDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      quantity: quantity ?? this.quantity,
      pnl: pnl ?? this.pnl,
      pnlPercentage: pnlPercentage ?? this.pnlPercentage,
      riskRewardRatio: riskRewardRatio ?? this.riskRewardRatio,
      strategy: strategy ?? this.strategy,
      emotion: emotion ?? this.emotion,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      entryDate: entryDate ?? this.entryDate,
      exitDate: exitDate ?? this.exitDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transactionId,
        symbol,
        side,
        entryPrice,
        exitPrice,
        quantity,
        pnl,
        pnlPercentage,
        riskRewardRatio,
        strategy,
        emotion,
        notes,
        tags,
        screenshotPath,
        entryDate,
        exitDate,
        createdAt,
        updatedAt,
      ];
}
