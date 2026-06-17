import 'package:core/network/aws_api_client.dart';
import 'package:core/constants/aws_endpoints.dart';
import '../models/chart_pattern_model.dart';

abstract class PatternRemoteDataSource {
  Future<List<ChartPatternModel>> getPatterns(String symbol);
}

class PatternRemoteDataSourceImpl implements PatternRemoteDataSource {
  final AwsApiClient _client;

  PatternRemoteDataSourceImpl({required AwsApiClient client}) : _client = client;

  @override
  Future<List<ChartPatternModel>> getPatterns(String symbol) async {
    final response = await _client.get(AwsEndpoints.patterns(symbol));
    return (response.data as List<dynamic>)
        .map((e) => ChartPatternModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
