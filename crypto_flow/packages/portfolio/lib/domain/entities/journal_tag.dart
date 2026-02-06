import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a reusable tag for journal entries
@immutable
class JournalTag extends Equatable {
  /// Unique identifier
  final int id;

  /// Tag name
  final String name;

  /// Color for UI display
  final int color;

  /// Number of times used
  final int usageCount;

  const JournalTag({
    required this.id,
    required this.name,
    required this.color,
    required this.usageCount,
  });

  /// Creates a copy with the given fields replaced
  JournalTag copyWith({
    int? id,
    String? name,
    int? color,
    int? usageCount,
  }) {
    return JournalTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  List<Object?> get props => [id, name, color, usageCount];
}
