import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_routes.dart';

class MemoryMatchApp extends StatelessWidget {
  const MemoryMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: const ValueKey('memory_match_app'),
      title: 'Memory Match Game',
      theme: AppTheme.nesTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
