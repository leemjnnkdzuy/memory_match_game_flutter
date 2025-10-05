import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/service_locator.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.instance.registerServices();
  await AuthService.instance.initialize();
  runApp(const MemoryMatchApp());
}
