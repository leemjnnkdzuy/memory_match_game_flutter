import 'package:flutter/material.dart';
import '../../domain/entities/offline_game_entity.dart';
import '../../domain/entities/pokemon_entity.dart';
import '../../services/image_cache_service.dart';
import 'offline_gameplay_screen.dart';
import '../../core/theme/app_theme.dart';
import 'dart:math' as math;

class LoadingScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  final List<PokemonEntity> pokemonList;

  const LoadingScreen({
    super.key,
    required this.difficulty,
    required this.pokemonList,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _progressController;
  late Animation<double> _spinAnimation;
  late Animation<double> _progressAnimation;

  int _loadedImages = 0;
  int _totalImages = 0;
  bool _hasStartedPreloading = false;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _spinAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _spinController, curve: Curves.linear));

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasStartedPreloading) {
      _hasStartedPreloading = true;
      _startPreloading();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _startPreloading() async {
    _totalImages = widget.difficulty.cardPairs;

    final selectedPokemon = widget.pokemonList;
    final imageCacheService = ImageCacheService();

    for (int i = 0; i < selectedPokemon.length; i++) {
      final pokemon = selectedPokemon[i];

      try {
        await imageCacheService.preloadImage(pokemon.imagePath, context);

        setState(() {
          _loadedImages = i + 1;
        });

        _progressController.animateTo(_loadedImages / _totalImages);

        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        debugPrint('Lỗi không tải được hình ảnh cho ${pokemon.name}: $e');
      }
    }
    imageCacheService.markAllImagesLoaded();
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OfflineGameplayScreen(
            difficulty: widget.difficulty,
            pokemonList: widget.pokemonList,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _spinAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinAnimation.value * 2 * math.pi,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60),
                              topRight: Radius.circular(60),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 120,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(60),
                                bottomRight: Radius.circular(60),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 56,
                          child: Container(
                            width: 120,
                            height: 8,
                            color: Colors.black,
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 40,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 4),
                            ),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 50),

            Container(
              width: 200,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(3),
              ),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
