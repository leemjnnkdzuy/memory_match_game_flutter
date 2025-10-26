import 'package:flutter/material.dart';
import '../custom/custom_button.dart';

class BattleRoyaleHostActions extends StatelessWidget {
  final bool canStart;
  final bool isStarting;
  final VoidCallback onStartMatch;
  final VoidCallback? onSettings;
  final VoidCallback onCloseRoom;

  const BattleRoyaleHostActions({
    super.key,
    required this.canStart,
    this.isStarting = false,
    required this.onStartMatch,
    this.onSettings,
    required this.onCloseRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          type: CustomButtonType.primary,
          isLoading: isStarting,
          onPressed: canStart ? onStartMatch : null,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: isStarting
                ? Row(
                    key: const ValueKey('starting_match'),
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Bắt đầu Trận đấu',
                    key: ValueKey('start_match_label'),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.error,
          onPressed: onCloseRoom,
          child: const Text('Đóng phòng', textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
