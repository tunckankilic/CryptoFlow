/// Trading direction for journal entries
enum TradeSide {
  /// Long position (buy low, sell high)
  long,

  /// Short position (sell high, buy low)
  short,
}

/// Extension methods for TradeSide
extension TradeSideX on TradeSide {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case TradeSide.long:
        return 'Long';
      case TradeSide.short:
        return 'Short';
    }
  }

  /// Serialize to JSON
  String toJson() {
    switch (this) {
      case TradeSide.long:
        return 'long';
      case TradeSide.short:
        return 'short';
    }
  }

  /// Deserialize from JSON
  static TradeSide fromJson(String json) {
    switch (json) {
      case 'long':
        return TradeSide.long;
      case 'short':
        return TradeSide.short;
      default:
        throw ArgumentError('Unknown trade side: $json');
    }
  }
}
