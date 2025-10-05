import '../../domain/repositories/offline_history_repository.dart';
import '../../domain/repositories/auth_repository.dart' show Result;
import '../../domain/entities/offline_history_entity.dart';
import '../datasources/offline_history_remote_data_source.dart';
import '../../core/error/exceptions.dart';

class OfflineHistoryRepositoryImpl implements OfflineHistoryRepository {
  final OfflineHistoryRemoteDataSource remoteDataSource;

  OfflineHistoryRepositoryImpl({required this.remoteDataSource});

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
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<Result<OfflineHistoryEntity>> getOfflineHistory(String id) async {
    try {
      final model = await remoteDataSource.getOfflineHistory(id);
      return Result.success(model.toEntity());
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<Result<OfflineHistoriesResponse>> getOfflineHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) async {
    try {
      final model = await remoteDataSource.getOfflineHistories(
        page: page,
        limit: limit,
        difficulty: difficulty,
        isWin: isWin,
        sortBy: sortBy,
        order: order,
      );
      return Result.success(model.toEntity());
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
