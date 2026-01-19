/// Settings package for CryptoFlow
///
/// This package provides:
/// - User settings management
/// - Theme preferences
/// - Currency preferences
library;

// Domain layer
export 'domain/entities/user_settings.dart';

export 'domain/repositories/settings_repository.dart';

export 'domain/usecases/get_settings.dart';
export 'domain/usecases/update_currency.dart';
export 'domain/usecases/update_theme.dart';

// Data layer
export 'data/models/user_settings_model.dart';

export 'data/datasources/settings_local_datasource.dart';

export 'data/repositories/settings_repository_impl.dart';

// Presentation layer
export 'presentation/bloc/settings_bloc.dart';
export 'presentation/bloc/settings_event.dart';
export 'presentation/bloc/settings_state.dart';

export 'presentation/pages/settings_page.dart';
