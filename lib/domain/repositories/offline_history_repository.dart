import '../entities/offline_history_entity.dart';
import 'auth_repository.dart' show Result;

abstract class OfflineHistoryRepository {
  /// Lưu lịch sử chơi offline
  Future<Result<OfflineHistoryEntity>> saveOfflineHistory({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  });

  /// Lấy một lịch sử chơi cụ thể
  Future<Result<OfflineHistoryEntity>> getOfflineHistory(String id);

  /// Lấy danh sách lịch sử chơi
  Future<Result<OfflineHistoriesResponse>> getOfflineHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  });
}
