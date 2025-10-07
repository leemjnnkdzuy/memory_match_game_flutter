import '../repositories/offline_history_repository.dart';
import '../repositories/auth_repository.dart' show Result;
import '../entities/offline_history_entity.dart';

class GetOfflineHistoriesUseCase {
  final OfflineHistoryRepository repository;

  GetOfflineHistoriesUseCase(this.repository);

  Future<Result<OfflineHistoriesResponse>> call({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) {
    return repository.getOfflineHistories(
      page: page,
      limit: limit,
      difficulty: difficulty,
      isWin: isWin,
      sortBy: sortBy,
      order: order,
    );
  }
}
