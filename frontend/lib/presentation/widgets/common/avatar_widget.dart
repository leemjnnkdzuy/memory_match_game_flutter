import 'package:flutter/material.dart';
import 'package:memory_match_game/services/auth_service.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../widgets/custom/custom_button.dart';

class AvatarWidget extends StatefulWidget {
  final double size;
  final double borderWidth;
  final VoidCallback? onRefresh;
  final String? userId;
  final String? avatarData;
  final bool showEditButton;
  final Function(String?)? onAvatarPreview;
  final bool isPreviewMode;

  const AvatarWidget({
    super.key,
    this.size = 100,
    this.borderWidth = 3,
    this.onRefresh,
    this.userId,
    this.avatarData,
    this.showEditButton = false,
    this.onAvatarPreview,
    this.isPreviewMode = false,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  Uint8List? _avatarBytes;
  bool _isLoadingAvatar = false;
  bool _isUploadingAvatar = false;
  String? _lastProcessedAvatarData;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _processAvatar();
  }

  @override
  void didUpdateWidget(AvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentAvatarData = _currentAvatarData;

    if (oldWidget.userId != widget.userId ||
        oldWidget.avatarData != widget.avatarData ||
        (currentAvatarData != null &&
            _avatarBytes == null &&
            _lastProcessedAvatarData != currentAvatarData)) {
      _processAvatar();
    }
  }

  String? get _currentUserId {
    return widget.userId ?? AuthService.instance.currentUser?.id;
  }

  String? get _currentAvatarData {
    return widget.avatarData ?? AuthService.instance.currentUser?.avatar;
  }

  Future<void> refreshAvatar() async {
    setState(() {
      _avatarBytes = null;
      _lastProcessedAvatarData = null;
    });
    await _processAvatar();
    widget.onRefresh?.call();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Chọn Nguồn Hình Ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Máy Ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Thư Viện'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _isUploadingAvatar = false;
        });
        return;
      }

      final bytes = await image.readAsBytes();

      final base64String = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64String';

      if (widget.isPreviewMode && widget.onAvatarPreview != null) {
        widget.onAvatarPreview!(dataUrl);
      } else {
        final success = await AuthService.instance.updateAvatar(dataUrl);

        if (success) {
          await refreshAvatar();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cập nhật avatar thành công!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Cập nhật avatar thất bại')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải lên avatar')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  Future<void> _processAvatar() async {
    final avatarData = _currentAvatarData;
    final userId = _currentUserId;

    if (avatarData == null ||
        avatarData.isEmpty ||
        userId == null ||
        _lastProcessedAvatarData == avatarData) {
      return;
    }

    setState(() {
      _isLoadingAvatar = true;
    });

    try {
      String base64String = avatarData.trim();

      if (base64String.startsWith('data:')) {
        final commaIndex = base64String.indexOf(',');
        if (commaIndex != -1) {
          base64String = base64String.substring(commaIndex + 1);
        }
      }

      base64String = base64String.trim().replaceAll(RegExp(r'\s+'), '');

      if (base64String.length % 4 != 0) {
        final padding = (4 - (base64String.length % 4)) % 4;
        base64String += '=' * padding;
      }

      final bytes = base64Decode(base64String);

      if (mounted) {
        setState(() {
          _avatarBytes = bytes;
          _lastProcessedAvatarData = avatarData;
          _isLoadingAvatar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _avatarBytes = null;
          _lastProcessedAvatarData = avatarData;
          _isLoadingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAvatarData = _currentAvatarData;

    if (!_isLoadingAvatar &&
        _avatarBytes == null &&
        currentAvatarData != null &&
        _lastProcessedAvatarData != currentAvatarData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processAvatar();
      });
    }

    if (_isLoadingAvatar || _isUploadingAvatar) {
      Widget loadingWidget = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: widget.borderWidth),
        ),
        child: Center(
          child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2),
        ),
      );

      if (widget.showEditButton) {
        return Column(
          children: [
            loadingWidget,
            SizedBox(height: 8),
            SizedBox(width: widget.size, height: 32, child: Container()),
          ],
        );
      }
      return loadingWidget;
    }

    Widget avatarWidget;
    if (_avatarBytes != null) {
      avatarWidget = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: widget.borderWidth),
        ),
        child: ClipOval(
          child: Image.memory(
            _avatarBytes!,
            fit: BoxFit.cover,
            width: widget.size,
            height: widget.size,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatarContent();
            },
          ),
        ),
      );
    } else {
      avatarWidget = _buildDefaultAvatar();
    }

    if (widget.showEditButton) {
      return Column(
        children: [
          avatarWidget,
          SizedBox(height: 8),
          SizedBox(
            width: widget.size,
            height: 48,
            child: CustomButton(
              type: CustomButtonType.primary,
              onPressed: _isUploadingAvatar ? null : _pickAndUploadAvatar,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 16, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    'Chỉnh Sửa',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return avatarWidget;
  }

  Widget _buildDefaultAvatarContent() {
    return Icon(Pixel.user, size: widget.size * 0.64, color: Colors.blue);
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: widget.borderWidth),
      ),
      child: _buildDefaultAvatarContent(),
    );
  }
}
