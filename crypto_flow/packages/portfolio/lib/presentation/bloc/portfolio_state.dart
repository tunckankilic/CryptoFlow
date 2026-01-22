import 'package:equatable/equatable.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/transaction.dart';

/// Base class for all portfolio states
abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

/// Loading portfolio data
class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

/// Portfolio data loaded successfully
class PortfolioLoaded extends PortfolioState {
  final PortfolioSummary summary;
  final List<Holding> holdings;
  final List<Transaction> transactions;
  final Map<String, double> currentPrices;

  const PortfolioLoaded({
    required this.summary,
    required this.holdings,
    required this.transactions,
    required this.currentPrices,
  });

  /// Create a copy with updated fields
  PortfolioLoaded copyWith({
    PortfolioSummary? summary,
    List<Holding>? holdings,
    List<Transaction>? transactions,
    Map<String, double>? currentPrices,
  }) {
    return PortfolioLoaded(
      summary: summary ?? this.summary,
      holdings: holdings ?? this.holdings,
      transactions: transactions ?? this.transactions,
      currentPrices: currentPrices ?? this.currentPrices,
    );
  }

  @override
  List<Object?> get props => [summary, holdings, transactions, currentPrices];
}

/// Error loading or managing portfolio
class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError({required this.message});

  @override
  List<Object?> get props => [message];
}
