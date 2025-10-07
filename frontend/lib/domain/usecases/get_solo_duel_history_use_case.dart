import '../repositories/solo_duel_repository.dart';
import '../repositories/auth_repository.dart' show Result;
import '../entities/solo_duel_history_entity.dart';

class GetSoloDuelHistoryUseCase {
  final SoloDuelRepository repository;

  GetSoloDuelHistoryUseCase(this.repository);

  Future<Result<SoloDuelHistoryEntity>> call(String id) async {
    return await repository.getSoloDuelHistory(id);
  }
}
