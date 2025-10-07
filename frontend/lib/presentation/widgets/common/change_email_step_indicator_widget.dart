import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ChangeEmailStepIndicator extends StatelessWidget {
  final int currentStep;

  const ChangeEmailStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
