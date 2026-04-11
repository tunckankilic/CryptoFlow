/// Compile-time application configuration.
///
/// All values are injected via `--dart-define` (or `--dart-define-from-file`)
/// at build time. Defaults keep the app working with the legacy Firebase /
/// direct-Binance configuration so that the migration can land incrementally.
class AppConfig {
  AppConfig._();

  /// Deployment environment: `dev`, `staging`, or `prod`.
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  /// AWS API Gateway REST base URL (e.g. `https://abc123.execute-api.eu-central-1.amazonaws.com/prod`).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// AWS API Gateway WebSocket base URL (e.g. `wss://xyz.execute-api.eu-central-1.amazonaws.com/prod`).
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: '',
  );

  /// Binance public REST endpoint (used directly by the Flutter client).
  static const String binanceRestUrl = String.fromEnvironment(
    'BINANCE_REST_URL',
    defaultValue: 'https://api.binance.com',
  );

  /// Binance public WebSocket endpoint (used directly by the Flutter client).
  static const String binanceWsUrl = String.fromEnvironment(
    'BINANCE_WS_URL',
    defaultValue: 'wss://stream.binance.com:9443',
  );

  /// Cognito User Pool ID.
  static const String cognitoUserPoolId = String.fromEnvironment(
    'COGNITO_USER_POOL_ID',
    defaultValue: '',
  );

  /// Cognito User Pool App Client ID.
  static const String cognitoClientId = String.fromEnvironment(
    'COGNITO_CLIENT_ID',
    defaultValue: '',
  );

  /// Cognito Identity Pool ID.
  static const String cognitoIdentityPoolId = String.fromEnvironment(
    'COGNITO_IDENTITY_POOL_ID',
    defaultValue: '',
  );

  /// AWS region for all backend services.
  static const String awsRegion = String.fromEnvironment(
    'AWS_REGION',
    defaultValue: 'eu-central-1',
  );

  static bool get isProduction => env == 'prod';
  static bool get isStaging => env == 'staging';
  static bool get isDev => env == 'dev';
}
