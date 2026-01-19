import 'package:equatable/equatable.dart';
import '../../../domain/entities/order_book.dart';

/// States for OrderBookBloc
abstract class OrderBookState extends Equatable {
  const OrderBookState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OrderBookInitial extends OrderBookState {
  const OrderBookInitial();
}

/// Loading state
class OrderBookLoading extends OrderBookState {
  const OrderBookLoading();
}

/// Loaded state with order book data
class OrderBookLoaded extends OrderBookState {
  /// Current order book
  final OrderBook orderBook;

  /// Whether receiving live updates
  final bool isLive;

  /// Cumulative bid depth for visualization
  List<double> get cumulativeBidDepth {
    double cumulative = 0;
    return orderBook.bids.map((entry) {
      cumulative += entry.quantity;
      return cumulative;
    }).toList();
  }

  /// Cumulative ask depth for visualization
  List<double> get cumulativeAskDepth {
    double cumulative = 0;
    return orderBook.asks.map((entry) {
      cumulative += entry.quantity;
      return cumulative;
    }).toList();
  }

  /// Maximum cumulative depth (for scaling)
  double get maxDepth {
    final bidMax =
        cumulativeBidDepth.isNotEmpty ? cumulativeBidDepth.last : 0.0;
    final askMax =
        cumulativeAskDepth.isNotEmpty ? cumulativeAskDepth.last : 0.0;
    return bidMax > askMax ? bidMax : askMax;
  }

  const OrderBookLoaded({
    required this.orderBook,
    this.isLive = false,
  });

  @override
  List<Object?> get props => [orderBook, isLive];

  OrderBookLoaded copyWith({
    OrderBook? orderBook,
    bool? isLive,
  }) {
    return OrderBookLoaded(
      orderBook: orderBook ?? this.orderBook,
      isLive: isLive ?? this.isLive,
    );
  }
}

/// Error state
class OrderBookError extends OrderBookState {
  final String message;

  const OrderBookError(this.message);

  @override
  List<Object?> get props => [message];
}
