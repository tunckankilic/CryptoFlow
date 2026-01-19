import '../../domain/entities/order_book.dart';

/// Data model for OrderBook with JSON parsing capabilities
class OrderBookModel extends OrderBook {
  const OrderBookModel({
    required super.symbol,
    required super.bids,
    required super.asks,
    required super.lastUpdateId,
  });

  /// Create from REST API depth response
  /// Example JSON:
  /// {
  ///   "lastUpdateId": 1027024,
  ///   "bids": [
  ///     ["4.00000000", "431.00000000"],  // [price, qty]
  ///     ["3.99000000", "300.00000000"]
  ///   ],
  ///   "asks": [
  ///     ["4.00000200", "12.00000000"],
  ///     ["5.10000000", "28.00000000"]
  ///   ]
  /// }
  factory OrderBookModel.fromJson(Map<String, dynamic> json, {String? symbol}) {
    return OrderBookModel(
      symbol: symbol ?? '',
      lastUpdateId: json['lastUpdateId'] as int? ?? 0,
      bids: _parseEntries(json['bids'] as List<dynamic>?),
      asks: _parseEntries(json['asks'] as List<dynamic>?),
    );
  }

  /// Create from WebSocket depth stream
  /// Example JSON:
  /// {
  ///   "e": "depthUpdate",
  ///   "s": "BTCUSDT",
  ///   "u": 1027024,        // Final update ID
  ///   "b": [               // Bids
  ///     ["4.00000000", "431.00000000"]
  ///   ],
  ///   "a": [               // Asks
  ///     ["4.00000200", "12.00000000"]
  ///   ]
  /// }
  factory OrderBookModel.fromWsJson(Map<String, dynamic> json) {
    return OrderBookModel(
      symbol: json['s'] as String? ?? '',
      lastUpdateId: json['u'] as int? ?? json['lastUpdateId'] as int? ?? 0,
      bids: _parseEntries(
          json['b'] as List<dynamic>? ?? json['bids'] as List<dynamic>?),
      asks: _parseEntries(
          json['a'] as List<dynamic>? ?? json['asks'] as List<dynamic>?),
    );
  }

  /// Parse bid/ask entries from JSON array
  static List<OrderBookEntry> _parseEntries(List<dynamic>? entries) {
    if (entries == null) return [];
    return entries.map((entry) {
      final list = entry as List<dynamic>;
      return OrderBookEntryModel.fromJson(list);
    }).toList();
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'lastUpdateId': lastUpdateId,
      'bids':
          bids.map((b) => [b.price.toString(), b.quantity.toString()]).toList(),
      'asks':
          asks.map((a) => [a.price.toString(), a.quantity.toString()]).toList(),
    };
  }

  /// Convert model to entity
  OrderBook toEntity() => OrderBook(
        symbol: symbol,
        bids: bids,
        asks: asks,
        lastUpdateId: lastUpdateId,
      );

  /// Create a copy with updated bids/asks (for delta updates)
  OrderBookModel copyWithUpdates({
    List<OrderBookEntry>? newBids,
    List<OrderBookEntry>? newAsks,
    int? newLastUpdateId,
  }) {
    return OrderBookModel(
      symbol: symbol,
      bids: newBids ?? bids,
      asks: newAsks ?? asks,
      lastUpdateId: newLastUpdateId ?? lastUpdateId,
    );
  }
}

/// Data model for OrderBookEntry with JSON parsing
class OrderBookEntryModel extends OrderBookEntry {
  const OrderBookEntryModel({
    required super.price,
    required super.quantity,
  });

  /// Create from JSON array [price, quantity]
  factory OrderBookEntryModel.fromJson(List<dynamic> json) {
    return OrderBookEntryModel(
      price: _parseDouble(json[0]),
      quantity: _parseDouble(json[1]),
    );
  }

  /// Convert to JSON array
  List<String> toJson() => [price.toString(), quantity.toString()];

  // Helper to safely parse double from String or num
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
