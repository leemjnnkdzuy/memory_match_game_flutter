import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../core/theme/app_theme.dart';
import '../../services/request_service.dart';
import '../routes/app_routes.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_container.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PageController _pageController = PageController();
  final _emailFormKey = GlobalKey<FormState>();
  final _pinFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _resetToken;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (result.isSuccess) {
        _showSuccessMessage('Mã xác thực đã được gửi về email!');
        _nextStep();
        _startResendCountdown();
      } else {
        throw Exception(result.error ?? 'Failed to send reset email');
      }
    } catch (e) {
      _showErrorMessage(
        'Error: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerifyPin() async {
    if (!_pinFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.verifyResetPin(
        email: _emailController.text.trim(),
        code: _pinController.text.trim(),
      );

      if (result.isSuccess && result.data != null) {
        _resetToken = result.data!;
        _showSuccessMessage('Xác thực thành công!');
        await Future.delayed(const Duration(milliseconds: 500));
        _nextStep();
      } else {
        throw Exception(result.error ?? 'Mã PIN không hợp lệ hoặc đã hết hạn');
      }
    } catch (e) {
      _showErrorMessage(
        'Error: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    if (_resetToken == null) {
      _showErrorMessage('Phiên đặt lại không hợp lệ. Vui lòng bắt đầu lại.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.resetPassword(
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        resetToken: _resetToken!,
      );

      if (result.isSuccess) {
        _showSuccessMessage('Đặt lại mật khẩu thành công!');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            AppRoutes.navigateToLogin(context);
          }
        });
      } else {
        throw Exception(result.error ?? 'Không thể đặt lại mật khẩu');
      }
    } catch (e) {
      _showErrorMessage(
        'Error: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendEmail() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (result.isSuccess) {
        _showSuccessMessage('Mã xác thực mới đã được gửi!');
        _startResendCountdown();
      } else {
        throw Exception(result.error ?? 'Không thể gửi lại email');
      }
    } catch (e) {
      _showErrorMessage(
        'Error: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        return _resendCountdown > 0;
      }
      return false;
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryColor, width: 2),
            color: index <= _currentStep
                ? AppTheme.primaryColor
                : Colors.transparent,
          ),
        );
      }),
    );
  }

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quên mật khẩu',
            style: AppTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Nhập địa chỉ email của bạn và chúng tôi sẽ gửi mã PIN để đặt lại mật khẩu.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Địa chỉ email',
                labelStyle: TextStyle(
                  fontFamily: 'AlanSans',
                  fontSize: 10,
                  color: AppTheme.primaryColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                prefixIcon: Icon(
                  Pixel.mail,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              style: const TextStyle(fontSize: 12),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email của bạn';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Vui lòng nhập email hợp lệ';
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Processing...',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomButton(
                  type: CustomButtonType.primary,
                  onPressed: _handleSendResetEmail,
                  child: const Text(
                    'Gửi email đặt lại mật khẩu',
                    textAlign: TextAlign.center,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPinStep() {
    return Form(
      key: _pinFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Xác minh mã PIN',
            style: AppTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Nhập mã PIN 6 chữ số được gửi đến email của bạn:\n${_emailController.text}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Mã PIN',
                labelStyle: TextStyle(
                  fontFamily: 'AlanSans',
                  fontSize: 10,
                  color: AppTheme.primaryColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterText: '',
                prefixIcon: Icon(
                  Pixel.lock,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              style: const TextStyle(fontSize: 14, letterSpacing: 2),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mã PIN';
                }
                if (value.length != 6) {
                  return 'Mã PIN phải có 6 chữ số';
                }
                if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                  return 'Mã PIN chỉ được chứa số';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: _resendCountdown > 0 ? null : _handleResendEmail,
            child: Text(
              _resendCountdown > 0
                  ? 'Gửi lại sau ${_resendCountdown}s'
                  : 'Gửi lại mã PIN',
              style: TextStyle(
                fontSize: 10,
                color: _resendCountdown > 0
                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                    : AppTheme.primaryColor.withValues(alpha: 0.7),
              ),
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Đang xử lý...',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomButton(
                  type: CustomButtonType.primary,
                  onPressed: _handleVerifyPin,
                  child: const Text(
                    'Xác minh mã PIN',
                    textAlign: TextAlign.center,
                  ),
                ),

          const SizedBox(height: 16),

          CustomButton(
            type: CustomButtonType.normal,
            onPressed: _previousStep,
            child: Text('Back', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mật khẩu mới',
            style: AppTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Nhập mật khẩu mới của bạn bên dưới.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
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
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Pixel.eyeclosed : Pixel.eye,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  onPressed: () {
                    if (!_isLoading) {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    }
                  },
                ),
              ),
              style: const TextStyle(fontSize: 12),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu mới';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
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
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Pixel.eyeclosed : Pixel.eye,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  onPressed: () {
                    if (!_isLoading) {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    }
                  },
                ),
              ),
              style: const TextStyle(fontSize: 12),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if (value != _passwordController.text) {
                  return 'Mật khẩu không khớp';
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Đang xử lý...',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomButton(
                  type: CustomButtonType.primary,
                  onPressed: _handleResetPassword,
                  child: const Text(
                    'Đặt lại mật khẩu',
                    textAlign: TextAlign.center,
                  ),
                ),

          const SizedBox(height: 16),

          CustomButton(
            type: CustomButtonType.normal,
            onPressed: _previousStep,
            child: Text('Quay lại', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildStepIndicator(),

              const SizedBox(height: 32),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildEmailStep(),
                    _buildPinStep(),
                    _buildPasswordStep(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              CustomButton(
                type: CustomButtonType.warning,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Quay lại đăng nhập', textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
