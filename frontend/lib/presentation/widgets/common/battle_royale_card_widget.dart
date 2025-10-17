import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../domain/entities/offline_game_entity.dart';
import '../../../domain/entities/pokemon_entity.dart';
import '../../../core/theme/app_theme.dart';
import 'cached_image_widget.dart';

class BattleRoyaleCardWidget extends StatefulWidget {
  final CardEntity card;
  final PokemonEntity pokemon;
  final VoidCallback onTap;
  final bool canInteract;

  const BattleRoyaleCardWidget({
    super.key,
    required this.card,
    required this.pokemon,
    required this.onTap,
    this.canInteract = true,
  });

  @override
  State<BattleRoyaleCardWidget> createState() => _BattleRoyaleCardWidgetState();
}

class _BattleRoyaleCardWidgetState extends State<BattleRoyaleCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _isFlipped = widget.card.isFlipped || widget.card.isMatched;
    if (_isFlipped) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BattleRoyaleCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldFlip = widget.card.isFlipped || widget.card.isMatched;
    if (shouldFlip != _isFlipped) {
      _isFlipped = shouldFlip;
      if (_isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.canInteract) {
      return;
    }
    if (widget.card.isFlipped) {
      return;
    }
    if (widget.card.isMatched) {
      return;
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final isFrontVisible = angle > math.pi / 2;
          final heroTag = 'battleRoyaleCard_${widget.card.id}';

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.card.isMatched
                      ? Colors.green
                      : widget.card.isFlipped
                      ? Colors.amber
                      : Colors.white.withValues(alpha: 0.5),
                  width: widget.card.isMatched ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isFrontVisible
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _CardFront(
                          pokemon: widget.pokemon,
                          isMatched: widget.card.isMatched,
                          heroTag: heroTag,
                        ),
                      )
                    : const _CardBack(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final PokemonEntity pokemon;
  final bool isMatched;
  final String heroTag;

  const _CardFront({
    required this.pokemon,
    required this.isMatched,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Hero(
                    tag: heroTag,
                    child: CachedImageWidget(
                      imagePath: pokemon.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pokemon.name.toUpperCase(),
                  style: AppTheme.labelLarge.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isMatched)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Pixel.check, color: Colors.green, size: 32),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE91E63).withValues(alpha: 0.8),
            const Color(0xFF880E4F),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern background
          Positioned.fill(
            child: CustomPaint(painter: _PokeballPatternPainter()),
          ),
          // Center icon
          const Center(
            child: Icon(Icons.catching_pokemon, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }
}

class _PokeballPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw decorative circles
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.8), 20, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
