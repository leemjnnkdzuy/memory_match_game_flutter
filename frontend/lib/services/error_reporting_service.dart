class ErrorReportingService {
  static final ErrorReportingService _instance =
      ErrorReportingService._internal();

  factory ErrorReportingService() => _instance;

  ErrorReportingService._internal();

  void reportError(dynamic error, StackTrace? stackTrace, {String? context}) {
    if (stackTrace != null) throw Exception('Stack trace: $stackTrace');
    if (context != null) throw Exception('Context: $context');
  }
}
