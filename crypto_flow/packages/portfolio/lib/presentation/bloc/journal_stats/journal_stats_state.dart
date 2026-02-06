import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/trade_emotion.dart';
import '../../../domain/entities/trading_stats.dart';

/// Base class for all journal stats states
abstract class JournalStatsState extends Equatable {
  const JournalStatsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any stats are loaded
class JournalStatsInitial extends JournalStatsState {
  const JournalStatsInitial();
}

/// Loading statistics data
class JournalStatsLoading extends JournalStatsState {
  const JournalStatsLoading();
}

/// Statistics data loaded successfully
class JournalStatsLoaded extends JournalStatsState {
  /// Main trading statistics
  final TradingStats stats;

  /// Equity curve (cumulative P&L over time)
  final List<double> equityCurve;

  /// P&L grouped by emotion
  final Map<TradeEmotion, double> emotionPnl;

  /// P&L grouped by symbol
  final Map<String, double> symbolPnl;

  /// Maximum drawdown percentage
  final double maxDrawdown;

  const JournalStatsLoaded({
    required this.stats,
    required this.equityCurve,
    required this.emotionPnl,
    required this.symbolPnl,
    required this.maxDrawdown,
  });

  /// Create a copy with updated fields
  JournalStatsLoaded copyWith({
    TradingStats? stats,
    List<double>? equityCurve,
    Map<TradeEmotion, double>? emotionPnl,
    Map<String, double>? symbolPnl,
    double? maxDrawdown,
  }) {
    return JournalStatsLoaded(
      stats: stats ?? this.stats,
      equityCurve: equityCurve ?? this.equityCurve,
      emotionPnl: emotionPnl ?? this.emotionPnl,
      symbolPnl: symbolPnl ?? this.symbolPnl,
      maxDrawdown: maxDrawdown ?? this.maxDrawdown,
    );
  }

  @override
  List<Object?> get props =>
      [stats, equityCurve, emotionPnl, symbolPnl, maxDrawdown];
}

/// Error loading statistics
class JournalStatsError extends JournalStatsState {
  final String message;

  const JournalStatsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Generating PDF report
class JournalReportGenerating extends JournalStatsState {
  const JournalReportGenerating();
}

/// PDF report generated successfully
class JournalReportGenerated extends JournalStatsState {
  final Uint8List pdfBytes;

  const JournalReportGenerated(this.pdfBytes);

  @override
  List<Object?> get props => [pdfBytes];
}

/// Error generating PDF report
class JournalReportError extends JournalStatsState {
  final String message;

  const JournalReportError(this.message);

  @override
  List<Object?> get props => [message];
}
