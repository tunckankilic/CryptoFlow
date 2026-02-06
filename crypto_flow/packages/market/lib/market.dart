/// Market package for CryptoWave
///
/// This package provides:
/// - Market data entities and models
/// - Binance WebSocket integration
/// - Real-time price streams
/// - Candlestick data
/// - Order book data
/// - Technical indicators (RSI, EMA, SMA, MACD)
library;

// Domain layer - Entities
export 'domain/entities/ticker.dart';
export 'domain/entities/candle.dart';
export 'domain/entities/order_book.dart';
export 'domain/entities/trade.dart';
export 'domain/entities/symbol_info.dart';
export 'domain/entities/indicator_type.dart';
export 'domain/entities/macd_result.dart';

// Domain layer - Repositories
export 'domain/repositories/market_repository.dart';
export 'domain/repositories/websocket_repository.dart';

// Domain layer - Use Cases
export 'domain/usecases/get_all_tickers.dart';
export 'domain/usecases/get_ticker_stream.dart';
export 'domain/usecases/get_candles.dart';
export 'domain/usecases/get_candle_stream.dart';
export 'domain/usecases/get_order_book.dart';
export 'domain/usecases/get_order_book_stream.dart';
export 'domain/usecases/search_symbols.dart';

// Domain layer - Services
export 'domain/services/technical_indicators.dart';

// Data layer - Models
export 'data/models/ticker_model.dart';
export 'data/models/candle_model.dart';
export 'data/models/order_book_model.dart';
export 'data/models/ws_message_model.dart';

// Data layer - Data Sources
export 'data/datasources/market_remote_datasource.dart';
export 'data/datasources/market_local_datasource.dart';
export 'data/datasources/binance_websocket_datasource.dart';

// Data layer - Repositories
export 'data/repositories/market_repository_impl.dart';
export 'data/repositories/websocket_repository_impl.dart';

// Presentation layer - BLoCs
export 'presentation/bloc/ticker_list/ticker_list_bloc.dart';
export 'presentation/bloc/ticker_list/ticker_list_event.dart';
export 'presentation/bloc/ticker_list/ticker_list_state.dart';

export 'presentation/bloc/ticker_detail/ticker_detail_bloc.dart';
export 'presentation/bloc/ticker_detail/ticker_detail_event.dart'
    hide LoadOrderBook, SubscribeToOrderBook;
export 'presentation/bloc/ticker_detail/ticker_detail_state.dart';

export 'presentation/bloc/candle/candle_bloc.dart';
export 'presentation/bloc/candle/candle_event.dart';
export 'presentation/bloc/candle/candle_state.dart';

export 'presentation/bloc/order_book/order_book_bloc.dart';
export 'presentation/bloc/order_book/order_book_event.dart';
export 'presentation/bloc/order_book/order_book_state.dart';

// Presentation layer - Pages
export 'presentation/pages/market_list_page.dart';
export 'presentation/pages/ticker_detail_page.dart';
export 'presentation/pages/search_page.dart';

// Presentation layer - Widgets
export 'presentation/widgets/ticker_list_tile.dart';
export 'presentation/widgets/interval_selector.dart';
export 'presentation/widgets/order_book_ladder.dart';
export 'presentation/widgets/depth_chart.dart';
export 'presentation/widgets/indicator_selector.dart';
export 'presentation/widgets/rsi_panel.dart';
export 'presentation/widgets/macd_panel.dart';
