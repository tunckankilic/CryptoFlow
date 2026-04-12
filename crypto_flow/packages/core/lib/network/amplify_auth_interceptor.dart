import 'dart:developer' show log;

import 'package:dio/dio.dart';

import 'token_provider.dart';

/// Dio [Interceptor] that attaches a Cognito JWT access token to every
/// outgoing request and handles 401 responses with a single token-refresh
/// retry.
///
/// If the refresh also fails the original 401 error is forwarded so that
/// upper layers (e.g. BLoC / UI) can redirect to the sign-in screen.
class AmplifyAuthInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;

  /// Optional callback invoked when the user's session is irrecoverably
  /// expired (i.e. even a forced refresh failed). The app should trigger a
  /// sign-out / redirect to login.
  final void Function()? onSessionExpired;

  AmplifyAuthInterceptor({
    required TokenProvider tokenProvider,
    this.onSessionExpired,
  }) : _tokenProvider = tokenProvider;

  // ------------------------------------------------------------------
  // Attach token
  // ------------------------------------------------------------------

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenProvider.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      log('AmplifyAuthInterceptor: failed to get token — $e');
    }
    handler.next(options);
  }

  // ------------------------------------------------------------------
  // Retry once on 401
  // ------------------------------------------------------------------

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Already retried? Give up.
    final alreadyRetried =
        err.requestOptions.extra['_authRetried'] as bool? ?? false;
    if (alreadyRetried) {
      onSessionExpired?.call();
      return handler.next(err);
    }

    log('AmplifyAuthInterceptor: 401 — attempting token refresh');

    try {
      final newToken = await _tokenProvider.forceRefreshToken();
      if (newToken == null) {
        onSessionExpired?.call();
        return handler.next(err);
      }

      // Clone the original request with the fresh token.
      final opts = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken'
        ..extra['_authRetried'] = true;

      final response = await Dio().fetch(opts);
      return handler.resolve(response);
    } catch (e) {
      log('AmplifyAuthInterceptor: refresh failed — $e');
      onSessionExpired?.call();
      return handler.next(err);
    }
  }
}
