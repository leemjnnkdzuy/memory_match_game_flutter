import '../../domain/repositories/history_repository.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/entities/offline_history_entity.dart';
import '../../domain/repositories/auth_repository.dart' show Result;
import '../../core/error/exceptions.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<OfflineHistoryEntity>> saveOfflineHistory({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  }) async {
    try {
      final model = await remoteDataSource.saveOfflineHistory(
        score: score,
        moves: moves,
        timeElapsed: timeElapsed,
        difficulty: difficulty,
        isWin: isWin,
      );
      return Result.success(model.toEntity());
    } on ApiException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  @override
  Future<Result<HistoryEntity>> getHistory(String id) async {
    try {
      final model = await remoteDataSource.getHistory(id);
      return Result.success(model.toEntity());
    } on ApiException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  @override
  Future<Result<HistoriesResponse>> getHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String? type,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) async {
    try {
      final model = await remoteDataSource.getHistories(
        page: page,
        limit: limit,
        difficulty: difficulty,
        isWin: isWin,
        type: type,
        sortBy: sortBy,
        order: order,
      );
      return Result.success(model.toEntity());
    } on ApiException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}
