import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_verify_screen.dart';
import '../screens/difficulty_selection_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/setting_screen.dart';
import '../screens/change_username_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/change_email_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String registerVerify = '/register-verify';
  static const String forgotPassword = '/forgot-password';
  static const String difficultySelection = '/difficulty-selection';
  static const String game = '/game';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String changeUsername = '/change-username';
  static const String changePassword = '/change-password';
  static const String changeEmail = '/change-email';
  static const String testSettings = '/test-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case registerVerify:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RegisterVerifyScreen(
            initialData: args?['initialData'] as Map<String, String>?,
            startWithVerification:
                args?['startWithVerification'] as bool? ?? false,
            verificationEmail: args?['verificationEmail'] as String?,
          ),
          settings: settings,
        );

      case difficultySelection:
        return MaterialPageRoute(
          builder: (context) => DifficultySelectionScreen(
            onDifficultySelected: (difficulty) {
              Navigator.pushNamed(context, game);
            },
          ),
          settings: settings,
        );

      case game:
        // TODO: Implement GameScreen
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Game Screen\n(Coming Soon)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          settings: settings,
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
          settings: settings,
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingScreen(),
          settings: settings,
        );

      case AppRoutes.changeUsername:
        return MaterialPageRoute(
          builder: (_) => const ChangeUsernameScreen(),
          settings: settings,
        );

      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
          settings: settings,
        );

      case AppRoutes.changeEmail:
        return MaterialPageRoute(
          builder: (_) => const ChangeEmailScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                '404\nPage Not Found',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          settings: settings,
        );
    }
  }

  static void navigateToWelcome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, welcome, (route) => false);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, login);
  }

  static void navigateToRegisterVerify(
    BuildContext context, {
    Map<String, String>? initialData,
    bool startWithVerification = false,
    String? verificationEmail,
  }) {
    Navigator.pushNamed(
      context,
      registerVerify,
      arguments: {
        'initialData': initialData,
        'startWithVerification': startWithVerification,
        'verificationEmail': verificationEmail,
      },
    );
  }

  static void navigateToDifficultySelection(BuildContext context) {
    Navigator.pushNamed(context, difficultySelection);
  }

  static void navigateToGame(BuildContext context) {
    Navigator.pushNamed(context, game);
  }

  static void navigateBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void navigateBackToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static void navigateBackToWelcome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, welcome, (route) => false);
  }

  static void navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, editProfile);
  }

  static void navigateToForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, forgotPassword);
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, settings);
  }

  static void navigateToChangeUsername(BuildContext context) {
    Navigator.pushNamed(context, changeUsername);
  }

  static void navigateToChangePassword(BuildContext context) {
    Navigator.pushNamed(context, changePassword);
  }

  static void navigateToChangeEmail(BuildContext context) {
    Navigator.pushNamed(context, changeEmail);
  }
}
