import 'package:flutter/foundation.dart';

/// Utility class for calculating technical indicators using isolates
/// for heavy computation to avoid blocking the UI thread
class TechnicalIndicators {
  /// Calculate Simple Moving Average using isolate
  ///
  /// [prices] - List of price values
  /// [period] - Number of periods for the moving average
  ///
  /// Returns list of MA values (zeros for insufficient data points)
  static Future<List<double>> calculateMA(
    List<double> prices,
    int period,
  ) async {
    if (prices.isEmpty || period <= 0) {
      return [];
    }

    return compute(_calculateMAIsolate, {
      'prices': prices,
      'period': period,
    });
  }

  /// Isolate function for MA calculation
  static List<double> _calculateMAIsolate(Map<String, dynamic> params) {
    final prices = params['prices'] as List<double>;
    final period = params['period'] as int;

    final result = <double>[];

    for (int i = 0; i < prices.length; i++) {
      if (i < period - 1) {
        // Not enough data points for MA
        result.add(0);
        continue;
      }

      // Calculate sum of last 'period' prices
      double sum = 0;
      for (int j = i - period + 1; j <= i; j++) {
        sum += prices[j];
      }

      result.add(sum / period);
    }

    return result;
  }

  /// Calculate Exponential Moving Average using isolate
  ///
  /// [prices] - List of price values
  /// [period] - Number of periods for the EMA
  ///
  /// Returns list of EMA values
  static Future<List<double>> calculateEMA(
    List<double> prices,
    int period,
  ) async {
    if (prices.isEmpty || period <= 0) {
      return [];
    }

    return compute(_calculateEMAIsolate, {
      'prices': prices,
      'period': period,
    });
  }

  /// Isolate function for EMA calculation
  static List<double> _calculateEMAIsolate(Map<String, dynamic> params) {
    final prices = params['prices'] as List<double>;
    final period = params['period'] as int;

    if (prices.length < period) {
      return List.filled(prices.length, 0);
    }

    final multiplier = 2.0 / (period + 1);
    final result = <double>[];

    // First EMA value is SMA
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += prices[i];
      result.add(0);
    }

    double ema = sum / period;
    result[period - 1] = ema;

    // Calculate subsequent EMA values
    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] - ema) * multiplier + ema;
      result.add(ema);
    }

    return result;
  }
}
