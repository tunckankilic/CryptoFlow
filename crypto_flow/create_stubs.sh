#!/bin/bash

# Core package stubs
touch packages/core/lib/constants/{api_endpoints,app_constants,ws_channels,storage_keys}.dart
touch packages/core/lib/error/{exceptions,failures}.dart
touch packages/core/lib/network/{api_client,websocket_client,network_info}.dart
touch packages/core/lib/usecases/usecase.dart
touch packages/core/lib/utils/{extensions,formatters,debouncer}.dart

# Design system package st packages/design_system/lib/atoms/{app_colors,app_typography,app_spacing}.dart
touch packages/design_system/lib/molecules/{price_text,percent_change,sparkline,loading_shimmer}.dart
touch packages/design_system/lib/organisms/{coin_tile,price_card,order_book_view,candle_chart}.dart
touch packages/design_system/lib/theme/{app_theme,dark_theme}.dart

# Market package stubs
mkdir -p packages/market/lib/domain/{entities,repositories,usecases}
mkdir -p packages/market/lib/data/{models,datasources,repositories}
mkdir -p packages/market/lib/presentation/{bloc/ticker_list,bloc/ticker_detail,bloc/candle,bloc/order_book,pages,widgets}
touch packages/market/lib/domain/entities/{ticker,candle,order_book,trade,symbol_info}.dart
touch packages/market/lib/domain/repositories/{market_repository,websocket_repository}.dart
touch packages/market/lib/domain/usecases/{get_all_tickers,get_ticker_stream,get_candles,get_candle_stream,get_order_book,get_order_book_stream,search_symbols}.dart
touch packages/market/lib/data/models/{ticker_model,candle_model,order_book_model,ws_message_model}.dart
touch packages/market/lib/data/datasources/{market_remote_datasource,market_local_datasource,binance_websocket_datasource}.dart
touch packages/market/lib/data/repositories/{market_repository_impl,websocket_repository_impl}.dart
touch packages/market/lib/presentation/bloc/ticker_list/{ticker_list_bloc,ticker_list_event,ticker_list_state}.dart
touch packages/market/lib/presentation/bloc/ticker_detail/{ticker_detail_bloc,ticker_detail_event,ticker_detail_state}.dart
touch packages/market/lib/presentation/bloc/candle/{candle_bloc,candle_event,candle_state}.dart
touch packages/market/lib/presentation/bloc/order_book/{order_book_bloc,order_book_event,order_book_state}.dart
touch packages/market/lib/presentation/pages/{market_list_page,ticker_detail_page,search_page}.dart
touch packages/market/lib/presentation/widgets/{ticker_list_tile,interval_selector,order_book_ladder,depth_chart}.dart

# Portfolio package stubs
mkdir -p packages/portfolio/lib/domain/{entities,repositories,usecases}
mkdir -p packages/portfolio/lib/data/{models,datasources,repositories}
mkdir -p packages/portfolio/lib/presentation/{bloc,pages,widgets}
touch packages/portfolio/lib/domain/entities/{holding,transaction,portfolio_summary}.dart
touch packages/portfolio/lib/domain/repositories/portfolio_repository.dart
touch packages/portfolio/lib/domain/usecases/{get_holdings,add_transaction,get_portfolio_value,get_pnl,watch_portfolio_value}.dart
touch packages/portfolio/lib/data/models/{holding_model,transaction_model}.dart
touch packages/portfolio/lib/data/datasources/portfolio_local_datasource.dart
touch packages/portfolio/lib/data/repositories/portfolio_repository_impl.dart
touch packages/portfolio/lib/presentation/bloc/{portfolio_bloc,portfolio_event,portfolio_state}.dart
touch packages/portfolio/lib/presentation/pages/{portfolio_page,add_transaction_page}.dart
touch packages/portfolio/lib/presentation/widgets/{holding_tile,portfolio_chart,pnl_card,allocation_pie}.dart

# Alerts package stubs
mkdir -p packages/alerts/lib/domain/{entities,repositories,usecases}
mkdir -p packages/alerts/lib/data/{models,datasources,repositories}
mkdir -p packages/alerts/lib/presentation/{bloc,pages,widgets}
touch packages/alerts/lib/domain/entities/price_alert.dart
touch packages/alerts/lib/domain/repositories/alert_repository.dart
touch packages/alerts/lib/domain/usecases/{create_alert,delete_alert,get_alerts,check_alerts}.dart
touch packages/alerts/lib/data/models/price_alert_model.dart
touch packages/alerts/lib/data/datasources/alert_local_datasource.dart
touch packages/alerts/lib/data/repositories/alert_repository_impl.dart
touch packages/alerts/lib/presentation/bloc/{alert_bloc,alert_event,alert_state}.dart
touch packages/alerts/lib/presentation/pages/alerts_page.dart
touch packages/alerts/lib/presentation/widgets/{alert_tile,create_alert_sheet}.dart

# Watchlist package stubs
mkdir -p packages/watchlist/lib/domain/{entities,repositories,usecases}
mkdir -p packages/watchlist/lib/data/{models,datasources,repositories}
mkdir -p packages/watchlist/lib/presentation/{bloc,pages,widgets}
touch packages/watchlist/lib/domain/entities/watchlist_item.dart
touch packages/watchlist/lib/domain/repositories/watchlist_repository.dart
touch packages/watchlist/lib/domain/usecases/{add_to_watchlist,remove_from_watchlist,get_watchlist,is_in_watchlist,reorder_watchlist}.dart
touch packages/watchlist/lib/data/models/watchlist_item_model.dart
touch packages/watchlist/lib/data/datasources/watchlist_local_datasource.dart
touch packages/watchlist/lib/data/repositories/watchlist_repository_impl.dart
touch packages/watchlist/lib/presentation/bloc/{watchlist_bloc,watchlist_event,watchlist_state}.dart
touch packages/watchlist/lib/presentation/pages/watchlist_page.dart
touch packages/watchlist/lib/presentation/widgets/watchlist_tile.dart

# Settings package stubs
mkdir -p packages/settings/lib/domain/{entities,repositories,usecases}
mkdir -p packages/settings/lib/data/{models,datasources,repositories}
mkdir -p packages/settings/lib/presentation/{bloc,pages}
touch packages/settings/lib/domain/entities/user_settings.dart
touch packages/settings/lib/domain/repositories/settings_repository.dart
touch packages/settings/lib/domain/usecases/{get_settings,update_currency,update_theme}.dart
touch packages/settings/lib/data/models/user_settings_model.dart
touch packages/settings/lib/data/datasources/settings_local_datasource.dart
touch packages/settings/lib/data/repositories/settings_repository_impl.dart
touch packages/settings/lib/presentation/bloc/{settings_bloc,settings_event,settings_state}.dart
touch packages/settings/lib/presentation/pages/settings_page.dart

echo "All stub files created successfully!"
