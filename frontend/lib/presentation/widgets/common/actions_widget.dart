import 'package:flutter/material.dart';
import '../../widgets/custom/custom_button.dart';

class ActionsWidget extends StatelessWidget {
  final VoidCallback? onRefreshAvatar;
  final VoidCallback? onEditProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;
  final bool showRefreshAvatar;
  final bool showEditProfile;
  final bool showSettings;
  final bool showLogout;

  const ActionsWidget({
    super.key,
    this.onRefreshAvatar,
    this.onEditProfile,
    this.onSettings,
    this.onLogout,
    this.showRefreshAvatar = true,
    this.showEditProfile = true,
    this.showSettings = true,
    this.showLogout = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
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
            'Hành động',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          SizedBox(height: 16),

          ...(_buildActionButtons(context)),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    if (showEditProfile) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            type: CustomButtonType.primary,
            onPressed: onEditProfile ?? () => _navigateToEditProfile(context),
            child: Text('Chỉnh sửa hồ sơ', textAlign: TextAlign.center),
          ),
        ),
      );
      buttons.add(SizedBox(height: 12));
    }

    if (showSettings) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            type: CustomButtonType.normal,
            onPressed: onSettings,
            child: Text('Cài đặt', textAlign: TextAlign.center),
          ),
        ),
      );
      buttons.add(SizedBox(height: 12));
    }

    if (showLogout) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            type: CustomButtonType.error,
            onPressed: onLogout != null
                ? () => _showLogoutConfirmation(context)
                : null,
            child: Text('Đăng xuất', textAlign: TextAlign.center),
          ),
        ),
      );
      buttons.add(SizedBox(height: 12));
    }

    // Remove last spacing
    if (buttons.isNotEmpty && buttons.last is SizedBox) {
      buttons.removeLast();
    }

    return buttons;
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && onLogout != null) {
      onLogout!();
    }
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, '/edit-profile');
  }
}
