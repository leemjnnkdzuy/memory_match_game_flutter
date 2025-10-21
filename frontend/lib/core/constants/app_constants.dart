class AppConstants {
  AppConstants._();

  static const String appName = 'Memory Match Game';
  static const String appVersion = '1.0.0';

  static const String apiBaseUrl = 'http://localhost:3001/';

  static const int maxFlippedCards = 2;
  static const Duration cardFlipDuration = Duration(milliseconds: 300);
  static const Duration cardMatchDelay = Duration(milliseconds: 800);
  static const Duration cardResetDelay = Duration(milliseconds: 1200);

  static const int scorePerMatch = 10;
  static const int scorePenaltyPerMove = 1;
  static const int timeBonus = 5;

  static const double cardAspectRatio = 0.8;
  static const double cardBorderRadius = 8.0;
  static const double cardElevation = 4.0;

  static const Duration fadeInDuration = Duration(milliseconds: 500);
  static const Duration slideInDuration = Duration(milliseconds: 300);
  static const Duration scaleUpDuration = Duration(milliseconds: 200);

  static const String gameHistoryKey = 'game_history';
  static const String currentGameKey = 'current_game';
  static const String userPreferencesKey = 'user_preferences';

  static const String imagesPath = 'assets/images/';
  static const String soundsPath = 'assets/sounds/';
  static const String fontsPath = 'assets/fonts/';
}
