import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'dart:async';
import 'dart:math';
import '../../domain/entities/offline_game_entity.dart';
import '../../domain/entities/pokemon_entity.dart';
import '../../services/image_cache_service.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../widgets/common/game_stats_widget.dart';
import '../widgets/common/game_board_widget.dart';
import '../widgets/common/game_dialog_widgets.dart';

class OfflineGameplayScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  final List<PokemonEntity> pokemonList;

  const OfflineGameplayScreen({
    super.key,
    required this.difficulty,
    required this.pokemonList,
  });

  @override
  State<OfflineGameplayScreen> createState() => _OfflineGameplayScreenState();
}

class _OfflineGameplayScreenState extends State<OfflineGameplayScreen>
    with TickerProviderStateMixin {
  late OfflineGameEntity _game;
  Timer? _gameTimer;
  Timer? _imageCheckTimer;
  late AnimationController _flipController;
  late AnimationController _matchController;

  Duration _timeRemaining = Duration.zero;
  List<CardEntity> _flippedCards = [];
  bool _isProcessingMove = false;
  int _score = 0;
  int _moves = 0;
  GameStatus _gameStatus = GameStatus.notStarted;
  bool _imagesReady = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _matchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _initializeGame();
    _startImageReadyChecker();
  }

  void _startImageReadyChecker() {
    _imageCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      final newImagesReady = ImageCacheService().allImagesReady;
      if (newImagesReady != _imagesReady) {
        setState(() {
          _imagesReady = newImagesReady;
        });
        if (_imagesReady) {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _imageCheckTimer?.cancel();
    _flipController.dispose();
    _matchController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final cards = _generateGameCards();

    _game = OfflineGameEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cards: cards,
      score: 0,
      moves: 0,
      timeElapsed: Duration.zero,
      status: GameStatus.notStarted,
      difficulty: widget.difficulty,
    );

    _timeRemaining = widget.difficulty.timeLimit;
    _score = 0;
    _moves = 0;
    _gameStatus = GameStatus.notStarted;

    setState(() {});
  }

  List<CardEntity> _generateGameCards() {
    final random = Random();

    final selectedPokemon = widget.pokemonList;

    final cards = <CardEntity>[];
    for (int i = 0; i < selectedPokemon.length; i++) {
      final pokemon = selectedPokemon[i];
      cards.add(
        CardEntity(
          id: '${pokemon.id}_1',
          pokemonId: pokemon.id,
          isFlipped: false,
          isMatched: false,
          position: i * 2,
        ),
      );
      cards.add(
        CardEntity(
          id: '${pokemon.id}_2',
          pokemonId: pokemon.id,
          isFlipped: false,
          isMatched: false,
          position: i * 2 + 1,
        ),
      );
    }

    cards.shuffle(random);

    for (int i = 0; i < cards.length; i++) {
      cards[i] = cards[i].copyWith(position: i);
    }

    return cards;
  }

  void _startGame() {
    setState(() {
      _gameStatus = GameStatus.playing;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameStatus == GameStatus.playing) {
        setState(() {
          _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        });

        if (_timeRemaining.inSeconds <= 0) {
          _endGame(false);
        }
      }
    });
  }

  void _pauseGame() {
    setState(() {
      _gameStatus = GameStatus.paused;
    });
  }

  void _resumeGame() {
    setState(() {
      _gameStatus = GameStatus.playing;
    });
  }

  void _endGame(bool isWin) {
    _gameTimer?.cancel();
    setState(() {
      _gameStatus = isWin ? GameStatus.completed : GameStatus.gameOver;
    });

    _saveGameHistory(isWin);

    _showGameEndDialog(isWin);
  }

  Future<void> _saveGameHistory(bool isWin) async {
    final authService = AuthService.instance;
    if (!authService.isRealUser) {
      return;
    }

    try {
      final requestService = RequestService.instance;
      final timeElapsed =
          widget.difficulty.timeLimit.inSeconds - _timeRemaining.inSeconds;

      String difficultyString = widget.difficulty.name;
      if (difficultyString == 'extreme') {
        difficultyString = 'expert';
      }

      final result = await requestService.saveOfflineHistory(
        score: _score,
        moves: _moves,
        timeElapsed: timeElapsed,
        difficulty: difficultyString,
        isWin: isWin,
      );

      if (result.isSuccess) {
        print('Game history saved successfully: ${result.data?.id}');
      } else {
        print('Failed to save game history: ${result.error}');
      }
    } catch (e) {
      print('Error saving game history: $e');
    }
  }

  void _showGameEndDialog(bool isWin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameEndDialogWidget(
          isWin: isWin,
          score: _score,
          moves: _moves,
          gameTime: widget.difficulty.timeLimit - _timeRemaining,
          onPlayAgain: () {
            Navigator.of(context).pop();
            _initializeGame();
          },
          onBackToMenu: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _onCardTapped(CardEntity card) {
    if (!ImageCacheService().allImagesReady) {
      print('Blocking card tap - images not ready yet');
      return;
    }

    if (_gameStatus == GameStatus.notStarted) {
      _startGame();
    }

    if (_gameStatus != GameStatus.playing ||
        _isProcessingMove ||
        card.isFlipped ||
        card.isMatched ||
        _flippedCards.length >= 2) {
      return;
    }

    setState(() {
      final cardIndex = _game.cards.indexWhere((c) => c.id == card.id);
      _game.cards[cardIndex] = card.copyWith(isFlipped: true);
      _flippedCards.add(_game.cards[cardIndex]);
    });

    _flipController.forward();

    if (_flippedCards.length == 2) {
      _isProcessingMove = true;
      _moves++;

      Timer(const Duration(milliseconds: 1000), () {
        _checkForMatch();
      });
    }
  }

  void _checkForMatch() {
    final card1 = _flippedCards[0];
    final card2 = _flippedCards[1];

    if (card1.pokemonId == card2.pokemonId) {
      setState(() {
        final card1Index = _game.cards.indexWhere((c) => c.id == card1.id);
        final card2Index = _game.cards.indexWhere((c) => c.id == card2.id);

        _game.cards[card1Index] = card1.copyWith(isMatched: true);
        _game.cards[card2Index] = card2.copyWith(isMatched: true);

        _score += 100;

        final timeBonus = (_timeRemaining.inSeconds * 2).clamp(0, 200);
        _score += timeBonus;
      });

      _matchController.forward().then((_) {
        _matchController.reset();
      });

      if (_game.cards.every((card) => card.isMatched)) {
        _endGame(true);
      }
    } else {
      setState(() {
        final card1Index = _game.cards.indexWhere((c) => c.id == card1.id);
        final card2Index = _game.cards.indexWhere((c) => c.id == card2.id);

        _game.cards[card1Index] = card1.copyWith(isFlipped: false);
        _game.cards[card2Index] = card2.copyWith(isFlipped: false);
      });
    }

    _flippedCards.clear();
    _isProcessingMove = false;
    _flipController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GameStatsWidget(
                        timeRemaining: _timeRemaining,
                        score: _score,
                        moves: _moves,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Pixel.pause,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          _pauseGame();
                          _showPauseDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    GameBoardWidget(
                      cards: _game.cards,
                      pokemonList: widget.pokemonList,
                      difficulty: widget.difficulty,
                      onCardTap: _onCardTapped,
                      flipController: _flipController,
                      matchController: _matchController,
                    ),

                    // Loading overlay if images not ready
                    if (!_imagesReady)
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading Pokemon Images...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Please wait for all images to load\nbefore starting the game',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GamePauseDialogWidget(
          score: _score,
          moves: _moves,
          timeRemaining: _timeRemaining,
          onResume: () {
            Navigator.of(context).pop();
            _resumeGame();
          },
          onQuit: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
