/// Base exception class for all custom exceptions
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server-side exception (API errors)
class ServerException extends AppException {
  ServerException({
    super.message = 'Server error occurred',
    super.code,
    super.details,
  });

  factory ServerException.fromResponse(int statusCode, dynamic responseBody) {
    String message = 'Server error occurred';

    // Try to extract error message from response body
    if (responseBody is Map) {
      message = responseBody['msg'] ??
          responseBody['message'] ??
          responseBody['error'] ??
          message;
    } else if (responseBody is String) {
      message = responseBody;
    }

    return ServerException(
      message: message,
      code: statusCode,
      details: responseBody,
    );
  }
}

/// Network exception (connection issues)
class NetworkException extends AppException {
  NetworkException({
    super.message = 'Network error occurred',
    super.code,
    super.details,
  });
}

/// Cache/Storage exception
class CacheException extends AppException {
  CacheException({
    super.message = 'Cache error occurred',
    super.code,
    super.details,
  });
}

/// WebSocket exception
class WebSocketException extends AppException {
  final WebSocketExceptionType type;

  WebSocketException({
    required this.type,
    String? message,
    super.code,
    super.details,
  }) : super(
          message: message ?? type.defaultMessage,
        );

  @override
  String toString() => 'WebSocketException ($type): $message';
}

/// Types of WebSocket exceptions
enum WebSocketExceptionType {
  connectionFailed('WebSocket connection failed'),
  connectionLost('WebSocket connection lost'),
  parseError('Failed to parse WebSocket message'),
  timeout('WebSocket connection timeout'),
  authenticationFailed('WebSocket authentication failed'),
  sendFailed('Failed to send WebSocket message'),
  unknown('Unknown WebSocket error');

  final String defaultMessage;
  const WebSocketExceptionType(this.defaultMessage);
}

/// Rate limit exception
class RateLimitException extends AppException {
  final int? retryAfterSeconds;

  RateLimitException({
    super.message = 'Rate limit exceeded',
    int super.code = 429,
    this.retryAfterSeconds,
    super.details,
  });

  factory RateLimitException.fromHeaders(Map<String, dynamic> headers) {
    int? retryAfter;

    // Check for Retry-After header
    if (headers.containsKey('retry-after')) {
      retryAfter = int.tryParse(headers['retry-after'].toString());
    } else if (headers.containsKey('x-ratelimit-reset')) {
      // Calculate seconds until reset
      final resetTimestamp =
          int.tryParse(headers['x-ratelimit-reset'].toString());
      if (resetTimestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        retryAfter = resetTimestamp - now;
      }
    }

    return RateLimitException(
      retryAfterSeconds: retryAfter,
      details: headers,
    );
  }
}

/// Data validation exception
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException({
    super.message = 'Validation failed',
    this.fieldErrors,
    super.code,
    super.details,
  });
}

/// Data parsing exception
class ParsingException extends AppException {
  final Type? expectedType;
  final dynamic actualData;

  ParsingException({
    super.message = 'Failed to parse data',
    this.expectedType,
    this.actualData,
    super.code,
  }) : super(
          details: {'expected': expectedType, 'actual': actualData},
        );

  @override
  String toString() {
    if (expectedType != null) {
      return 'ParsingException: Failed to parse data to $expectedType. $message';
    }
    return super.toString();
  }
}

/// Timeout exception
class TimeoutException extends AppException {
  final Duration? duration;

  TimeoutException({
    super.message = 'Operation timed out',
    this.duration,
    super.code,
    super.details,
  });

  @override
  String toString() {
    if (duration != null) {
      return 'TimeoutException: Operation timed out after ${duration!.inSeconds}s';
    }
    return super.toString();
  }
}

/// Permission denied exception
class PermissionException extends AppException {
  final String? permission;

  PermissionException({
    super.message = 'Permission denied',
    this.permission,
    super.code,
    super.details,
  });

  @override
  String toString() {
    if (permission != null) {
      return 'PermissionException: Permission denied for $permission';
    }
    return super.toString();
  }
}

/// Authentication/Authorization exception
class AuthException extends AppException {
  AuthException({
    super.message = 'Authentication failed',
    int super.code = 401,
    super.details,
  });
}

/// Not found exception
class NotFoundException extends AppException {
  final String? resourceType;

  NotFoundException({
    super.message = 'Resource not found',
    this.resourceType,
    int super.code = 404,
    super.details,
  });

  @override
  String toString() {
    if (resourceType != null) {
      return 'NotFoundException: $resourceType not found';
    }
    return super.toString();
  }
}
