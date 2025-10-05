// Core error handling
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class CacheException extends AppException {
  CacheException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class GameException extends AppException {
  GameException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}
