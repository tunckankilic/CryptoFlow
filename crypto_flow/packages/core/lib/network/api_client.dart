import 'dart:developer' show log;

import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'network_info.dart';

/// Binance REST API client using Dio
class BinanceApiClient {
  final Dio dio;
  final NetworkInfo networkInfo;

  // Rate limiting
  final List<DateTime> _requestTimestamps = [];
  static const int _rateLimitWindow = 60; // seconds

  BinanceApiClient({
    required this.dio,
    required this.networkInfo,
  }) {
    _configureDio();
  }

  /// Configure Dio with interceptors and options
  void _configureDio() {
    dio.options = BaseOptions(
      baseUrl: BinanceEndpoints.baseUrl,
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

    // Add interceptors
    dio.interceptors.add(_RequestInterceptor(this));
    dio.interceptors.add(_ResponseInterceptor());
    dio.interceptors.add(_ErrorInterceptor());
  }

  /// Check and enforce rate limiting
  Future<void> _checkRateLimit() async {
    final now = DateTime.now();

    // Remove timestamps older than the rate limit window
    _requestTimestamps.removeWhere((timestamp) {
      return now.difference(timestamp).inSeconds > _rateLimitWindow;
    });

    // Check if we've exceeded the rate limit
    if (_requestTimestamps.length >= AppConstants.rateLimitPerMinute) {
      final oldestTimestamp = _requestTimestamps.first;
      final timeSinceOldest = now.difference(oldestTimestamp).inSeconds;
      final waitTime = _rateLimitWindow - timeSinceOldest;

      throw RateLimitException(
        message: 'Rate limit exceeded. Too many requests.',
        retryAfterSeconds: waitTime > 0 ? waitTime : 1,
      );
    }

    // Add current request timestamp
    _requestTimestamps.add(now);
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkRateLimit();

    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkRateLimit();

    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkRateLimit();

    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkRateLimit();

    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Clear rate limit history (useful for testing)
  void clearRateLimit() {
    _requestTimestamps.clear();
  }
}

/// Request interceptor for logging and network checking
class _RequestInterceptor extends Interceptor {
  final BinanceApiClient client;

  _RequestInterceptor(this.client);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check network connectivity
    final isConnected = await client.networkInfo.isConnected;
    if (!isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: NetworkException(
            message: 'No internet connection',
          ),
          type: DioExceptionType.connectionError,
        ),
      );
    }

    // Log request (in debug mode)
    log('API Request: ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      log('Query: ${options.queryParameters}');
    }

    handler.next(options);
  }
}

/// Response interceptor for logging
class _ResponseInterceptor extends Interceptor {
  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Log response (in debug mode)
    log('API Response: ${response.statusCode} ${response.requestOptions.uri}');

    handler.next(response);
  }
}

/// Error interceptor for handling API errors
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    log('API Error: ${err.type} ${err.requestOptions.uri}');
    log('Message: ${err.message}');

    // Transform DioException to custom exceptions
    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException(
          message: 'Request timeout. Please try again.',
          duration: err.requestOptions.receiveTimeout,
        );
        break;

      case DioExceptionType.connectionError:
        if (err.error is NetworkException) {
          exception = err.error as NetworkException;
        } else {
          exception = NetworkException(
            message: 'Connection failed. Please check your internet.',
          );
        }
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;

        if (statusCode == 429) {
          // Rate limit exceeded
          final headers = err.response?.headers.map ?? {};
          exception = RateLimitException.fromHeaders(headers);
        } else {
          // Other server errors
          exception = ServerException.fromResponse(
            statusCode,
            err.response?.data,
          );
        }
        break;

      case DioExceptionType.cancel:
        exception = AppException(message: 'Request cancelled');
        break;

      case DioExceptionType.badCertificate:
        exception = AppException(message: 'SSL certificate error');
        break;

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

/// Retry interceptor for failed requests
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // Only retry on network or timeout errors
    final shouldRetry = (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout) &&
        retryCount < maxRetries;

    if (shouldRetry) {
      log('Retrying request (attempt ${retryCount + 1}/$maxRetries)');

      // Wait before retrying
      await Future.delayed(retryDelay * (retryCount + 1));

      // Increment retry count
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      // Retry the request
      try {
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return super.onError(e, handler);
        }
      }
    }

    return super.onError(err, handler);
  }
}
