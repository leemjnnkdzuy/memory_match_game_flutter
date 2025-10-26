import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/models/battle_royale_player_model.dart';
import '../../services/battle_royale_service.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_game_dialog_widgets.dart';

class BattleRoyaleLeaderboardScreen extends StatefulWidget {
  final String matchId;
  final String roomId;
  final int myScore;
  final int myPairsFound;
  final int myFlipCount;
  final int myCompletionTime;

  const BattleRoyaleLeaderboardScreen({
    super.key,
    required this.matchId,
    required this.roomId,
    required this.myScore,
    required this.myPairsFound,
    required this.myFlipCount,
    required this.myCompletionTime,
  });

  @override
  State<BattleRoyaleLeaderboardScreen> createState() =>
      _BattleRoyaleLeaderboardScreenState();
}

class _BattleRoyaleLeaderboardScreenState
    extends State<BattleRoyaleLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  List<BattleRoyalePlayer> _leaderboard = [];
  bool _isMatchFinished = false;
  StreamSubscription? _scoreUpdateSub;
  StreamSubscription? _playerUpdateSub;
  StreamSubscription? _matchFinishSub;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _confettiTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _setupListeners();
    _loadCurrentLeaderboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scoreUpdateSub?.cancel();
    _playerUpdateSub?.cancel();
    _matchFinishSub?.cancel();
    _confettiTimer?.cancel();
    super.dispose();
  }

  void _setupListeners() {
    _scoreUpdateSub = BattleRoyaleService.instance.scoreUpdates.listen((
      player,
    ) {
      setState(() {
        final index = _leaderboard.indexWhere((p) => p.id == player.id);
        if (index != -1) {
          final existing = _leaderboard[index];
          _leaderboard[index] = _mergeScoreFields(existing, player);
        } else {
          _leaderboard.add(player);
        }
        _sortLeaderboard();
      });

      if (player.isFinished) {
        SoundService().playMatchSound();
      }
    });

    _playerUpdateSub = BattleRoyaleService.instance.playerUpdates.listen((
      players,
    ) {
      setState(() {
        for (final player in players) {
          final index = _leaderboard.indexWhere((p) => p.id == player.id);
          if (index != -1) {
            final existing = _leaderboard[index];
            _leaderboard[index] = _mergeMetaFields(existing, player);
          } else {
            _leaderboard.add(player);
          }
        }
        _sortLeaderboard();
      });
    });

    _matchFinishSub = BattleRoyaleService.instance.matchFinishes.listen((
      leaderboard,
    ) {
      setState(() {
        _leaderboard = leaderboard;
        _isMatchFinished = true;
        _sortLeaderboard();
      });

      _showMatchFinishedEffect();
    });
  }

  void _loadCurrentLeaderboard() {
    final cachedPlayers = BattleRoyaleService.instance.latestPlayers;
    if (cachedPlayers.isEmpty) return;

    setState(() {
      _leaderboard = List<BattleRoyalePlayer>.from(cachedPlayers);
      _sortLeaderboard();
    });
  }

  void _sortLeaderboard() {
    _leaderboard.sort((a, b) {
      if (a.isFinished && !b.isFinished) return -1;
      if (!a.isFinished && b.isFinished) return 1;

      if (a.isFinished && b.isFinished) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;
        return a.completionTime.compareTo(b.completionTime);
      }

      return b.pairsFound.compareTo(a.pairsFound);
    });
  }

  BattleRoyalePlayer _mergeMetaFields(
    BattleRoyalePlayer existing,
    BattleRoyalePlayer incoming,
  ) {
    return existing.copyWith(
      username: incoming.username,
      avatarUrl: incoming.avatarUrl ?? existing.avatarUrl,
      borderColor: incoming.borderColor.isNotEmpty
          ? incoming.borderColor
          : existing.borderColor,
      isReady: incoming.isReady,
      isHost: incoming.isHost,
      ping: incoming.ping ?? existing.ping,
      isConnected: incoming.isConnected,
    );
  }

  BattleRoyalePlayer _mergeScoreFields(
    BattleRoyalePlayer existing,
    BattleRoyalePlayer incoming,
  ) {
    final mergedMeta = _mergeMetaFields(existing, incoming);
    return mergedMeta.copyWith(
      pairsFound: incoming.pairsFound,
      flipCount: incoming.flipCount,
      completionTime: incoming.completionTime,
      score: incoming.score,
      isFinished: incoming.isFinished,
    );
  }

  void _showMatchFinishedEffect() {
    SoundService().playMatchSound();

    _confettiTimer = Timer(const Duration(seconds: 3), () {});
  }

  Future<void> _showExitDialog() async {
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => ExitMatchConfirmDialogWidget(
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    if (shouldQuit == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  int _getMyRank() {
    final currentUserId = AuthService.instance.currentUser?.id;
    if (currentUserId == null) return -1;

    return _leaderboard.indexWhere((p) => p.id == currentUserId) + 1;
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '👤';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[300]!;
      case 2:
        return Colors.grey[300]!;
      case 3:
        return Colors.orange[300]!;
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myRank = _getMyRank();
    final currentUserId = AuthService.instance.currentUser?.id;
    final finishedCount = _leaderboard.where((p) => p.isFinished).length;
    final totalPlayers = _leaderboard.length;

    return PopScope(
      canPop: _isMatchFinished,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _showExitDialog();
        }
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildHeader(finishedCount, totalPlayers),
                    const SizedBox(height: 24),

                    if (myRank > 0) ...[
                      _buildMyRankCard(myRank),
                      const SizedBox(height: 24),
                    ],

                    Expanded(child: _buildLeaderboardList(currentUserId)),

                    const SizedBox(height: 24),

                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int finishedCount, int totalPlayers) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            _isMatchFinished ? 'KẾT QUẢ CUỐI CÙNG' : 'BẢNG XẾP HẠNG',
            style: AppTheme.headlineLarge.copyWith(
              fontSize: 20,
              color: Color(0xFFFFFFFF),
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isMatchFinished) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Đang chờ: $finishedCount/$totalPlayers người chơi',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyRankCard(int myRank) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getRankColor(myRank),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    myRank <= 3 ? _getRankEmoji(myRank) : '#$myRank',
                    style: TextStyle(
                      fontSize: myRank <= 3 ? 28 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hạng của bạn',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _buildStatColumn('Điểm số', widget.myScore.toString()),
          _buildStatColumn('Cặp', widget.myPairsFound.toString()),
          _buildStatColumn('Thời gian', '${widget.myCompletionTime}s'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTheme.bodyMedium.copyWith(color: Colors.black54)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Text(
            value,
            style: AppTheme.headlineMedium.copyWith(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(String? currentUserId) {
    if (_leaderboard.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: const CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _leaderboard.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.black, thickness: 2, height: 24),
        itemBuilder: (context, index) {
          final player = _leaderboard[index];
          final rank = index + 1;
          final isMe = player.id == currentUserId;

          return _buildPlayerCard(player: player, rank: rank, isMe: isMe);
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isMatchFinished) {
      return CustomButton(
        type: CustomButtonType.primary,
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        child: const Text('Quay lại lobby', textAlign: TextAlign.center),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Đang chờ người chơi khác...',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard({
    required BattleRoyalePlayer player,
    required int rank,
    required bool isMe,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? Colors.amber[50] : Colors.white,
        border: Border.all(color: Colors.black, width: isMe ? 3 : 2),
        boxShadow: isMe
            ? const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                rank <= 3 ? _getRankEmoji(rank) : '#$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: rank <= 3 ? 24 : 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.username,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMe ? 16 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          'Bạn',
                          style: AppTheme.labelLarge.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildPlayerStat('Cặp', player.pairsFound.toString()),
                    _buildPlayerStat('Lật', player.flipCount.toString()),
                    if (player.isFinished)
                      _buildPlayerStat('TG', '${player.completionTime}s'),
                  ],
                ),
              ],
            ),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'ĐIỂM',
                  style: AppTheme.labelLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  player.score.toInt().toString(),
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Text(
        '$label: $value',
        style: AppTheme.bodyMedium.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
