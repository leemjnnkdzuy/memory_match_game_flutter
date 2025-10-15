// Game difficulty selection screen
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'dart:math';
import '../../domain/entities/offline_game_entity.dart';
import '../../domain/entities/pokemon_entity.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../data/implements/pokemon_repository_impl.dart';
import '../../data/datasources/local_pokemon_data_source.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_container.dart';
import '../widgets/custom/custom_app_bar.dart';
import 'loading_screen.dart';

class DifficultySelectionScreen extends StatefulWidget {
  final Function(GameDifficulty)? onDifficultySelected;
  final VoidCallback? onBack;

  const DifficultySelectionScreen({
    super.key,
    this.onDifficultySelected,
    this.onBack,
  });

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  late final PokemonRepository _pokemonRepository;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pokemonRepository = PokemonRepositoryImpl(LocalPokemonDataSource());
  }

  Future<void> _onDifficultySelected(GameDifficulty difficulty) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final allPokemonList = await _pokemonRepository.getAllPokemon();

      final random = Random();
      final selectedPokemon = <PokemonEntity>[];
      final shuffledPokemon = List<PokemonEntity>.from(allPokemonList)
        ..shuffle(random);
      selectedPokemon.addAll(shuffledPokemon.take(difficulty.cardPairs));

      if (!mounted) return;

      widget.onDifficultySelected?.call(difficulty);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(
            difficulty: difficulty,
            pokemonList: selectedPokemon,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'LỖI',
              style: AppTheme.headlineMedium.copyWith(color: Colors.red),
            ),
            content: Text(
              'Không thể tải dữ liệu Pokemon. Vui lòng thử lại.',
              style: AppTheme.bodyMedium,
            ),
            actions: [
              CustomButton(
                type: CustomButtonType.primary,
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chọn độ khó',
        leading: IconButton(
          icon: const Icon(Pixel.arrowleft),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else
                    ...GameDifficulty.values.map((difficulty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: _DifficultyCard(
                            difficulty: difficulty,
                            onSelected: () => _onDifficultySelected(difficulty),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final GameDifficulty difficulty;
  final VoidCallback onSelected;

  const _DifficultyCard({required this.difficulty, required this.onSelected});

  String get _difficultyName {
    switch (difficulty) {
      case GameDifficulty.veryEasy:
        return 'VERY EASY';
      case GameDifficulty.easy:
        return 'EASY';
      case GameDifficulty.normal:
        return 'NORMAL';
      case GameDifficulty.medium:
        return 'MEDIUM';
      case GameDifficulty.hard:
        return 'HARD';
      case GameDifficulty.superHard:
        return 'SUPER HARD';
      case GameDifficulty.insane:
        return 'INSANE';
      case GameDifficulty.extreme:
        return 'EXTREME';
    }
  }

  String get _difficultyDescription {
    switch (difficulty) {
      case GameDifficulty.veryEasy:
        return '${difficulty.cardPairs} cặp • ${difficulty.timeLimit.inMinutes} phút';
      case GameDifficulty.easy:
        return '${difficulty.cardPairs} cặp • ${difficulty.timeLimit.inMinutes} phút';
      case GameDifficulty.normal:
        return '${difficulty.cardPairs} cặp • ${difficulty.timeLimit.inMinutes} phút';
      case GameDifficulty.medium:
        return '${difficulty.cardPairs} cặp • ${difficulty.timeLimit.inMinutes} phút';
      case GameDifficulty.hard:
        return '${difficulty.cardPairs} cặp • ${difficulty.timeLimit.inMinutes} phút';
      case GameDifficulty.superHard:
        return '${difficulty.cardPairs} cặp • ${difficulty.timeLimit.inMinutes} phút';
      case GameDifficulty.insane:
        return '${difficulty.cardPairs} cặp • ${difficulty.timeLimit.inMinutes} phút';
      case GameDifficulty.extreme:
        return '${difficulty.cardPairs} cặp • ${difficulty.timeLimit.inMinutes} phút';
    }
  }

  CustomButtonType get _buttonType {
    switch (difficulty) {
      case GameDifficulty.veryEasy:
        return CustomButtonType.success;
      case GameDifficulty.easy:
        return CustomButtonType.success;
      case GameDifficulty.normal:
        return CustomButtonType.warning;
      case GameDifficulty.medium:
        return CustomButtonType.warning;
      case GameDifficulty.hard:
        return CustomButtonType.primary;
      case GameDifficulty.superHard:
        return CustomButtonType.primary;
      case GameDifficulty.insane:
        return CustomButtonType.error;
      case GameDifficulty.extreme:
        return CustomButtonType.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _difficultyName,
                  style: AppTheme.headlineMedium.copyWith(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _difficultyDescription,
                  style: AppTheme.bodyMedium.copyWith(
                    color: const Color.fromARGB(179, 0, 0, 0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CustomButton(
            type: _buttonType,
            onPressed: onSelected,
            child: Text('CHỌN'),
          ),
        ],
      ),
    );
  }
}
