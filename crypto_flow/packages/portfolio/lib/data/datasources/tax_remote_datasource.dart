import 'package:core/network/aws_api_client.dart';
import 'package:core/constants/aws_endpoints.dart';

abstract class TaxRemoteDataSource {
  Future<Map<String, dynamic>> generateTaxReport({
    required int year,
    required String costBasisMethod,
    String? jurisdiction,
  });

  Future<List<Map<String, dynamic>>> listTaxReports();
}

class TaxRemoteDataSourceImpl implements TaxRemoteDataSource {
  final AwsApiClient _client;

  TaxRemoteDataSourceImpl({required AwsApiClient client}) : _client = client;

  @override
  Future<Map<String, dynamic>> generateTaxReport({
    required int year,
    required String costBasisMethod,
    String? jurisdiction,
  }) async {
    final response = await _client.post(
      AwsEndpoints.taxGenerateReport,
      data: {
        'year': year,
        'costBasisMethod': costBasisMethod,
        if (jurisdiction != null) 'jurisdiction': jurisdiction,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> listTaxReports() async {
    final response = await _client.get(AwsEndpoints.taxReports);
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
