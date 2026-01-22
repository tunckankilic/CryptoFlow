import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

/// Base class for all portfolio events
abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

/// Load portfolio data (holdings and summary)
class LoadPortfolio extends PortfolioEvent {
  const LoadPortfolio();
}

/// Add a new transaction
class AddTransactionEvent extends PortfolioEvent {
  final Transaction transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Delete a transaction by ID
class DeleteTransactionEvent extends PortfolioEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// Subscribe to real-time portfolio value updates with live prices
class WatchPortfolioValue extends PortfolioEvent {
  const WatchPortfolioValue();
}

/// Refresh current prices from market
class RefreshPrices extends PortfolioEvent {
  const RefreshPrices();
}

/// Update portfolio with new market prices
class UpdatePrices extends PortfolioEvent {
  final Map<String, double> prices;

  const UpdatePrices(this.prices);

  @override
  List<Object?> get props => [prices];
}

/// Holdings updated from database
class HoldingsUpdated extends PortfolioEvent {
  const HoldingsUpdated();
}
