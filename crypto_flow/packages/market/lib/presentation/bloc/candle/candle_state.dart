import 'package:equatable/equatable.dart';
import '../../../domain/entities/candle.dart';

/// States for CandleBloc
abstract class CandleState extends Equatable {
  const CandleState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CandleInitial extends CandleState {
  const CandleInitial();
}

/// Loading state
class CandleLoading extends CandleState {
  const CandleLoading();
}

/// Loaded state with candle data
class CandleLoaded extends CandleState {
  /// Symbol being tracked
  final String symbol;

  /// List of candles
  final List<Candle> candles;

  /// Current interval
  final String interval;

  /// Whether receiving live updates
  final bool isLive;

  /// High price in visible range
  double get high => candles.isEmpty
      ? 0
      : candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);

  /// Low price in visible range
  double get low => candles.isEmpty
      ? 0
      : candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);

  const CandleLoaded({
    required this.symbol,
    required this.candles,
    required this.interval,
    this.isLive = false,
  });

  @override
  List<Object?> get props => [symbol, candles, interval, isLive];

  CandleLoaded copyWith({
    String? symbol,
    List<Candle>? candles,
    String? interval,
    bool? isLive,
  }) {
    return CandleLoaded(
      symbol: symbol ?? this.symbol,
      candles: candles ?? this.candles,
      interval: interval ?? this.interval,
      isLive: isLive ?? this.isLive,
    );
  }
}

/// Error state
class CandleError extends CandleState {
  final String message;

  const CandleError(this.message);

  @override
  List<Object?> get props => [message];
}
