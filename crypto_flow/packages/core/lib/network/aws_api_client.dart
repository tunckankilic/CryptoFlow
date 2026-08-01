// ignore_for_file: unused_local_variable

import 'dart:developer' show log;

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'amplify_auth_interceptor.dart';
import 'network_info.dart';
import 'token_provider.dart';

/// Authenticated REST client for the CryptoFlow AWS API Gateway backend.
///
/// This is a **separate** Dio instance from the Binance client. It points at
/// [AppConfig.apiBaseUrl] and automatically attaches the Cognito JWT via
/// [AmplifyAuthInterceptor].
class AwsApiClient {
  final Dio dio;
  final NetworkInfo networkInfo;
  final TokenProvider tokenProvider;

  /// Optional callback forwarded to [AmplifyAuthInterceptor].
  final void Function()? onSessionExpired;

  AwsApiClient({
    required this.dio,
    required this.networkInfo,
    required this.tokenProvider,
    this.onSessionExpired,
  }) {
    _configureDio();
  }

  void _configureDio() {
    dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(
        seconds: AppConstants.connectionTimeoutSeconds,
      ),
      receiveTimeout: Duration(
        seconds: AppConstants.requestTimeoutSeconds,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.addAll([
      AmplifyAuthInterceptor(
        tokenProvider: tokenProvider,
        onSessionExpired: onSessionExpired,
      ),
      _NetworkCheckInterceptor(networkInfo),
      _AwsErrorInterceptor(),
    ]);
  }

  // ------------------------------------------------------------------ HTTP

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

// ======================================================================
// Interceptors
// ======================================================================

/// Rejects requests when the device has no internet connectivity.
class _NetworkCheckInterceptor extends Interceptor {
  final NetworkInfo _networkInfo;
  _NetworkCheckInterceptor(this._networkInfo);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: NetworkException(message: 'No internet connection'),
          type: DioExceptionType.connectionError,
        ),
      );
    }
    log('AWS Request: ${options.method} ${options.uri}');
    handler.next(options);
  }
}

/// Maps AWS API Gateway error responses to the shared exception vocabulary.
///
/// Expected server error shape: `{ "error": "...", "code": "...", "requestId": "..." }`.
class _AwsErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('AWS Error: ${err.type} ${err.requestOptions.uri}');

    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        exception = TimeoutException(
          message: 'Request timeout. Please try again.',
          duration: err.requestOptions.receiveTimeout,
        );

      case DioExceptionType.connectionError:
        if (err.error is NetworkException) {
          exception = err.error as NetworkException;
        } else {
          exception = NetworkException(
            message: 'Connection failed. Please check your internet.',
          );
        }

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final body = err.response?.data;

        // Extract message from the structured error body if available.
        String? serverMessage;
        String? serverCode;
        if (body is Map<String, dynamic>) {
          serverMessage = body['error'] as String?;
          serverCode = body['code'] as String?;
        }

        if (statusCode == 401) {
          // Auth interceptor already retried once; this is a hard failure.
          exception = AuthException(
            message: serverMessage ?? 'Unauthorized',
            code: statusCode,
          );
        } else if (statusCode == 429) {
          exception = RateLimitException(
            message: serverMessage ?? 'Too many requests',
            retryAfterSeconds: 5,
          );
        } else {
          exception = ServerException(
            message: serverMessage ?? 'Server error ($statusCode)',
            code: statusCode,
          );
        }

      case DioExceptionType.cancel:
        exception = AppException(message: 'Request cancelled');

      case DioExceptionType.badCertificate:
        exception = AppException(message: 'SSL certificate error');

      case DioExceptionType.unknown:
        exception = AppException(
          message: err.message ?? 'Unknown error occurred',
        );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }
}
