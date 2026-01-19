import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Uses the Either pattern from dartz for error handling
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network connection failure (no internet, timeout, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
    super.details,
  });
}

/// Server-side failure (4xx, 5xx HTTP errors)
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred. Please try again later.',
    super.code,
    super.details,
  });

  /// Create from HTTP status code
  factory ServerFailure.fromStatusCode(int statusCode,
      {String? customMessage}) {
    String message;
    switch (statusCode) {
      case 400:
        message = customMessage ?? 'Bad request. Please check your input.';
        break;
      case 401:
        message = customMessage ?? 'Unauthorized. Please login again.';
        break;
      case 403:
        message = customMessage ?? 'Access forbidden.';
        break;
      case 404:
        message = customMessage ?? 'Resource not found.';
        break;
      case 429:
        message = customMessage ?? 'Too many requests. Please slow down.';
        break;
      case 500:
        message = customMessage ?? 'Internal server error.';
        break;
      case 502:
        message =
            customMessage ?? 'Bad gateway. Server is temporarily unavailable.';
        break;
      case 503:
        message =
            customMessage ?? 'Service unavailable. Please try again later.';
        break;
      default:
        message = customMessage ?? 'Server error occurred (Code: $statusCode).';
    }
    return ServerFailure(message: message, code: statusCode);
  }
}

/// Local cache/storage failure
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local storage.',
    super.code,
    super.details,
  });
}

/// WebSocket connection failure
class WebSocketFailure extends Failure {
  final WebSocketFailureType type;

  WebSocketFailure({
    required this.type,
    String? message,
    super.code,
    super.details,
  }) : super(
          message: message ?? type.defaultMessage,
        );

  @override
  List<Object?> get props => [type, message, code, details];
}

/// Types of WebSocket failures
enum WebSocketFailureType {
  connectionLost('WebSocket connection lost'),
  connectionFailed('Failed to establish WebSocket connection'),
  parseError('Failed to parse WebSocket message'),
  timeout('WebSocket connection timeout'),
  authenticationFailed('WebSocket authentication failed'),
  unknown('Unknown WebSocket error');

  final String defaultMessage;
  const WebSocketFailureType(this.defaultMessage);
}

/// API rate limit exceeded failure
class RateLimitFailure extends Failure {
  final int? retryAfterSeconds;

  const RateLimitFailure({
    super.message = 'API rate limit exceeded. Please try again later.',
    super.code = 429,
    this.retryAfterSeconds,
    super.details,
  });

  @override
  List<Object?> get props => [message, code, retryAfterSeconds, details];

  String get retryMessage {
    if (retryAfterSeconds != null) {
      return 'Please retry after $retryAfterSeconds seconds.';
    }
    return 'Please retry after a short while.';
  }
}

/// Data validation failure
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation failed. Please check your input.',
    this.fieldErrors,
    super.code,
    super.details,
  });

  @override
  List<Object?> get props => [message, fieldErrors, code, details];
}

/// Data parsing failure
class ParsingFailure extends Failure {
  const ParsingFailure({
    super.message = 'Failed to parse data. Data format may be invalid.',
    super.code,
    super.details,
  });
}

/// Permission denied failure
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied.',
    super.code,
    super.details,
  });
}

/// Unknown/Unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
    super.details,
  });
}
