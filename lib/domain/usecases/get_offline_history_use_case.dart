import '../repositories/offline_history_repository.dart';
import '../repositories/auth_repository.dart' show Result;
import '../entities/offline_history_entity.dart';

class GetOfflineHistoryUseCase {
  final OfflineHistoryRepository repository;

  GetOfflineHistoryUseCase(this.repository);

  Future<Result<OfflineHistoryEntity>> call(String id) {
    return repository.getOfflineHistory(id);
  }
}
