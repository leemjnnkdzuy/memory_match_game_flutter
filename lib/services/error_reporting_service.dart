import 'package:flutter/foundation.dart';

class ErrorReportingService {
  static final ErrorReportingService _instance =
      ErrorReportingService._internal();

  factory ErrorReportingService() => _instance;

  ErrorReportingService._internal();

  void reportError(dynamic error, StackTrace? stackTrace, {String? context}) {
    debugPrint('Error reported: $error');
    if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
    if (context != null) debugPrint('Context: $context');
  }
}
