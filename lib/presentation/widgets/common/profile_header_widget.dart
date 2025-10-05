import 'package:flutter/material.dart';
import 'package:memory_match_game/presentation/widgets/common/avatar_widget.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String? fullName;
  final String? username;
  final bool isVerified;
  final double avatarSize;
  final VoidCallback? onAvatarRefresh;
  final String? userId;
  final String? avatarData;

  const ProfileHeaderWidget({
    super.key,
    this.fullName,
    this.username,
    this.isVerified = false,
    this.avatarSize = 100,
    this.onAvatarRefresh,
    this.userId,
    this.avatarData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
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
          AvatarWidget(
            size: avatarSize,
            onRefresh: onAvatarRefresh,
            userId: userId,
            avatarData: avatarData,
            showEditButton: false,
          ),
          SizedBox(height: 16),

          if (fullName != null && fullName!.isNotEmpty)
            Text(
              fullName!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),

          SizedBox(height: 4),

          if (username != null && username!.isNotEmpty)
            Text(
              '@$username',
              style: const TextStyle(fontSize: 16, color: Color.fromARGB(179, 71, 71, 71)),
            ),

          if (isVerified) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
