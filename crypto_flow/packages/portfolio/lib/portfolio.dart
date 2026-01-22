/// Portfolio package for CryptoFlow
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

export 'domain/repositories/portfolio_repository.dart';

export 'domain/usecases/get_holdings.dart';
export 'domain/usecases/add_transaction.dart';
export 'domain/usecases/get_portfolio_value.dart';
export 'domain/usecases/get_pnl.dart';
export 'domain/usecases/get_allocation.dart';

// Data layer
export 'data/models/holding_model.dart';
export 'data/models/transaction_model.dart';

export 'data/datasources/portfolio_local_datasource.dart';

export 'data/repositories/portfolio_repository_impl.dart';

// Presentation layer
export 'presentation/bloc/portfolio_bloc.dart';
export 'presentation/bloc/portfolio_event.dart';
export 'presentation/bloc/portfolio_state.dart';

export 'presentation/pages/portfolio_page.dart';
export 'presentation/pages/add_transaction_page.dart';

export 'presentation/widgets/holding_tile.dart';
export 'presentation/widgets/portfolio_chart.dart';
export 'presentation/widgets/pnl_card.dart';
export 'presentation/widgets/allocation_pie.dart';
