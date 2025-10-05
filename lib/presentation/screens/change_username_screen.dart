import 'package:flutter/material.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_container.dart';
import '../../services/request_service.dart';
import '../../services/auth_service.dart';

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
  String _buttonText = 'Check username availability';
  bool _canChange = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (value.length > 50) {
      return 'Username must not exceed 50 characters';
    }
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(value)) {
      return 'Only letters, numbers, and underscores are allowed';
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
        _errorMessage = 'New username is the same as current username';
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
            _buttonText = 'Change now';
            _errorMessage = null;
            _canChange = true;
          } else {
            _buttonText = 'Check username availability';
            _errorMessage = 'Username already exists';
            _canChange = false;
          }
        });
      } else {
        setState(() {
          _errorMessage = result.error ?? 'An error occurred';
          _hasChecked = false;
          _isAvailable = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error. Please try again';
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
          'Confirm Username Change',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to change your username to "${_usernameController.text}"?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
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
                  content: Text('Username changed successfully!'),
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
                  content: Text('Username changed successfully!'),
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
            _errorMessage = result.error ?? 'An error occurred';
            _hasChecked = false;
            _isAvailable = false;
            _buttonText = 'Check username availability';
            _canChange = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again';
          _hasChecked = false;
          _isAvailable = false;
          _buttonText = 'Check username availability';
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
        _buttonText = 'Check username availability';
        _errorMessage = null;
        _canChange = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Change Username')),
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
                          'Current username:',
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
                  'Enter new username',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '• Username must be 3-50 characters long\n'
                  '• Only letters (a-z, A-Z), numbers (0-9), and underscores (_) are allowed',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _usernameController,
                  enabled: !_isChecking,
                  decoration: InputDecoration(
                    labelText: 'New username',
                    hintText: 'Enter new username',
                    border: const OutlineInputBorder(),
                    errorText: _hasChecked && !_isAvailable
                        ? _errorMessage
                        : null,
                    suffixIcon: _hasChecked && _isAvailable
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  validator: _validateUsername,
                  onChanged: _onUsernameChanged,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        'Username available',
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
                                'Processing...',
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
