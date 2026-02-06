import 'package:drift/drift.dart';

/// Trading statistics table definition
/// Tracks aggregated trading performance metrics by time period
class TradingStats extends Table {
  /// Unique identifier (auto-generated)
  IntColumn get id => integer().autoIncrement()();

  /// Time period: "daily", "weekly", "monthly", "allTime"
  TextColumn get period => text()();

  /// Period start date
  DateTimeColumn get periodStart => dateTime()();

  /// Period end date
  DateTimeColumn get periodEnd => dateTime()();

  /// Total number of trades
  IntColumn get totalTrades => integer()();

  /// Number of winning trades
  IntColumn get winCount => integer()();

  /// Number of losing trades
  IntColumn get lossCount => integer()();

  /// Win rate as percentage
  RealColumn get winRate => real()();

  /// Total profit/loss
  RealColumn get totalPnl => real()();

  /// Average risk/reward ratio
  RealColumn get averageRR => real()();

  /// Largest winning trade
  RealColumn get largestWin => real()();

  /// Largest losing trade
  RealColumn get largestLoss => real()();

  /// Profit factor (gross profit / gross loss)
  RealColumn get profitFactor => real()();

  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime()();
}
