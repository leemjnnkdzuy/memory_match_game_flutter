import 'package:flutter/material.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_container.dart';
import '../widgets/custom/custom_text_input.dart';
import '../../services/request_service.dart';
import '../../services/auth_service.dart';
import '../widgets/custom/custom_app_bar.dart';
import 'package:pixelarticons/pixel.dart';

class ChangeUsernameScreen extends StatefulWidget {
  const ChangeUsernameScreen({super.key});

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isChecking = false;
  bool _isAvailable = false;
  bool _hasChecked = false;
  String? _errorMessage;
  String _buttonText = 'Kiểm tra tên người dùng có sẵn';
  bool _canChange = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên người dùng';
    }
    if (value.length < 3) {
      return 'Tên người dùng phải có ít nhất 3 ký tự';
    }
    if (value.length > 50) {
      return 'Tên người dùng không được vượt quá 50 ký tự';
    }
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(value)) {
      return 'Chỉ cho phép chữ cái, số và dấu gạch dưới';
    }
    return null;
  }

  Future<void> _checkUsername() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null &&
        _usernameController.text.toLowerCase() ==
            currentUser.username.toLowerCase()) {
      setState(() {
        _errorMessage = 'Tên người dùng mới giống với tên hiện tại';
        _hasChecked = false;
        _isAvailable = false;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
      _hasChecked = false;
      _isAvailable = false;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.checkUsernameExists(
        _usernameController.text,
      );

      if (result.isSuccess) {
        final exists = result.data ?? false;
        setState(() {
          _hasChecked = true;
          _isAvailable = !exists;

          if (_isAvailable) {
            _buttonText = 'Đổi ngay';
            _errorMessage = null;
            _canChange = true;
          } else {
            _buttonText = 'Kiểm tra tên người dùng có sẵn';
            _errorMessage = 'Tên người dùng đã tồn tại';
            _canChange = false;
          }
        });
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Đã xảy ra lỗi';
          _hasChecked = false;
          _isAvailable = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối. Vui lòng thử lại';
        _hasChecked = false;
        _isAvailable = false;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _changeUsername() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận đổi tên người dùng',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Bạn có chắc chắn muốn đổi tên người dùng thành "${_usernameController.text}"?',
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
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.changeUsername(
        newUsername: _usernameController.text,
      );

      if (mounted) {
        if (result.isSuccess && result.data != null) {
          final profileResult = await requestService.getProfile();

          if (profileResult.isSuccess && profileResult.data != null) {
            await AuthService.instance.updateUser(profileResult.data!);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tên người dùng đã được đổi thành công!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );

              await Future.delayed(const Duration(seconds: 1));
              if (mounted) {
                Navigator.pop(context, true);
              }
            }
          } else {
            await AuthService.instance.updateUser(result.data!);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tên người dùng đã được đổi thành công!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );

              await Future.delayed(const Duration(seconds: 1));
              if (mounted) {
                Navigator.pop(context, true);
              }
            }
          }
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Đã xảy ra lỗi';
            _hasChecked = false;
            _isAvailable = false;
            _buttonText = 'Kiểm tra tên người dùng có sẵn';
            _canChange = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại';
          _hasChecked = false;
          _isAvailable = false;
          _buttonText = 'Kiểm tra tên người dùng có sẵn';
          _canChange = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _onUsernameChanged(String value) {
    if (_hasChecked) {
      setState(() {
        _hasChecked = false;
        _isAvailable = false;
        _buttonText = 'Kiểm tra tên người dùng có sẵn';
        _errorMessage = null;
        _canChange = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Đổi mật khẩu',
        leading: IconButton(
          icon: const Icon(Pixel.arrowleft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (currentUser != null) ...[
                  CustomContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tên người dùng hiện tại:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentUser.username,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  'Nhập tên người dùng mới',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '• Tên người dùng phải có 3-50 ký tự\n'
                  '• Chỉ cho phép chữ cái (a-z, A-Z), số (0-9) và dấu gạch dưới (_)',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                CustomTextInput(
                  controller: _usernameController,
                  enabled: !_isChecking,
                  labelText: 'Tên người dùng mới',
                  hintText: 'Nhập tên người dùng mới',
                  suffixIcon: _hasChecked && _isAvailable
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  validator: _validateUsername,
                  onChanged: _onUsernameChanged,
                ),

                if (_hasChecked && _isAvailable) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tên người dùng có sẵn',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                _isChecking
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
                        type: _canChange
                            ? CustomButtonType.success
                            : CustomButtonType.primary,
                        onPressed: _canChange
                            ? _changeUsername
                            : _checkUsername,
                        child: Text(_buttonText, textAlign: TextAlign.center),
                      ),

                if (_errorMessage != null &&
                    (!_hasChecked || !_isAvailable)) ...[
                  const SizedBox(height: 16),
                  CustomContainer(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Colors.red[50],
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
