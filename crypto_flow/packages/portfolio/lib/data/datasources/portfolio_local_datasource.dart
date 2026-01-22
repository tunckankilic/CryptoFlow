import 'package:core/error/exceptions.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/transaction.dart' as domain;
import 'portfolio_database.dart';

/// Local data source for portfolio using Drift database
class PortfolioLocalDataSource {
  final PortfolioDatabase _database;

  PortfolioLocalDataSource(this._database);

  /// Add a transaction to the database
  Future<void> addTransaction(domain.Transaction transaction) async {
    try {
      await _database.insertTransaction(
        TransactionsCompanion.insert(
          id: transaction.id,
          symbol: transaction.symbol,
          type: transaction.type.toJson(),
          quantity: transaction.quantity,
          price: transaction.price,
          fee: Value(transaction.fee),
          feeAsset: Value(transaction.feeAsset),
          timestamp: transaction.timestamp,
          note: Value(transaction.note),
        ),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to add transaction: $e');
    }
  }

  /// Get all transactions
  Future<List<domain.Transaction>> getTransactions({String? symbol}) async {
    try {
      final List<Transaction> dbTransactions;
      if (symbol != null) {
        dbTransactions = await _database.getTransactionsBySymbol(symbol);
      } else {
        dbTransactions = await _database.getAllTransactions();
      }

      return dbTransactions.map((t) => _transactionFromDb(t)).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get transactions: $e');
    }
  }

  /// Delete transaction by ID
  Future<void> deleteTransaction(String id) async {
    try {
      final deletedCount = await _database.deleteTransaction(id);
      if (deletedCount == 0) {
        throw CacheException(message: 'Transaction not found: $id');
      }
    } catch (e) {
      throw CacheException(message: 'Failed to delete transaction: $e');
    }
  }

  /// Watch transactions for real-time updates
  Stream<List<domain.Transaction>> watchTransactions({String? symbol}) {
    try {
      final stream = symbol != null
          ? _database.watchTransactionsBySymbol(symbol)
          : _database.watchAllTransactions();

      return stream.map(
        (dbTransactions) =>
            dbTransactions.map((t) => _transactionFromDb(t)).toList(),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to watch transactions: $e');
    }
  }

  /// Calculate holdings from transactions
  Future<List<Holding>> calculateHoldings() async {
    try {
      final transactions = await getTransactions();

      // Group transactions by symbol
      final transactionsBySymbol = <String, List<domain.Transaction>>{};
      for (final tx in transactions) {
        transactionsBySymbol.putIfAbsent(tx.symbol, () => []).add(tx);
      }

      final holdings = <Holding>[];

      // Calculate holdings for each symbol
      for (final entry in transactionsBySymbol.entries) {
        final symbol = entry.key;
        final txList = entry.value;

        // Sort by timestamp
        txList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        double totalQuantity = 0;
        double totalCost = 0;
        DateTime? firstBuyDate;

        for (final tx in txList) {
          if (tx.type.isIncoming) {
            // Buy or Transfer In - add to holdings
            totalQuantity += tx.quantity;
            totalCost += tx.totalCost;
            firstBuyDate ??= tx.timestamp;
          } else {
            // Sell or Transfer Out - reduce holdings
            final sellQuantity = tx.quantity;
            if (totalQuantity > 0) {
              // Calculate proportion being sold
              final proportion = sellQuantity / totalQuantity;

              // Reduce cost proportionally
              totalCost -= totalCost * proportion;
              totalQuantity -= sellQuantity;
            }
          }
        }

        // Only create holding if we have remaining quantity
        if (totalQuantity > 0 && firstBuyDate != null) {
          final avgBuyPrice = totalCost / totalQuantity;

          // Extract base asset from symbol (e.g., "BTC" from "BTCUSDT")
          final baseAsset = symbol
              .replaceAll('USDT', '')
              .replaceAll('BTC', '')
              .replaceAll('ETH', '')
              .replaceAll('BNB', '');

          holdings.add(
            Holding(
              symbol: symbol,
              baseAsset: baseAsset.isEmpty ? symbol : baseAsset,
              quantity: totalQuantity,
              avgBuyPrice: avgBuyPrice,
              firstBuyDate: firstBuyDate,
            ),
          );
        }
      }

      return holdings;
    } catch (e) {
      throw CacheException(message: 'Failed to calculate holdings: $e');
    }
  }

  /// Watch holdings for real-time updates
  Stream<List<Holding>> watchHoldings() {
    return watchTransactions().asyncMap((_) => calculateHoldings());
  }

  /// Convert database transaction to domain entity
  domain.Transaction _transactionFromDb(Transaction dbTransaction) {
    return domain.Transaction(
      id: dbTransaction.id,
      symbol: dbTransaction.symbol,
      type: domain.TransactionTypeX.fromJson(dbTransaction.type),
      quantity: dbTransaction.quantity,
      price: dbTransaction.price,
      fee: dbTransaction.fee,
      feeAsset: dbTransaction.feeAsset,
      timestamp: dbTransaction.timestamp,
      note: dbTransaction.note,
    );
  }
}
