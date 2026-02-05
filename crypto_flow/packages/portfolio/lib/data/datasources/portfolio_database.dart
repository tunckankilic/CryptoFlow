import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../local/tables/journal_entries_table.dart';
import '../local/tables/journal_tags_table.dart';
import '../local/tables/trading_stats_table.dart';

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
@DriftDatabase(tables: [
  Transactions,
  JournalEntries,
  JournalTags,
  TradingStats,
])
class PortfolioDatabase extends _$PortfolioDatabase {
  PortfolioDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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

  // Journal Entries CRUD operations

  /// Get all journal entries
  Future<List<JournalEntry>> getAllJournalEntries() =>
      select(journalEntries).get();

  /// Get journal entry by ID
  Future<JournalEntry?> getJournalEntryById(int id) {
    return (select(journalEntries)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get journal entries by symbol
  Future<List<JournalEntry>> getJournalEntriesBySymbol(String symbol) {
    return (select(journalEntries)..where((e) => e.symbol.equals(symbol)))
        .get();
  }

  /// Insert journal entry
  Future<int> insertJournalEntry(JournalEntriesCompanion entry) {
    return into(journalEntries).insert(entry);
  }

  /// Update journal entry
  Future<bool> updateJournalEntry(JournalEntriesCompanion entry) {
    return update(journalEntries).replace(entry);
  }

  /// Delete journal entry
  Future<int> deleteJournalEntry(int id) {
    return (delete(journalEntries)..where((e) => e.id.equals(id))).go();
  }

  /// Watch all journal entries
  Stream<List<JournalEntry>> watchJournalEntries() {
    return (select(journalEntries)
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Watch journal entries by symbol
  Stream<List<JournalEntry>> watchJournalEntriesBySymbol(String symbol) {
    return (select(journalEntries)
          ..where((e) => e.symbol.equals(symbol))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // Journal Tags CRUD operations

  /// Get all tags
  Future<List<JournalTag>> getAllTags() => select(journalTags).get();

  /// Get tag by ID
  Future<JournalTag?> getTagById(int id) {
    return (select(journalTags)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get tag by name
  Future<JournalTag?> getTagByName(String name) {
    return (select(journalTags)..where((t) => t.name.equals(name)))
        .getSingleOrNull();
  }

  /// Insert tag
  Future<int> insertTag(JournalTagsCompanion tag) {
    return into(journalTags).insert(tag);
  }

  /// Update tag usage count
  Future<int> updateTagUsageCount(int tagId, int count) {
    return (update(journalTags)..where((t) => t.id.equals(tagId)))
        .write(JournalTagsCompanion(usageCount: Value(count)));
  }

  /// Delete tag
  Future<int> deleteTag(int id) {
    return (delete(journalTags)..where((t) => t.id.equals(id))).go();
  }

  /// Watch all tags ordered by usage count
  Stream<List<JournalTag>> watchTags() {
    return (select(journalTags)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.usageCount, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // Trading Stats CRUD operations

  /// Get stats by period
  Future<TradingStat?> getStatsByPeriod(String period) {
    return (select(tradingStats)..where((s) => s.period.equals(period)))
        .getSingleOrNull();
  }

  /// Get all stats
  Future<List<TradingStat>> getAllStats() => select(tradingStats).get();

  /// Upsert (insert or update) stats
  Future<void> upsertStats(TradingStatsCompanion stats) async {
    await into(tradingStats).insertOnConflictUpdate(stats);
  }

  /// Delete stats by period
  Future<int> deleteStatsByPeriod(String period) {
    return (delete(tradingStats)..where((s) => s.period.equals(period))).go();
  }

  /// Watch stats for a specific period
  Stream<TradingStat?> watchStatsByPeriod(String period) {
    return (select(tradingStats)..where((s) => s.period.equals(period)))
        .watchSingleOrNull();
  }

  /// Watch all stats
  Stream<List<TradingStat>> watchAllStats() => select(tradingStats).watch();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'portfolio.db'));
    return NativeDatabase(file);
  });
}
