import '../repositories/history_repository.dart';
import '../repositories/auth_repository.dart' show Result;
import '../entities/offline_history_entity.dart';

class SaveOfflineHistoryUseCase {
  final HistoryRepository repository;

  SaveOfflineHistoryUseCase(this.repository);

  Future<Result<OfflineHistoryEntity>> call({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  }) {
    return repository.saveOfflineHistory(
      score: score,
      moves: moves,
      timeElapsed: timeElapsed,
      difficulty: difficulty,
      isWin: isWin,
    );
  }
}
