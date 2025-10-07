import '../repositories/solo_duel_repository.dart';
import '../repositories/auth_repository.dart' show Result;
import '../entities/solo_duel_history_entity.dart';

class GetSoloDuelHistoriesUseCase {
  final SoloDuelRepository repository;

  GetSoloDuelHistoriesUseCase(this.repository);

  Future<Result<SoloDuelHistoriesResponse>> call({
    int page = 1,
    int limit = 10,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) async {
    return await repository.getSoloDuelHistories(
      page: page,
      limit: limit,
      isWin: isWin,
      sortBy: sortBy,
      order: order,
    );
  }
}
