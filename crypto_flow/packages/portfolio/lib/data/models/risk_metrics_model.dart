import '../../domain/entities/risk_metrics.dart';

class PositionSizeResultModel {
  final Map<String, dynamic> _json;
  PositionSizeResultModel.fromJson(this._json);

  PositionSizeResult toEntity() => PositionSizeResult(
        symbol: _json['symbol'] as String? ?? '',
        accountSize: (_json['accountSize'] as num?)?.toDouble() ?? 0,
        riskPercentage: (_json['riskPercentage'] as num?)?.toDouble() ?? 0,
        entryPrice: (_json['entryPrice'] as num?)?.toDouble() ?? 0,
        stopLossPrice: (_json['stopLossPrice'] as num?)?.toDouble() ?? 0,
        positionSize: (_json['positionSize'] as num?)?.toDouble() ?? 0,
        positionValue: (_json['positionValue'] as num?)?.toDouble() ?? 0,
        riskAmount: (_json['riskAmount'] as num?)?.toDouble() ?? 0,
      );
}

class CorrelationMatrixModel {
  final Map<String, dynamic> _json;
  CorrelationMatrixModel.fromJson(this._json);

  CorrelationMatrix toEntity() {
    final symbols = (_json['symbols'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final rawMatrix = (_json['matrix'] as List<dynamic>?) ?? [];
    final matrix = rawMatrix
        .map((row) => (row as List<dynamic>)
            .map((v) => (v as num).toDouble())
            .toList())
        .toList();

    return CorrelationMatrix(
      symbols: symbols,
      matrix: matrix,
      period: _json['period'] as String? ?? 'monthly',
    );
  }
}

class VaRResultModel {
  final Map<String, dynamic> _json;
  VaRResultModel.fromJson(this._json);

  VaRResult toEntity() {
    final components = (_json['componentVaR'] as List<dynamic>?)
            ?.map((e) => ComponentVaRModel.fromJson(e as Map<String, dynamic>).toEntity())
            .toList() ??
        [];

    return VaRResult(
      portfolioValue: (_json['portfolioValue'] as num?)?.toDouble() ?? 0,
      confidence: (_json['confidence'] as num?)?.toDouble() ?? 95,
      holdingPeriodDays: (_json['holdingPeriodDays'] as num?)?.toInt() ?? 1,
      historicalVaR: (_json['historicalVaR'] as num?)?.toDouble() ?? 0,
      historicalVaRPct: (_json['historicalVaRPct'] as num?)?.toDouble() ?? 0,
      componentVaR: components,
    );
  }
}

class ComponentVaRModel {
  final Map<String, dynamic> _json;
  ComponentVaRModel.fromJson(this._json);

  ComponentVaR toEntity() => ComponentVaR(
        symbol: _json['symbol'] as String? ?? '',
        weight: (_json['weight'] as num?)?.toDouble() ?? 0,
        value: (_json['value'] as num?)?.toDouble() ?? 0,
        var_: (_json['var'] as num?)?.toDouble() ?? 0,
      );
}
