import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixel.dart';
import '../../core/theme/app_theme.dart';
import '../../services/request_service.dart';
import '../routes/app_routes.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_container.dart';

class RegisterVerifyScreen extends StatefulWidget {
  final Map<String, String>? initialData;

  final bool startWithVerification;

  final String? verificationEmail;

  const RegisterVerifyScreen({
    super.key,
    this.initialData,
    this.startWithVerification = false,
    this.verificationEmail,
  });

  @override
  State<RegisterVerifyScreen> createState() => _RegisterVerifyScreenState();
}

class _RegisterVerifyScreenState extends State<RegisterVerifyScreen>
    with TickerProviderStateMixin {
  RegistrationPhase _currentPhase = RegistrationPhase.register;
  late AnimationController _phaseAnimationController;
  late Animation<double> _fadeAnimation;

  final _registerFormKey = GlobalKey<FormState>();
  final _verifyFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _verificationCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _registeredEmail;
  int _resendCooldown = 0;

  final RequestService _requestService = RequestService.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _phaseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _phaseAnimationController.forward();
  }

  void _initializeData() {
    if (widget.initialData != null) {
      _usernameController.text = widget.initialData!['username'] ?? '';
      _emailController.text = widget.initialData!['email'] ?? '';
      _firstNameController.text = widget.initialData!['firstName'] ?? '';
      _lastNameController.text = widget.initialData!['lastName'] ?? '';
    }

    if (widget.startWithVerification) {
      _currentPhase = RegistrationPhase.verify;
      _registeredEmail = widget.verificationEmail;
      if (widget.verificationEmail != null) {
        _emailController.text = widget.verificationEmail!;
      }
    }
  }

  @override
  void dispose() {
    _phaseAnimationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _switchToVerificationPhase(String email) async {
    await _phaseAnimationController.reverse();

    setState(() {
      _currentPhase = RegistrationPhase.verify;
      _registeredEmail = email;
      _isLoading = false;
    });

    await _phaseAnimationController.forward();
  }

  Future<void> _switchToRegistrationPhase() async {
    await _phaseAnimationController.reverse();

    setState(() {
      _currentPhase = RegistrationPhase.register;
      _verificationCodeController.clear();
      _isLoading = false;
    });

    await _phaseAnimationController.forward();
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _requestService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (mounted) {
        if (result.isSuccess) {
          _showSnackBar(
            'Đăng ký thành công! Vui lòng kiểm tra email để xác minh tài khoản.',
            AppTheme.secondaryColor,
          );

          await _switchToVerificationPhase(_emailController.text.trim());
        } else {
          _showSnackBar(
            result.error ?? 'Đăng ký thất bại. Vui lòng thử lại.',
            AppTheme.errorColor,
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Có lỗi xảy ra: ${e.toString()}', AppTheme.errorColor);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleVerification() async {
    if (!_verifyFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _requestService.verifyEmail(
        code: _verificationCodeController.text.trim(),
      );

      if (mounted) {
        if (result.isSuccess) {
          _showSnackBar(
            'Xác minh email thành công! Bạn có thể đăng nhập ngay bây giờ.',
            AppTheme.secondaryColor,
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => route.settings.name == '/welcome',
          );
        } else {
          _showSnackBar(
            result.error ?? 'Mã xác minh không hợp lệ hoặc đã hết hạn.',
            AppTheme.errorColor,
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Có lỗi xảy ra: ${e.toString()}', AppTheme.errorColor);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendVerification() async {
    if (_resendCooldown > 0 || _registeredEmail == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _requestService.resendVerificationEmail(
        email: _registeredEmail!,
      );

      if (mounted) {
        if (result.isSuccess) {
          _showSnackBar(
            'Mã xác minh mới đã được gửi về email!',
            AppTheme.secondaryColor,
          );
          _startResendCooldown();
        } else {
          _showSnackBar(
            result.error ?? 'Không thể gửi lại mã xác minh.',
            AppTheme.errorColor,
          );
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Có lỗi xảy ra: ${e.toString()}', AppTheme.errorColor);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCooldown--;
        });
        return _resendCooldown > 0;
      }
      return false;
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _currentPhase == RegistrationPhase.register
                    ? _buildRegistrationForm()
                    : _buildVerificationForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          _buildNesTextField(
            controller: _usernameController,
            label: 'Tên người dùng',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên người dùng';
              }
              if (value.length < 3) {
                return 'Tên người dùng phải có ít nhất 3 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          _buildNesTextField(
            controller: _emailController,
            label: 'Email',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!_isValidEmail(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildNesTextField(
                  controller: _firstNameController,
                  label: 'Tên',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNesTextField(
                  controller: _lastNameController,
                  label: 'Họ',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildNesTextField(
            controller: _passwordController,
            label: 'Mật khẩu',
            obscureText: _obscurePassword,
            suffix: _isLoading
                ? null
                : IconButton(
                    icon: Icon(
                      _obscurePassword ? Pixel.eyeclosed : Pixel.eye,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
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
          const SizedBox(height: 12),

          _buildNesTextField(
            controller: _confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            obscureText: _obscureConfirmPassword,
            suffix: _isLoading
                ? null
                : IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Pixel.eyeclosed : Pixel.eye,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
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
                  onPressed: _handleRegister,
                  child: const Text('Đăng ký', textAlign: TextAlign.center),
                ),

          const SizedBox(height: 16),

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
                    color: AppTheme.primaryColor.withValues(alpha: 0.7),
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
                    Navigator.pushNamed(context, '/login');
                  },
            child: const Text(
              'Quay lại đăng nhập',
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
    );
  }

  Widget _buildVerificationForm() {
    return Form(
      key: _verifyFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),

          Text(
            'Xác minh email',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Vui lòng nhập mã 6 chữ số được gửi đến email của bạn',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          _buildNesTextField(
            controller: _verificationCodeController,
            label: 'Mã xác minh',
            textAlign: TextAlign.center,
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mã xác minh';
              }
              if (value.length != 6) {
                return 'Mã xác minh phải có 6 chữ số';
              }
              return null;
            },
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
                  type: CustomButtonType.success,
                  onPressed: _handleVerification,
                  child: const Text('Xác minh', textAlign: TextAlign.center),
                ),
          const SizedBox(height: 12),

          CustomButton(
            type: CustomButtonType.normal,
            onPressed: _resendCooldown > 0 || _isLoading
                ? null
                : _handleResendVerification,
            child: Text(
              _resendCooldown > 0 ? 'Gửi lại ($_resendCooldown)' : 'Gửi lại mã',
              textAlign: TextAlign.center,
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
                    color: AppTheme.primaryColor.withValues(alpha: 0.7),
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
            type: CustomButtonType.warning,
            onPressed: _isLoading ? null : _switchToRegistrationPhase,
            child: const Text('Quay lại đăng ký', textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),

          CustomButton(
            type: CustomButtonType.normal,
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => route.settings.name == '/welcome',
                    );
                  },
            child: const Text('Đến đăng nhập', textAlign: TextAlign.center),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNesTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffix,
    TextAlign textAlign = TextAlign.start,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        textAlign: textAlign,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        enabled: !_isLoading,
        style: const TextStyle(fontSize: 10),
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Nhập $label',
          border: const OutlineInputBorder(),
          suffixIcon: suffix,
          counterText: '',
        ),
      ),
    );
  }
}

/// Enum for registration phases
enum RegistrationPhase { register, verify }
