import 'package:flutter/material.dart';
import 'dart:math';
import 'package:nes_ui/nes_ui.dart';

class GameModeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isEnabled;
  final VoidCallback? onTap;

  const GameModeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isEnabled,
    this.onTap,
  });

  @override
  State<GameModeCard> createState() => _GameModeCardState();
}

class _GameModeCardState extends State<GameModeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isEnabled) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = sin(_shakeAnimation.value * 3.14159 * 8) * 3;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.isEnabled ? widget.color : Colors.grey.shade400,
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
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Center(
                      child: Icon(widget.icon, size: 32, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.isEnabled
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.isEnabled
                                ? Colors.white70
                                : Colors.grey.shade500,
                          ),
                        ),
                        if (!widget.isEnabled)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade800,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: const Text(
                              'LOCKED',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.isEnabled)
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: NesButton(
                        type: NesButtonType.primary,
                        onPressed: widget.onTap,
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
