import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../core/theme/app_theme.dart';
import '../../services/request_service.dart';
import '../../services/auth_service.dart';
import '../widgets/custom/custom_app_bar.dart';
import '../widgets/common/change_email_step_indicator_widget.dart';
import '../widgets/common/change_email_step0_widget.dart';
import '../widgets/common/change_email_step1_widget.dart';
import '../widgets/common/change_email_step2_widget.dart';
import '../widgets/common/change_email_step3_widget.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController _currentEmailPinController =
      TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newEmailPinController = TextEditingController();
  final _currentEmailPinFormKey = GlobalKey<FormState>();
  final _newEmailFormKey = GlobalKey<FormState>();
  final _newEmailPinFormKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _changeMailAuthHashCode;
  String? _currentEmail;
  String? _newEmail;

  @override
  void initState() {
    super.initState();
    _currentEmail = AuthService.instance.currentUser?.email;
  }

  @override
  void dispose() {
    _currentEmailPinController.dispose();
    _newEmailController.dispose();
    _newEmailPinController.dispose();
    super.dispose();
  }

  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mã PIN';
    }
    if (value.length != 6) {
      return 'Mã PIN phải có 6 chữ số';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Mã PIN chỉ được chứa số';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa chỉ email';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Định dạng email không hợp lệ';
    }
    if (value.toLowerCase() == _currentEmail?.toLowerCase()) {
      return 'Email mới phải khác với email hiện tại';
    }
    return null;
  }

  Future<void> _requestChangeEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.requestChangeEmail();

      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            _currentEmail = result.data?['email'];
            _currentStep = 1;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã gửi mã PIN đến $_currentEmail'),
              backgroundColor: AppTheme.secondaryColor,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Không thể gửi mã PIN';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi kết nối. Vui lòng thử lại';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmCurrentEmail() async {
    if (!_currentEmailPinFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.confirmChangeEmail(
        pin: _currentEmailPinController.text,
      );

      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            _changeMailAuthHashCode = result.data?['changeMailAuthHashCode'];
            _currentStep = 2;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email hiện tại đã được xác minh thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _errorMessage =
                result.error ?? 'Mã PIN không hợp lệ hoặc đã hết hạn';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi kết nối. Vui lòng thử lại';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitNewEmail() async {
    if (!_newEmailFormKey.currentState!.validate()) {
      return;
    }

    if (_changeMailAuthHashCode == null) {
      setState(() {
        _errorMessage = 'Lỗi xác thực. Vui lòng bắt đầu lại';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.submitNewEmail(
        newEmail: _newEmailController.text,
        changeMailAuthHashCode: _changeMailAuthHashCode!,
      );

      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            _newEmail = result.data?['newEmail'];
            _currentStep = 3;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã gửi mã PIN đến $_newEmail'),
              backgroundColor: AppTheme.secondaryColor,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          setState(() {
            _errorMessage =
                result.error ?? 'Không thể gửi mã PIN đến email mới';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection error. Please try again';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeEmailChange() async {
    if (!_newEmailPinFormKey.currentState!.validate()) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận đổi email',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Bạn có chắc chắn muốn đổi email thành "$_newEmail"?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.completeChangeEmail(
        pin: _newEmailPinController.text,
      );

      if (mounted) {
        if (result.isSuccess) {
          if (result.data?['user'] != null) {
            await AuthService.instance.updateUser(result.data!['user']);
          }

          _changeMailAuthHashCode = null;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email đã được đổi thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _errorMessage =
                result.error ?? 'Mã PIN không hợp lệ hoặc đã hết hạn';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi kết nối. Vui lòng thử lại';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetFlow() {
    setState(() {
      _currentStep = 0;
      _errorMessage = null;
      _changeMailAuthHashCode = null;
      _newEmail = null;
      _currentEmailPinController.clear();
      _newEmailController.clear();
      _newEmailPinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Đổi mật khẩu',
        leading: IconButton(
          icon: const Icon(Pixel.arrowleft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChangeEmailStepIndicator(currentStep: _currentStep),
                const SizedBox(height: 20),
                if (_currentStep == 0)
                  ChangeEmailStep0(
                    currentEmail: _currentEmail,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onRequestChangeEmail: _requestChangeEmail,
                  ),
                if (_currentStep == 1)
                  ChangeEmailStep1(
                    formKey: _currentEmailPinFormKey,
                    pinController: _currentEmailPinController,
                    currentEmail: _currentEmail,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    pinValidator: _validatePin,
                    onConfirmCurrentEmail: _confirmCurrentEmail,
                    onRequestChangeEmail: _requestChangeEmail,
                    onResetFlow: _resetFlow,
                  ),
                if (_currentStep == 2)
                  ChangeEmailStep2(
                    formKey: _newEmailFormKey,
                    emailController: _newEmailController,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    emailValidator: _validateEmail,
                    onSubmitNewEmail: _submitNewEmail,
                    onResetFlow: _resetFlow,
                  ),
                if (_currentStep == 3)
                  ChangeEmailStep3(
                    formKey: _newEmailPinFormKey,
                    pinController: _newEmailPinController,
                    newEmail: _newEmail,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    pinValidator: _validatePin,
                    onCompleteEmailChange: _completeEmailChange,
                    onSubmitNewEmail: _submitNewEmail,
                    onResetFlow: _resetFlow,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
