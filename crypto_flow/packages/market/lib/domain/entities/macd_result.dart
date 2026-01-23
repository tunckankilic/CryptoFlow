import 'package:equatable/equatable.dart';

/// Result of MACD calculation containing all three components
class MACDResult extends Equatable {
  /// MACD line values (fast EMA - slow EMA)
  final List<double?> macdLine;

  /// Signal line values (EMA of MACD line)
  final List<double?> signalLine;

  /// Histogram values (MACD line - Signal line)
  final List<double?> histogram;

  const MACDResult({
    required this.macdLine,
    required this.signalLine,
    required this.histogram,
  });

  /// Creates an empty MACD result
  const MACDResult.empty()
      : macdLine = const [],
        signalLine = const [],
        histogram = const [];

  /// Returns true if the result has no data
  bool get isEmpty => macdLine.isEmpty;

  /// Returns the number of data points
  int get length => macdLine.length;

  /// Gets the latest MACD value
  double? get latestMacd => macdLine.isNotEmpty ? macdLine.last : null;

  /// Gets the latest signal value
  double? get latestSignal => signalLine.isNotEmpty ? signalLine.last : null;

  /// Gets the latest histogram value
  double? get latestHistogram => histogram.isNotEmpty ? histogram.last : null;

  /// Returns true if MACD crossed above signal line at the last point
  bool get bullishCrossover {
    if (macdLine.length < 2 || signalLine.length < 2) return false;

    final prevMacd = macdLine[macdLine.length - 2];
    final currMacd = macdLine.last;
    final prevSignal = signalLine[signalLine.length - 2];
    final currSignal = signalLine.last;

    if (prevMacd == null ||
        currMacd == null ||
        prevSignal == null ||
        currSignal == null) {
      return false;
    }

    return prevMacd <= prevSignal && currMacd > currSignal;
  }

  /// Returns true if MACD crossed below signal line at the last point
  bool get bearishCrossover {
    if (macdLine.length < 2 || signalLine.length < 2) return false;

    final prevMacd = macdLine[macdLine.length - 2];
    final currMacd = macdLine.last;
    final prevSignal = signalLine[signalLine.length - 2];
    final currSignal = signalLine.last;

    if (prevMacd == null ||
        currMacd == null ||
        prevSignal == null ||
        currSignal == null) {
      return false;
    }

    return prevMacd >= prevSignal && currMacd < currSignal;
  }

  @override
  List<Object?> get props => [macdLine, signalLine, histogram];
}
