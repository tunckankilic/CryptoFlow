import 'package:equatable/equatable.dart';

/// Position size calculation result
class PositionSizeResult extends Equatable {
  final String symbol;
  final double accountSize;
  final double riskPercentage;
  final double entryPrice;
  final double stopLossPrice;
  final double positionSize;
  final double positionValue;
  final double riskAmount;

  const PositionSizeResult({
    required this.symbol,
    required this.accountSize,
    required this.riskPercentage,
    required this.entryPrice,
    required this.stopLossPrice,
    required this.positionSize,
    required this.positionValue,
    required this.riskAmount,
  });

  @override
  List<Object?> get props => [
        symbol,
        accountSize,
        riskPercentage,
        entryPrice,
        stopLossPrice,
        positionSize,
        positionValue,
        riskAmount,
      ];
}

/// Cross-asset correlation matrix
class CorrelationMatrix extends Equatable {
  final List<String> symbols;
  final List<List<double>> matrix;
  final String period;

  const CorrelationMatrix({
    required this.symbols,
    required this.matrix,
    required this.period,
  });

  @override
  List<Object?> get props => [symbols, matrix, period];
}

/// Value at Risk result
class VaRResult extends Equatable {
  final double portfolioValue;
  final double confidence;
  final int holdingPeriodDays;
  final double historicalVaR;
  final double historicalVaRPct;
  final List<ComponentVaR> componentVaR;

  const VaRResult({
    required this.portfolioValue,
    required this.confidence,
    required this.holdingPeriodDays,
    required this.historicalVaR,
    required this.historicalVaRPct,
    required this.componentVaR,
  });

  @override
  List<Object?> get props => [
        portfolioValue,
        confidence,
        holdingPeriodDays,
        historicalVaR,
        historicalVaRPct,
        componentVaR,
      ];
}

/// Per-asset VaR component
class ComponentVaR extends Equatable {
  final String symbol;
  final double weight;
  final double value;
  final double var_;

  const ComponentVaR({
    required this.symbol,
    required this.weight,
    required this.value,
    required this.var_,
  });

  @override
  List<Object?> get props => [symbol, weight, value, var_];
}
