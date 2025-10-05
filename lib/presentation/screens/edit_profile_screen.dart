import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../services/auth_service.dart';
import '../widgets/common/avatar_widget.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_container.dart';

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
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
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
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 10),
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter $label',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon, color: Colors.black, size: 20),
        ),
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
      return 'Please enter a valid URL (starting with http:// or https://)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: const TextStyle(fontSize: 16, color: Colors.blue),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Pixel.arrowleft, color: Colors.blue),
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
                        'Avatar',
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
                        'Basic Information',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _firstNameController,
                        label: 'First name',
                        icon: Pixel.user,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'First name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Last name',
                        icon: Pixel.user,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Last name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: _bioController,
                        label: 'Bio',
                        icon: Pixel.edit,
                        maxLines: 3,
                        validator: (value) {
                          if (value != null && value.length > 500) {
                            return 'Bio must be less than 500 characters';
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
                        'Social Links',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _githubController,
                        label: 'Github URL',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _linkedinController,
                        label: 'LinkedIn URL',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _websiteController,
                        label: 'Website URL',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _youtubeController,
                        label: 'Youtube URL',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _facebookController,
                        label: 'Facebook URL',
                        icon: Pixel.link,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),

                      _buildTextField(
                        controller: _instagramController,
                        label: 'Instagram URL',
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
                        child: Text('Cancel', textAlign: TextAlign.center),
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
                          : CustomButton(
                              type: CustomButtonType.primary,
                              onPressed: _hasChanges ? _handleSave : null,
                              child: Text(
                                'Save Changes',
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
