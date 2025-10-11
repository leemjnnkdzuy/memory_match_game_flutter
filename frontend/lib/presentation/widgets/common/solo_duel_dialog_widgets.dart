import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../core/theme/app_theme.dart';
import '../custom/custom_button.dart';

class SoloDuelGameOverDialog extends StatelessWidget {
  final bool isWinner;
  final String winnerUsername;
  final int winnerScore;
  final int winnerMatchedCards;
  final String loserUsername;
  final int loserScore;
  final int loserMatchedCards;
  final VoidCallback onBackToHome;

  const SoloDuelGameOverDialog({
    super.key,
    required this.isWinner,
    required this.winnerUsername,
    required this.winnerScore,
    required this.winnerMatchedCards,
    required this.loserUsername,
    required this.loserScore,
    required this.loserMatchedCards,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
      title: Column(
        children: [
          Icon(
            isWinner ? Pixel.trophy : Pixel.close,
            size: 64,
            color: isWinner ? Colors.amber : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            isWinner ? 'Chiến Thắng!' : 'Thất Bại!',
            style: AppTheme.headlineMedium.copyWith(
              color: isWinner ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '🏆 Người Chiến Thắng',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  winnerUsername,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$winnerScore điểm • $winnerMatchedCards cặp',
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(loserUsername, style: AppTheme.bodyLarge),
                const SizedBox(height: 4),
                Text(
                  '$loserScore điểm • $loserMatchedCards cặp',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: onBackToHome,
          child: const Text('Về Trang Chủ'),
        ),
      ],
    );
  }
}

class SoloDuelPauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onSurrender;

  const SoloDuelPauseDialog({
    super.key,
    required this.onResume,
    required this.onSurrender,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
      title: Column(
        children: [
          const Icon(Pixel.pause, size: 48, color: Colors.orange),
          const SizedBox(height: 12),
          Text(
            'Trận Đấu Tạm Dừng',
            style: AppTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bạn có muốn đầu hàng?',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: onResume,
          child: const Text('Tiếp Tục'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.error,
          onPressed: onSurrender,
          child: const Text('Đầu Hàng'),
        ),
      ],
    );
  }
}

class SoloDuelSurrenderConfirmationDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const SoloDuelSurrenderConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
      title: Column(
        children: [
          const Icon(Pixel.alert, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            'Xác Nhận Đầu Hàng',
            style: AppTheme.headlineMedium.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bạn có chắc chắn muốn đầu hàng?\nBạn sẽ bị thua trận đấu này.',
            style: AppTheme.bodyMedium,
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
          child: const Text('Đầu Hàng'),
        ),
      ],
    );
  }
}

class SoloDuelOpponentDisconnectedDialog extends StatelessWidget {
  final String opponentUsername;
  final int waitTimeSeconds;
  final VoidCallback onClose;

  const SoloDuelOpponentDisconnectedDialog({
    super.key,
    required this.opponentUsername,
    required this.waitTimeSeconds,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
      title: Column(
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.orange.shade700),
          const SizedBox(height: 12),
          Text(
            'Đối Thủ Mất Kết Nối',
            style: AppTheme.headlineMedium.copyWith(color: Colors.orange),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$opponentUsername đã mất kết nối',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Đang chờ đối thủ kết nối lại trong $waitTimeSeconds giây...',
            style: AppTheme.bodyMedium.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.normal,
          onPressed: onClose,
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}

class SoloDuelRejoinDialog extends StatelessWidget {
  final VoidCallback onSurrender;
  final VoidCallback onRejoin;

  const SoloDuelRejoinDialog({
    super.key,
    required this.onSurrender,
    required this.onRejoin,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
      title: Column(
        children: [
          Icon(Icons.replay, size: 48, color: Colors.blue.shade700),
          const SizedBox(height: 12),
          Text(
            'Trận Đấu Đang Diễn Ra',
            style: AppTheme.headlineMedium.copyWith(color: Colors.blue),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bạn có một trận đấu đang diễn ra.\nBạn có muốn tham gia lại không?',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.error,
          onPressed: onSurrender,
          child: const Text('Đầu Hàng'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: onRejoin,
          child: const Text('Tham Gia Lại'),
        ),
      ],
    );
  }
}

class SoloDuelLoadingDialog extends StatelessWidget {
  final String message;

  const SoloDuelLoadingDialog({super.key, this.message = 'Đang kết nối...'});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
