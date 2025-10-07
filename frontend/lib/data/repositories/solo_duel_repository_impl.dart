import '../../data/datasources/solo_duel_remote_data_source.dart';
import '../../domain/repositories/solo_duel_repository.dart';
import '../../domain/repositories/auth_repository.dart' show Result;
import '../../domain/entities/solo_duel_history_entity.dart';

class SoloDuelRepositoryImpl implements SoloDuelRepository {
  final SoloDuelRemoteDataSource remoteDataSource;

  SoloDuelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<SoloDuelHistoriesResponse>> getSoloDuelHistories({
    int page = 1,
    int limit = 10,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) async {
    try {
      final response = await remoteDataSource.getSoloDuelHistories(
        page: page,
        limit: limit,
        isWin: isWin,
        sortBy: sortBy,
        order: order,
      );

      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.message);
      }
    } catch (e) {
      return Result.error('Failed to get solo duel histories: ${e.toString()}');
    }
  }

  @override
  Future<Result<SoloDuelHistoryEntity>> getSoloDuelHistory(String id) async {
    try {
      final response = await remoteDataSource.getSoloDuelHistory(id);

      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.message);
      }
    } catch (e) {
      return Result.error('Failed to get solo duel history: ${e.toString()}');
    }
  }
}
