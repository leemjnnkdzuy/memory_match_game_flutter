import '../repositories/history_repository.dart';
import '../repositories/auth_repository.dart' show Result;
import '../entities/history_entity.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<Result<HistoryEntity>> call(String id) {
    return repository.getHistory(id);
  }
}
