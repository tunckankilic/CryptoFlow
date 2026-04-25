import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart' hide AuthException;
import 'package:amplify_flutter/amplify_flutter.dart' hide AuthException;

import '../../domain/entities/app_user.dart' as domain;
import '../models/app_user_model.dart';
import 'auth_data_source.dart';

/// AWS Cognito authentication datasource backed by Amplify Flutter Gen 2.
///
/// Assumes `Amplify.configure()` has already been called from `main.dart`
/// before this datasource is used.
class CognitoAuthDataSource implements AuthDataSource {
  CognitoAuthDataSource() {
    _authStateController = StreamController<AppUserModel?>.broadcast(
      onListen: _onFirstListener,
      onCancel: _onLastCancel,
    );
  }

  late final StreamController<AppUserModel?> _authStateController;
  StreamSubscription<AuthHubEvent>? _hubSubscription;

  void _onFirstListener() {
    // Seed with the current user, then subscribe to Hub events.
    _emitCurrentUser();
    _hubSubscription = Amplify.Hub.listen(HubChannel.Auth, (event) {
      switch (event.type) {
        case AuthHubEventType.signedIn:
        case AuthHubEventType.sessionExpired:
        case AuthHubEventType.userDeleted:
          _emitCurrentUser();
          break;
        case AuthHubEventType.signedOut:
          _authStateController.add(null);
          break;
      }
    });
  }

  void _onLastCancel() {
    _hubSubscription?.cancel();
    _hubSubscription = null;
  }

  Future<void> _emitCurrentUser() async {
    try {
      final user = await getCurrentUser();
      _authStateController.add(user);
    } on AuthException {
      _authStateController.add(null);
    }
  }

  @override
  Stream<AppUserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<AppUserModel?> getCurrentUser() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) return null;

      final authUser = await Amplify.Auth.getCurrentUser();
      final attributes = await Amplify.Auth.fetchUserAttributes();
      return AppUserModel.fromCognitoUser(
        authUser: authUser,
        attributes: attributes,
      );
    } on SignedOutException {
      return null;
    } on AmplifyException catch (e) {
      throw mapAmplifyException(e, fallback: 'Failed to fetch current user');
    }
  }

  @override
  Future<AppUserModel> signInWithGoogle() =>
      _signInWithProvider(AuthProvider.google, domain.AuthProvider.google);

  @override
  Future<AppUserModel> signInWithApple() =>
      _signInWithProvider(AuthProvider.apple, domain.AuthProvider.apple);

  Future<AppUserModel> _signInWithProvider(
    AuthProvider amplifyProvider,
    domain.AuthProvider domainProvider,
  ) async {
    try {
      final result = await Amplify.Auth.signInWithWebUI(
        provider: amplifyProvider,
      );
      if (!result.isSignedIn) {
        throw const AuthException(
          'Sign in did not complete',
          code: 'unknown',
        );
      }
      final user = await getCurrentUser();
      if (user == null) {
        throw const AuthException(
          'No user after successful sign-in',
          code: 'null-user',
        );
      }
      // Override provider with the one we requested — Cognito attribute
      // inference is best-effort and may fail for fresh accounts.
      return AppUserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        provider: domainProvider,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
      );
    } on UserCancelledException {
      throw const AuthException(
        'Sign in was cancelled',
        code: 'cancelled',
      );
    } on AmplifyException catch (e) {
      throw mapAmplifyException(e, fallback: 'Sign in failed');
    }
  }

  @override
  Future<AppUserModel> signInAnonymously() async {
    throw const AuthException(
      'Anonymous sign-in is not supported on Cognito',
      code: 'unsupported',
    );
  }

  @override
  Future<void> signOut() async {
    try {
      final result = await Amplify.Auth.signOut();
      if (result is CognitoFailedSignOut) {
        throw mapAmplifyException(
          result.exception,
          fallback: 'Sign out failed',
        );
      }
    } on AmplifyException catch (e) {
      throw mapAmplifyException(e, fallback: 'Sign out failed');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await Amplify.Auth.deleteUser();
    } on AuthNotAuthorizedException catch (e) {
      throw AuthException(
        e.message,
        code: 'requires-recent-login',
      );
    } on AmplifyException catch (e) {
      throw mapAmplifyException(e, fallback: 'Account deletion failed');
    }
  }
}

/// Pure-function mapping from [AmplifyException] to the shared
/// [AuthException] vocabulary.
///
/// Exposed at top level so it can be unit-tested without spinning up Amplify.
AuthException mapAmplifyException(
  AmplifyException e, {
  required String fallback,
}) {
  if (e is UserCancelledException) {
    return AuthException(e.message, code: 'cancelled');
  }
  if (e is AuthNotAuthorizedException) {
    return AuthException(e.message, code: 'not-authorized');
  }
  if (e is SignedOutException) {
    return AuthException(e.message, code: 'no-user');
  }
  if (e is SessionExpiredException) {
    return AuthException(e.message, code: 'requires-recent-login');
  }
  if (e is NetworkException) {
    return AuthException(e.message, code: 'network');
  }
  return AuthException(e.message.isEmpty ? fallback : e.message, code: 'unknown');
}
