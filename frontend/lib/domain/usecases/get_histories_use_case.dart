import '../repositories/history_repository.dart';
import '../repositories/auth_repository.dart' show Result;
import '../entities/history_entity.dart';

class GetHistoriesUseCase {
  final HistoryRepository repository;

  GetHistoriesUseCase(this.repository);

  Future<Result<HistoriesResponse>> call({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String? type,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) {
    return repository.getHistories(
      page: page,
      limit: limit,
      difficulty: difficulty,
      isWin: isWin,
      type: type,
      sortBy: sortBy,
      order: order,
    );
  }
}
