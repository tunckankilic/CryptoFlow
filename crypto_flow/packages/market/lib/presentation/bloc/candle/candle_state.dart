import 'package:equatable/equatable.dart';
import '../../../domain/entities/candle.dart';
import '../../../domain/entities/indicator_type.dart';
import '../../../domain/entities/macd_result.dart';

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

/// Loaded state with candle data and optional indicators
class CandleLoaded extends CandleState {
  /// Symbol being tracked
  final String symbol;

  /// List of candles
  final List<Candle> candles;

  /// Current interval
  final String interval;

  /// Whether receiving live updates
  final bool isLive;

  /// RSI values (0-100, null for insufficient data)
  final List<double?> rsiValues;

  /// EMA values by period (e.g., {9: [...], 21: [...], 50: [...]})
  final Map<int, List<double?>> emaValues;

  /// SMA values (period: 20)
  final List<double?> smaValues;

  /// MACD calculation result
  final MACDResult? macdResult;

  /// Currently active indicators
  final Set<IndicatorType> activeIndicators;

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
    this.rsiValues = const [],
    this.emaValues = const {},
    this.smaValues = const [],
    this.macdResult,
    this.activeIndicators = const {},
  });

  @override
  List<Object?> get props => [
        symbol,
        candles,
        interval,
        isLive,
        rsiValues,
        emaValues,
        smaValues,
        macdResult,
        activeIndicators,
      ];

  CandleLoaded copyWith({
    String? symbol,
    List<Candle>? candles,
    String? interval,
    bool? isLive,
    List<double?>? rsiValues,
    Map<int, List<double?>>? emaValues,
    List<double?>? smaValues,
    MACDResult? macdResult,
    Set<IndicatorType>? activeIndicators,
  }) {
    return CandleLoaded(
      symbol: symbol ?? this.symbol,
      candles: candles ?? this.candles,
      interval: interval ?? this.interval,
      isLive: isLive ?? this.isLive,
      rsiValues: rsiValues ?? this.rsiValues,
      emaValues: emaValues ?? this.emaValues,
      smaValues: smaValues ?? this.smaValues,
      macdResult: macdResult ?? this.macdResult,
      activeIndicators: activeIndicators ?? this.activeIndicators,
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
