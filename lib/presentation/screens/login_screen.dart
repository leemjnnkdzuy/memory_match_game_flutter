import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pixelarticons/pixel.dart';
import '../../core/theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../../services/request_service.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final requestService = RequestService.instance;
      final loginResult = await requestService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (loginResult.isSuccess && loginResult.data != null) {
        final authService = AuthService.instance;
        await authService.login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        String errorMessage = loginResult.error ?? 'Login failed';

        if (errorMessage.contains('Invalid login credentials') ||
            errorMessage.contains('Thông tin đăng nhập không hợp lệ')) {
          errorMessage = 'Invalid username or password. Please try again.';
        } else if (errorMessage.contains('verify email') ||
            errorMessage.contains('xác minh email')) {
          errorMessage = 'Please verify your email before logging in.';
        } else if (errorMessage.contains('deactivated') ||
            errorMessage.contains('vô hiệu hóa')) {
          errorMessage =
              'Your account has been deactivated. Please contact support.';
        } else if (errorMessage.contains('Network error')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed';
        if (e is Exception) {
          errorMessage = e
              .toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('ApiException: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: TextFormField(
                        controller: _usernameController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(
                            Pixel.user,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(
                            Pixel.lock,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          suffixIcon: _isLoading
                              ? null
                              : IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                  ),
                                  color: AppTheme.primaryColor,
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                        ),
                        style: const TextStyle(fontSize: 12),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    _isLoading
                        ? NesContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Processing...',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : NesButton(
                            type: NesButtonType.primary,
                            onPressed: _handleLogin,
                            child: const Text(
                              'Login',
                              textAlign: TextAlign.center,
                            ),
                          ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              AppRoutes.navigateToForgotPassword(context);
                            },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    NesButton(
                      type: NesButtonType.normal,
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, '/register-verify');
                            },
                      child: const Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    NesButton(
                      type: NesButtonType.warning,
                      onPressed: _isLoading
                          ? null
                          : () {
                              AppRoutes.navigateBackToWelcome(context);
                            },
                      child: const Text(
                        'Back to Welcome',
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
