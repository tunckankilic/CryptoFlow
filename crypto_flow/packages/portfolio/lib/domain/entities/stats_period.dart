/// Statistics aggregation period
enum StatsPeriod {
  /// Daily statistics
  daily,

  /// Weekly statistics
  weekly,

  /// Monthly statistics
  monthly,

  /// All-time statistics
  allTime,
}

/// Extension methods for StatsPeriod
extension StatsPeriodX on StatsPeriod {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case StatsPeriod.daily:
        return 'Daily';
      case StatsPeriod.weekly:
        return 'Weekly';
      case StatsPeriod.monthly:
        return 'Monthly';
      case StatsPeriod.allTime:
        return 'All Time';
    }
  }

  /// Serialize to JSON
  String toJson() {
    switch (this) {
      case StatsPeriod.daily:
        return 'daily';
      case StatsPeriod.weekly:
        return 'weekly';
      case StatsPeriod.monthly:
        return 'monthly';
      case StatsPeriod.allTime:
        return 'allTime';
    }
  }

  /// Deserialize from JSON
  static StatsPeriod fromJson(String json) {
    switch (json) {
      case 'daily':
        return StatsPeriod.daily;
      case 'weekly':
        return StatsPeriod.weekly;
      case 'monthly':
        return StatsPeriod.monthly;
      case 'allTime':
        return StatsPeriod.allTime;
      default:
        throw ArgumentError('Unknown stats period: $json');
    }
  }
}
