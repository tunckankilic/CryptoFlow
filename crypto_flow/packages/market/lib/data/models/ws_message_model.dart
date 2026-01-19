import '../../domain/entities/trade.dart';

/// WebSocket message event types from Binance
enum WsMessageType {
  ticker,
  miniTicker,
  kline,
  depthUpdate,
  trade,
  aggTrade,
  unknown,
}

/// Wrapper for WebSocket messages with type detection
class WsMessage {
  final WsMessageType type;
  final Map<String, dynamic> data;
  final String? symbol;
  final DateTime timestamp;

  const WsMessage({
    required this.type,
    required this.data,
    this.symbol,
    required this.timestamp,
  });

  /// Parse WebSocket message and detect type
  factory WsMessage.fromJson(Map<String, dynamic> json) {
    final eventType = json['e'] as String?;
    final type = _parseEventType(eventType);

    return WsMessage(
      type: type,
      data: json,
      symbol: json['s'] as String?,
      timestamp: json['E'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['E'] as int)
          : DateTime.now(),
    );
  }

  /// Parse array message (for all tickers stream)
  static List<WsMessage> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray
        .whereType<Map<String, dynamic>>()
        .map((json) => WsMessage.fromJson(json))
        .toList();
  }

  static WsMessageType _parseEventType(String? eventType) {
    switch (eventType) {
      case '24hrTicker':
        return WsMessageType.ticker;
      case '24hrMiniTicker':
        return WsMessageType.miniTicker;
      case 'kline':
        return WsMessageType.kline;
      case 'depthUpdate':
        return WsMessageType.depthUpdate;
      case 'trade':
        return WsMessageType.trade;
      case 'aggTrade':
        return WsMessageType.aggTrade;
      default:
        return WsMessageType.unknown;
    }
  }

  /// Check if this is a kline closed event
  bool get isKlineClosed {
    if (type != WsMessageType.kline) return false;
    final k = data['k'] as Map<String, dynamic>?;
    return k?['x'] as bool? ?? false;
  }
}

/// Trade model for WebSocket trade stream
class TradeModel extends Trade {
  const TradeModel({
    required super.id,
    required super.symbol,
    required super.price,
    required super.quantity,
    required super.time,
    required super.isBuyerMaker,
    super.isBestMatch,
  });

  /// Create from WebSocket trade stream
  /// {
  ///   "e": "trade",
  ///   "s": "BTCUSDT",
  ///   "t": 12345,         // Trade ID
  ///   "p": "0.001",       // Price
  ///   "q": "100",         // Quantity
  ///   "T": 123456785,     // Trade time
  ///   "m": true,          // Is the buyer the market maker?
  ///   "M": true           // Is best match?
  /// }
  factory TradeModel.fromWsJson(Map<String, dynamic> json) {
    return TradeModel(
      id: json['t'] as int,
      symbol: json['s'] as String,
      price: _parseDouble(json['p']),
      quantity: _parseDouble(json['q']),
      time: DateTime.fromMillisecondsSinceEpoch(json['T'] as int),
      isBuyerMaker: json['m'] as bool? ?? false,
      isBestMatch: json['M'] as bool? ?? true,
    );
  }

  /// Create from REST API trades response
  /// {
  ///   "id": 28457,
  ///   "price": "4.00000100",
  ///   "qty": "12.00000000",
  ///   "time": 1499865549590,
  ///   "isBuyerMaker": true,
  ///   "isBestMatch": true
  /// }
  factory TradeModel.fromJson(Map<String, dynamic> json,
      {required String symbol}) {
    return TradeModel(
      id: json['id'] as int,
      symbol: symbol,
      price: _parseDouble(json['price']),
      quantity: _parseDouble(json['qty']),
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
      isBuyerMaker: json['isBuyerMaker'] as bool? ?? false,
      isBestMatch: json['isBestMatch'] as bool? ?? true,
    );
  }

  /// Convert model to entity
  Trade toEntity() => Trade(
        id: id,
        symbol: symbol,
        price: price,
        quantity: quantity,
        time: time,
        isBuyerMaker: isBuyerMaker,
        isBestMatch: isBestMatch,
      );

  // Helper to safely parse double from String or num
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Symbol info model for exchange info
class SymbolInfoModel {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final String status;
  final int baseAssetPrecision;
  final int quoteAssetPrecision;

  const SymbolInfoModel({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.status,
    required this.baseAssetPrecision,
    required this.quoteAssetPrecision,
  });

  factory SymbolInfoModel.fromJson(Map<String, dynamic> json) {
    return SymbolInfoModel(
      symbol: json['symbol'] as String,
      baseAsset: json['baseAsset'] as String,
      quoteAsset: json['quoteAsset'] as String,
      status: json['status'] as String,
      baseAssetPrecision: json['baseAssetPrecision'] as int? ?? 8,
      quoteAssetPrecision: json['quoteAssetPrecision'] as int? ?? 8,
    );
  }

  bool get isTradable => status == 'TRADING';
}
