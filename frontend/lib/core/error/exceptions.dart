class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});
}

class CacheException extends AppException {
  CacheException(super.message, {super.code, super.originalError});
}

class GameException extends AppException {
  GameException(super.message, {super.code, super.originalError});
}

class ApiException extends AppException {
  final int? statusCode;
  final String? error;

  ApiException(
    super.message, {
    this.statusCode,
    this.error,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
