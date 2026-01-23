/// Types of technical indicators available for chart analysis

/// Types of technical indicators available for chart analysis
enum IndicatorType {
  /// Relative Strength Index (period: 14)
  rsi,

  /// Exponential Moving Average (period: 9)
  ema9,

  /// Exponential Moving Average (period: 21)
  ema21,

  /// Exponential Moving Average (period: 50)
  ema50,

  /// Simple Moving Average (period: 20)
  sma20,

  /// Moving Average Convergence Divergence
  macd,
}

/// Extension methods for IndicatorType
extension IndicatorTypeExtension on IndicatorType {
  /// Display name for the indicator
  String get displayName {
    switch (this) {
      case IndicatorType.rsi:
        return 'RSI (14)';
      case IndicatorType.ema9:
        return 'EMA (9)';
      case IndicatorType.ema21:
        return 'EMA (21)';
      case IndicatorType.ema50:
        return 'EMA (50)';
      case IndicatorType.sma20:
        return 'SMA (20)';
      case IndicatorType.macd:
        return 'MACD';
    }
  }

  /// Short name for the indicator
  String get shortName {
    switch (this) {
      case IndicatorType.rsi:
        return 'RSI';
      case IndicatorType.ema9:
        return 'EMA9';
      case IndicatorType.ema21:
        return 'EMA21';
      case IndicatorType.ema50:
        return 'EMA50';
      case IndicatorType.sma20:
        return 'SMA20';
      case IndicatorType.macd:
        return 'MACD';
    }
  }

  /// Period used for the indicator calculation
  int get period {
    switch (this) {
      case IndicatorType.rsi:
        return 14;
      case IndicatorType.ema9:
        return 9;
      case IndicatorType.ema21:
        return 21;
      case IndicatorType.ema50:
        return 50;
      case IndicatorType.sma20:
        return 20;
      case IndicatorType.macd:
        return 12; // Fast period
    }
  }

  /// Whether the indicator is displayed as an overlay on the main chart
  bool get isOverlay {
    switch (this) {
      case IndicatorType.ema9:
      case IndicatorType.ema21:
      case IndicatorType.ema50:
      case IndicatorType.sma20:
        return true;
      case IndicatorType.rsi:
      case IndicatorType.macd:
        return false;
    }
  }
}
