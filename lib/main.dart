import 'dart:async';
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/locator_service.dart';
import 'services/auth_service.dart';
import 'services/error_reporting_service.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        ErrorReportingService().reportError(
          details.exception,
          details.stack,
          context: 'Flutter Error',
        );
      };

      ServiceLocator.instance.registerServices();
      await AuthService.instance.initialize();

      runApp(const MemoryMatchApp());
    },
    (Object error, StackTrace stack) {
      ErrorReportingService().reportError(
        error,
        stack,
        context: 'Unhandled Zone Error',
      );
    },
  );
}
