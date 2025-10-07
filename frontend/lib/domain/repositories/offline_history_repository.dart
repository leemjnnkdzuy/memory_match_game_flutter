import '../entities/offline_history_entity.dart';
import 'auth_repository.dart' show Result;

abstract class OfflineHistoryRepository {
  Future<Result<OfflineHistoryEntity>> saveOfflineHistory({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  });

  Future<Result<OfflineHistoryEntity>> getOfflineHistory(String id);

  Future<Result<OfflineHistoriesResponse>> getOfflineHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  });
}
