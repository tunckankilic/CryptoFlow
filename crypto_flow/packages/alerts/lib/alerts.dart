/// Alerts package for CryptoFlow
///
/// This package provides:
/// - Price alert creation and management
/// - Alert notifications
library;

// Domain layer
export 'domain/entities/price_alert.dart';

export 'domain/repositories/alert_repository.dart';

export 'domain/usecases/create_alert.dart';
export 'domain/usecases/delete_alert.dart';
export 'domain/usecases/get_alerts.dart';
export 'domain/usecases/check_alerts.dart';

// Data layer
export 'data/models/price_alert_model.dart';

export 'data/datasources/alert_local_datasource.dart';

export 'data/repositories/alert_repository_impl.dart';

// Presentation layer
export 'presentation/bloc/alert_bloc.dart';
export 'presentation/bloc/alert_event.dart';
export 'presentation/bloc/alert_state.dart';

export 'presentation/pages/alerts_page.dart';

export 'presentation/widgets/alert_tile.dart';
export 'presentation/widgets/create_alert_sheet.dart';
