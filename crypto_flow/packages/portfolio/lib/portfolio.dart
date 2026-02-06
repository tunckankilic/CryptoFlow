/// Portfolio package for CryptoWave
///
/// This package provides:
/// - Portfolio holdings management
/// - Transaction tracking
/// - P&L calculation
library;

// Domain layer
export 'domain/entities/holding.dart';
export 'domain/entities/transaction.dart';
export 'domain/entities/portfolio_summary.dart';
export 'domain/entities/journal_entry.dart';
export 'domain/entities/journal_tag.dart';
export 'domain/entities/trading_stats.dart';
export 'domain/entities/stats_period.dart';
export 'domain/entities/trade_side.dart';
export 'domain/entities/trade_emotion.dart';

export 'domain/repositories/portfolio_repository.dart';
export 'domain/repositories/journal_repository.dart';

export 'domain/usecases/get_holdings.dart';
export 'domain/usecases/add_transaction.dart';
export 'domain/usecases/get_portfolio_value.dart';
export 'domain/usecases/get_pnl.dart';
export 'domain/usecases/get_allocation.dart';
export 'domain/usecases/watch_portfolio_value.dart';

// Journal Use Cases
export 'domain/usecases/add_journal_entry.dart';
export 'domain/usecases/update_journal_entry.dart';
export 'domain/usecases/delete_journal_entry.dart';
export 'domain/usecases/get_journal_entries.dart';
export 'domain/usecases/get_trading_stats.dart';
export 'domain/usecases/get_equity_curve.dart';
export 'domain/usecases/get_pnl_analysis.dart';
export 'domain/usecases/export_journal_pdf.dart';

// Data layer
export 'data/models/holding_model.dart';
export 'data/models/transaction_model.dart';
export 'data/models/journal_entry_model.dart';
export 'data/models/journal_tag_model.dart';
export 'data/models/trading_stats_model.dart';

export 'data/datasources/portfolio_local_datasource.dart';

export 'data/repositories/portfolio_repository_impl.dart';
export 'data/repositories/journal_repository_impl.dart';

export 'data/local/daos/journal_dao.dart';
export 'data/local/daos/tag_dao.dart';

export 'data/datasources/portfolio_database.dart'
    hide Transaction, JournalEntry, JournalTag, TradingStat;

// Presentation layer
export 'presentation/bloc/portfolio_bloc.dart';
export 'presentation/bloc/portfolio_event.dart' hide WatchPortfolioValue;
export 'presentation/bloc/portfolio_state.dart';

// Journal BLoCs
export 'presentation/bloc/journal/journal_bloc.dart';
export 'presentation/bloc/journal/journal_event.dart';
export 'presentation/bloc/journal/journal_state.dart';
export 'presentation/bloc/journal/journal_filter.dart';
export 'presentation/bloc/journal/journal_sort.dart';

export 'presentation/bloc/journal_stats/journal_stats_bloc.dart';
export 'presentation/bloc/journal_stats/journal_stats_event.dart';
export 'presentation/bloc/journal_stats/journal_stats_state.dart';

export 'presentation/pages/portfolio_page.dart';
export 'presentation/pages/add_transaction_page.dart';
export 'presentation/pages/journal/journal_list_page.dart';
export 'presentation/pages/journal/add_edit_journal_page.dart';
export 'presentation/pages/journal/journal_detail_page.dart';
export 'presentation/pages/journal/analytics_page.dart';

export 'presentation/widgets/holding_tile.dart';
export 'presentation/widgets/portfolio_chart.dart';
export 'presentation/widgets/pnl_card.dart';
export 'presentation/widgets/allocation_pie.dart';
