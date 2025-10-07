import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../domain/entities/solo_duel_match_entity.dart';
import '../../../domain/entities/pokemon_entity.dart';
import '../../../core/theme/app_theme.dart';

class SoloDuelCardWidget extends StatefulWidget {
  final SoloDuelCardEntity card;
  final PokemonEntity pokemon;
  final VoidCallback onTap;
  final bool isMyTurn;

  const SoloDuelCardWidget({
    super.key,
    required this.card,
    required this.pokemon,
    required this.onTap,
    required this.isMyTurn,
  });

  @override
  State<SoloDuelCardWidget> createState() => _SoloDuelCardWidgetState();
}

class _SoloDuelCardWidgetState extends State<SoloDuelCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _localFlipController;
  late Animation<double> _flipAnimation;
  bool _isShowingFront = false;

  @override
  void initState() {
    super.initState();
    _localFlipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _localFlipController, curve: Curves.easeInOut),
    );

    _isShowingFront = widget.card.isFlipped || widget.card.isMatched;
    if (_isShowingFront) {
      _localFlipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SoloDuelCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldShowFront = widget.card.isFlipped || widget.card.isMatched;
    if (shouldShowFront != _isShowingFront) {
      _isShowingFront = shouldShowFront;
      if (_isShowingFront) {
        _localFlipController.forward();
      } else {
        _localFlipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _localFlipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused border logic variables

    return GestureDetector(
      onTap:
          (widget.card.isMatched || widget.card.isFlipped || !widget.isMyTurn)
          ? null
          : widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final flipValue = _flipAnimation.value;

          return ClipRect(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(flipValue * 3.14159),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.card.isMatched ? Colors.green : Colors.white,
                    width: widget.card.isMatched ? 3 : 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: flipValue < 0.5
                      ? _buildCardBack()
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(3.14159),
                          child: Container(
                            color: Colors.white,
                            child: _isShowingFront
                                ? _buildCardFront()
                                : _buildCardBack(),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
          ),
        ),
        child: const Center(
          child: Icon(Icons.catching_pokemon, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return RepaintBoundary(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/${widget.pokemon.imagePath}',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.pokemon.name.toUpperCase(),
                    style: AppTheme.labelLarge.copyWith(
                      fontSize: 8,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (widget.card.isMatched)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Pixel.check, color: Colors.green, size: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
