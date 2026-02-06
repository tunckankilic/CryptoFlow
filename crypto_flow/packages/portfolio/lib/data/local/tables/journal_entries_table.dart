import 'package:drift/drift.dart';

/// Journal entries table definition
/// Tracks detailed trading journal entries with associated metadata
class JournalEntries extends Table {
  /// Unique identifier (auto-generated)
  IntColumn get id => integer().autoIncrement()();

  /// Optional reference to transaction in transactions table
  TextColumn get transactionId => text().nullable()();

  /// Trading symbol (e.g., "BTCUSDT")
  TextColumn get symbol => text()();

  /// Trade side: "long" or "short"
  TextColumn get side => text()();

  /// Entry price
  RealColumn get entryPrice => real()();

  /// Exit price (nullable for open positions)
  RealColumn get exitPrice => real().nullable()();

  /// Quantity traded
  RealColumn get quantity => real()();

  /// Profit/Loss (calculated)
  RealColumn get pnl => real().nullable()();

  /// P&L as percentage
  RealColumn get pnlPercentage => real().nullable()();

  /// Risk/Reward ratio
  RealColumn get riskRewardRatio => real().nullable()();

  /// Strategy name (e.g., "breakout", "support bounce")
  TextColumn get strategy => text().nullable()();

  /// Emotional state during trade
  /// Values: "confident", "neutral", "fearful", "greedy", "fomo", "revenge"
  TextColumn get emotion => text()();

  /// Trade notes/description
  TextColumn get notes => text().nullable()();

  /// Tags as JSON array string (e.g., '["swing", "scalp", "news"]')
  TextColumn get tags => text()();

  /// Local file path to chart screenshot
  TextColumn get screenshotPath => text().nullable()();

  /// Entry date/time
  DateTimeColumn get entryDate => dateTime()();

  /// Exit date/time (nullable for open positions)
  DateTimeColumn get exitDate => dateTime().nullable()();

  /// Record creation timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime()();
}
