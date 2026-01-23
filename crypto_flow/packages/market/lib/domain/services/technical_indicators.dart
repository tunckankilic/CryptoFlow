import '../entities/candle.dart';
import '../entities/macd_result.dart';

/// Service for calculating technical indicators on candlestick data
class TechnicalIndicators {
  /// Calculates RSI (Relative Strength Index) using Wilder's smoothed method
  ///
  /// [candles] - List of candles to calculate RSI for
  /// [period] - RSI period (default: 14)
  ///
  /// Returns a list of RSI values (0-100), with null for insufficient data
  static List<double?> calculateRSI(List<Candle> candles, {int period = 14}) {
    if (candles.length < period + 1) {
      return List.filled(candles.length, null);
    }

    final result = List<double?>.filled(candles.length, null);

    // Calculate price changes
    final changes = <double>[];
    for (int i = 1; i < candles.length; i++) {
      changes.add(candles[i].close - candles[i - 1].close);
    }

    // Initial average gain and loss
    double avgGain = 0;
    double avgLoss = 0;

    for (int i = 0; i < period; i++) {
      if (changes[i] > 0) {
        avgGain += changes[i];
      } else {
        avgLoss += changes[i].abs();
      }
    }

    avgGain /= period;
    avgLoss /= period;

    // First RSI value
    if (avgLoss == 0) {
      result[period] = 100;
    } else {
      final rs = avgGain / avgLoss;
      result[period] = 100 - (100 / (1 + rs));
    }

    // Wilder's smoothing for subsequent values
    for (int i = period; i < changes.length; i++) {
      final change = changes[i];
      final gain = change > 0 ? change : 0.0;
      final loss = change < 0 ? change.abs() : 0.0;

      avgGain = ((avgGain * (period - 1)) + gain) / period;
      avgLoss = ((avgLoss * (period - 1)) + loss) / period;

      if (avgLoss == 0) {
        result[i + 1] = 100;
      } else {
        final rs = avgGain / avgLoss;
        result[i + 1] = 100 - (100 / (1 + rs));
      }
    }

    return result;
  }

  /// Calculates EMA (Exponential Moving Average)
  ///
  /// [candles] - List of candles to calculate EMA for
  /// [period] - EMA period (default: 21)
  ///
  /// Returns a list of EMA values, with null for insufficient data
  static List<double?> calculateEMA(List<Candle> candles, {int period = 21}) {
    if (candles.isEmpty) return [];
    if (candles.length < period) {
      return List.filled(candles.length, null);
    }

    final result = List<double?>.filled(candles.length, null);
    final multiplier = 2 / (period + 1);

    // Initial SMA for first EMA value
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += candles[i].close;
    }
    result[period - 1] = sum / period;

    // Calculate EMA for remaining values
    for (int i = period; i < candles.length; i++) {
      final prevEma = result[i - 1]!;
      result[i] = (candles[i].close - prevEma) * multiplier + prevEma;
    }

    return result;
  }

  /// Calculates SMA (Simple Moving Average)
  ///
  /// [candles] - List of candles to calculate SMA for
  /// [period] - SMA period (default: 20)
  ///
  /// Returns a list of SMA values, with null for insufficient data
  static List<double?> calculateSMA(List<Candle> candles, {int period = 20}) {
    if (candles.isEmpty) return [];
    if (candles.length < period) {
      return List.filled(candles.length, null);
    }

    final result = List<double?>.filled(candles.length, null);

    // Calculate rolling sum
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += candles[i].close;
    }
    result[period - 1] = sum / period;

    // Sliding window for remaining values
    for (int i = period; i < candles.length; i++) {
      sum = sum - candles[i - period].close + candles[i].close;
      result[i] = sum / period;
    }

    return result;
  }

  /// Calculates MACD (Moving Average Convergence Divergence)
  ///
  /// [candles] - List of candles to calculate MACD for
  /// [fastPeriod] - Fast EMA period (default: 12)
  /// [slowPeriod] - Slow EMA period (default: 26)
  /// [signalPeriod] - Signal line period (default: 9)
  ///
  /// Returns MACDResult containing MACD line, signal line, and histogram
  static MACDResult calculateMACD(
    List<Candle> candles, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (candles.length < slowPeriod + signalPeriod) {
      return MACDResult(
        macdLine: List.filled(candles.length, null),
        signalLine: List.filled(candles.length, null),
        histogram: List.filled(candles.length, null),
      );
    }

    // Calculate fast and slow EMAs
    final fastEma = calculateEMA(candles, period: fastPeriod);
    final slowEma = calculateEMA(candles, period: slowPeriod);

    // Calculate MACD line (fast EMA - slow EMA)
    final macdLine = List<double?>.filled(candles.length, null);
    for (int i = slowPeriod - 1; i < candles.length; i++) {
      if (fastEma[i] != null && slowEma[i] != null) {
        macdLine[i] = fastEma[i]! - slowEma[i]!;
      }
    }

    // Calculate signal line (EMA of MACD line)
    final signalLine = List<double?>.filled(candles.length, null);
    final macdMultiplier = 2 / (signalPeriod + 1);

    // Find first valid MACD value for initial signal
    int firstValidIndex = -1;
    double macdSum = 0;
    int count = 0;

    for (int i = slowPeriod - 1;
        i < candles.length && count < signalPeriod;
        i++) {
      if (macdLine[i] != null) {
        if (firstValidIndex == -1) firstValidIndex = i;
        macdSum += macdLine[i]!;
        count++;
      }
    }

    if (count == signalPeriod && firstValidIndex >= 0) {
      final signalStartIndex = firstValidIndex + signalPeriod - 1;
      signalLine[signalStartIndex] = macdSum / signalPeriod;

      // Calculate remaining signal values
      for (int i = signalStartIndex + 1; i < candles.length; i++) {
        if (macdLine[i] != null && signalLine[i - 1] != null) {
          signalLine[i] = (macdLine[i]! - signalLine[i - 1]!) * macdMultiplier +
              signalLine[i - 1]!;
        }
      }
    }

    // Calculate histogram (MACD line - signal line)
    final histogram = List<double?>.filled(candles.length, null);
    for (int i = 0; i < candles.length; i++) {
      if (macdLine[i] != null && signalLine[i] != null) {
        histogram[i] = macdLine[i]! - signalLine[i]!;
      }
    }

    return MACDResult(
      macdLine: macdLine,
      signalLine: signalLine,
      histogram: histogram,
    );
  }

  /// Calculates Bollinger Bands
  ///
  /// [candles] - List of candles
  /// [period] - SMA period (default: 20)
  /// [stdDev] - Standard deviation multiplier (default: 2)
  ///
  /// Returns a tuple (upper, middle, lower) bands
  static (List<double?>, List<double?>, List<double?>) calculateBollingerBands(
    List<Candle> candles, {
    int period = 20,
    double stdDev = 2.0,
  }) {
    if (candles.isEmpty) {
      return ([], [], []);
    }

    final middle = calculateSMA(candles, period: period);
    final upper = List<double?>.filled(candles.length, null);
    final lower = List<double?>.filled(candles.length, null);

    for (int i = period - 1; i < candles.length; i++) {
      if (middle[i] == null) continue;

      // Calculate standard deviation
      double sumSquares = 0;
      for (int j = i - period + 1; j <= i; j++) {
        final diff = candles[j].close - middle[i]!;
        sumSquares += diff * diff;
      }
      final sd = (sumSquares / period).sqrt();

      upper[i] = middle[i]! + (stdDev * sd);
      lower[i] = middle[i]! - (stdDev * sd);
    }

    return (upper, middle, lower);
  }
}

extension on double {
  double sqrt() => this < 0
      ? 0
      : double.parse(
                (this).toStringAsFixed(10),
              ).toDouble().compareTo(0) >=
              0
          ? _sqrt(this)
          : 0;
}

double _sqrt(double x) {
  if (x < 0) return 0;
  if (x == 0) return 0;

  double guess = x / 2;
  for (int i = 0; i < 20; i++) {
    guess = (guess + x / guess) / 2;
  }
  return guess;
}
