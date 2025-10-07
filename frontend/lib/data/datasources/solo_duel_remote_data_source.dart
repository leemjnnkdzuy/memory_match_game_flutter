import '../models/api_response_model.dart';
import '../models/solo_duel_history_model.dart';
import '../../core/utils/http_client_utils.dart';
import '../../services/token_storage_service.dart';

abstract class SoloDuelRemoteDataSource {
  Future<ApiResponse<SoloDuelHistoriesResponseModel>> getSoloDuelHistories({
    int page = 1,
    int limit = 10,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  });

  Future<ApiResponse<SoloDuelHistoryModel>> getSoloDuelHistory(String id);
}

class SoloDuelRemoteDataSourceImpl implements SoloDuelRemoteDataSource {
  final HttpClient _httpClient;
  final TokenStorage _tokenStorage;

  SoloDuelRemoteDataSourceImpl({
    required HttpClient httpClient,
    required TokenStorage tokenStorage,
  }) : _httpClient = httpClient,
       _tokenStorage = tokenStorage;

  Future<Map<String, String>> _getAuthHeaders() async {
    final accessToken = await _tokenStorage.getAccessToken();
    return {if (accessToken != null) 'Authorization': 'Bearer $accessToken'};
  }

  @override
  Future<ApiResponse<SoloDuelHistoriesResponseModel>> getSoloDuelHistories({
    int page = 1,
    int limit = 10,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) async {
    final queryParams = <String>[];
    queryParams.add('page=$page');
    queryParams.add('limit=$limit');
    queryParams.add('sortBy=$sortBy');
    queryParams.add('order=$order');

    if (isWin != null) {
      queryParams.add('isWin=$isWin');
    }

    final queryString = queryParams.join('&');
    final endpoint = '/solo-duel/history?$queryString';

    final headers = await _getAuthHeaders();

    return await _httpClient.get<SoloDuelHistoriesResponseModel>(
      endpoint,
      headers: headers,
      fromJson: (data) => SoloDuelHistoriesResponseModel.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<SoloDuelHistoryModel>> getSoloDuelHistory(
    String id,
  ) async {
    final headers = await _getAuthHeaders();

    return await _httpClient.get<SoloDuelHistoryModel>(
      '/solo-duel/history/$id',
      headers: headers,
      fromJson: (data) => SoloDuelHistoryModel.fromJson(data),
    );
  }
}
