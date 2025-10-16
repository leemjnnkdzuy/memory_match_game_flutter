import 'package:flutter/material.dart';
import '../custom/custom_button.dart';

class BattleRoyalePlayerActions extends StatelessWidget {
  final bool isReady;
  final VoidCallback onToggleReady;
  final Future<void> Function() onLeaveRoom;

  const BattleRoyalePlayerActions({
    super.key,
    required this.isReady,
    required this.onToggleReady,
    required this.onLeaveRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          type: isReady ? CustomButtonType.warning : CustomButtonType.success,
          onPressed: onToggleReady,
          child: Text(isReady ? 'Hủy Sẵn Sàng' : 'Sẵn Sàng'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.error,
          onPressed: onLeaveRoom,
          child: const Text('Rời phòng'),
        ),
      ],
    );
  }
}
