import 'dart:convert';

import 'package:drift/drift.dart' as db;

import '../../domain/entities/journal_entry.dart' as domain;
import '../../domain/entities/trade_side.dart';
import '../../domain/entities/trade_emotion.dart';
import '../datasources/portfolio_database.dart' as db;

/// Data model for JournalEntry entity
class JournalEntryModel extends domain.JournalEntry {
  const JournalEntryModel({
    required super.id,
    super.transactionId,
    required super.symbol,
    required super.side,
    required super.entryPrice,
    super.exitPrice,
    required super.quantity,
    super.pnl,
    super.pnlPercentage,
    super.riskRewardRatio,
    super.strategy,
    required super.emotion,
    super.notes,
    super.tags,
    super.screenshotPath,
    required super.entryDate,
    super.exitDate,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from JSON
  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as int,
      transactionId: json['transactionId'] as String?,
      symbol: json['symbol'] as String,
      side: TradeSideX.fromJson(json['side'] as String),
      entryPrice: (json['entryPrice'] as num).toDouble(),
      exitPrice: json['exitPrice'] != null
          ? (json['exitPrice'] as num).toDouble()
          : null,
      quantity: (json['quantity'] as num).toDouble(),
      pnl: json['pnl'] != null ? (json['pnl'] as num).toDouble() : null,
      pnlPercentage: json['pnlPercentage'] != null
          ? (json['pnlPercentage'] as num).toDouble()
          : null,
      riskRewardRatio: json['riskRewardRatio'] != null
          ? (json['riskRewardRatio'] as num).toDouble()
          : null,
      strategy: json['strategy'] as String?,
      emotion: TradeEmotionX.fromJson(json['emotion'] as String),
      notes: json['notes'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(jsonDecode(json['tags'] as String))
          : [],
      screenshotPath: json['screenshotPath'] as String?,
      entryDate: DateTime.parse(json['entryDate'] as String),
      exitDate: json['exitDate'] != null
          ? DateTime.parse(json['exitDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'symbol': symbol,
      'side': side.toJson(),
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'quantity': quantity,
      'pnl': pnl,
      'pnlPercentage': pnlPercentage,
      'riskRewardRatio': riskRewardRatio,
      'strategy': strategy,
      'emotion': emotion.toJson(),
      'notes': notes,
      'tags': jsonEncode(tags),
      'screenshotPath': screenshotPath,
      'entryDate': entryDate.toIso8601String(),
      'exitDate': exitDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  domain.JournalEntry toEntity() {
    return domain.JournalEntry(
      id: id,
      transactionId: transactionId,
      symbol: symbol,
      side: side,
      entryPrice: entryPrice,
      exitPrice: exitPrice,
      quantity: quantity,
      pnl: pnl,
      pnlPercentage: pnlPercentage,
      riskRewardRatio: riskRewardRatio,
      strategy: strategy,
      emotion: emotion,
      notes: notes,
      tags: tags,
      screenshotPath: screenshotPath,
      entryDate: entryDate,
      exitDate: exitDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory JournalEntryModel.fromEntity(domain.JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      transactionId: entry.transactionId,
      symbol: entry.symbol,
      side: entry.side,
      entryPrice: entry.entryPrice,
      exitPrice: entry.exitPrice,
      quantity: entry.quantity,
      pnl: entry.pnl,
      pnlPercentage: entry.pnlPercentage,
      riskRewardRatio: entry.riskRewardRatio,
      strategy: entry.strategy,
      emotion: entry.emotion,
      notes: entry.notes,
      tags: entry.tags,
      screenshotPath: entry.screenshotPath,
      entryDate: entry.entryDate,
      exitDate: entry.exitDate,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  /// Create from Drift row
  factory JournalEntryModel.fromDrift(db.JournalEntry driftRow) {
    return JournalEntryModel(
      id: driftRow.id,
      transactionId: driftRow.transactionId,
      symbol: driftRow.symbol,
      side: TradeSideX.fromJson(driftRow.side),
      entryPrice: driftRow.entryPrice,
      exitPrice: driftRow.exitPrice,
      quantity: driftRow.quantity,
      pnl: driftRow.pnl,
      pnlPercentage: driftRow.pnlPercentage,
      riskRewardRatio: driftRow.riskRewardRatio,
      strategy: driftRow.strategy,
      emotion: TradeEmotionX.fromJson(driftRow.emotion),
      notes: driftRow.notes,
      tags: List<String>.from(jsonDecode(driftRow.tags)),
      screenshotPath: driftRow.screenshotPath,
      entryDate: driftRow.entryDate,
      exitDate: driftRow.exitDate,
      createdAt: driftRow.createdAt,
      updatedAt: driftRow.updatedAt,
    );
  }

  /// Convert to Drift companion
  db.JournalEntriesCompanion toDrift() {
    return db.JournalEntriesCompanion.insert(
      transactionId: db.Value(transactionId),
      symbol: symbol,
      side: side.toJson(),
      entryPrice: entryPrice,
      exitPrice: db.Value(exitPrice),
      quantity: quantity,
      pnl: db.Value(pnl),
      pnlPercentage: db.Value(pnlPercentage),
      riskRewardRatio: db.Value(riskRewardRatio),
      strategy: db.Value(strategy),
      emotion: emotion.toJson(),
      notes: db.Value(notes),
      tags: jsonEncode(tags),
      screenshotPath: db.Value(screenshotPath),
      entryDate: entryDate,
      exitDate: db.Value(exitDate),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
