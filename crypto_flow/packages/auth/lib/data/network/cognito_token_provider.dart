import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:core/core.dart';

/// [TokenProvider] implementation backed by AWS Amplify / Cognito.
///
/// Retrieves the user-pool access token from the current
/// [CognitoAuthSession]. Amplify handles caching and automatic refresh of
/// the underlying tokens, so calling [getAccessToken] is cheap in the
/// common case.
class CognitoTokenProvider implements TokenProvider {
  @override
  Future<String?> getAccessToken() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) return null;

      final cognitoSession = session as CognitoAuthSession;
      return cognitoSession.userPoolTokensResult.value.accessToken.toJson();
    } on SignedOutException {
      return null;
    } on AmplifyException {
      return null;
    }
  }

  @override
  Future<String?> forceRefreshToken() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(forceRefresh: true),
      );
      if (!session.isSignedIn) return null;

      final cognitoSession = session as CognitoAuthSession;
      return cognitoSession.userPoolTokensResult.value.accessToken.toJson();
    } on SignedOutException {
      return null;
    } on AmplifyException {
      return null;
    }
  }
}
