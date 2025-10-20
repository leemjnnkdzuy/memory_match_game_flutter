import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../widgets/custom/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _hasCheckedLoginStatus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedLoginStatus) {
      _hasCheckedLoginStatus = true;
      _checkLoginStatus();
    }
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
                            fontFamily: 'PressStart2P',
                            color: AppTheme.primaryColor,
                            fontSize: 38,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MEMORY MATCH',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontFamily: 'PressStart2P',
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
                      CustomButton(
                        type: CustomButtonType.primary,
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text('Đăng nhập', textAlign: TextAlign.center),
                      ),

                      const SizedBox(height: 16),

                      CustomButton(
                        type: CustomButtonType.normal,
                        onPressed: () {
                          Navigator.pushNamed(context, '/register-verify');
                        },
                        child: Text('Đăng ký', textAlign: TextAlign.center),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Hoặc',
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
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      CustomButton(
                        type: CustomButtonType.success,
                        onPressed: () async {
                          await AuthService.instance.loginAsGuest();
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        child: Text(
                          'Chơi với tư cách khách',
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
