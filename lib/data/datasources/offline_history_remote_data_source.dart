import '../models/offline_history_model.dart';
import 'http_client.dart';
import 'token_storage.dart';

abstract class OfflineHistoryRemoteDataSource {
  Future<OfflineHistoryModel> saveOfflineHistory({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  });
  Future<OfflineHistoryModel> getOfflineHistory(String id);

  Future<OfflineHistoriesResponseModel> getOfflineHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  });
}

class OfflineHistoryRemoteDataSourceImpl
    implements OfflineHistoryRemoteDataSource {
  final HttpClient httpClient;
  final TokenStorage tokenStorage;

  OfflineHistoryRemoteDataSourceImpl({
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
      '/history-offline-game/save-offline-history',
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
  Future<OfflineHistoryModel> getOfflineHistory(String id) async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null) {
      throw ApiException('No access token found');
    }

    final response = await httpClient.get<Map<String, dynamic>>(
      '/history-offline-game/get-offline-history/$id',
      headers: {'Authorization': 'Bearer $accessToken'},
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
      '/history-offline-game/get-offline-histories?$queryString',
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(response.message);
    }

    return OfflineHistoriesResponseModel.fromJson(response.data!);
  }
}
