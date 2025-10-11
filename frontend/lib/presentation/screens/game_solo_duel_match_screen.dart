import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../../services/solo_duel_game_service.dart';
import '../../services/auth_service.dart';
import '../../domain/entities/solo_duel_match_entity.dart';
import '../../domain/entities/pokemon_entity.dart';
import '../../core/utils/pokemon_name_utils.dart';
import '../widgets/common/solo_duel_card_widget.dart';
import '../widgets/common/solo_duel_dialog_widgets.dart';
import '../widgets/common/animated_not_your_turn_overlay.dart';
import '../widgets/common/player_avatar_card_widget.dart';
import '../widgets/common/solo_duel_ready_screen_widget.dart';
import '../routes/app_routes.dart';
import './game_solo_duel_screen.dart';

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
  final Map<String, Uint8List?> _avatarCache = {};
  Timer? _readyTimer;
  int _countdown = 60;
  bool _isDisconnectDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _startReadyTimer();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _readyTimer?.cancel();
    _gameService.gameStarted.removeListener(_onGameStarted);
    _gameService.cardFlipped.removeListener(_onCardFlipped);
    _gameService.currentMatchNotifier.removeListener(_onMatchUpdated);
    _gameService.gameOver.removeListener(_onGameOver);
    _gameService.error.removeListener(_onError);
    _gameService.playerReady.removeListener(_onPlayerReady);
    _gameService.playerDisconnected.removeListener(_onPlayerDisconnected);
    _gameService.playerReconnected.removeListener(_onPlayerReconnected);
    _gameService.matchState.removeListener(_onMatchStateReceived);
    super.dispose();
  }

  void _setupListeners() {
    _gameService.gameStarted.addListener(_onGameStarted);
    _gameService.cardFlipped.addListener(_onCardFlipped);
    _gameService.currentMatchNotifier.addListener(
      _onMatchUpdated,
    ); // Listen to match updates
    _gameService.gameOver.addListener(_onGameOver);
    _gameService.error.addListener(_onError);
    _gameService.playerReady.addListener(_onPlayerReady);
    _gameService.playerDisconnected.addListener(_onPlayerDisconnected);
    _gameService.playerReconnected.addListener(_onPlayerReconnected);
    _gameService.matchState.addListener(_onMatchStateReceived);
  }

  void _onGameStarted() {
    if (_gameService.gameStarted.value && mounted) {
      _readyTimer?.cancel();
      setState(() {});
    }
  }

  void _onCardFlipped() {
    final data = _gameService.cardFlipped.value;
    if (data != null && mounted) {
      setState(() {});
    }
  }

  void _onMatchUpdated() {
    // Triggered whenever currentMatch changes (including score updates)
    if (mounted) {
      setState(() {});
    }
  }

  void _onGameOver() {
    final data = _gameService.gameOver.value;
    if (data != null && mounted) {
      if (_isDisconnectDialogShowing) {
        _isDisconnectDialogShowing = false;
        Navigator.pop(context);
      }

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

  void _onPlayerReady() {
    final readyUserId = _gameService.playerReady.value;
    if (readyUserId != null && mounted) {
      final myUserId = _authService.currentUser?.id ?? '';
      if (readyUserId == myUserId) {
        setState(() {
          _isReady = true;
        });
      }
    }
  }

  void _onPlayerDisconnected() {
    final data = _gameService.playerDisconnected.value;
    if (data != null && mounted) {
      final myUserId = _authService.currentUser?.id ?? '';
      final disconnectedUserId = data['userId'];

      if (disconnectedUserId != myUserId) {
        _showOpponentDisconnectedDialog(data);
      }
      setState(() {});
    }
  }

  void _onPlayerReconnected() {
    final data = _gameService.playerReconnected.value;
    if (data != null && mounted) {
      if (_isDisconnectDialogShowing) {
        _isDisconnectDialogShowing = false;
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data['username']} đã kết nối lại!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
  }

  void _onMatchStateReceived() {
    final data = _gameService.matchState.value;
    if (data != null && mounted) {
      setState(() {});
    }
  }

  void _startReadyTimer() {
    _readyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
        });
      }
      if (_countdown <= 0) {
        _onReadyTimeout();
        timer.cancel();
      }
    });
  }

  void _onReadyTimeout() {
    final match = _gameService.currentMatch;
    if (match == null || !mounted) return;

    final myUserId = _authService.currentUser?.id ?? '';
    final me = match.players.firstWhere((p) => p.userId == myUserId);
    final opponent = match.players.firstWhere((p) => p.userId != myUserId);

    _gameService.resetMatch();

    if (me.isReady && opponent.isReady) {
      return;
    } else if (me.isReady && !opponent.isReady) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SoloDuelScreen(autoJoin: true),
        ),
      );
    } else if (!me.isReady && opponent.isReady) {
      AppRoutes.navigateBackToHome(context);
    } else {
      AppRoutes.navigateBackToHome(context);
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
      _showNotYourTurnOverlay();
      return;
    }

    final card = match.cards[index];

    if (card.isMatched || card.isFlipped) {
      return;
    }

    if (match.flippedCards.length >= 2) {
      return;
    }

    _gameService.flipCard(widget.matchId, index);
  }

  void _showNotYourTurnOverlay() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AnimatedNotYourTurnOverlay(
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _showSurrenderConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SoloDuelSurrenderConfirmationDialog(
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          _gameService.surrender(widget.matchId);
        },
      ),
    );
  }

  void _showOpponentDisconnectedDialog(Map<String, dynamic> data) {
    final opponentUsername = data['username'] ?? 'Đối thủ';
    final waitTime = data['waitTimeSeconds'] ?? 30;

    _isDisconnectDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: SoloDuelOpponentDisconnectedDialog(
          opponentUsername: opponentUsername,
          waitTimeSeconds: waitTime,
          onClose: () {
            _isDisconnectDialogShowing = false;
            Navigator.pop(context);
          },
        ),
      ),
    );
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
      builder: (context) => SoloDuelGameOverDialog(
        isWinner: isWinner,
        winnerUsername: winner['username'],
        winnerScore: winner['score'],
        winnerMatchedCards: winner['matchedCards'],
        loserUsername: loser['username'],
        loserScore: loser['score'],
        loserMatchedCards: loser['matchedCards'],
        onBackToHome: () {
          _gameService.resetMatch();
          Navigator.pop(context);
          AppRoutes.navigateBackToHome(context);
        },
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
              // Only show avatars and pause button when game has started
              if (isGameStarted)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: PlayerAvatarCardWidget(
                          username: me.username,
                          score: me.score,
                          matchedCards: me.matchedCards,
                          avatarBytes: _processAvatarData(me.avatar),
                          isMe: true,
                          isActive: isMyTurn && isGameStarted,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: IconButton(
                          icon: const Icon(Icons.pause_circle_filled, size: 48),
                          color: Colors.white,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => SoloDuelPauseDialog(
                                onResume: () => Navigator.pop(context),
                                onSurrender: () {
                                  Navigator.pop(context);
                                  _showSurrenderConfirmationDialog();
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      Expanded(
                        child: PlayerAvatarCardWidget(
                          username: opponent.username,
                          score: opponent.score,
                          matchedCards: opponent.matchedCards,
                          avatarBytes: _processAvatarData(opponent.avatar),
                          isMe: false,
                          isActive: !isMyTurn && isGameStarted,
                        ),
                      ),
                    ],
                  ),
                ),

              if (isGameStarted) const SizedBox(height: 8),

              Expanded(
                child: !isGameStarted
                    ? SoloDuelReadyScreenWidget(
                        players: match.players,
                        currentUserId: myUserId,
                        countdown: _countdown,
                        isReady: _isReady,
                        onSetReady: _setReady,
                      )
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

  Widget _buildGameBoard(SoloDuelMatchEntity match) {
    final myUserId = _authService.currentUser?.id ?? '';

    bool areTwoCardsFlippedAndMatching = false;
    if (match.flippedCards.length == 2) {
      final firstIndex = match.flippedCards[0].cardIndex;
      final secondIndex = match.flippedCards[1].cardIndex;
      final firstCard = match.cards[firstIndex];
      final secondCard = match.cards[secondIndex];
      areTwoCardsFlippedAndMatching =
          firstCard.pokemonId == secondCard.pokemonId;
    }

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
          imagePath: PokemonNameUtils.pokemonNameToImagePath(card.pokemonName),
        );

        final showGreenBorder =
            card.isMatched ||
            (card.isFlipped &&
                !card.isMatched &&
                areTwoCardsFlippedAndMatching);

        return SoloDuelCardWidget(
          card: card,
          pokemon: pokemon,
          onTap: () => _onCardTap(index),
          isMyTurn: match.currentTurn == myUserId,
          isPotentialMatch: showGreenBorder,
        );
      },
    );
  }
}
