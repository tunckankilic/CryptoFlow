import 'package:core/network/aws_api_client.dart';
import 'package:core/constants/aws_endpoints.dart';
import '../models/performance_metrics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<PerformanceMetricsModel> getPerformanceAnalytics({
    required String period,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final AwsApiClient _client;

  AnalyticsRemoteDataSourceImpl({required AwsApiClient client})
      : _client = client;

  @override
  Future<PerformanceMetricsModel> getPerformanceAnalytics({
    required String period,
  }) async {
    final response = await _client.get(
      AwsEndpoints.performanceAnalytics,
      queryParameters: {'period': period},
    );
    return PerformanceMetricsModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
