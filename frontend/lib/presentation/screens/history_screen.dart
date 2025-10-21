import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../../domain/entities/history_entity.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_header.dart';
import '../widgets/common/history_card_widget.dart';
import '../widgets/common/online_history_card_widget.dart';
import '../widgets/common/battle_royale_history_card_widget.dart';
import '../widgets/common/history_filter_dialog_widget.dart';
import '../../domain/entities/battle_royale_history_entity.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _requestService = RequestService.instance;
  final _authService = AuthService.instance;

  List<HistoryEntity> _histories = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  String? _selectedDifficulty;
  bool? _selectedIsWin;
  String? _selectedType;
  final String _sortBy = 'datePlayed';
  final String _order = 'desc';

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories({bool loadMore = false}) async {
    if (!_authService.isRealUser) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vui lòng đăng nhập để xem lịch sử';
      });
      return;
    }

    if (loadMore && !_hasMore) return;

    if (!mounted) return;
    setState(() {
      if (!loadMore) {
        _isLoading = true;
        _currentPage = 1;
        _histories.clear();
      }
    });

    try {
      final result = await _requestService.getHistories(
        page: loadMore ? _currentPage + 1 : 1,
        limit: _limit,
        difficulty: _selectedDifficulty,
        isWin: _selectedIsWin,
        type: _selectedType,
        sortBy: _sortBy,
        order: _order,
      );

      if (!mounted) return;
      if (result.isSuccess && result.data != null) {
        setState(() {
          if (loadMore) {
            _histories.addAll(result.data!.histories);
            _currentPage++;
          } else {
            _histories = result.data!.histories;
            _currentPage = 1;
          }
          _hasMore = result.data!.pagination.hasNextPage;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.error ?? 'Không thể tải lịch sử';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã xảy ra lỗi: $e';
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => HistoryFilterDialog(
        selectedDifficulty: _selectedDifficulty,
        selectedIsWin: _selectedIsWin,
        selectedType: _selectedType,
        onApply: (difficulty, isWin, type) {
          setState(() {
            _selectedDifficulty = difficulty;
            _selectedIsWin = isWin;
            _selectedType = type;
          });
          _loadHistories();
        },
        onClear: () {
          setState(() {
            _selectedType = null;
            _selectedDifficulty = null;
            _selectedIsWin = null;
          });
          _loadHistories();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            onBack: () => Navigator.pop(context),
            title: 'Lịch sử',
            textColor: Colors.black,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showFilterDialog,
          backgroundColor: Colors.blue.shade600,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
          child: const Icon(Icons.filter_list, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _histories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _histories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            if (_errorMessage == 'Vui lòng đăng nhập để xem lịch sử')
              SizedBox(
                width: 200,
                child: CustomButton(
                  type: CustomButtonType.primary,
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Đăng nhập'),
                ),
              )
            else
              SizedBox(
                width: 200,
                child: CustomButton(
                  type: CustomButtonType.normal,
                  onPressed: () => _loadHistories(),
                  child: const Text('Thử lại'),
                ),
              ),
          ],
        ),
      );
    }

    if (_histories.isEmpty) {
      return const Center(child: Text('Không có lịch sử trò chơi nào'));
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadHistories(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _histories.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _histories.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 200,
                        child: CustomButton(
                          type: CustomButtonType.primary,
                          onPressed: () => _loadHistories(loadMore: true),
                          child: const Text('Tải thêm'),
                        ),
                      ),
                    ),
                  );
                }

                final history = _histories[index];
                return _buildHistoryCard(history);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(HistoryEntity history) {
    if (history.type == 'offline') {
      return HistoryCard(
        difficulty: history.difficulty ?? '',
        isWin: history.isWin ?? false,
        score: history.score ?? 0,
        moves: history.moves ?? 0,
        timeElapsed: history.timeElapsed ?? 0,
        datePlayed: history.datePlayed ?? DateTime.now(),
      );
    } else if (history.type == 'battle_royale') {
      // Battle Royale history
      final brHistory = BattleRoyaleHistoryEntity(
        id: history.id,
        matchId: history.matchId ?? '',
        userId: history.userId ?? '',
        rank: history.rank ?? 0,
        score: history.score ?? 0,
        pairsFound: history.pairsFound ?? 0,
        flipCount: history.flipCount ?? 0,
        completionTime: history.completionTime ?? 0,
        isFinished: history.isFinished ?? false,
        datePlayed: history.datePlayed ?? DateTime.now(),
        createdAt: history.createdAt,
        updatedAt: history.updatedAt,
        user: history.user,
        players: history.players
            ?.map(
              (p) => BattleRoyalePlayerResult(
                userId: p.playerId,
                username: p.username ?? p.player?.username ?? 'Player',
                avatarUrl: p.avatarUrl ?? p.player?.avatar,
                borderColor: p.borderColor ?? '#4CAF50',
                rank: p.rank ?? 0,
                score: p.score,
                pairsFound: p.pairsFound ?? 0,
                flipCount: p.flipCount ?? 0,
                completionTime: p.completionTime ?? p.timeTaken,
                isFinished: p.isFinished ?? true,
              ),
            )
            .toList(),
        totalPlayers: history.totalPlayers ?? 0,
      );
      return BattleRoyaleHistoryCard(history: brHistory);
    } else {
      // Solo Duel history
      return OnlineHistoryCard(
        history: history,
        currentUserId: _authService.currentUser?.id,
      );
    }
  }
}
