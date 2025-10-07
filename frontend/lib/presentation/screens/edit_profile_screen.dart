import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../services/auth_service.dart';
import '../widgets/common/avatar_widget.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_container.dart';
import '../widgets/custom/custom_text_input.dart';
import '../widgets/custom/custom_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _previewAvatar;
  bool _hasChanges = false;

  String _originalFirstName = '';
  String _originalLastName = '';
  String _originalBio = '';
  String _originalGithub = '';
  String _originalLinkedin = '';
  String _originalWebsite = '';
  String _originalYoutube = '';
  String _originalFacebook = '';
  String _originalInstagram = '';
  String? _originalAvatar;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _websiteController;
  late final TextEditingController _youtubeController;
  late final TextEditingController _facebookController;
  late final TextEditingController _instagramController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _bioController = TextEditingController();
    _githubController = TextEditingController();
    _linkedinController = TextEditingController();
    _websiteController = TextEditingController();
    _youtubeController = TextEditingController();
    _facebookController = TextEditingController();
    _instagramController = TextEditingController();
  }

  void _loadInitialData() {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      _originalFirstName = user.firstName;
      _originalLastName = user.lastName;
      _originalBio = user.bio ?? '';
      _originalGithub = user.githubUrl ?? '';
      _originalLinkedin = user.linkedinUrl ?? '';
      _originalWebsite = user.websiteUrl ?? '';
      _originalYoutube = user.youtubeUrl ?? '';
      _originalFacebook = user.facebookUrl ?? '';
      _originalInstagram = user.instagramUrl ?? '';
      _originalAvatar = user.avatar;

      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _bioController.text = user.bio ?? '';
      _githubController.text = user.githubUrl ?? '';
      _linkedinController.text = user.linkedinUrl ?? '';
      _websiteController.text = user.websiteUrl ?? '';
      _youtubeController.text = user.youtubeUrl ?? '';
      _facebookController.text = user.facebookUrl ?? '';
      _instagramController.text = user.instagramUrl ?? '';

      _firstNameController.addListener(_checkForChanges);
      _lastNameController.addListener(_checkForChanges);
      _bioController.addListener(_checkForChanges);
      _githubController.addListener(_checkForChanges);
      _linkedinController.addListener(_checkForChanges);
      _websiteController.addListener(_checkForChanges);
      _youtubeController.addListener(_checkForChanges);
      _facebookController.addListener(_checkForChanges);
      _instagramController.addListener(_checkForChanges);
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_checkForChanges);
    _lastNameController.removeListener(_checkForChanges);
    _bioController.removeListener(_checkForChanges);
    _githubController.removeListener(_checkForChanges);
    _linkedinController.removeListener(_checkForChanges);
    _websiteController.removeListener(_checkForChanges);
    _youtubeController.removeListener(_checkForChanges);
    _facebookController.removeListener(_checkForChanges);
    _instagramController.removeListener(_checkForChanges);

    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _onAvatarPreview(String? avatarData) {
    setState(() {
      _previewAvatar = avatarData;
      _checkForChanges();
    });
  }

  void _checkForChanges() {
    final hasFieldChanges =
        _firstNameController.text.trim() != _originalFirstName ||
        _lastNameController.text.trim() != _originalLastName ||
        _bioController.text.trim() != _originalBio ||
        _githubController.text.trim() != _originalGithub ||
        _linkedinController.text.trim() != _originalLinkedin ||
        _websiteController.text.trim() != _originalWebsite ||
        _youtubeController.text.trim() != _originalYoutube ||
        _facebookController.text.trim() != _originalFacebook ||
        _instagramController.text.trim() != _originalInstagram;

    final hasAvatarChanges =
        _previewAvatar != null && _previewAvatar != _originalAvatar;

    final newHasChanges = hasFieldChanges || hasAvatarChanges;

    if (newHasChanges != _hasChanges) {
      setState(() {
        _hasChanges = newHasChanges;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = <String, dynamic>{};

      if (_previewAvatar != null) {
        final avatarSuccess = await AuthService.instance.updateAvatar(
          _previewAvatar!,
        );
        if (!avatarSuccess) {
          throw Exception('Failed to update avatar');
        }
      }

      if (_firstNameController.text.trim().isNotEmpty) {
        profileData['first_name'] = _firstNameController.text.trim();
      }
      if (_lastNameController.text.trim().isNotEmpty) {
        profileData['last_name'] = _lastNameController.text.trim();
      }
      if (_bioController.text.trim().isNotEmpty) {
        profileData['bio'] = _bioController.text.trim();
      }
      if (_githubController.text.trim().isNotEmpty) {
        profileData['github_url'] = _githubController.text.trim();
      }
      if (_linkedinController.text.trim().isNotEmpty) {
        profileData['linkedin_url'] = _linkedinController.text.trim();
      }
      if (_websiteController.text.trim().isNotEmpty) {
        profileData['website_url'] = _websiteController.text.trim();
      }
      if (_youtubeController.text.trim().isNotEmpty) {
        profileData['youtube_url'] = _youtubeController.text.trim();
      }
      if (_facebookController.text.trim().isNotEmpty) {
        profileData['facebook_url'] = _facebookController.text.trim();
      }
      if (_instagramController.text.trim().isNotEmpty) {
        profileData['instagram_url'] = _instagramController.text.trim();
      }

      await AuthService.instance.updateProfile(profileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hồ sơ đã được cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật hồ sơ: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CustomTextInput(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        fontSize: 10,
        labelText: label,
        hintText: 'Nhập $label',
        prefixIcon: Icon(icon, color: Colors.black, size: 20),
        validator: validator,
      ),
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final urlPattern = RegExp(
      r'^https?://(?:[-\w.])+(?:[:\d]+)?(?:/(?:[\w/_@.~!$&()*+,;=:%-])*(?:\?(?:[\w&=%@.~!$()*+,;:/-])*)?(?:#(?:[\w@.~!$&()*+,;=:%-]*))?)?$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(value)) {
      return 'Vui lòng nhập URL hợp lệ (bắt đầu bằng http:// hoặc https://)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Chỉnh sửa hồ sơ',
        leading: IconButton(
          icon: Icon(Pixel.arrowleft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Ảnh đại diện',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AvatarWidget(
                        size: 120,
                        showEditButton: true,
                        userId: AuthService.instance.currentUser?.id,
                        avatarData:
                            _previewAvatar ??
                            AuthService.instance.currentUser?.avatar,
                        onAvatarPreview: _onAvatarPreview,
                        isPreviewMode: true,
                        onRefresh: () {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin cơ bản',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _firstNameController,
                        label: 'Tên',
                        icon: Pixel.user,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tên là bắt buộc';
                          }
                          if (value.trim().length < 2) {
                            return 'Tên phải có ít nhất 2 ký tự';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Họ',
                        icon: Pixel.user,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Họ là bắt buộc';
                          }
                          if (value.trim().length < 2) {
                            return 'Họ phải có ít nhất 2 ký tự';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: _bioController,
                        label: 'Tiểu sử',
                        icon: Pixel.edit,
                        maxLines: 3,
                        validator: (value) {
                          if (value != null && value.length > 500) {
                            return 'Tiểu sử phải ít hơn 500 ký tự';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liên kết mạng xã hội',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _githubController,
                        label: 'URL GitHub',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _linkedinController,
                        label: 'URL LinkedIn',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _websiteController,
                        label: 'URL Website',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _youtubeController,
                        label: 'URL YouTube',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _facebookController,
                        label: 'URL Facebook',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _instagramController,
                        label: 'URL Instagram',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        type: CustomButtonType.normal,
                        onPressed: () => Navigator.pop(context),
                        child: Text('Hủy', textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _isLoading
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
                              onPressed: _hasChanges ? _handleSave : null,
                              child: Text(
                                'Lưu thay đổi',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _hasChanges ? null : Colors.grey,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
