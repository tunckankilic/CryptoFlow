import 'package:core/core.dart';

import '../../domain/entities/watchlist_item.dart';

/// Remote data source for watchlist operations against the AWS backend.
abstract class WatchlistRemoteDataSource {
  Future<List<WatchlistItem>> getWatchlist();
  Future<void> addToWatchlist(String symbol);
  Future<void> removeFromWatchlist(String symbol);
  Future<void> reorderWatchlist(List<WatchlistItem> items);
}

/// Implementation backed by the CryptoFlow REST API.
class WatchlistRemoteDataSourceImpl implements WatchlistRemoteDataSource {
  final AwsApiClient _api;
  WatchlistRemoteDataSourceImpl({required AwsApiClient apiClient})
      : _api = apiClient;

  @override
  Future<List<WatchlistItem>> getWatchlist() async {
    final response = await _api.get(AwsEndpoints.watchlist);
    final list = response.data as List<dynamic>;
    return list
        .map((json) => _itemFromApiJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addToWatchlist(String symbol) async {
    await _api.post(AwsEndpoints.watchlist, data: {'symbol': symbol});
  }

  @override
  Future<void> removeFromWatchlist(String symbol) async {
    await _api.delete(AwsEndpoints.watchlistSymbol(symbol));
  }

  @override
  Future<void> reorderWatchlist(List<WatchlistItem> items) async {
    final body = {
      'items': items
          .map((item) => {'symbol': item.symbol, 'order': item.order})
          .toList(),
    };
    await _api.put(AwsEndpoints.watchlistReorder, data: body);
  }

  // ---------------------------------------------------------------- Mapping

  WatchlistItem _itemFromApiJson(Map<String, dynamic> json) {
    return WatchlistItem(
      symbol: json['symbol'] as String? ?? '',
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
      order: json['order'] as int? ?? json['sortOrder'] as int? ?? 0,
    );
  }
}
