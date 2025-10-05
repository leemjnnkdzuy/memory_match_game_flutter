import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pixelarticons/pixel.dart';
import '../../core/theme/app_theme.dart';
import '../../services/request_service.dart';
import '../../services/auth_service.dart';

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
      return 'Please enter PIN code';
    }
    if (value.length != 6) {
      return 'PIN must be 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only numbers';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email address';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    if (value.toLowerCase() == _currentEmail?.toLowerCase()) {
      return 'New email must be different from current email';
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
              content: Text('PIN sent to $_currentEmail'),
              backgroundColor: AppTheme.secondaryColor,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Failed to send PIN';
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
              content: Text('Current email verified successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Invalid or expired PIN';
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

  Future<void> _submitNewEmail() async {
    if (!_newEmailFormKey.currentState!.validate()) {
      return;
    }

    if (_changeMailAuthHashCode == null) {
      setState(() {
        _errorMessage = 'Authentication error. Please start over';
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
              content: Text('PIN sent to $_newEmail'),
              backgroundColor: AppTheme.secondaryColor,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Failed to send PIN to new email';
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
          'Confirm Email Change',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to change your email to "$_newEmail"?',
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email changed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Invalid or expired PIN';
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

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        enabled: !_isLoading,
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(fontSize: 10, color: AppTheme.primaryColor),
          hintStyle: TextStyle(
            fontSize: 10,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(Pixel.lock, color: AppTheme.primaryColor, size: 20),
          counterText: '',
        ),
        style: const TextStyle(fontSize: 12, letterSpacing: 4),
        textAlign: TextAlign.center,
        validator: _validatePin,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildEmailField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        enabled: !_isLoading,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(fontSize: 10, color: AppTheme.primaryColor),
          hintStyle: TextStyle(
            fontSize: 10,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(Pixel.mail, color: AppTheme.primaryColor, size: 20),
        ),
        style: const TextStyle(fontSize: 12),
        validator: _validateEmail,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildInfoContainer({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return NesContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Pixel.check,
                      size: 12,
                      color: AppTheme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_currentEmail != null) ...[
          NesContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Pixel.mail, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Current Email',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _currentEmail!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        _buildInfoContainer(
          icon: Pixel.infobox,
          title: 'Email Change Process',
          items: [
            'We will send a PIN to your current email',
            'Verify your current email with the PIN',
            'Enter your new email address',
            'Verify your new email with another PIN',
          ],
        ),
        const SizedBox(height: 30),
        _isLoading
            ? _buildLoadingButton()
            : NesButton(
                type: NesButtonType.primary,
                onPressed: _requestChangeEmail,
                child: const Text(
                  'Start Email Change',
                  textAlign: TextAlign.center,
                ),
              ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 20),
          _buildErrorContainer(_errorMessage!),
        ],
      ],
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _currentEmailPinFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NesContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Pixel.mail, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PIN sent to:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentEmail ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPinField(
            controller: _currentEmailPinController,
            label: 'PIN Code',
            hint: 'Enter 6-digit PIN',
          ),
          const SizedBox(height: 20),
          _buildInfoContainer(
            icon: Pixel.infobox,
            title: 'Instructions',
            items: [
              'Check your current email inbox',
              'Enter the 6-digit PIN code',
              'PIN expires in 10 minutes',
            ],
          ),
          const SizedBox(height: 30),
          _isLoading
              ? _buildLoadingButton()
              : NesButton(
                  type: NesButtonType.success,
                  onPressed: _confirmCurrentEmail,
                  child: const Text(
                    'Verify Current Email',
                    textAlign: TextAlign.center,
                  ),
                ),
          const SizedBox(height: 12),
          NesButton(
            type: NesButtonType.normal,
            onPressed: _isLoading ? null : _requestChangeEmail,
            child: const Text('Resend PIN', textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          NesButton(
            type: NesButtonType.error,
            onPressed: _isLoading ? null : _resetFlow,
            child: const Text('Cancel', textAlign: TextAlign.center),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            _buildErrorContainer(_errorMessage!),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _newEmailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NesContainer(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.green[50],
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Current email verified!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildEmailField(
            controller: _newEmailController,
            label: 'New Email Address',
            hint: 'Enter your new email',
          ),
          const SizedBox(height: 20),
          _buildInfoContainer(
            icon: Pixel.infobox,
            title: 'Requirements',
            items: [
              'Must be a valid email format',
              'Must be different from current email',
              'Must not be used by another account',
            ],
          ),
          const SizedBox(height: 30),
          _isLoading
              ? _buildLoadingButton()
              : NesButton(
                  type: NesButtonType.primary,
                  onPressed: _submitNewEmail,
                  child: const Text(
                    'Send PIN to New Email',
                    textAlign: TextAlign.center,
                  ),
                ),
          const SizedBox(height: 12),
          NesButton(
            type: NesButtonType.error,
            onPressed: _isLoading ? null : _resetFlow,
            child: const Text('Cancel', textAlign: TextAlign.center),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            _buildErrorContainer(_errorMessage!),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: _newEmailPinFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NesContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Pixel.mail, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PIN sent to new email:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _newEmail ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPinField(
            controller: _newEmailPinController,
            label: 'PIN Code',
            hint: 'Enter 6-digit PIN',
          ),
          const SizedBox(height: 20),
          _buildInfoContainer(
            icon: Pixel.infobox,
            title: 'Final Step',
            items: [
              'Check your new email inbox',
              'Enter the 6-digit PIN code',
              'PIN expires in 10 minutes',
              'Your email will be updated after verification',
            ],
          ),
          const SizedBox(height: 30),
          _isLoading
              ? _buildLoadingButton()
              : NesButton(
                  type: NesButtonType.success,
                  onPressed: _completeEmailChange,
                  child: const Text(
                    'Complete Email Change',
                    textAlign: TextAlign.center,
                  ),
                ),
          const SizedBox(height: 12),
          NesButton(
            type: NesButtonType.normal,
            onPressed: _isLoading ? null : _submitNewEmail,
            child: const Text('Resend PIN', textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          NesButton(
            type: NesButtonType.error,
            onPressed: _isLoading ? null : _resetFlow,
            child: const Text('Cancel', textAlign: TextAlign.center),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            _buildErrorContainer(_errorMessage!),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingButton() {
    return NesContainer(
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
    );
  }

  Widget _buildErrorContainer(String message) {
    return NesContainer(
      padding: const EdgeInsets.all(12),
      backgroundColor: AppTheme.errorColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Pixel.close, color: AppTheme.errorColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Change Email'),
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
                _buildStepIndicator(),
                const SizedBox(height: 20),
                if (_currentStep == 0) _buildStep0(),
                if (_currentStep == 1) _buildStep1(),
                if (_currentStep == 2) _buildStep2(),
                if (_currentStep == 3) _buildStep3(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
