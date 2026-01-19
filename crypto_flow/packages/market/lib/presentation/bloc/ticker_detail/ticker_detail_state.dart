import 'package:equatable/equatable.dart';
import '../../../domain/entities/ticker.dart';
import '../../../domain/entities/candle.dart';
import '../../../domain/entities/order_book.dart';

/// States for TickerDetailBloc
abstract class TickerDetailState extends Equatable {
  const TickerDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TickerDetailInitial extends TickerDetailState {
  const TickerDetailInitial();
}

/// Loading state
class TickerDetailLoading extends TickerDetailState {
  const TickerDetailLoading();
}

/// Loaded state with ticker details
class TickerDetailLoaded extends TickerDetailState {
  /// Current ticker data
  final Ticker ticker;

  /// Historical candles
  final List<Candle> candles;

  /// Current order book
  final OrderBook? orderBook;

  /// Selected chart interval
  final String interval;

  /// Live connection status
  final bool isLiveUpdating;

  /// Available intervals
  static const List<String> intervals = [
    '1m',
    '5m',
    '15m',
    '30m',
    '1h',
    '4h',
    '1d',
    '1w'
  ];

  const TickerDetailLoaded({
    required this.ticker,
    required this.candles,
    this.orderBook,
    this.interval = '1h',
    this.isLiveUpdating = false,
  });

  @override
  List<Object?> get props => [
        ticker,
        candles,
        orderBook,
        interval,
        isLiveUpdating,
      ];

  TickerDetailLoaded copyWith({
    Ticker? ticker,
    List<Candle>? candles,
    OrderBook? orderBook,
    String? interval,
    bool? isLiveUpdating,
  }) {
    return TickerDetailLoaded(
      ticker: ticker ?? this.ticker,
      candles: candles ?? this.candles,
      orderBook: orderBook ?? this.orderBook,
      interval: interval ?? this.interval,
      isLiveUpdating: isLiveUpdating ?? this.isLiveUpdating,
    );
  }
}

/// Error state
class TickerDetailError extends TickerDetailState {
  final String message;

  const TickerDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
