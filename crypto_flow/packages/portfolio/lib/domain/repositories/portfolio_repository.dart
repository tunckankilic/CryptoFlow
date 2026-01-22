import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/holding.dart';
import '../entities/transaction.dart';

/// Abstract repository interface for portfolio operations
abstract class PortfolioRepository {
  /// Get all current holdings
  Future<Either<Failure, List<Holding>>> getHoldings();

  /// Add a new transaction to the portfolio
  Future<Either<Failure, void>> addTransaction(Transaction transaction);

  /// Get all transactions, optionally filtered by symbol
  Future<Either<Failure, List<Transaction>>> getTransactions({
    String? symbol,
  });

  /// Delete a transaction by ID
  Future<Either<Failure, void>> deleteTransaction(String id);

  /// Watch holdings for real-time updates
  Stream<List<Holding>> watchHoldings();

  /// Watch transactions for real-time updates
  Stream<List<Transaction>> watchTransactions({String? symbol});
}
