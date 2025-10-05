import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color backgroundColor = Color(0xFFFFFFFF);

  static final ThemeData nesTheme = _buildNesTheme();

  static ThemeData _buildNesTheme() {
    final baseTheme = flutterNesTheme();
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      extensions: baseTheme.extensions.values,
      textTheme: baseTheme.textTheme.copyWith(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelLarge: labelLarge,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'PressStart2P',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'PressStart2P',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'PressStart2P',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'PressStart2P',
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'PressStart2P',
    fontSize: 12,
    color: Colors.black87,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'PressStart2P',
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}

ThemeData nesAppTheme() => AppTheme.nesTheme;
