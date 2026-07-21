import 'package:amplify_flutter/amplify_flutter.dart' as amplify
    hide AuthException;
import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapAmplifyException', () {
    test('UserCancelledException → cancelled', () {
      final result = mapAmplifyException(
        const amplify.UserCancelledException('user cancelled'),
        fallback: 'fallback',
      );
      expect(result.code, 'cancelled');
      expect(result.message, 'user cancelled');
    });

    test('AuthNotAuthorizedException → not-authorized', () {
      final result = mapAmplifyException(
        const amplify.AuthNotAuthorizedException('bad creds'),
        fallback: 'fallback',
      );
      expect(result.code, 'not-authorized');
    });

    test('SignedOutException → no-user', () {
      final result = mapAmplifyException(
        const amplify.SignedOutException('signed out'),
        fallback: 'fallback',
      );
      expect(result.code, 'no-user');
    });

    test('SessionExpiredException → requires-recent-login', () {
      final result = mapAmplifyException(
        const amplify.SessionExpiredException('expired'),
        fallback: 'fallback',
      );
      expect(result.code, 'requires-recent-login');
    });

    test('NetworkException → network', () {
      final result = mapAmplifyException(
        const amplify.NetworkException('offline'),
        fallback: 'fallback',
      );
      expect(result.code, 'network');
    });

    test('unknown AmplifyException uses fallback when message empty', () {
      final result = mapAmplifyException(
        const amplify.UnknownException(''),
        fallback: 'fallback msg',
      );
      expect(result.code, 'unknown');
      expect(result.message, 'fallback msg');
    });
  });
}
