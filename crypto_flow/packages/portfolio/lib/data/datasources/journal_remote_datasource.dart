import 'package:core/core.dart';

import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/trade_emotion.dart';
import '../../domain/entities/trade_side.dart';
import '../../domain/entities/trading_stats.dart';
import '../../domain/entities/stats_period.dart';

/// Remote data source for journal entries against the AWS backend.
abstract class JournalRemoteDataSource {
  Future<List<JournalEntry>> getEntries();
  Future<JournalEntry> createEntry(JournalEntry entry);
  Future<JournalEntry> updateEntry(String entryId, JournalEntry entry);
  Future<void> deleteEntry(String entryId);
  Future<TradingStats> getStats({String period});
}

/// Implementation backed by the CryptoFlow REST API.
class JournalRemoteDataSourceImpl implements JournalRemoteDataSource {
  final AwsApiClient _api;
  JournalRemoteDataSourceImpl({required AwsApiClient apiClient})
      : _api = apiClient;

  @override
  Future<List<JournalEntry>> getEntries() async {
    final response = await _api.get(AwsEndpoints.journalEntries);
    final list = response.data as List<dynamic>;
    return list
        .map((json) => _journalEntryFromApiJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<JournalEntry> createEntry(JournalEntry entry) async {
    final body = _journalEntryToApiJson(entry);
    final response = await _api.post(AwsEndpoints.journalEntries, data: body);
    return _journalEntryFromApiJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<JournalEntry> updateEntry(String entryId, JournalEntry entry) async {
    final body = _journalEntryToApiJson(entry);
    final response =
        await _api.put(AwsEndpoints.journalEntry(entryId), data: body);
    return _journalEntryFromApiJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    await _api.delete(AwsEndpoints.journalEntry(entryId));
  }

  @override
  Future<TradingStats> getStats({String period = 'monthly'}) async {
    final response = await _api.get(
      AwsEndpoints.journalStats,
      queryParameters: {'period': period},
    );
    return _tradingStatsFromApiJson(response.data as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------- Mapping
  // The backend uses ULID string IDs while the domain entity uses int.
  // We convert using the ULID's hashCode so existing local logic still works.
  // The original ULID is preserved in `transactionId` for round-trip mapping.

  JournalEntry _journalEntryFromApiJson(Map<String, dynamic> json) {
    final entryId = json['entryId'] as String? ?? '';
    return JournalEntry(
      id: entryId.hashCode.abs(),
      transactionId: entryId, // preserve server ULID
      symbol: json['symbol'] as String? ?? '',
      side: _parseSide(json['side'] as String?),
      entryPrice: _toDouble(json['entryPrice']),
      exitPrice:
          json['exitPrice'] != null ? _toDouble(json['exitPrice']) : null,
      quantity: _toDouble(json['quantity']),
      pnl: json['pnl'] != null ? _toDouble(json['pnl']) : null,
      pnlPercentage: json['pnlPercentage'] != null
          ? _toDouble(json['pnlPercentage'])
          : null,
      riskRewardRatio: json['riskRewardRatio'] != null
          ? _toDouble(json['riskRewardRatio'])
          : null,
      strategy: json['strategy'] as String?,
      emotion: _parseEmotion(json['emotion'] as String?),
      notes: json['notes'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      screenshotPath: json['screenshotPath'] as String?,
      entryDate: DateTime.parse(json['entryDate'] as String),
      exitDate: json['exitDate'] != null
          ? DateTime.parse(json['exitDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _journalEntryToApiJson(JournalEntry entry) {
    return {
      'symbol': entry.symbol,
      'side': entry.side.toJson(),
      'entryPrice': entry.entryPrice,
      if (entry.exitPrice != null) 'exitPrice': entry.exitPrice,
      'quantity': entry.quantity,
      if (entry.pnl != null) 'pnl': entry.pnl,
      if (entry.pnlPercentage != null) 'pnlPercentage': entry.pnlPercentage,
      if (entry.riskRewardRatio != null)
        'riskRewardRatio': entry.riskRewardRatio,
      if (entry.strategy != null) 'strategy': entry.strategy,
      'emotion': entry.emotion.toJson(),
      if (entry.notes != null) 'notes': entry.notes,
      if (entry.tags.isNotEmpty) 'tags': entry.tags,
      if (entry.screenshotPath != null) 'screenshotPath': entry.screenshotPath,
      'entryDate': entry.entryDate.toIso8601String(),
      if (entry.exitDate != null) 'exitDate': entry.exitDate!.toIso8601String(),
    };
  }

  TradingStats _tradingStatsFromApiJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return TradingStats(
      id: 0,
      period: _parseStatsPeriod(json['period'] as String?),
      periodStart: now.subtract(const Duration(days: 30)),
      periodEnd: now,
      totalTrades: json['totalTrades'] as int? ?? 0,
      winCount: json['closedTrades'] as int? ?? 0,
      lossCount: (json['totalTrades'] as int? ?? 0) -
          (json['closedTrades'] as int? ?? 0),
      winRate: _toDouble(json['winRate']) * 100,
      totalPnl: _toDouble(json['totalPnl']),
      averageRR: 0,
      largestWin: _toDouble(json['bestTrade']),
      largestLoss: _toDouble(json['worstTrade']),
      profitFactor: 0,
      updatedAt: now,
    );
  }

  // ---------------------------------------------------------------- Helpers

  static double _toDouble(dynamic v) => v == null ? 0.0 : (v as num).toDouble();

  static TradeSide _parseSide(String? s) {
    if (s == 'short') return TradeSide.short;
    return TradeSide.long;
  }

  static TradeEmotion _parseEmotion(String? s) {
    return TradeEmotion.values.firstWhere(
      (e) => e.toJson() == s,
      orElse: () => TradeEmotion.neutral,
    );
  }

  static StatsPeriod _parseStatsPeriod(String? s) {
    if (s == 'weekly') return StatsPeriod.weekly;
    if (s == 'all') return StatsPeriod.allTime;
    return StatsPeriod.monthly;
  }
}
