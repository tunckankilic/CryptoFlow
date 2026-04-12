/// Core package for CryptoWave
///
/// This package provides:
/// - Network clients (REST and WebSocket)
/// - Error handling and failures
/// - Constants and configurations
/// - Base use cases
/// - Utility functions
/// - Cloud sync service
library;

// Config
export 'config/config.dart';

// Constants
export 'constants/api_endpoints.dart';
export 'constants/app_constants.dart';
export 'constants/aws_endpoints.dart';
export 'constants/ws_channels.dart';
export 'constants/storage_keys.dart';

// Error handling
export 'error/exceptions.dart';
export 'error/failures.dart';

// Network
export 'network/api_client.dart';
export 'network/amplify_auth_interceptor.dart';
export 'network/aws_api_client.dart';
export 'network/aws_websocket_client.dart';
export 'network/network_info.dart';
export 'network/token_provider.dart';
export 'network/websocket_client.dart';
export 'network/fear_greed_datasource.dart';

// Entities
export 'entities/fear_greed_index.dart';

// Services
export 'services/cloud_sync_service.dart';
export 'services/share_service.dart';
export 'services/widget_data_service.dart';

// Use cases
export 'usecases/usecase.dart';

// Utils
export 'utils/extensions.dart';
export 'utils/formatters.dart';
export 'utils/debouncer.dart';
