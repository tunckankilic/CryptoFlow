/// Emotional state during trade execution
enum TradeEmotion {
  /// Confident and assured
  confident,

  /// Neutral, no strong emotions
  neutral,

  /// Fearful or anxious
  fearful,

  /// Greedy, wanting more
  greedy,

  /// Fear of missing out
  fomo,

  /// Revenge trading after loss
  revenge,
}

/// Extension methods for TradeEmotion
extension TradeEmotionX on TradeEmotion {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case TradeEmotion.confident:
        return 'Confident';
      case TradeEmotion.neutral:
        return 'Neutral';
      case TradeEmotion.fearful:
        return 'Fearful';
      case TradeEmotion.greedy:
        return 'Greedy';
      case TradeEmotion.fomo:
        return 'FOMO';
      case TradeEmotion.revenge:
        return 'Revenge';
    }
  }

  /// Serialize to JSON
  String toJson() {
    switch (this) {
      case TradeEmotion.confident:
        return 'confident';
      case TradeEmotion.neutral:
        return 'neutral';
      case TradeEmotion.fearful:
        return 'fearful';
      case TradeEmotion.greedy:
        return 'greedy';
      case TradeEmotion.fomo:
        return 'fomo';
      case TradeEmotion.revenge:
        return 'revenge';
    }
  }

  /// Deserialize from JSON
  static TradeEmotion fromJson(String json) {
    switch (json) {
      case 'confident':
        return TradeEmotion.confident;
      case 'neutral':
        return TradeEmotion.neutral;
      case 'fearful':
        return TradeEmotion.fearful;
      case 'greedy':
        return TradeEmotion.greedy;
      case 'fomo':
        return TradeEmotion.fomo;
      case 'revenge':
        return TradeEmotion.revenge;
      default:
        throw ArgumentError('Unknown trade emotion: $json');
    }
  }
}
