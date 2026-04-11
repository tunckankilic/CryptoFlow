/// Compile-time feature flags governing the Firebase → AWS migration.
///
/// Both flags are injected via `--dart-define` at build time. They default
/// to `false`, keeping the app on the legacy Firebase stack until each
/// environment is ready to flip over.
class FeatureFlags {
  FeatureFlags._();

  /// When `true`, CRUD calls go to API Gateway / Lambda. Market data
  /// (Binance REST + WebSocket) keeps connecting directly from the client
  /// regardless of this flag.
  static const bool useAwsBackend = bool.fromEnvironment(
    'USE_AWS_BACKEND',
    defaultValue: false,
  );

  /// When `true`, authentication uses Amplify + Cognito. When `false`, the
  /// app continues to use Firebase Auth.
  static const bool useCognitoAuth = bool.fromEnvironment(
    'USE_COGNITO_AUTH',
    defaultValue: false,
  );
}
