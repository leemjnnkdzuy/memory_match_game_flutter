import '../entities/history_entity.dart';
import '../entities/offline_history_entity.dart';
import 'auth_repository.dart' show Result;

abstract class HistoryRepository {
  // Lưu offline history
  Future<Result<OfflineHistoryEntity>> saveOfflineHistory({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  });

  // Lấy một history theo ID (cả offline và online)
  Future<Result<HistoryEntity>> getHistory(String id);

  // Lấy tất cả histories
  Future<Result<HistoriesResponse>> getHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String? type,
    String sortBy = 'datePlayed',
    String order = 'desc',
  });
}
