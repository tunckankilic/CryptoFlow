import 'package:drift/drift.dart' as db;

import '../../domain/entities/journal_tag.dart' as domain;
import '../datasources/portfolio_database.dart' as db;

/// Data model for JournalTag entity
class JournalTagModel extends domain.JournalTag {
  const JournalTagModel({
    required super.id,
    required super.name,
    required super.color,
    required super.usageCount,
  });

  /// Create from JSON
  factory JournalTagModel.fromJson(Map<String, dynamic> json) {
    return JournalTagModel(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as int,
      usageCount: json['usageCount'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'usageCount': usageCount,
    };
  }

  /// Convert to domain entity
  domain.JournalTag toEntity() {
    return domain.JournalTag(
      id: id,
      name: name,
      color: color,
      usageCount: usageCount,
    );
  }

  /// Create from domain entity
  factory JournalTagModel.fromEntity(domain.JournalTag tag) {
    return JournalTagModel(
      id: tag.id,
      name: tag.name,
      color: tag.color,
      usageCount: tag.usageCount,
    );
  }

  /// Create from Drift row
  factory JournalTagModel.fromDrift(db.JournalTag driftRow) {
    return JournalTagModel(
      id: driftRow.id,
      name: driftRow.name,
      color: driftRow.color,
      usageCount: driftRow.usageCount,
    );
  }

  /// Convert to Drift companion
  db.JournalTagsCompanion toDrift() {
    return db.JournalTagsCompanion.insert(
      name: name,
      color: color,
      usageCount: db.Value(usageCount),
    );
  }
}
