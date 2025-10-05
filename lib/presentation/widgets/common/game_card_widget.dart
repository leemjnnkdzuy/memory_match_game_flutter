import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../domain/entities/offline_game_entity.dart';
import '../../../domain/entities/pokemon_entity.dart';
import '../../../core/theme/app_theme.dart';
import 'cached_image_widget.dart';

class GameCardWidget extends StatefulWidget {
  final CardEntity card;
  final PokemonEntity? pokemon;
  final VoidCallback? onTap;
  final AnimationController flipController;
  final AnimationController matchController;

  const GameCardWidget({
    super.key,
    required this.card,
    required this.pokemon,
    this.onTap,
    required this.flipController,
    required this.matchController,
  });

  @override
  State<GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget>
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
  void didUpdateWidget(GameCardWidget oldWidget) {
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
    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final flipValue = _flipAnimation.value;

            return ClipRect(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(flipValue * math.pi),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.card.isMatched
                          ? Colors.green
                          : Colors.white,
                      width: widget.card.isMatched ? 3 : 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: flipValue < 0.5
                        ? const _CardBack()
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: Container(
                              color: Colors.white,
                              child: _isShowingFront && widget.pokemon != null
                                  ? _CardFront(
                                      pokemon: widget.pokemon!,
                                      isMatched: widget.card.isMatched,
                                    )
                                  : const _CardBack(),
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final PokemonEntity pokemon;
  final bool isMatched;

  const _CardFront({required this.pokemon, required this.isMatched});

  @override
  Widget build(BuildContext context) {
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
          if (isMatched)
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

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
        ),
        child: const Center(
          child: Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
