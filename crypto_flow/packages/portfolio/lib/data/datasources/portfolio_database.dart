import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'portfolio_database.g.dart';

/// Transactions table definition
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get symbol => text()();
  TextColumn get type => text()(); // buy, sell, transfer_in, transfer_out
  RealColumn get quantity => real()();
  RealColumn get price => real()();
  RealColumn get fee => real().nullable()();
  TextColumn get feeAsset => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift database for portfolio data
@DriftDatabase(tables: [Transactions])
class PortfolioDatabase extends _$PortfolioDatabase {
  PortfolioDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Transactions CRUD operations

  /// Get all transactions
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  /// Get transactions by symbol
  Future<List<Transaction>> getTransactionsBySymbol(String symbol) {
    return (select(transactions)..where((t) => t.symbol.equals(symbol))).get();
  }

  /// Get transaction by ID
  Future<Transaction?> getTransactionById(String id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert transaction
  Future<void> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  /// Delete transaction
  Future<int> deleteTransaction(String id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Watch all transactions
  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactions)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Watch transactions by symbol
  Stream<List<Transaction>> watchTransactionsBySymbol(String symbol) {
    return (select(transactions)
          ..where((t) => t.symbol.equals(symbol))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'portfolio.db'));
    return NativeDatabase(file);
  });
}
