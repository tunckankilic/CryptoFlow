/// Watchlist package for CryptoFlow
///
/// This package provides:
/// - Cryptocurrency watchlist management
/// - Favorites tracking
library;

// Domain layer
export 'domain/entities/watchlist_item.dart';

export 'domain/repositories/watchlist_repository.dart';

export 'domain/usecases/add_to_watchlist.dart';
export 'domain/usecases/remove_from_watchlist.dart';
export 'domain/usecases/get_watchlist.dart';
export 'domain/usecases/is_in_watchlist.dart';
export 'domain/usecases/reorder_watchlist.dart';

// Data layer
export 'data/models/watchlist_item_model.dart';

export 'data/datasources/watchlist_local_datasource.dart';

export 'data/repositories/watchlist_repository_impl.dart';

// Presentation layer
export 'presentation/bloc/watchlist_bloc.dart';
export 'presentation/bloc/watchlist_event.dart';
export 'presentation/bloc/watchlist_state.dart';

export 'presentation/pages/watchlist_page.dart';

export 'presentation/widgets/watchlist_tile.dart';
