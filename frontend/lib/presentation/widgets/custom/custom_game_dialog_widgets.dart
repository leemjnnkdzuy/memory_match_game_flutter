import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'custom_button.dart';
import 'custom_password_input.dart';

class GameEndDialogWidget extends StatelessWidget {
  final bool isWin;
  final int score;
  final int moves;
  final Duration gameTime;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;

  const GameEndDialogWidget({
    super.key,
    required this.isWin,
    required this.score,
    required this.moves,
    required this.gameTime,
    required this.onPlayAgain,
    required this.onBackToMenu,
  });

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isWin ? 'Chúc Mừng!' : 'Trò Chơi Kết Thúc',
        style: AppTheme.headlineMedium.copyWith(
          color: isWin ? Colors.green : Colors.red,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isWin
                ? 'Bạn đã hoàn thành trò chơi!'
                : 'Hết giờ! Chúc may mắn lần sau.',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Điểm: $score', style: AppTheme.bodyMedium),
          Text('Nước đi: $moves', style: AppTheme.bodyMedium),
          Text(
            'Thời gian: ${_formatTime(gameTime)}',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: onPlayAgain,
          child: Text('Chơi Lại'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.normal,
          onPressed: onBackToMenu,
          child: Text('Quay Về Menu'),
        ),
      ],
    );
  }
}

class GamePauseDialogWidget extends StatelessWidget {
  final int score;
  final int moves;
  final Duration timeRemaining;
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const GamePauseDialogWidget({
    super.key,
    required this.score,
    required this.moves,
    required this.timeRemaining,
    required this.onResume,
    required this.onQuit,
  });

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Trò Chơi Tạm Dừng',
        style: AppTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Điểm: $score', style: AppTheme.bodyMedium),
          Text('Nước đi: $moves', style: AppTheme.bodyMedium),
          Text(
            'Thời gian còn lại: ${_formatTime(timeRemaining)}',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: onResume,
          child: Text('Tiếp Tục'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.error,
          onPressed: onQuit,
          child: Text('Thoát Trò Chơi'),
        ),
      ],
    );
  }
}

class CloseRoomConfirmDialogWidget extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final int playerCount;

  const CloseRoomConfirmDialogWidget({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.playerCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Xác Nhận Đóng Phòng',
        style: AppTheme.headlineMedium.copyWith(color: Colors.red),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playerCount > 1)
            Text(
              'Tất cả $playerCount người chơi trong phòng sẽ bị kick ra.',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          if (playerCount <= 1)
            Text(
              'Phòng sẽ bị xóa hoàn toàn.',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.orange,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.normal,
          onPressed: onCancel,
          child: const Text('Hủy'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.error,
          onPressed: onConfirm,
          child: const Text('Đóng Phòng'),
        ),
      ],
    );
  }
}

class KickPlayerConfirmDialogWidget extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String playerName;

  const KickPlayerConfirmDialogWidget({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Xác Nhận Kick Người Chơi',
        style: AppTheme.headlineMedium.copyWith(color: Colors.orange),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bạn có chắc chắn muốn kick người chơi này?',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    playerName,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Người chơi sẽ bị đá ra khỏi phòng ngay lập tức.',
            style: AppTheme.bodyMedium.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.normal,
          onPressed: onCancel,
          child: const Text('Hủy'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.warning,
          onPressed: onConfirm,
          child: const Text('Kick Người Chơi'),
        ),
      ],
    );
  }
}

class LeaveRoomConfirmDialogWidget extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool showDisconnectHint;

  const LeaveRoomConfirmDialogWidget({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.showDisconnectHint = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Rời phòng?',
        style: AppTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDisconnectHint) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nếu bị mất kết nối ngoài ý muốn, hãy chờ ứng dụng tự kết nối lại để giữ vị trí.',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.normal,
          onPressed: onCancel,
          child: const Text('Ở lại'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.error,
          onPressed: onConfirm,
          child: const Text('Rời phòng'),
        ),
      ],
    );
  }
}

class EnterPasswordDialogWidget extends StatefulWidget {
  final String roomName;
  final Function(String) onConfirm;
  final VoidCallback onCancel;

  const EnterPasswordDialogWidget({
    super.key,
    required this.roomName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<EnterPasswordDialogWidget> createState() =>
      _EnterPasswordDialogWidgetState();
}

class _EnterPasswordDialogWidgetState extends State<EnterPasswordDialogWidget> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
      title: Text(
        'Nhập Mật Khẩu',
        style: AppTheme.headlineMedium.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Phòng "${widget.roomName}" yêu cầu mật khẩu',
            style: AppTheme.bodyMedium.copyWith(color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CustomPasswordInput(
            controller: _passwordController,
            hintText: 'Nhập mật khẩu...',
            fontSize: 14,
            borderColor: Colors.grey.withValues(alpha: 0.3),
            borderWidth: 1,
            onChanged: (value) {
              // Optional: handle changes if needed
            },
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.normal,
          onPressed: widget.onCancel,
          child: const Text('Hủy'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: () {
            final password = _passwordController.text.trim();
            if (password.isNotEmpty) {
              widget.onConfirm(password);
            }
          },
          child: const Text('Tham Gia'),
        ),
      ],
    );
  }
}

class ChangeUsernameConfirmDialogWidget extends StatelessWidget {
  final String newUsername;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ChangeUsernameConfirmDialogWidget({
    super.key,
    required this.newUsername,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
      title: Text(
        'Xác nhận đổi tên người dùng',
        style: AppTheme.headlineMedium.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bạn có chắc chắn muốn đổi tên người dùng thành "$newUsername"?',
            style: AppTheme.bodyMedium.copyWith(color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.normal,
          onPressed: onCancel,
          child: const Text('Hủy'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: onConfirm,
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
