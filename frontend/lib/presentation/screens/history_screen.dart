import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';
import '../../domain/entities/history_entity.dart';
import '../widgets/custom/custom_button.dart';

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

  int _totalOffline = 0;
  int _totalOnline = 0;

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
          _totalOffline = result.data!.pagination.totalOffline;
          _totalOnline = result.data!.pagination.totalOnline;
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
      builder: (context) => AlertDialog(
        title: const Text('Lọc lịch sử'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Loại trận đấu:'),
                RadioListTile<String?>(
                  title: const Text('Tất cả'),
                  value: null,
                  groupValue: _selectedType,
                  onChanged: (value) {
                    setDialogState(() => _selectedType = value);
                  },
                ),
                RadioListTile<String?>(
                  title: const Text('Offline'),
                  value: 'offline',
                  groupValue: _selectedType,
                  onChanged: (value) {
                    setDialogState(() => _selectedType = value);
                  },
                ),
                RadioListTile<String?>(
                  title: const Text('Online'),
                  value: 'online',
                  groupValue: _selectedType,
                  onChanged: (value) {
                    setDialogState(() => _selectedType = value);
                  },
                ),
                const Divider(),
                if (_selectedType != 'online') ...[
                  const Text('Độ khó:'),
                  DropdownButton<String?>(
                    value: _selectedDifficulty,
                    isExpanded: true,
                    hint: const Text('Tất cả độ khó'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(
                        value: 'veryEasy',
                        child: Text('Rất dễ'),
                      ),
                      DropdownMenuItem(value: 'easy', child: Text('Dễ')),
                      DropdownMenuItem(
                        value: 'normal',
                        child: Text('Bình thường'),
                      ),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text('Trung bình'),
                      ),
                      DropdownMenuItem(value: 'hard', child: Text('Khó')),
                      DropdownMenuItem(
                        value: 'superHard',
                        child: Text('Rất khó'),
                      ),
                      DropdownMenuItem(value: 'insane', child: Text('Cực khó')),
                      DropdownMenuItem(
                        value: 'expert',
                        child: Text('Chuyên gia'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() => _selectedDifficulty = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Kết quả:'),
                  RadioListTile<bool?>(
                    title: const Text('Tất cả'),
                    value: null,
                    groupValue: _selectedIsWin,
                    onChanged: (value) {
                      setDialogState(() => _selectedIsWin = value);
                    },
                  ),
                  RadioListTile<bool?>(
                    title: const Text('Thắng'),
                    value: true,
                    groupValue: _selectedIsWin,
                    onChanged: (value) {
                      setDialogState(() => _selectedIsWin = value);
                    },
                  ),
                  RadioListTile<bool?>(
                    title: const Text('Thua'),
                    value: false,
                    groupValue: _selectedIsWin,
                    onChanged: (value) {
                      setDialogState(() => _selectedIsWin = value);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedDifficulty = null;
                _selectedIsWin = null;
              });
              Navigator.pop(context);
              _loadHistories();
            },
            child: const Text('Xóa bộ lọc'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadHistories();
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử trận đấu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _buildBody(),
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
        // Statistics bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Offline', _totalOffline),
              _buildStatItem('Online', _totalOnline),
              _buildStatItem('Tổng', _totalOffline + _totalOnline),
            ],
          ),
        ),
        // History list
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

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildHistoryCard(HistoryEntity history) {
    if (history.type == 'offline') {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: history.isWin == true ? Colors.green : Colors.red,
            child: Icon(
              history.isWin == true ? Icons.check : Icons.close,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Offline - ${_getDifficultyText(history.difficulty ?? '')}',
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Điểm: ${history.score} | Nước đi: ${history.moves}'),
              Text('Thời gian: ${history.timeElapsed}s'),
              if (history.datePlayed != null)
                Text(_formatDate(history.datePlayed!)),
            ],
          ),
          isThreeLine: true,
        ),
      );
    } else {
      // Online history
      final isWinner = history.winner is Map
          ? (history.winner as Map)['_id'] == _authService.currentUser?.id
          : false;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isWinner ? Colors.green : Colors.red,
            child: Icon(
              isWinner ? Icons.emoji_events : Icons.group,
              color: Colors.white,
            ),
          ),
          title: Text('Online - ${isWinner ? 'Thắng' : 'Thua'}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Số người chơi: ${history.players?.length ?? 0}'),
              if (history.createdAt != null)
                Text(_formatDate(history.createdAt!)),
            ],
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to detail screen
          },
        ),
      );
    }
  }

  String _getDifficultyText(String difficulty) {
    const difficultyMap = {
      'veryEasy': 'Rất dễ',
      'easy': 'Dễ',
      'normal': 'Bình thường',
      'medium': 'Trung bình',
      'hard': 'Khó',
      'superHard': 'Rất khó',
      'insane': 'Cực khó',
      'expert': 'Chuyên gia',
    };
    return difficultyMap[difficulty] ?? difficulty;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hôm nay ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hôm qua ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
