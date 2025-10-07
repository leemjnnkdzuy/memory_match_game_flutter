import '../entities/solo_duel_history_entity.dart';
import './auth_repository.dart' show Result;

abstract class SoloDuelRepository {
  Future<Result<SoloDuelHistoriesResponse>> getSoloDuelHistories({
    int page = 1,
    int limit = 10,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  });

  Future<Result<SoloDuelHistoryEntity>> getSoloDuelHistory(String id);
}
