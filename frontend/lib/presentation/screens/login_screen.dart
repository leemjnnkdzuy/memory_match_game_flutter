import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../core/theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../../services/request_service.dart';
import '../../services/auth_service.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_container.dart';
import '../widgets/custom/custom_text_input.dart';
import '../widgets/custom/custom_password_input.dart';

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
          errorMessage =
              'Tên người dùng hoặc mật khẩu không hợp lệ. Vui lòng thử lại.';
        } else if (errorMessage.contains('verify email') ||
            errorMessage.contains('xác minh email')) {
          errorMessage = 'Vui lòng xác minh email trước khi đăng nhập.';
        } else if (errorMessage.contains('deactivated') ||
            errorMessage.contains('vô hiệu hóa')) {
          errorMessage =
              'Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.';
        } else if (errorMessage.contains('Network error')) {
          errorMessage = 'Lỗi mạng. Vui lòng kiểm tra kết nối internet.';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Đăng nhập thất bại';
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
                      margin: const EdgeInsets.only(bottom: 16),
                      child: CustomTextInput(
                        controller: _usernameController,
                        enabled: !_isLoading,
                        fontSize: 10,
                        labelText: 'Tên người dùng',
                        hintText: 'Nhập tên người dùng',
                        prefixIcon: Icon(
                          Pixel.user,
                          color: Colors.black,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên người dùng';
                          }
                          if (value.length < 3) {
                            return 'Tên người dùng phải có ít nhất 3 ký tự';
                          }
                          return null;
                        },
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: CustomPasswordInput(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        fontSize: 10,
                        labelText: 'Mật khẩu',
                        hintText: 'Nhập mật khẩu',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    _isLoading
                        ? CustomContainer(
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
                                    'Đang xử lý...',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : CustomButton(
                            type: CustomButtonType.primary,
                            onPressed: _handleLogin,
                            child: const Text(
                              'Đăng nhập',
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
                        'Quên mật khẩu?',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'HOẶC',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    CustomButton(
                      type: CustomButtonType.normal,
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, '/register-verify');
                            },
                      child: const Text(
                        'Tạo tài khoản',
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    CustomButton(
                      type: CustomButtonType.warning,
                      onPressed: _isLoading
                          ? null
                          : () {
                              AppRoutes.navigateBackToWelcome(context);
                            },
                      child: const Text(
                        'Quay lại trang chào mừng',
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
