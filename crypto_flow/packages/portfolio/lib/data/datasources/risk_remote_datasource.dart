import 'package:core/core.dart';
import '../models/risk_metrics_model.dart';

abstract class RiskRemoteDataSource {
  Future<PositionSizeResultModel> getPositionSize({
    required String symbol,
    required double accountSize,
    required double riskPercentage,
    required double entryPrice,
    required double stopLossPrice,
  });

  Future<CorrelationMatrixModel> getCorrelation({String period = 'monthly'});

  Future<VaRResultModel> getVaR({
    double confidence = 95,
    int holdingPeriodDays = 1,
  });
}

class RiskRemoteDataSourceImpl implements RiskRemoteDataSource {
  final AwsApiClient _client;

  RiskRemoteDataSourceImpl({required AwsApiClient client}) : _client = client;

  @override
  Future<PositionSizeResultModel> getPositionSize({
    required String symbol,
    required double accountSize,
    required double riskPercentage,
    required double entryPrice,
    required double stopLossPrice,
  }) async {
    final response = await _client.get(
      AwsEndpoints.riskPositionSize,
      queryParameters: {
        'symbol': symbol,
        'accountSize': accountSize.toString(),
        'riskPercentage': riskPercentage.toString(),
        'entryPrice': entryPrice.toString(),
        'stopLossPrice': stopLossPrice.toString(),
      },
    );
    return PositionSizeResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CorrelationMatrixModel> getCorrelation({String period = 'monthly'}) async {
    final response = await _client.get(
      AwsEndpoints.riskCorrelation,
      queryParameters: {'period': period},
    );
    return CorrelationMatrixModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<VaRResultModel> getVaR({
    double confidence = 95,
    int holdingPeriodDays = 1,
  }) async {
    final response = await _client.get(
      AwsEndpoints.riskVar,
      queryParameters: {
        'confidence': confidence.toString(),
        'holdingPeriodDays': holdingPeriodDays.toString(),
      },
    );
    return VaRResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}
