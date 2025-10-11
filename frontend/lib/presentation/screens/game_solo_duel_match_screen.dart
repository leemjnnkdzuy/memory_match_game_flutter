import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../../services/solo_duel_game_service.dart';
import '../../services/auth_service.dart';
import '../../domain/entities/solo_duel_match_entity.dart';
import '../../domain/entities/pokemon_entity.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/common/solo_duel_card_widget.dart';

class SoloDuelMatchScreen extends StatefulWidget {
  final String matchId;

  const SoloDuelMatchScreen({super.key, required this.matchId});

  @override
  State<SoloDuelMatchScreen> createState() => _SoloDuelMatchScreenState();
}

class _SoloDuelMatchScreenState extends State<SoloDuelMatchScreen>
    with TickerProviderStateMixin {
  final _gameService = SoloDuelGameService.instance;
  final _authService = AuthService.instance;

  bool _isReady = false;
  Timer? _turnTimer;
  final List<int> _flippedCards = [];
  final Map<String, Uint8List?> _avatarCache = {};

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }

  void _setupListeners() {
    _gameService.gameStarted.addListener(_onGameStarted);
    _gameService.cardFlipped.addListener(_onCardFlipped);
    _gameService.matchResult.addListener(_onMatchResult);
    _gameService.gameOver.addListener(_onGameOver);
    _gameService.error.addListener(_onError);
  }

  void _onGameStarted() {
    if (_gameService.gameStarted.value && mounted) {
      setState(() {});
    }
  }

  void _onCardFlipped() {
    final data = _gameService.cardFlipped.value;
    if (data != null && mounted) {
      setState(() {});
    }
  }

  void _onMatchResult() {
    final data = _gameService.matchResult.value;
    if (data != null && mounted) {
      setState(() {
        _flippedCards.clear();
      });
    }
  }

  void _onGameOver() {
    final data = _gameService.gameOver.value;
    if (data != null && mounted) {
      _showGameOverDialog(data);
    }
  }

  void _onError() {
    final error = _gameService.error.value;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  void _setReady() {
    setState(() {
      _isReady = true;
    });
    _gameService.setPlayerReady(widget.matchId);
  }

  void _onCardTap(int index) {
    final match = _gameService.currentMatch;
    if (match == null) return;

    final myUserId = _authService.currentUser?.id ?? '';

    if (match.currentTurn != myUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa đến lượt của bạn!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final card = match.cards[index];
    if (card.isMatched || card.isFlipped) {
      return;
    }

    setState(() {
      _flippedCards.add(index);
    });

    _gameService.flipCard(widget.matchId, index);
  }

  void _showGameOverDialog(Map<String, dynamic> data) {
    final myUserId = _authService.currentUser?.id ?? '';
    final winnerId = data['winner']['userId'];
    final isWinner = winnerId == myUserId;

    final winner = data['winner'];
    final loser = data['loser'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isWinner ? 'Chiến thắng!' : 'Thất bại!',
          style: TextStyle(
            color: isWinner ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWinner ? Pixel.trophy : Pixel.close,
              size: 64,
              color: isWinner ? Colors.amber : Colors.red,
            ),
            const SizedBox(height: 16),
            // Show winner
            Text(
              '${winner['username']}: ${winner['score']} điểm (${winner['matchedCards']} cặp)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            // Show loser
            Text(
              '${loser['username']}: ${loser['score']} điểm (${loser['matchedCards']} cặp)',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ],
        ),
        actions: [
          CustomButton(
            type: CustomButtonType.primary,
            onPressed: () {
              _gameService.resetMatch();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = _gameService.currentMatch;

    if (match == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final myUserId = _authService.currentUser?.id ?? '';
    final opponent = match.players.firstWhere(
      (p) => p.userId != myUserId,
      orElse: () => match.players.first,
    );
    final me = match.players.firstWhere(
      (p) => p.userId == myUserId,
      orElse: () => match.players.first,
    );

    final isMyTurn = match.currentTurn == myUserId;
    final isGameStarted = match.status == MatchStatus.playing;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF9800), Color(0xFFE65100)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Avatar | Pause Button | Avatar Layout
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // My Avatar
                    Expanded(
                      child: _buildAvatarCard(
                        me,
                        isMe: true,
                        isActive: isMyTurn && isGameStarted,
                      ),
                    ),

                    // Pause Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        icon: const Icon(Icons.pause_circle_filled, size: 48),
                        color: Colors.white,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Tạm dừng'),
                              content: const Text('Bạn có muốn rời trận đấu?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tiếp tục'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _gameService.resetMatch();
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  },
                                  child: const Text('Rời trận'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Opponent Avatar
                    Expanded(
                      child: _buildAvatarCard(
                        opponent,
                        isMe: false,
                        isActive: !isMyTurn && isGameStarted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Game Board
              Expanded(
                child: !isGameStarted
                    ? _buildReadyScreen()
                    : _buildGameBoard(match),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Uint8List? _processAvatarData(String? avatarData) {
    if (avatarData == null || avatarData.isEmpty) {
      return null;
    }

    if (_avatarCache.containsKey(avatarData)) {
      return _avatarCache[avatarData];
    }

    try {
      String base64String = avatarData.trim();

      if (base64String.startsWith('data:')) {
        final commaIndex = base64String.indexOf(',');
        if (commaIndex != -1) {
          base64String = base64String.substring(commaIndex + 1);
        }
      }

      base64String = base64String.trim().replaceAll(RegExp(r'\s+'), '');

      if (base64String.length % 4 != 0) {
        final padding = (4 - (base64String.length % 4)) % 4;
        base64String += '=' * padding;
      }

      final bytes = base64Decode(base64String);
      _avatarCache[avatarData] = bytes;
      return bytes;
    } catch (e) {
      _avatarCache[avatarData] = null;
      return null;
    }
  }

  Widget _buildAvatarCard(
    PlayerEntity player, {
    required bool isMe,
    required bool isActive,
  }) {
    final avatarBytes = _processAvatarData(player.avatar);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isActive ? (isMe ? Colors.blue : Colors.orange) : Colors.black,
          width: isActive ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar Image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? (isMe ? Colors.blue : Colors.orange)
                    : Colors.grey,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: avatarBytes != null
                  ? Image.memory(
                      avatarBytes,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Pixel.user,
                          size: 48,
                          color: isActive
                              ? (isMe ? Colors.blue : Colors.orange)
                              : Colors.grey,
                        );
                      },
                    )
                  : Icon(
                      Pixel.user,
                      size: 48,
                      color: isActive
                          ? (isMe ? Colors.blue : Colors.orange)
                          : Colors.grey,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMe ? 'Bạn' : player.username,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            '${player.score} điểm',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          Text(
            '${player.matchedCards} cặp',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyScreen() {
    final match = _gameService.currentMatch!;
    final allReady = match.players.every((p) => p.isReady);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Pixel.zap, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Sẵn sàng chiến đấu?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...match.players.map((player) {
              final myUserId = _authService.currentUser?.id ?? '';
              final isMe = player.userId == myUserId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      player.isReady ? Pixel.check : Pixel.close,
                      color: player.isReady ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMe ? 'Bạn' : player.username,
                      style: TextStyle(
                        fontWeight: player.isReady
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            if (!_isReady)
              CustomButton(
                type: CustomButtonType.primary,
                onPressed: _setReady,
                child: const Text('Sẵn sàng!'),
              )
            else if (!allReady)
              const Text(
                'Đang chờ đối thủ...',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard(SoloDuelMatchEntity match) {
    final myUserId = _authService.currentUser?.id ?? '';

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: match.cards.length,
      itemBuilder: (context, index) {
        final card = match.cards[index];
        final pokemon = PokemonEntity(
          id: card.pokemonId,
          name: card.pokemonName,
          imagePath: 'images/${card.pokemonName}.png',
        );

        return SoloDuelCardWidget(
          card: card,
          pokemon: pokemon,
          onTap: () => _onCardTap(index),
          isMyTurn: match.currentTurn == myUserId,
        );
      },
    );
  }
}
