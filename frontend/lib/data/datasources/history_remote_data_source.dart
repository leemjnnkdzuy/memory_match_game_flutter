import '../models/offline_history_model.dart';
import '../models/history_model.dart';
import '../../core/utils/http_client_utils.dart';
import '../../services/token_storage_service.dart';
import '../../core/error/exceptions.dart';

abstract class HistoryRemoteDataSource {
  Future<OfflineHistoryModel> saveOfflineHistory({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  });

  Future<HistoryModel> getHistory(String id);

  Future<HistoriesResponseModel> getHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String? type,
    String sortBy = 'datePlayed',
    String order = 'desc',
  });

  Future<OfflineHistoriesResponseModel> getOfflineHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  });
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final HttpClient httpClient;
  final TokenStorage tokenStorage;

  HistoryRemoteDataSourceImpl({
    required this.httpClient,
    required this.tokenStorage,
  });

  @override
  Future<OfflineHistoryModel> saveOfflineHistory({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  }) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null) {
      throw ApiException('No access token found');
    }

    final response = await httpClient.post<Map<String, dynamic>>(
      '/history/save-offline-history',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'score': score,
        'moves': moves,
        'timeElapsed': timeElapsed,
        'difficulty': difficulty,
        'isWin': isWin,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(response.message);
    }

    return OfflineHistoryModel.fromJson(
      response.data!['history'] as Map<String, dynamic>,
    );
  }

  @override
  Future<HistoryModel> getHistory(String id) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null) {
      throw ApiException('No access token found');
    }

    final response = await httpClient.get<Map<String, dynamic>>(
      '/history/get-history/$id',
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(response.message);
    }

    return HistoryModel.fromJson(
      response.data!['history'] as Map<String, dynamic>,
    );
  }

  @override
  Future<HistoriesResponseModel> getHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String? type,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null) {
      throw ApiException('No access token found');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'order': order,
    };

    if (difficulty != null) {
      queryParams['difficulty'] = difficulty;
    }
    if (isWin != null) {
      queryParams['isWin'] = isWin.toString();
    }
    if (type != null) {
      queryParams['type'] = type;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await httpClient.get<Map<String, dynamic>>(
      '/history/get-histories?$queryString',
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(response.message);
    }

    return HistoriesResponseModel.fromJson(response.data!);
  }

  @override
  Future<OfflineHistoriesResponseModel> getOfflineHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null) {
      throw ApiException('No access token found');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'order': order,
      'type': 'offline',
    };

    if (difficulty != null) {
      queryParams['difficulty'] = difficulty;
    }
    if (isWin != null) {
      queryParams['isWin'] = isWin.toString();
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await httpClient.get<Map<String, dynamic>>(
      '/history/get-histories?$queryString',
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(response.message);
    }

    final data = response.data!;
    final histories = (data['histories'] as List)
        .where((h) => h['type'] == 'offline')
        .map((h) {
          final historyData = Map<String, dynamic>.from(
            h as Map<String, dynamic>,
          );
          historyData.remove('type');
          return OfflineHistoryModel.fromJson(historyData);
        })
        .toList();

    return OfflineHistoriesResponseModel(
      histories: histories,
      pagination: PaginationModel.fromJson(
        data['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}
