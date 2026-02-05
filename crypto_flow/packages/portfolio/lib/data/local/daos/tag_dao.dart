import 'package:drift/drift.dart';

import '../../datasources/portfolio_database.dart';
import '../../models/journal_tag_model.dart';

/// Data Access Object for Journal Tags
/// Provides CRUD operations and usage tracking for tags
class TagDao {
  final PortfolioDatabase _db;

  TagDao(this._db);

  // ==================== CRUD Operations ====================

  /// Get all tags ordered by usage count (descending)
  Future<List<JournalTagModel>> getAllTags() async {
    final results = await (_db.select(_db.journalTags)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.usageCount, mode: OrderingMode.desc)
          ]))
        .get();

    return results.map((t) => JournalTagModel.fromDrift(t)).toList();
  }

  /// Get a single tag by ID
  Future<JournalTagModel?> getTagById(int id) async {
    final result = await (_db.select(_db.journalTags)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    return result != null ? JournalTagModel.fromDrift(result) : null;
  }

  /// Get a tag by name
  Future<JournalTagModel?> getTagByName(String name) async {
    final result = await (_db.select(_db.journalTags)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();

    return result != null ? JournalTagModel.fromDrift(result) : null;
  }

  /// Insert a new tag
  Future<int> insertTag(JournalTagModel tag) async {
    return await _db.into(_db.journalTags).insert(tag.toDrift());
  }

  /// Delete a tag by ID
  Future<int> deleteTag(int id) async {
    return await (_db.delete(_db.journalTags)..where((t) => t.id.equals(id)))
        .go();
  }

  // ==================== Usage Tracking ====================

  /// Increment the usage count for a tag
  Future<int> incrementUsage(int id) async {
    final tag = await getTagById(id);
    if (tag == null) return 0;

    return await (_db.update(_db.journalTags)..where((t) => t.id.equals(id)))
        .write(JournalTagsCompanion(usageCount: Value(tag.usageCount + 1)));
  }

  /// Decrement the usage count for a tag
  Future<int> decrementUsage(int id) async {
    final tag = await getTagById(id);
    if (tag == null) return 0;

    final newCount = (tag.usageCount - 1).clamp(0, double.infinity).toInt();
    return await (_db.update(_db.journalTags)..where((t) => t.id.equals(id)))
        .write(JournalTagsCompanion(usageCount: Value(newCount)));
  }

  /// Set the usage count for a tag
  Future<int> setUsageCount(int id, int count) async {
    return await (_db.update(_db.journalTags)..where((t) => t.id.equals(id)))
        .write(JournalTagsCompanion(usageCount: Value(count)));
  }

  // ==================== Stream Operations ====================

  /// Watch all tags for real-time updates
  Stream<List<JournalTagModel>> watchTags() {
    return (_db.select(_db.journalTags)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.usageCount, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((tags) => tags.map((t) => JournalTagModel.fromDrift(t)).toList());
  }
}
