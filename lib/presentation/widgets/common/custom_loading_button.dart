import 'package:flutter/material.dart';
import '../custom/custom_container.dart';

class CustomLoadingButton extends StatelessWidget {
  const CustomLoadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Đang xử lý...',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
