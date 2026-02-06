import 'package:drift/drift.dart';

/// Journal tags table definition
/// Manages reusable tags for categorizing journal entries
class JournalTags extends Table {
  /// Unique identifier (auto-generated)
  IntColumn get id => integer().autoIncrement()();

  /// Tag name (unique)
  TextColumn get name => text().unique()();

  /// Color value for UI display
  IntColumn get color => integer()();

  /// Number of times this tag has been used
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
}
