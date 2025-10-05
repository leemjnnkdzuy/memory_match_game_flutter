import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../../domain/entities/offline_history_entity.dart';
import '../widgets/common/history_card_widget.dart';
import '../widgets/custom/custom_button.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _requestService = RequestService.instance;
  final _authService = AuthService.instance;

  List<OfflineHistoryEntity> _histories = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  String? _selectedDifficulty;
  bool? _selectedIsWin;
  final String _sortBy = 'datePlayed';
  final String _order = 'desc';

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories({bool loadMore = false}) async {
    if (!_authService.isRealUser) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vui lòng đăng nhập để xem lịch sử';
      });
      return;
    }

    if (loadMore && !_hasMore) return;

    setState(() {
      if (!loadMore) {
        _isLoading = true;
        _currentPage = 1;
        _histories.clear();
      }
    });

    try {
      final result = await _requestService.getOfflineHistories(
        page: loadMore ? _currentPage + 1 : 1,
        limit: _limit,
        difficulty: _selectedDifficulty,
        isWin: _selectedIsWin,
        sortBy: _sortBy,
        order: _order,
      );

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
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã xảy ra lỗi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
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

    return RefreshIndicator(
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
          return HistoryCard(
            difficulty: history.difficulty,
            isWin: history.isWin,
            score: history.score,
            moves: history.moves,
            timeElapsed: history.timeElapsed,
            datePlayed: history.datePlayed,
            onTap: () {
              // TODO: Navigate to history detail or replay
            },
          );
        },
      ),
    );
  }
}
