abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code})
    : super(message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code})
    : super(message, code: code);
}

class GameFailure extends Failure {
  const GameFailure(String message, {String? code})
    : super(message, code: code);
}
