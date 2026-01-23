import 'package:mocktail/mocktail.dart';
import 'package:market/domain/entities/ticker.dart';
import 'package:market/domain/repositories/market_repository.dart';
import 'package:market/domain/repositories/websocket_repository.dart';

/// Mock implementation of MarketRepository
class MockMarketRepository extends Mock implements MarketRepository {}

/// Mock implementation of WebSocketRepository
class MockWebSocketRepository extends Mock implements WebSocketRepository {}

/// Register fallback values for mocktail
void registerFallbackValues() {
  registerFallbackValue(const Ticker(
    symbol: 'BTCUSDT',
    baseAsset: 'BTC',
    quoteAsset: 'USDT',
    price: 69000.0,
    priceChange: 1000.0,
    priceChangePercent: 1.5,
    high24h: 70000.0,
    low24h: 68000.0,
    volume: 10000.0,
    quoteVolume: 690000000.0,
    trades: 100000,
  ));
}
