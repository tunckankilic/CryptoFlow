import 'package:dio/dio.dart';
import '../entities/fear_greed_index.dart';
import '../error/exceptions.dart';

/// Datasource for Alternative.me Fear & Greed Index API
class FearGreedDatasource {
  final Dio _dio;

  FearGreedDatasource(this._dio);

  /// Fetch current Fear & Greed Index
  ///
  /// Endpoint: https://api.alternative.me/fng/
  Future<FearGreedIndex> getFearGreedIndex() async {
    try {
      final response = await _dio.get('https://api.alternative.me/fng/');

      if (response.statusCode == 200) {
        final data = response.data['data'][0];

        return FearGreedIndex(
          value: int.parse(data['value']),
          classification: data['value_classification'],
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            int.parse(data['timestamp']) * 1000,
          ),
          timeUntilUpdate: int.parse(data['time_until_update'] ?? '0'),
        );
      } else {
        throw ServerException(message: 'Failed to load Fear & Greed Index');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(message: 'Failed to parse Fear & Greed Index');
    }
  }
}
