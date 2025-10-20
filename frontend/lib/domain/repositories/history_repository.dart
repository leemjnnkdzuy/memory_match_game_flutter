import '../entities/history_entity.dart';
import '../entities/offline_history_entity.dart';
import 'auth_repository.dart' show Result;

abstract class HistoryRepository {
  Future<Result<OfflineHistoryEntity>> saveOfflineHistory({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  });

  Future<Result<HistoryEntity>> getHistory(String id);

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
