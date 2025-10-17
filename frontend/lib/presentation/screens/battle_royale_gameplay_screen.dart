import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../domain/entities/offline_game_entity.dart';
import '../../domain/entities/pokemon_entity.dart';
import '../../services/image_cache_service.dart';
import '../../services/battle_royale_service.dart';
import '../../services/sound_service.dart';
import '../../data/datasources/local_pokemon_data_source.dart';
import '../widgets/common/battle_royale_card_widget.dart';
import 'battle_royale_leaderboard_screen.dart';

class BattleRoyaleGameplayScreen extends StatefulWidget {
  final String matchId;
  final String roomId;
  final List<int> pokemonIds;
  final String seed;

  const BattleRoyaleGameplayScreen({
    super.key,
    required this.matchId,
    required this.roomId,
    required this.pokemonIds,
    required this.seed,
  });

  @override
  State<BattleRoyaleGameplayScreen> createState() =>
      _BattleRoyaleGameplayScreenState();
}

class _BattleRoyaleGameplayScreenState
    extends State<BattleRoyaleGameplayScreen> {
  List<CardEntity> _cards = [];
  Timer? _gameTimer;
  Timer? _updateTimer;
  final LocalPokemonDataSource _pokemonDataSource = LocalPokemonDataSource();
  Map<int, PokemonEntity> _pokemonMap = {};

  Duration _timeElapsed = Duration.zero;
  final List<CardEntity> _flippedCards = [];
  bool _isProcessingMove = false;
  int _pairsFound = 0;
  int _flipCount = 0;
  GameStatus _gameStatus = GameStatus.notStarted;
  bool _hasFinished = false;

  StreamSubscription? _playerFinishedSub;
  StreamSubscription? _matchFinishedSub;

  @override
  void initState() {
    super.initState();
    SoundService().preload();
    _setupListeners();
    _loadPokemonData();
  }

  Future<void> _loadPokemonData() async {
    final allPokemon = await _pokemonDataSource.getAllPokemon();
    final pokemonMap = <int, PokemonEntity>{};

    for (final pokemon in allPokemon) {
      pokemonMap[pokemon.id] = PokemonEntity(
        id: pokemon.id,
        name: pokemon.name,
        imagePath: pokemon.imagePath,
      );
    }

    if (!mounted) return;

    setState(() {
      _pokemonMap = pokemonMap;
    });

    _initializeGame();

    final imageCacheService = ImageCacheService();
    final uniquePokemonIds = widget.pokemonIds.toSet();
    final preloadFutures = <Future<void>>[];

    for (final pokemonId in uniquePokemonIds) {
      final pokemon = pokemonMap[pokemonId];
      if (pokemon != null) {
        preloadFutures.add(
          imageCacheService.preloadImage(pokemon.imagePath, context),
        );
      }
    }

    try {
      await Future.wait(preloadFutures);
      imageCacheService.markAllImagesLoaded();
    } catch (e) {
      imageCacheService.markAllImagesLoaded();
    }

    if (mounted) {
      _startGame();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _updateTimer?.cancel();
    _playerFinishedSub?.cancel();
    _matchFinishedSub?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    final cards = _generateGameCards();
    _cards = cards;
    _timeElapsed = Duration.zero;
    _pairsFound = 0;
    _flipCount = 0;
    _gameStatus = GameStatus.notStarted;
    _hasFinished = false;

    setState(() {});
  }

  List<CardEntity> _generateGameCards() {
    final random = Random(
      int.tryParse(widget.seed) ?? DateTime.now().millisecondsSinceEpoch,
    );
    final cards = <CardEntity>[];

    for (int i = 0; i < widget.pokemonIds.length; i++) {
      final pokemonId = widget.pokemonIds[i];
      cards.add(
        CardEntity(
          id: '${pokemonId}_1',
          pokemonId: pokemonId,
          isFlipped: false,
          isMatched: false,
          position: i * 2,
        ),
      );
      cards.add(
        CardEntity(
          id: '${pokemonId}_2',
          pokemonId: pokemonId,
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

  void _setupListeners() {
    _playerFinishedSub = BattleRoyaleService.instance.scoreUpdates.listen((
      player,
    ) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${player.username} đã hoàn thành!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    _matchFinishedSub = BattleRoyaleService.instance.matchFinishes.listen((
      leaderboard,
    ) {
      if (mounted && !_hasFinished) {
        final score = _calculateScore();
        _navigateToLeaderboard(score.toInt());
      }
    });
  }

  void _startGame() {
    setState(() {
      _gameStatus = GameStatus.playing;
    });
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameStatus == GameStatus.playing) {
        setState(() {
          _timeElapsed = _timeElapsed + const Duration(seconds: 1);
        });
      }
    });

    _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_gameStatus == GameStatus.playing && !_hasFinished) {
        _sendProgressUpdate();
      }
    });
  }

  void _sendProgressUpdate() {
    BattleRoyaleService.instance.sendScoreUpdate(
      matchId: widget.matchId,
      pairsFound: _pairsFound,
      flipCount: _flipCount,
      completionTime: _timeElapsed.inSeconds,
    );
  }

  void _endGame() {
    if (_hasFinished) return;

    _hasFinished = true;
    _gameTimer?.cancel();
    _updateTimer?.cancel();

    setState(() {
      _gameStatus = GameStatus.completed;
    });

    final score = _calculateScore();

    BattleRoyaleService.instance.sendMatchFinish(
      matchId: widget.matchId,
      pairsFound: _pairsFound,
      flipCount: _flipCount,
      completionTime: _timeElapsed.inSeconds,
      score: score,
    );

    _navigateToLeaderboard(score.toInt());
  }

  void _navigateToLeaderboard(int score) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BattleRoyaleLeaderboardScreen(
          matchId: widget.matchId,
          roomId: widget.roomId,
          myScore: score,
          myPairsFound: _pairsFound,
          myFlipCount: _flipCount,
          myCompletionTime: _timeElapsed.inSeconds,
        ),
      ),
    );
  }

  double _calculateScore() {
    final pairCount = widget.pokemonIds.length;
    final baseScore = (_pairsFound / pairCount) * 1000;
    final timeBonus = max(0, 300 - _timeElapsed.inSeconds) * 2;
    final efficiencyBonus = _flipCount > 0
        ? ((_pairsFound * 2) / _flipCount * 100).clamp(0, 200)
        : 0;

    return baseScore + timeBonus + efficiencyBonus;
  }

  void _onCardTapped(CardEntity card) {
    if (_gameStatus != GameStatus.playing ||
        _isProcessingMove ||
        card.isFlipped ||
        card.isMatched ||
        _flippedCards.length >= 2) {
      return;
    }

    debugPrint('Processing card tap: ${card.id}');

    setState(() {
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = _cards[index].copyWith(isFlipped: true);
        _flippedCards.add(_cards[index]);
      }
    });

    SoundService().playCardFlipSound();

    if (_flippedCards.length == 2) {
      _flipCount++;
      _isProcessingMove = true;
      _checkMatch();
    }
  }

  Widget _buildStatsWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTight = constraints.maxWidth < 260;
          final stats = <Widget>[
            _buildStatItem(Icons.timer, _formatTime(_timeElapsed)),
            _buildStatItem(
              Icons.emoji_events,
              '$_pairsFound/${widget.pokemonIds.length}',
            ),
            _buildStatItem(Icons.refresh, '$_flipCount'),
          ];

          if (isTight) {
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: stats,
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats,
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildGameBoard() {
    if (_cards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalPairs = widget.pokemonIds.length;
    final cardCount = totalPairs * 2;
    final crossAxisCount = _calculateGridColumns(cardCount);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          final pokemon = _pokemonMap[card.pokemonId];

          if (pokemon == null) {
            return const Card(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final canInteract =
              _gameStatus == GameStatus.playing &&
              !_isProcessingMove &&
              _flippedCards.length < 2;

          return BattleRoyaleCardWidget(
            key: ValueKey(card.id),
            card: card,
            pokemon: pokemon,
            onTap: () => _onCardTapped(card),
            canInteract: canInteract,
          );
        },
      ),
    );
  }

  int _calculateGridColumns(int cardCount) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    if (cardCount <= 12) return isSmallScreen ? 3 : 4;
    if (cardCount <= 24) return isSmallScreen ? 4 : 6;
    return isSmallScreen ? 5 : 8;
  }

  void _checkMatch() {
    final card1 = _flippedCards[0];
    final card2 = _flippedCards[1];

    if (card1.pokemonId == card2.pokemonId) {
      SoundService().playMatchSound();

      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          for (final flippedCard in _flippedCards) {
            final index = _cards.indexWhere((c) => c.id == flippedCard.id);
            if (index != -1) {
              _cards[index] = _cards[index].copyWith(isMatched: true);
            }
          }
          _flippedCards.clear();
          _isProcessingMove = false;
          _pairsFound++;

          if (_pairsFound == widget.pokemonIds.length) {
            _endGame();
          }
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          for (final flippedCard in _flippedCards) {
            final index = _cards.indexWhere((c) => c.id == flippedCard.id);
            if (index != -1) {
              _cards[index] = _cards[index].copyWith(isFlipped: false);
            }
          }
          _flippedCards.clear();
          _isProcessingMove = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPairs = widget.pokemonIds.length;
    final progress = totalPairs > 0 ? _pairsFound / totalPairs : 0.0;

    return WillPopScope(
      onWillPop: () async {
        if (_gameStatus == GameStatus.playing && !_hasFinished) {
          final shouldQuit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận thoát'),
              content: const Text(
                'Bạn có chắc muốn thoát? Tiến trình sẽ được lưu.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Ở lại'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Thoát'),
                ),
              ],
            ),
          );
          return shouldQuit ?? false;
        }
        return true;
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildStatsWidget(),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.greenAccent,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 16),
                Expanded(child: _buildGameBoard()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
