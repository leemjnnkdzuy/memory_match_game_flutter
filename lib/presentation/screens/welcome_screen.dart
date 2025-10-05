import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService.instance.isRealUser) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'POKEMON',
                          style: AppTheme.headlineLarge.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MEMORY MATCH',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NesButton(
                        type: NesButtonType.primary,
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text('Login', textAlign: TextAlign.center),
                      ),

                      const SizedBox(height: 16),

                      NesButton(
                        type: NesButtonType.normal,
                        onPressed: () {
                          Navigator.pushNamed(context, '/register-verify');
                        },
                        child: Text('Sign Up', textAlign: TextAlign.center),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      NesButton(
                        type: NesButtonType.success,
                        onPressed: () async {
                          // Login as guest using AuthService
                          await AuthService.instance.loginAsGuest();
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        child: Text(
                          'Play as Guest',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
