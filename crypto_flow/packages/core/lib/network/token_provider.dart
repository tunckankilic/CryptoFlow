/// Abstract interface for providing authentication tokens.
///
/// The core package stays Amplify-agnostic. The auth package supplies the
/// concrete [CognitoTokenProvider] implementation.
abstract class TokenProvider {
  /// Returns the current Cognito access token, or `null` if the user is
  /// signed out or the token cannot be retrieved.
  Future<String?> getAccessToken();

  /// Forces a token refresh and returns the new access token, or `null` if
  /// the refresh fails (e.g. the refresh token itself has expired).
  Future<String?> forceRefreshToken();
}
