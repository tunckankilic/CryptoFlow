# CryptoFlow - Complete Project Documentation

## 📋 İçindekiler

1. [Proje Özeti](#proje-özeti)
2. [Clean Architecture Yapısı](#clean-architecture-yapısı)
3. [Antigravity IDE Promptları](#antigravity-ide-promptları)
4. [Binance WebSocket Entegrasyonu](#binance-websocket-entegrasyonu)
5. [Transfer Prompt](#transfer-prompt)

---

# 🎯 Proje Özeti

## CryptoFlow Nedir?

Real-time kripto para takip uygulaması. Binance WebSocket API kullanarak anlık fiyat, grafik ve order book verisi gösterir.

## Teknik Özellikler

| Kategori | Teknoloji |
|----------|-----------|
| State Management | BLoC + Stream |
| Architecture | Clean Architecture (Modular) |
| Real-time Data | Binance WebSocket Streams |
| Charts | fl_chart / syncfusion_flutter_charts |
| Local DB | Drift (SQLite) + Hive |
| DI | GetIt + Injectable |
| Navigation | GoRouter |
| Testing | Mocktail + BLoC Test |

## Binance API Endpoints

```
WebSocket Streams:
- wss://stream.binance.com:9443/ws/btcusdt@ticker      (24h ticker)
- wss://stream.binance.com:9443/ws/btcusdt@kline_1m    (candlestick)
- wss://stream.binance.com:9443/ws/btcusdt@depth20     (order book)
- wss://stream.binance.com:9443/ws/!miniTicker@arr     (all tickers)

REST API:
- https://api.binance.com/api/v3/ticker/24hr           (24h stats)
- https://api.binance.com/api/v3/klines                (historical candles)
- https://api.binance.com/api/v3/exchangeInfo          (trading pairs)
```

---

# 📁 Clean Architecture Yapısı

```
cryptoflow/
├── packages/                           # 🔌 Modüler Paketler
│   │
│   ├── core/                           # 🧱 Temel Altyapı
│   │   ├── lib/
│   │   │   ├── core.dart
│   │   │   ├── constants/
│   │   │   │   ├── api_endpoints.dart
│   │   │   │   ├── app_constants.dart
│   │   │   │   ├── ws_channels.dart
│   │   │   │   └── storage_keys.dart
│   │   │   ├── error/
│   │   │   │   ├── exceptions.dart
│   │   │   │   └── failures.dart
│   │   │   ├── network/
│   │   │   │   ├── api_client.dart
│   │   │   │   ├── websocket_client.dart
│   │   │   │   └── network_info.dart
│   │   │   ├── usecases/
│   │   │   │   └── usecase.dart
│   │   │   └── utils/
│   │   │       ├── extensions.dart
│   │   │       ├── formatters.dart
│   │   │       └── debouncer.dart
│   │   └── pubspec.yaml
│   │
│   ├── design_system/                  # 🎨 UI Kit
│   │   ├── lib/
│   │   │   ├── design_system.dart
│   │   │   ├── atoms/
│   │   │   │   ├── app_colors.dart         # Kripto renkleri (green/red)
│   │   │   │   ├── app_typography.dart
│   │   │   │   └── app_spacing.dart
│   │   │   ├── molecules/
│   │   │   │   ├── price_text.dart         # Animasyonlu fiyat
│   │   │   │   ├── percent_change.dart     # +/- badge
│   │   │   │   ├── sparkline.dart          # Mini chart
│   │   │   │   └── loading_shimmer.dart
│   │   │   ├── organisms/
│   │   │   │   ├── coin_tile.dart
│   │   │   │   ├── price_card.dart
│   │   │   │   ├── order_book_view.dart
│   │   │   │   └── candle_chart.dart
│   │   │   └── theme/
│   │   │       ├── app_theme.dart
│   │   │       └── dark_theme.dart
│   │   └── pubspec.yaml
│   │
│   ├── market/                         # 📊 Market Verileri
│   │   ├── lib/
│   │   │   ├── market.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── ticker.dart
│   │   │   │   │   ├── candle.dart
│   │   │   │   │   ├── order_book.dart
│   │   │   │   │   ├── trade.dart
│   │   │   │   │   └── symbol_info.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── market_repository.dart
│   │   │   │   │   └── websocket_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_all_tickers.dart
│   │   │   │       ├── get_ticker_stream.dart
│   │   │   │       ├── get_candles.dart
│   │   │   │       ├── get_candle_stream.dart
│   │   │   │       ├── get_order_book.dart
│   │   │   │       ├── get_order_book_stream.dart
│   │   │   │       └── search_symbols.dart
│   │   │   │
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── ticker_model.dart
│   │   │   │   │   ├── candle_model.dart
│   │   │   │   │   ├── order_book_model.dart
│   │   │   │   │   └── ws_message_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── market_remote_datasource.dart
│   │   │   │   │   ├── market_local_datasource.dart
│   │   │   │   │   └── binance_websocket_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── market_repository_impl.dart
│   │   │   │       └── websocket_repository_impl.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── ticker_list/
│   │   │       │   │   ├── ticker_list_bloc.dart
│   │   │       │   │   ├── ticker_list_event.dart
│   │   │       │   │   └── ticker_list_state.dart
│   │   │       │   ├── ticker_detail/
│   │   │       │   │   ├── ticker_detail_bloc.dart
│   │   │       │   │   ├── ticker_detail_event.dart
│   │   │       │   │   └── ticker_detail_state.dart
│   │   │       │   ├── candle/
│   │   │       │   │   ├── candle_bloc.dart
│   │   │       │   │   ├── candle_event.dart
│   │   │       │   │   └── candle_state.dart
│   │   │       │   └── order_book/
│   │   │       │       ├── order_book_bloc.dart
│   │   │       │       ├── order_book_event.dart
│   │   │       │       └── order_book_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── market_list_page.dart
│   │   │       │   ├── ticker_detail_page.dart
│   │   │       │   └── search_page.dart
│   │   │       └── widgets/
│   │   │           ├── ticker_list_tile.dart
│   │   │           ├── interval_selector.dart
│   │   │           ├── order_book_ladder.dart
│   │   │           └── depth_chart.dart
│   │   │
│   │   └── pubspec.yaml
│   │
│   ├── portfolio/                      # 💼 Portföy Yönetimi
│   │   ├── lib/
│   │   │   ├── portfolio.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── holding.dart
│   │   │   │   │   ├── transaction.dart
│   │   │   │   │   └── portfolio_summary.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── portfolio_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_holdings.dart
│   │   │   │       ├── add_transaction.dart
│   │   │   │       ├── get_portfolio_value.dart
│   │   │   │       ├── get_pnl.dart
│   │   │   │       └── watch_portfolio_value.dart
│   │   │   │
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── holding_model.dart
│   │   │   │   │   └── transaction_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── portfolio_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── portfolio_repository_impl.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── portfolio_bloc.dart
│   │   │       │   ├── portfolio_event.dart
│   │   │       │   └── portfolio_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── portfolio_page.dart
│   │   │       │   └── add_transaction_page.dart
│   │   │       └── widgets/
│   │   │           ├── holding_tile.dart
│   │   │           ├── portfolio_chart.dart
│   │   │           ├── pnl_card.dart
│   │   │           └── allocation_pie.dart
│   │   │
│   │   └── pubspec.yaml
│   │
│   ├── alerts/                         # 🔔 Fiyat Alarmları
│   │   ├── lib/
│   │   │   ├── alerts.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── price_alert.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── alert_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── create_alert.dart
│   │   │   │       ├── delete_alert.dart
│   │   │   │       ├── get_alerts.dart
│   │   │   │       └── check_alerts.dart
│   │   │   │
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── price_alert_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── alert_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── alert_repository_impl.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── alert_bloc.dart
│   │   │       │   ├── alert_event.dart
│   │   │       │   └── alert_state.dart
│   │   │       ├── pages/
│   │   │       │   └── alerts_page.dart
│   │   │       └── widgets/
│   │   │           ├── alert_tile.dart
│   │   │           └── create_alert_sheet.dart
│   │   │
│   │   └── pubspec.yaml
│   │
│   ├── watchlist/                      # ⭐ Takip Listesi
│   │   ├── lib/
│   │   │   ├── watchlist.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── watchlist_item.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── watchlist_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── add_to_watchlist.dart
│   │   │   │       ├── remove_from_watchlist.dart
│   │   │   │       ├── get_watchlist.dart
│   │   │   │       ├── is_in_watchlist.dart
│   │   │   │       └── reorder_watchlist.dart
│   │   │   │
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── watchlist_item_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── watchlist_local_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── watchlist_repository_impl.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── watchlist_bloc.dart
│   │   │       │   ├── watchlist_event.dart
│   │   │       │   └── watchlist_state.dart
│   │   │       ├── pages/
│   │   │       │   └── watchlist_page.dart
│   │   │       └── widgets/
│   │   │           └── watchlist_tile.dart
│   │   │
│   │   └── pubspec.yaml
│   │
│   └── settings/                       # ⚙️ Ayarlar
│       ├── lib/
│       │   ├── settings.dart
│       │   │
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── user_settings.dart
│       │   │   ├── repositories/
│       │   │   │   └── settings_repository.dart
│       │   │   └── usecases/
│       │   │       ├── get_settings.dart
│       │   │       ├── update_currency.dart
│       │   │       └── update_theme.dart
│       │   │
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── user_settings_model.dart
│       │   │   ├── datasources/
│       │   │   │   └── settings_local_datasource.dart
│       │   │   └── repositories/
│       │   │       └── settings_repository_impl.dart
│       │   │
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── settings_bloc.dart
│       │       │   ├── settings_event.dart
│       │       │   └── settings_state.dart
│       │       └── pages/
│       │           └── settings_page.dart
│       │
│       └── pubspec.yaml
│
├── lib/                                # 🚀 Ana Uygulama
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── config/
│   │   ├── app_config.dart
│   │   └── env_config.dart
│   │
│   ├── di/
│   │   ├── injection_container.dart
│   │   ├── core_module.dart
│   │   ├── market_module.dart
│   │   ├── portfolio_module.dart
│   │   ├── alerts_module.dart
│   │   ├── watchlist_module.dart
│   │   └── settings_module.dart
│   │
│   └── navigation/
│       └── app_router.dart
│
├── test/
│   ├── unit/
│   │   ├── market/
│   │   │   ├── ticker_model_test.dart
│   │   │   ├── market_repository_test.dart
│   │   │   └── ticker_list_bloc_test.dart
│   │   └── portfolio/
│   │       └── portfolio_bloc_test.dart
│   ├── widget/
│   │   ├── ticker_list_tile_test.dart
│   │   └── price_text_test.dart
│   └── integration/
│       └── websocket_stream_test.dart
│
├── pubspec.yaml
└── README.md
```

---

## 📦 Paket Bağımlılıkları

### Ana `pubspec.yaml`

```yaml
name: cryptoflow
description: Real-time cryptocurrency tracker with Binance WebSocket

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Local Packages
  core:
    path: packages/core
  design_system:
    path: packages/design_system
  market:
    path: packages/market
  portfolio:
    path: packages/portfolio
  alerts:
    path: packages/alerts
  watchlist:
    path: packages/watchlist
  settings:
    path: packages/settings
  
  # DI
  get_it: ^7.6.0
  injectable: ^2.3.0
  
  # Navigation
  go_router: ^12.0.0
  
  # State
  flutter_bloc: ^8.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  injectable_generator: ^2.4.0
  build_runner: ^2.4.0
  mocktail: ^1.0.0
  bloc_test: ^9.1.0
```

### `packages/core/pubspec.yaml`

```yaml
name: core
description: Core utilities for CryptoFlow

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  # Network
  dio: ^5.3.0
  web_socket_channel: ^2.4.0
  connectivity_plus: ^5.0.0
  
  # Functional
  dartz: ^0.10.1
  equatable: ^2.0.5
  rxdart: ^0.27.7
  
  # Utils
  intl: ^0.18.0
```

### `packages/market/pubspec.yaml`

```yaml
name: market
description: Market data and WebSocket streams

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  core:
    path: ../core
  design_system:
    path: ../design_system
  
  flutter_bloc: ^8.1.0
  web_socket_channel: ^2.4.0
  rxdart: ^0.27.7
  
  # Charts
  fl_chart: ^0.65.0
  # veya
  # syncfusion_flutter_charts: ^23.0.0
  
  # Local storage
  drift: ^2.13.0
  sqlite3_flutter_libs: ^0.5.0
  hive_flutter: ^1.1.0

dev_dependencies:
  drift_dev: ^2.13.0
  build_runner: ^2.4.0
```

---

## 🔗 Modül İletişim Diyagramı

```
┌─────────────────────────────────────────────────────────────────┐
│                          lib/ (App)                             │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │                    GetIt (DI Container)                  │  │
│   └─────────────────────────────────────────────────────────┘  │
│                              │                                  │
│   ┌──────────────────────────┼──────────────────────────────┐  │
│   │                          ▼                              │  │
│   │  ┌──────────┐    ┌──────────────┐    ┌──────────────┐  │  │
│   │  │ watchlist│◄──►│    market    │◄──►│   portfolio  │  │  │
│   │  └──────────┘    └──────┬───────┘    └──────────────┘  │  │
│   │                         │                               │  │
│   │                         ▼                               │  │
│   │                  ┌──────────────┐                       │  │
│   │                  │    alerts    │                       │  │
│   │                  └──────────────┘                       │  │
│   │                                                         │  │
│   │  ┌────────────────────────────────────────────────────┐│  │
│   │  │                    core                            ││  │
│   │  │  ┌─────────────┐  ┌─────────────────────────────┐ ││  │
│   │  │  │ API Client  │  │   WebSocket Client          │ ││  │
│   │  │  │   (REST)    │  │   (Real-time Streams)       │ ││  │
│   │  │  └─────────────┘  └─────────────────────────────┘ ││  │
│   │  └────────────────────────────────────────────────────┘│  │
│   │                                                         │  │
│   │  ┌────────────────────────────────────────────────────┐│  │
│   │  │                 design_system                      ││  │
│   │  └────────────────────────────────────────────────────┘│  │
│   └─────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Binance API Layer                            │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐│
│  │   REST API          │    │   WebSocket Streams             ││
│  │   /api/v3/...       │    │   wss://stream.binance.com      ││
│  └─────────────────────┘    └─────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## 🌊 WebSocket Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    WebSocket Stream Flow                        │
│                                                                 │
│  Binance WS ──► WebSocketClient ──► Repository ──► BLoC ──► UI │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   BinanceWebSocketDataSource             │   │
│  │                                                          │   │
│  │   connect(stream) ─────────────────────────────────┐    │   │
│  │         │                                          │    │   │
│  │         ▼                                          ▼    │   │
│  │   ┌──────────────┐    parse    ┌───────────────────┐   │   │
│  │   │ Raw JSON     │ ──────────► │ TickerModel       │   │   │
│  │   │ from Binance │             │ CandleModel       │   │   │
│  │   └──────────────┘             │ OrderBookModel    │   │   │
│  │                                └─────────┬─────────┘   │   │
│  │                                          │             │   │
│  │                                          ▼             │   │
│  │                               Stream<Model> broadcast  │   │
│  └──────────────────────────────────────────┼─────────────┘   │
│                                             │                  │
│  ┌──────────────────────────────────────────┼─────────────┐   │
│  │                   TickerListBloc         │             │   │
│  │                                          ▼             │   │
│  │   on<SubscribeToTickers>                              │   │
│  │         │                                              │   │
│  │         ├──► _tickerSubscription = stream.listen()    │   │
│  │         │         │                                    │   │
│  │         │         ▼                                    │   │
│  │         │    emit(TickerListUpdated(tickers))         │   │
│  │         │                                              │   │
│  │   on<UnsubscribeFromTickers>                          │   │
│  │         │                                              │   │
│  │         └──► _tickerSubscription?.cancel()            │   │
│  │                                                        │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

# 🚀 Antigravity IDE Promptları

## PROMPT 1: Proje Kurulumu

```
Flutter projesi oluştur: cryptoflow

Modüler Clean Architecture kullan. packages/ klasörü altında şu paketleri oluştur:
- core (network, websocket client, error handling, base classes)
- design_system (kripto UI components, charts, theme)
- market (Binance API entegrasyonu, WebSocket streams)
- portfolio (holding takibi, P&L hesaplama)
- alerts (fiyat alarmları)
- watchlist (takip listesi)
- settings (kullanıcı ayarları)

Her paket için:
1. flutter create --template=package ile oluştur
2. lib/ altında domain/, data/, presentation/ klasörleri
3. Barrel export dosyası

Kullanılacak paketler:
- flutter_bloc: ^8.1.0
- get_it: ^7.6.0
- injectable: ^2.3.0
- go_router: ^12.0.0
- dio: ^5.3.0
- web_socket_channel: ^2.4.0
- rxdart: ^0.27.7
- dartz: ^0.10.1
- equatable: ^2.0.5
- fl_chart: ^0.65.0
- drift: ^2.13.0
- hive_flutter: ^1.1.0
- intl: ^0.18.0
```

---

## PROMPT 2: Core Package - Network & WebSocket

```
packages/core paketi için şunları oluştur:

1. lib/constants/api_endpoints.dart:
class BinanceEndpoints {
  static const baseUrl = 'https://api.binance.com';
  static const wsBaseUrl = 'wss://stream.binance.com:9443';
  
  // REST
  static const ticker24h = '/api/v3/ticker/24hr';
  static const klines = '/api/v3/klines';
  static const exchangeInfo = '/api/v3/exchangeInfo';
  static const depth = '/api/v3/depth';
  
  // WebSocket streams
  static String tickerStream(String symbol) => '/ws/${symbol.toLowerCase()}@ticker';
  static String klineStream(String symbol, String interval) => '/ws/${symbol.toLowerCase()}@kline_$interval';
  static String depthStream(String symbol, [int levels = 20]) => '/ws/${symbol.toLowerCase()}@depth$levels';
  static const allTickersStream = '/ws/!ticker@arr';
  static const allMiniTickersStream = '/ws/!miniTicker@arr';
  
  // Combined streams
  static String combinedStream(List<String> streams) => '/stream?streams=${streams.join('/')}';
}

2. lib/network/websocket_client.dart:
abstract class WebSocketClient {
  Stream<dynamic> connect(String url);
  void disconnect();
  bool get isConnected;
  Stream<WebSocketStatus> get statusStream;
}

class BinanceWebSocketClient implements WebSocketClient {
  WebSocketChannel? _channel;
  final _statusController = BehaviorSubject<WebSocketStatus>.seeded(WebSocketStatus.disconnected);
  
  @override
  Stream<dynamic> connect(String url) {
    final fullUrl = '${BinanceEndpoints.wsBaseUrl}$url';
    _channel = WebSocketChannel.connect(Uri.parse(fullUrl));
    _statusController.add(WebSocketStatus.connected);
    
    return _channel!.stream.handleError((error) {
      _statusController.add(WebSocketStatus.error);
    }).doOnDone(() {
      _statusController.add(WebSocketStatus.disconnected);
    });
  }
  
  @override
  void disconnect() {
    _channel?.sink.close();
    _statusController.add(WebSocketStatus.disconnected);
  }
  
  // Reconnection logic with exponential backoff
  // Ping/pong handling
}

enum WebSocketStatus { connecting, connected, disconnected, error, reconnecting }

3. lib/network/api_client.dart:
- Dio wrapper with interceptors
- Rate limiting (Binance: 1200 requests/minute)
- Error handling
- Response caching

4. lib/error/failures.dart:
- NetworkFailure, ServerFailure, CacheFailure
- WebSocketFailure (connection lost, parse error)
- RateLimitFailure

5. lib/utils/formatters.dart:
class CryptoFormatters {
  static String formatPrice(double price, {int decimals = 2});
  static String formatPercent(double percent);
  static String formatVolume(double volume); // 1.2B, 500M, etc.
  static String formatMarketCap(double cap);
  static String timeAgo(DateTime time);
}
```

---

## PROMPT 3: Design System - Kripto UI Kit

```
packages/design_system paketi için kripto temalı UI kit oluştur:

1. lib/atoms/app_colors.dart:
class CryptoColors {
  // Price colors
  static const priceUp = Color(0xFF00C853);      // Yeşil
  static const priceDown = Color(0xFFFF1744);    // Kırmızı
  static const priceNeutral = Color(0xFF9E9E9E);
  
  // Chart colors
  static const candleGreen = Color(0xFF26A69A);
  static const candleRed = Color(0xFFEF5350);
  static const chartLine = Color(0xFF2196F3);
  static const chartFill = Color(0x332196F3);
  
  // Order book
  static const bidGreen = Color(0x3300C853);
  static const askRed = Color(0x33FF1744);
  
  // Background
  static const darkBg = Color(0xFF121212);
  static const cardBg = Color(0xFF1E1E1E);
  static const surfaceBg = Color(0xFF2C2C2C);
}

2. lib/molecules/price_text.dart:
class PriceText extends StatefulWidget {
  final double price;
  final double? previousPrice;
  final TextStyle? style;
  final bool animate; // Flash animation on change
  
  // Fiyat değişince kısa flash animasyonu
  // Yeşil/kırmızı highlight
}

3. lib/molecules/percent_change.dart:
class PercentChange extends StatelessWidget {
  final double percent;
  final bool showIcon; // ▲ veya ▼
  final PercentChangeSize size;
  
  // +5.23% yeşil, -2.15% kırmızı badge
}

4. lib/molecules/sparkline.dart:
class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color? lineColor;
  final bool showGradient;
  final double height;
  
  // 7 günlük mini chart (fl_chart LineChart)
}

5. lib/organisms/coin_tile.dart:
class CoinTile extends StatelessWidget {
  final String symbol;
  final String name;
  final String? iconUrl;
  final double price;
  final double percentChange24h;
  final List<double>? sparklineData;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress; // Quick add to watchlist
  
  // [ICON] BTC     $67,234.50
  //        Bitcoin    +2.34% [SPARKLINE]
}

6. lib/organisms/candle_chart.dart:
class CandleChart extends StatelessWidget {
  final List<Candle> candles;
  final String interval;
  final bool showVolume;
  final bool showMA; // Moving averages
  final Function(Candle)? onCandleTap;
  
  // Interactive candlestick chart
  // Pinch to zoom, pan, crosshair
}

7. lib/organisms/order_book_view.dart:
class OrderBookView extends StatelessWidget {
  final List<OrderBookEntry> bids;
  final List<OrderBookEntry> asks;
  final int depth; // Gösterilecek seviye sayısı
  final bool showDepthChart;
  
  // Bids (yeşil) solda, Asks (kırmızı) sağda
  // Depth visualization bars
}

8. lib/theme/dark_theme.dart:
- Full dark theme optimized for crypto
- AMOLED black option
- High contrast for prices
```

---

## PROMPT 4: Market Package - Domain Layer

```
packages/market paketi için domain layer oluştur:

1. lib/domain/entities/ticker.dart:
@immutable
class Ticker extends Equatable {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final double price;
  final double priceChange;
  final double priceChangePercent;
  final double high24h;
  final double low24h;
  final double volume;
  final double quoteVolume;
  final int trades;
  final DateTime? lastUpdate;
  
  bool get isUp => priceChangePercent >= 0;
}

2. lib/domain/entities/candle.dart:
@immutable
class Candle extends Equatable {
  final DateTime openTime;
  final DateTime closeTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final int trades;
  
  bool get isBullish => close >= open;
  double get bodySize => (close - open).abs();
  double get upperWick => high - (isBullish ? close : open);
  double get lowerWick => (isBullish ? open : close) - low;
}

3. lib/domain/entities/order_book.dart:
@immutable
class OrderBook extends Equatable {
  final String symbol;
  final List<OrderBookEntry> bids; // Alış emirleri
  final List<OrderBookEntry> asks; // Satış emirleri
  final int lastUpdateId;
  
  double get spread => asks.first.price - bids.first.price;
  double get spreadPercent => (spread / bids.first.price) * 100;
  double get midPrice => (bids.first.price + asks.first.price) / 2;
}

@immutable
class OrderBookEntry extends Equatable {
  final double price;
  final double quantity;
  
  double get total => price * quantity;
}

4. lib/domain/repositories/market_repository.dart:
abstract class MarketRepository {
  // REST API
  Future<Either<Failure, List<Ticker>>> getAllTickers();
  Future<Either<Failure, Ticker>> getTicker(String symbol);
  Future<Either<Failure, List<Candle>>> getCandles(String symbol, String interval, {int limit = 500});
  Future<Either<Failure, OrderBook>> getOrderBook(String symbol, {int limit = 20});
  Future<Either<Failure, List<SymbolInfo>>> getExchangeInfo();
  
  // Search
  Future<Either<Failure, List<Ticker>>> searchSymbols(String query);
}

5. lib/domain/repositories/websocket_repository.dart:
abstract class WebSocketRepository {
  // Single streams
  Stream<Either<Failure, Ticker>> getTickerStream(String symbol);
  Stream<Either<Failure, Candle>> getCandleStream(String symbol, String interval);
  Stream<Either<Failure, OrderBook>> getOrderBookStream(String symbol, {int depth = 20});
  
  // Bulk streams
  Stream<Either<Failure, List<Ticker>>> getAllTickersStream();
  Stream<Either<Failure, List<Ticker>>> getMultipleTickersStream(List<String> symbols);
  
  // Connection management
  void connect();
  void disconnect();
  Stream<WebSocketStatus> get statusStream;
}

6. lib/domain/usecases/:
- GetAllTickersUseCase (REST)
- GetTickerStreamUseCase (WebSocket)
- GetCandlesUseCase (REST for history)
- GetCandleStreamUseCase (WebSocket for live)
- GetOrderBookUseCase
- GetOrderBookStreamUseCase
- SearchSymbolsUseCase
```

---

## PROMPT 5: Market Package - Data Layer

```
packages/market paketi için data layer oluştur:

1. lib/data/models/ticker_model.dart:
class TickerModel extends Ticker {
  const TickerModel({...});
  
  factory TickerModel.fromJson(Map<String, dynamic> json) {
    // Binance 24hr ticker response:
    // {
    //   "symbol": "BTCUSDT",
    //   "priceChange": "-94.99999800",
    //   "priceChangePercent": "-0.134",
    //   "lastPrice": "69000.00000000",
    //   "highPrice": "70000.00000000",
    //   "lowPrice": "68000.00000000",
    //   "volume": "100000.00000000",
    //   "quoteVolume": "6900000000.00000000",
    //   "count": 500000
    // }
  }
  
  factory TickerModel.fromWsJson(Map<String, dynamic> json) {
    // WebSocket ticker format farklı olabilir
    // {
    //   "e": "24hrTicker",
    //   "s": "BTCUSDT",
    //   "p": "-94.99999800",
    //   "P": "-0.134",
    //   "c": "69000.00000000",
    //   ...
    // }
  }
  
  factory TickerModel.fromMiniTicker(Map<String, dynamic> json) {
    // Mini ticker format
  }
  
  Ticker toEntity() => Ticker(...);
}

2. lib/data/models/candle_model.dart:
class CandleModel extends Candle {
  factory CandleModel.fromJson(List<dynamic> json) {
    // Binance kline format: [openTime, open, high, low, close, volume, closeTime, ...]
    return CandleModel(
      openTime: DateTime.fromMillisecondsSinceEpoch(json[0]),
      open: double.parse(json[1]),
      high: double.parse(json[2]),
      low: double.parse(json[3]),
      close: double.parse(json[4]),
      volume: double.parse(json[5]),
      closeTime: DateTime.fromMillisecondsSinceEpoch(json[6]),
      trades: json[8],
    );
  }
  
  factory CandleModel.fromWsJson(Map<String, dynamic> json) {
    // WebSocket kline format
    final k = json['k'];
    return CandleModel(
      openTime: DateTime.fromMillisecondsSinceEpoch(k['t']),
      open: double.parse(k['o']),
      high: double.parse(k['h']),
      low: double.parse(k['l']),
      close: double.parse(k['c']),
      volume: double.parse(k['v']),
      closeTime: DateTime.fromMillisecondsSinceEpoch(k['T']),
      trades: k['n'],
    );
  }
}

3. lib/data/models/order_book_model.dart:
class OrderBookModel extends OrderBook {
  factory OrderBookModel.fromJson(Map<String, dynamic> json) {
    return OrderBookModel(
      lastUpdateId: json['lastUpdateId'],
      bids: (json['bids'] as List).map((b) => 
        OrderBookEntry(price: double.parse(b[0]), quantity: double.parse(b[1]))
      ).toList(),
      asks: (json['asks'] as List).map((a) => 
        OrderBookEntry(price: double.parse(a[0]), quantity: double.parse(a[1]))
      ).toList(),
    );
  }
}

4. lib/data/datasources/binance_websocket_datasource.dart:
class BinanceWebSocketDataSource {
  final WebSocketClient _wsClient;
  
  // Ticker streams
  Stream<TickerModel> connectToTicker(String symbol) {
    return _wsClient
      .connect(BinanceEndpoints.tickerStream(symbol))
      .map((data) => TickerModel.fromWsJson(jsonDecode(data)));
  }
  
  Stream<List<TickerModel>> connectToAllTickers() {
    return _wsClient
      .connect(BinanceEndpoints.allTickersStream)
      .map((data) {
        final list = jsonDecode(data) as List;
        return list.map((t) => TickerModel.fromWsJson(t)).toList();
      });
  }
  
  // Candle streams
  Stream<CandleModel> connectToCandles(String symbol, String interval) {
    return _wsClient
      .connect(BinanceEndpoints.klineStream(symbol, interval))
      .map((data) => CandleModel.fromWsJson(jsonDecode(data)));
  }
  
  // Order book streams
  Stream<OrderBookModel> connectToOrderBook(String symbol, {int depth = 20}) {
    return _wsClient
      .connect(BinanceEndpoints.depthStream(symbol, depth))
      .map((data) => OrderBookModel.fromJson(jsonDecode(data)));
  }
  
  // Combined stream for multiple symbols
  Stream<Map<String, TickerModel>> connectToMultipleTickers(List<String> symbols) {
    final streams = symbols.map((s) => '${s.toLowerCase()}@ticker').toList();
    return _wsClient
      .connect(BinanceEndpoints.combinedStream(streams))
      .map((data) {
        final json = jsonDecode(data);
        final ticker = TickerModel.fromWsJson(json['data']);
        return {ticker.symbol: ticker};
      });
  }
}

5. lib/data/datasources/market_remote_datasource.dart:
- REST API calls with Dio
- Error handling
- Response caching headers

6. lib/data/datasources/market_local_datasource.dart:
- Drift database for candle history
- Hive for ticker cache
- Last known prices for offline

7. lib/data/repositories/websocket_repository_impl.dart:
class WebSocketRepositoryImpl implements WebSocketRepository {
  final BinanceWebSocketDataSource _wsDataSource;
  final _subscriptions = <String, StreamSubscription>{};
  
  @override
  Stream<Either<Failure, Ticker>> getTickerStream(String symbol) {
    return _wsDataSource
      .connectToTicker(symbol)
      .map<Either<Failure, Ticker>>((model) => Right(model.toEntity()))
      .handleError((error) => Left(WebSocketFailure(error.toString())));
  }
  
  // Resource management
  void _addSubscription(String key, StreamSubscription sub) {
    _subscriptions[key]?.cancel();
    _subscriptions[key] = sub;
  }
  
  @override
  void disconnect() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _wsDataSource.disconnect();
  }
}
```

---

## PROMPT 6: Market Package - Presentation Layer

```
packages/market paketi için presentation layer oluştur:

1. lib/presentation/bloc/ticker_list/ticker_list_bloc.dart:

// Events
abstract class TickerListEvent extends Equatable {}

class LoadTickers extends TickerListEvent {
  @override
  List<Object?> get props => [];
}

class SubscribeToTickers extends TickerListEvent {
  final List<String>? symbols; // null = all tickers
  @override
  List<Object?> get props => [symbols];
}

class UnsubscribeFromTickers extends TickerListEvent {
  @override
  List<Object?> get props => [];
}

class TickersUpdated extends TickerListEvent {
  final List<Ticker> tickers;
  @override
  List<Object?> get props => [tickers];
}

class FilterTickers extends TickerListEvent {
  final String? quoteAsset; // USDT, BTC, ETH, etc.
  final TickerSortBy sortBy;
  final bool ascending;
  @override
  List<Object?> get props => [quoteAsset, sortBy, ascending];
}

enum TickerSortBy { symbol, price, change, volume }

// States
abstract class TickerListState extends Equatable {}

class TickerListInitial extends TickerListState { ... }
class TickerListLoading extends TickerListState { ... }
class TickerListLoaded extends TickerListState {
  final List<Ticker> tickers;
  final List<Ticker> filteredTickers;
  final String? activeFilter;
  final TickerSortBy sortBy;
  final bool ascending;
  final WebSocketStatus connectionStatus;
}
class TickerListError extends TickerListState {
  final String message;
}

// Bloc
class TickerListBloc extends Bloc<TickerListEvent, TickerListState> {
  final GetAllTickersUseCase _getAllTickers;
  final WebSocketRepository _wsRepository;
  
  StreamSubscription<Either<Failure, List<Ticker>>>? _tickerSubscription;
  List<Ticker> _allTickers = [];
  
  TickerListBloc(...) : super(TickerListInitial()) {
    on<LoadTickers>(_onLoadTickers);
    on<SubscribeToTickers>(_onSubscribe);
    on<UnsubscribeFromTickers>(_onUnsubscribe);
    on<TickersUpdated>(_onTickersUpdated);
    on<FilterTickers>(_onFilterTickers);
  }
  
  Future<void> _onSubscribe(SubscribeToTickers event, Emitter emit) async {
    _tickerSubscription?.cancel();
    _tickerSubscription = _wsRepository.getAllTickersStream().listen(
      (either) => either.fold(
        (failure) => add(TickerListError(failure.message)),
        (tickers) => add(TickersUpdated(tickers)),
      ),
    );
  }
  
  void _onTickersUpdated(TickersUpdated event, Emitter emit) {
    // Merge updates with existing tickers
    final updatedMap = {for (var t in event.tickers) t.symbol: t};
    _allTickers = _allTickers.map((t) => updatedMap[t.symbol] ?? t).toList();
    
    // Apply current filters
    emit(_buildLoadedState());
  }
  
  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}

2. lib/presentation/bloc/ticker_detail/ticker_detail_bloc.dart:
- Single ticker detail with real-time updates
- Manages candle stream subscription
- Order book stream subscription
- Interval switching (1m, 5m, 15m, 1h, 4h, 1d)

3. lib/presentation/bloc/candle/candle_bloc.dart:
- Historical candle loading (REST)
- Live candle updates (WebSocket)
- Interval management
- Technical indicator calculations (optional)

4. lib/presentation/bloc/order_book/order_book_bloc.dart:
- Order book depth stream
- Cumulative depth calculation
- Spread monitoring

5. lib/presentation/pages/market_list_page.dart:
class MarketListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TickerListBloc>()
        ..add(LoadTickers())
        ..add(SubscribeToTickers()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Markets'),
          actions: [
            // Search button
            // Filter dropdown (USDT, BTC, etc.)
            // Sort options
          ],
        ),
        body: Column(
          children: [
            // Connection status indicator
            // Quote asset tabs (USDT | BTC | ETH | ...)
            // Ticker list
            Expanded(
              child: BlocBuilder<TickerListBloc, TickerListState>(
                builder: (context, state) {
                  if (state is TickerListLoaded) {
                    return ListView.builder(
                      itemCount: state.filteredTickers.length,
                      itemBuilder: (_, i) => CoinTile(
                        ticker: state.filteredTickers[i],
                        onTap: () => context.push('/ticker/${state.filteredTickers[i].symbol}'),
                      ),
                    );
                  }
                  return LoadingShimmer();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

6. lib/presentation/pages/ticker_detail_page.dart:
- Hero animation from list
- Tab bar: Chart | Order Book | Trades | Info
- Interval selector
- Watchlist/Alert buttons
- Price card with real-time updates

7. lib/presentation/widgets/:
- TickerListTile (optimized for real-time updates)
- IntervalSelector (1m, 5m, 15m, 1h, 4h, 1d, 1w)
- OrderBookLadder (bid/ask visualization)
- DepthChart (cumulative depth visualization)
- ConnectionStatusBar
```

---

## PROMPT 7: Portfolio Package

```
packages/portfolio paketi - Portföy takibi:

DOMAIN LAYER:

1. entities/holding.dart:
class Holding extends Equatable {
  final String symbol;
  final String baseAsset;
  final double quantity;
  final double avgBuyPrice;
  final DateTime firstBuyDate;
  
  // Calculated (needs current price)
  double currentValue(double currentPrice) => quantity * currentPrice;
  double pnl(double currentPrice) => currentValue(currentPrice) - (quantity * avgBuyPrice);
  double pnlPercent(double currentPrice) => ((currentPrice - avgBuyPrice) / avgBuyPrice) * 100;
}

2. entities/transaction.dart:
class Transaction extends Equatable {
  final String id;
  final String symbol;
  final TransactionType type; // buy, sell, transfer_in, transfer_out
  final double quantity;
  final double price;
  final double? fee;
  final String? feeAsset;
  final DateTime timestamp;
  final String? note;
}

3. entities/portfolio_summary.dart:
class PortfolioSummary extends Equatable {
  final double totalValue;
  final double totalInvested;
  final double totalPnl;
  final double totalPnlPercent;
  final double btcValue; // Portfolio value in BTC
  final Map<String, double> allocation; // Asset allocation percentages
  final List<Holding> holdings;
}

4. repositories/portfolio_repository.dart:
abstract class PortfolioRepository {
  Future<Either<Failure, List<Holding>>> getHoldings();
  Future<Either<Failure, void>> addTransaction(Transaction transaction);
  Future<Either<Failure, List<Transaction>>> getTransactions({String? symbol});
  Future<Either<Failure, void>> deleteTransaction(String id);
  Stream<List<Holding>> watchHoldings();
}

5. usecases/:
- GetHoldingsUseCase
- AddTransactionUseCase (recalculates avg buy price)
- GetPortfolioValueUseCase (combines holdings with live prices)
- GetPnLUseCase
- WatchPortfolioValueUseCase (stream that updates with price changes)
- GetAllocationUseCase

DATA LAYER:

6. Drift database schema for transactions
7. Computed holdings from transactions

PRESENTATION LAYER:

8. bloc/portfolio_bloc.dart:
States:
- PortfolioInitial
- PortfolioLoading
- PortfolioLoaded(summary, holdings)
- PortfolioError

Events:
- LoadPortfolio
- AddTransaction
- WatchPortfolioValue
- RefreshPrices

9. pages/:
- PortfolioPage (summary card, holdings list, allocation pie)
- AddTransactionPage (buy/sell form)
- TransactionHistoryPage

10. widgets/:
- HoldingTile (symbol, quantity, value, pnl with colors)
- PortfolioSummaryCard (total value, total pnl, 24h change)
- AllocationPieChart
- PnLChart (line chart over time)
```

---

## PROMPT 8: Alerts Package

```
packages/alerts paketi - Fiyat alarmları:

DOMAIN LAYER:

1. entities/price_alert.dart:
class PriceAlert extends Equatable {
  final String id;
  final String symbol;
  final AlertType type; // above, below, percent_change
  final double targetPrice;
  final double? percentChange; // for percent_change type
  final bool isActive;
  final bool isTriggered;
  final DateTime createdAt;
  final DateTime? triggeredAt;
  final bool repeatEnabled;
}

enum AlertType { above, below, percentUp, percentDown }

2. repositories/alert_repository.dart:
abstract class AlertRepository {
  Future<Either<Failure, List<PriceAlert>>> getAlerts();
  Future<Either<Failure, PriceAlert>> createAlert(PriceAlert alert);
  Future<Either<Failure, void>> deleteAlert(String id);
  Future<Either<Failure, void>> toggleAlert(String id, bool isActive);
  Future<Either<Failure, void>> checkAlerts(Map<String, double> currentPrices);
  Stream<List<PriceAlert>> watchAlerts();
}

3. usecases/:
- GetAlertsUseCase
- CreateAlertUseCase
- DeleteAlertUseCase
- CheckAlertsUseCase (called on price updates)

DATA LAYER:

4. Hive storage for alerts
5. Background service integration (WorkManager)

PRESENTATION LAYER:

6. bloc/alert_bloc.dart
7. pages/alerts_page.dart (list of alerts)
8. widgets/:
- AlertTile (symbol, target, status)
- CreateAlertSheet (bottom sheet form)
```

---

## PROMPT 9: Watchlist Package

```
packages/watchlist paketi:

DOMAIN LAYER:

1. entities/watchlist_item.dart:
class WatchlistItem extends Equatable {
  final String symbol;
  final int order; // for drag-to-reorder
  final DateTime addedAt;
}

2. repositories/watchlist_repository.dart:
abstract class WatchlistRepository {
  Future<Either<Failure, List<WatchlistItem>>> getWatchlist();
  Future<Either<Failure, void>> addToWatchlist(String symbol);
  Future<Either<Failure, void>> removeFromWatchlist(String symbol);
  Future<Either<Failure, bool>> isInWatchlist(String symbol);
  Future<Either<Failure, void>> reorderWatchlist(List<WatchlistItem> items);
  Stream<List<WatchlistItem>> watchWatchlist();
}

DATA LAYER:

3. Hive storage

PRESENTATION LAYER:

4. bloc/watchlist_bloc.dart
5. pages/watchlist_page.dart:
- Real-time prices for watchlist items
- Drag to reorder (ReorderableListView)
- Swipe to delete
- Quick add from search

6. widgets/:
- WatchlistTile (extends CoinTile with drag handle)
- AddToWatchlistButton (star icon toggle)
```

---

## PROMPT 10: Dependency Injection & Navigation

```
lib/di/ ve lib/navigation/ kurulumu:

1. injection_container.dart:
@InjectableInit()
Future<void> configureDependencies() async {
  // Hive initialization
  await Hive.initFlutter();
  Hive.registerAdapter(WatchlistItemModelAdapter());
  Hive.registerAdapter(PriceAlertModelAdapter());
  
  // Open boxes
  await Hive.openBox<WatchlistItemModel>('watchlist');
  await Hive.openBox<PriceAlertModel>('alerts');
  
  // Drift database
  final database = AppDatabase();
  getIt.registerSingleton(database);
  
  await getIt.init();
}

2. core_module.dart:
@module
abstract class CoreModule {
  @lazySingleton
  Dio get dio => Dio(BaseOptions(
    baseUrl: BinanceEndpoints.baseUrl,
    connectTimeout: Duration(seconds: 10),
  ))..interceptors.addAll([
    LogInterceptor(),
    RateLimitInterceptor(),
  ]);
  
  @lazySingleton
  WebSocketClient get wsClient => BinanceWebSocketClient();
  
  @lazySingleton
  NetworkInfo get networkInfo => NetworkInfoImpl(Connectivity());
}

3. market_module.dart:
@module
abstract class MarketModule {
  @lazySingleton
  BinanceWebSocketDataSource wsDataSource(WebSocketClient client) => 
    BinanceWebSocketDataSource(client);
  
  @lazySingleton
  MarketRepository marketRepository(
    MarketRemoteDataSource remote,
    MarketLocalDataSource local,
  ) => MarketRepositoryImpl(remote, local);
  
  @lazySingleton
  WebSocketRepository wsRepository(BinanceWebSocketDataSource ds) =>
    WebSocketRepositoryImpl(ds);
  
  @injectable
  TickerListBloc tickerListBloc(...) => TickerListBloc(...);
}

4. app_router.dart:
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => MarketListPage()),
        GoRoute(path: '/watchlist', builder: (_, __) => WatchlistPage()),
        GoRoute(path: '/portfolio', builder: (_, __) => PortfolioPage()),
        GoRoute(path: '/alerts', builder: (_, __) => AlertsPage()),
        GoRoute(path: '/settings', builder: (_, __) => SettingsPage()),
      ],
    ),
    GoRoute(
      path: '/ticker/:symbol',
      builder: (_, state) => TickerDetailPage(
        symbol: state.pathParameters['symbol']!,
      ),
    ),
    GoRoute(
      path: '/portfolio/add',
      builder: (_, __) => AddTransactionPage(),
    ),
  ],
);

5. app.dart:
class CryptoFlowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<TickerListBloc>()),
        BlocProvider(create: (_) => getIt<WatchlistBloc>()..add(LoadWatchlist())),
        BlocProvider(create: (_) => getIt<PortfolioBloc>()..add(LoadPortfolio())),
        BlocProvider(create: (_) => getIt<AlertBloc>()..add(LoadAlerts())),
        BlocProvider(create: (_) => getIt<SettingsBloc>()..add(LoadSettings())),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            routerConfig: appRouter,
            theme: CryptoTheme.light,
            darkTheme: CryptoTheme.dark,
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
```

---

## PROMPT 11: Testing Setup

```
test/ klasörü için comprehensive test suite:

1. test/unit/market/ticker_model_test.dart:
void main() {
  group('TickerModel', () {
    test('fromJson parses REST response correctly', () {
      final json = {
        'symbol': 'BTCUSDT',
        'lastPrice': '69000.00',
        'priceChangePercent': '2.5',
        ...
      };
      
      final model = TickerModel.fromJson(json);
      
      expect(model.symbol, 'BTCUSDT');
      expect(model.price, 69000.0);
      expect(model.priceChangePercent, 2.5);
    });
    
    test('fromWsJson parses WebSocket response correctly', () {
      // WebSocket format test
    });
  });
}

2. test/unit/market/ticker_list_bloc_test.dart:
void main() {
  late TickerListBloc bloc;
  late MockGetAllTickersUseCase mockGetAllTickers;
  late MockWebSocketRepository mockWsRepository;
  
  setUp(() {
    mockGetAllTickers = MockGetAllTickersUseCase();
    mockWsRepository = MockWebSocketRepository();
    bloc = TickerListBloc(
      getAllTickers: mockGetAllTickers,
      wsRepository: mockWsRepository,
    );
  });
  
  blocTest<TickerListBloc, TickerListState>(
    'emits [Loading, Loaded] when LoadTickers succeeds',
    build: () {
      when(() => mockGetAllTickers(any()))
        .thenAnswer((_) async => Right([mockTicker]));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadTickers()),
    expect: () => [
      TickerListLoading(),
      isA<TickerListLoaded>(),
    ],
  );
  
  blocTest<TickerListBloc, TickerListState>(
    'updates tickers when WebSocket stream emits',
    build: () {
      when(() => mockWsRepository.getAllTickersStream())
        .thenAnswer((_) => Stream.value(Right([updatedTicker])));
      return bloc;
    },
    act: (bloc) => bloc.add(SubscribeToTickers()),
    expect: () => [
      isA<TickerListLoaded>().having(
        (s) => s.tickers.first.price,
        'updated price',
        69500.0,
      ),
    ],
  );
  
  blocTest<TickerListBloc, TickerListState>(
    'filters tickers by quote asset',
    seed: () => TickerListLoaded(tickers: mockTickers),
    act: (bloc) => bloc.add(FilterTickers(quoteAsset: 'USDT')),
    expect: () => [
      isA<TickerListLoaded>().having(
        (s) => s.filteredTickers.every((t) => t.quoteAsset == 'USDT'),
        'all USDT pairs',
        true,
      ),
    ],
  );
}

3. test/unit/market/websocket_repository_test.dart:
- Stream subscription tests
- Reconnection logic tests
- Error handling tests

4. test/widget/coin_tile_test.dart:
void main() {
  testWidgets('displays ticker information correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CoinTile(ticker: mockTicker),
      ),
    );
    
    expect(find.text('BTCUSDT'), findsOneWidget);
    expect(find.text('\$69,000.00'), findsOneWidget);
    expect(find.text('+2.50%'), findsOneWidget);
  });
  
  testWidgets('shows green color for positive change', (tester) async {
    // Color assertion test
  });
}

5. test/integration/websocket_stream_test.dart:
- Real WebSocket connection test (integration)
- Multiple stream subscription test
- Disconnection/reconnection test
```

---

## PROMPT 12: Performance Optimizations

```
Performans optimizasyonları:

1. Efficient List Rendering:
// ticker_list_page.dart
ListView.builder(
  itemCount: tickers.length,
  itemBuilder: (context, index) {
    return RepaintBoundary(
      child: CoinTile(
        key: ValueKey(tickers[index].symbol),
        ticker: tickers[index],
      ),
    );
  },
)

2. Selective Rebuilds:
// BlocSelector kullan
BlocSelector<TickerListBloc, TickerListState, List<Ticker>>(
  selector: (state) => state is TickerListLoaded ? state.filteredTickers : [],
  builder: (context, tickers) => TickerList(tickers: tickers),
)

3. WebSocket Message Batching:
// Batch updates instead of emit per message
class TickerListBloc {
  final _pendingUpdates = <String, Ticker>{};
  Timer? _batchTimer;
  
  void _onWsMessage(Ticker ticker) {
    _pendingUpdates[ticker.symbol] = ticker;
    _batchTimer ??= Timer(Duration(milliseconds: 100), _flushUpdates);
  }
  
  void _flushUpdates() {
    add(TickersUpdated(_pendingUpdates.values.toList()));
    _pendingUpdates.clear();
    _batchTimer = null;
  }
}

4. Image Caching:
// Coin icons
CachedNetworkImage(
  imageUrl: 'https://assets.coingecko.com/coins/images/1/small/bitcoin.png',
  placeholder: (_, __) => CircleAvatar(child: Text('BTC')),
  errorWidget: (_, __, ___) => CircleAvatar(child: Text('BTC')),
)

5. Isolate for Heavy Computation:
// Technical indicators, large data processing
Future<List<double>> calculateMA(List<Candle> candles, int period) {
  return compute(_calculateMAIsolate, {'candles': candles, 'period': period});
}

6. Memory Management:
// Dispose WebSocket subscriptions properly
@override
Future<void> close() {
  _tickerSubscription?.cancel();
  _candleSubscription?.cancel();
  _orderBookSubscription?.cancel();
  return super.close();
}
```

---

## PROMPT 13: App Store / Play Store Hazırlığı

```
Release hazırlığı:

1. App Icon:
- 1024x1024 icon (gradient background + chart icon)
- flutter_launcher_icons configuration

2. Splash Screen:
- Logo + "CryptoFlow" text
- flutter_native_splash

3. Screenshots:
- Market list with live prices
- Candlestick chart
- Portfolio page
- Order book
- Dark mode variants

4. App Description:
"""
CryptoFlow - Real-time Kripto Takip

📊 CANLI FİYATLAR
Binance WebSocket ile anlık fiyat güncellemeleri. 
Gecikme yok, her saniye güncel.

📈 PROFESYONEl GRAFİKLER  
Candlestick, çizgi grafik, teknik göstergeler.
1 dakikadan 1 aya kadar zaman dilimleri.

📋 ORDER BOOK
Gerçek zamanlı alış/satış emirleri.
Piyasa derinliği görselleştirmesi.

💼 PORTFÖY TAKİBİ
Varlıklarını ekle, P&L'ini takip et.
Otomatik kar/zarar hesaplama.

🔔 FİYAT ALARMLARI
Hedef fiyata ulaşınca bildirim al.
Hiçbir fırsatı kaçırma.

⭐ TAKİP LİSTESİ
Favori coinlerini hızlı erişim için kaydet.
Sürükle-bırak sıralama.

🌙 KARANLIK MOD
Göz yormayan AMOLED uyumlu tema.

━━━━━━━━━━━━━━━━

✓ Binance WebSocket API
✓ 500+ işlem çifti
✓ Ücretsiz, reklamsız
✓ Türkçe arayüz
"""

5. Privacy Policy:
- No personal data collection
- Local-only storage
- API data usage disclosure

6. Keywords:
kripto, bitcoin, ethereum, binance, fiyat takip, 
borsa, trading, portföy, grafik, alarm
```

---

# 🔄 Transfer Prompt

Aşağıdaki prompt'u yeni bir chat'e yapıştırarak projeye kaldığın yerden devam edebilirsin:

```
# CryptoFlow Proje Context Transfer

## 🎯 Proje Özeti
CryptoFlow, Binance WebSocket API kullanan real-time kripto takip uygulaması. 
Hedef: Binance iş başvurusu için portföy projesi.

## 🏗️ Mimari
- **Pattern:** Clean Architecture (Modular Packages)
- **State Management:** BLoC + Stream
- **DI:** GetIt + Injectable

## 📦 Modüller (packages/ altında)
1. **core** - Network, WebSocket client, error handling, formatters
2. **design_system** - Kripto UI kit (PriceText, CandleChart, OrderBookView)
3. **market** - Binance API entegrasyonu, ticker/candle/orderbook streams
4. **portfolio** - Holding takibi, transaction management, P&L
5. **alerts** - Fiyat alarmları
6. **watchlist** - Takip listesi
7. **settings** - Kullanıcı ayarları

## 🔌 Binance API
```
REST Base: https://api.binance.com/api/v3
WS Base: wss://stream.binance.com:9443

Streams:
- /ws/{symbol}@ticker (24h ticker)
- /ws/{symbol}@kline_{interval} (candlestick)
- /ws/{symbol}@depth{levels} (order book)
- /ws/!ticker@arr (all tickers)
```

## 📊 Ana BLoC'lar
1. **TickerListBloc** - Market listesi + WebSocket subscription
2. **TickerDetailBloc** - Tek coin detay + candle/orderbook streams
3. **PortfolioBloc** - Holdings + real-time value calculation
4. **AlertBloc** - Price alerts management
5. **WatchlistBloc** - Favorites with reordering

## 🔑 Kritik Teknik Detaylar
- WebSocket reconnection with exponential backoff
- Message batching (100ms) for performance
- RepaintBoundary + ValueKey for list optimization
- BlocSelector for selective rebuilds
- Drift (SQLite) for transactions, Hive for preferences

## 📱 Sayfalar
- MarketListPage (tab: USDT/BTC/ETH pairs)
- TickerDetailPage (chart, orderbook, trades tabs)
- PortfolioPage (summary, holdings, allocation pie)
- WatchlistPage (drag-to-reorder)
- AlertsPage
- SettingsPage

## 🎨 Tema
- Dark mode öncelikli (kripto standartı)
- Green: #00C853 (price up)
- Red: #FF1744 (price down)
- AMOLED black option

## 📦 Temel Paketler
flutter_bloc, get_it, injectable, go_router, dio, 
web_socket_channel, rxdart, dartz, equatable,
fl_chart, drift, hive_flutter

## ⏳ Mevcut Durum
[Buraya kaldığın yeri yaz, örneğin:]
- Core package tamamlandı
- Market domain layer tamamlandı
- WebSocket datasource yazılıyor

## 🎯 Sonraki Adım
[Buraya bir sonraki yapılacak işi yaz, örneğin:]
- BinanceWebSocketDataSource'u tamamla
- TickerListBloc'u yaz
- Market list page UI'ı oluştur

---

Yukarıdaki context ile devam ediyorum. Şu an [MEVCUT DURUM] aşamasındayım. 
[SONRAKİ ADIM] ile devam edelim.
```

---

## 📝 Transfer Prompt Kullanım Rehberi

1. **Yeni chat aç**
2. **Transfer prompt'u yapıştır**
3. **[MEVCUT DURUM] kısmını güncelle** - Son nerede kaldın?
4. **[SONRAKİ ADIM] kısmını güncelle** - Ne yapmak istiyorsun?
5. **Gönder ve devam et**

### Örnek Kullanım:

```
## ⏳ Mevcut Durum
- Core package tamamlandı ✅
- Design system tamamlandı ✅
- Market domain layer tamamlandı ✅
- Market data layer - models yazıldı ✅
- BinanceWebSocketDataSource yazılıyor 🔄

## 🎯 Sonraki Adım
BinanceWebSocketDataSource'daki connectToAllTickers() metodunu 
tamamla ve error handling ekle.

---

Yukarıdaki context ile devam ediyorum. WebSocket datasource'da 
reconnection logic'i nasıl implemente etmeliyim?
```

---

# ✅ Checklist

## Geliştirme Sırası

- [ ] PROMPT 1: Proje kurulumu
- [ ] PROMPT 2: Core package
- [ ] PROMPT 3: Design system
- [ ] PROMPT 4: Market domain
- [ ] PROMPT 5: Market data
- [ ] PROMPT 6: Market presentation
- [ ] PROMPT 7: Portfolio package
- [ ] PROMPT 8: Alerts package
- [ ] PROMPT 9: Watchlist package
- [ ] PROMPT 10: DI & Navigation
- [ ] PROMPT 11: Testing
- [ ] PROMPT 12: Performance
- [ ] PROMPT 13: Release

## Binance Showcase Özellikleri

- [ ] Real-time WebSocket streams
- [ ] Efficient list rendering (100+ items)
- [ ] Candlestick charts
- [ ] Order book visualization
- [ ] Clean Architecture
- [ ] Comprehensive tests
- [ ] Error handling & reconnection
- [ ] Dark mode

---

**Son Güncelleme:** Bu dosya ile CryptoFlow projesini sıfırdan tamamlayabilirsin.
