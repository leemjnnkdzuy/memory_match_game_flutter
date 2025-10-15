import '../core/utils/http_client_utils.dart';
import '../data/implements/http_client_impl.dart';
import 'token_storage_service.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/history_remote_data_source.dart';
import '../data/datasources/solo_duel_remote_data_source.dart';
import '../data/implements/auth_repository_impl.dart';
import '../data/implements/history_repository_impl.dart';
import '../data/implements/solo_duel_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/history_repository.dart';
import '../domain/repositories/solo_duel_repository.dart';
import '../domain/usecases/login_use_case.dart';
import '../domain/usecases/register_use_case.dart';
import '../domain/usecases/logout_use_case.dart';
import '../domain/usecases/get_profile_use_case.dart';
import '../domain/usecases/save_offline_history_use_case.dart';
import '../domain/usecases/get_history_use_case.dart';
import '../domain/usecases/get_histories_use_case.dart';
import '../domain/usecases/get_solo_duel_histories_use_case.dart';
import '../domain/usecases/get_solo_duel_history_use_case.dart';
import '../data/models/user_model.dart';
import '../domain/auth/session.dart';
import '../domain/entities/offline_history_entity.dart';
import '../domain/entities/history_entity.dart';
import '../domain/entities/solo_duel_history_entity.dart';

class RequestService {
  static RequestService? _instance;

  late final HttpClient _httpClient;
  late final TokenStorage _tokenStorage;
  late final AuthRemoteDataSource _authRemoteDataSource;
  late final HistoryRemoteDataSource _historyRemoteDataSource;
  late final SoloDuelRemoteDataSource _soloDuelRemoteDataSource;
  late final AuthRepository _authRepository;
  late final HistoryRepository _historyRepository;
  late final SoloDuelRepository _soloDuelRepository;

  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetProfileUseCase _getProfileUseCase;
  late final SaveOfflineHistoryUseCase _saveOfflineHistoryUseCase;
  late final GetHistoryUseCase _getHistoryUseCase;
  late final GetHistoriesUseCase _getHistoriesUseCase;
  late final GetSoloDuelHistoriesUseCase _getSoloDuelHistoriesUseCase;
  late final GetSoloDuelHistoryUseCase _getSoloDuelHistoryUseCase;

  RequestService._internal() {
    _initialize();
  }

  static RequestService get instance {
    _instance ??= RequestService._internal();
    return _instance!;
  }

  void _initialize() {
    _httpClient = HttpClientImpl();
    _tokenStorage = TokenStorageImpl();
    _authRemoteDataSource = AuthRemoteDataSourceImpl(
      httpClient: _httpClient,
      tokenStorage: _tokenStorage,
    );
    _historyRemoteDataSource = HistoryRemoteDataSourceImpl(
      httpClient: _httpClient,
      tokenStorage: _tokenStorage,
    );
    _soloDuelRemoteDataSource = SoloDuelRemoteDataSourceImpl(
      httpClient: _httpClient,
      tokenStorage: _tokenStorage,
    );
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      tokenStorage: _tokenStorage,
    );
    _historyRepository = HistoryRepositoryImpl(
      remoteDataSource: _historyRemoteDataSource,
    );
    _soloDuelRepository = SoloDuelRepositoryImpl(
      remoteDataSource: _soloDuelRemoteDataSource,
    );

    _loginUseCase = LoginUseCase(_authRepository);
    _registerUseCase = RegisterUseCase(_authRepository);
    _logoutUseCase = LogoutUseCase(_authRepository);
    _getProfileUseCase = GetProfileUseCase(_authRepository);
    _saveOfflineHistoryUseCase = SaveOfflineHistoryUseCase(_historyRepository);
    _getHistoryUseCase = GetHistoryUseCase(_historyRepository);
    _getHistoriesUseCase = GetHistoriesUseCase(_historyRepository);
    _getSoloDuelHistoriesUseCase = GetSoloDuelHistoriesUseCase(
      _soloDuelRepository,
    );
    _getSoloDuelHistoryUseCase = GetSoloDuelHistoryUseCase(_soloDuelRepository);
  }

  Future<void> init() async {}

  Future<Result<Map<String, dynamic>>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    return await _registerUseCase(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
    );
  }

  Future<Result<User>> login({
    String? username,
    String? email,
    required String password,
  }) async {
    return await _loginUseCase(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<Result<void>> verifyEmail({required String code}) async {
    return await _authRepository.verifyEmail(code: code);
  }

  Future<Result<void>> forgotPassword({required String email}) async {
    return await _authRepository.forgotPassword(email: email);
  }

  Future<Result<String>> verifyResetPin({
    required String email,
    required String code,
  }) async {
    return await _authRepository.verifyResetPin(email: email, code: code);
  }

  Future<Result<void>> resetPassword({
    required String password,
    required String confirmPassword,
    required String resetToken,
  }) async {
    return await _authRepository.resetPassword(
      password: password,
      confirmPassword: confirmPassword,
      resetToken: resetToken,
    );
  }

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    return await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }

  Future<Result<void>> resendVerificationEmail({required String email}) async {
    return await _authRepository.resendVerificationEmail(email: email);
  }

  Future<Result<User>> getProfile() async {
    return await _getProfileUseCase();
  }

  Future<Result<User>> updateProfile(Map<String, dynamic> profileData) async {
    return await _authRepository.updateProfile(profileData);
  }

  Future<Result<User>> getPublicUser(String idOrUsername) async {
    return await _authRepository.getPublicUser(idOrUsername);
  }

  Future<Result<void>> logout() async {
    return await _logoutUseCase();
  }

  Future<Result<void>> logoutAll() async {
    return await _authRepository.logoutAll();
  }

  Future<Result<List<Session>>> getActiveSessions() async {
    return await _authRepository.getActiveSessions();
  }

  Future<Result<void>> revokeSession(String sessionId) async {
    return await _authRepository.revokeSession(sessionId);
  }

  Future<Result<bool>> checkUsernameExists(String username) async {
    return await _authRepository.checkUsernameExists(username);
  }

  Future<Result<User>> changeUsername({required String newUsername}) async {
    return await _authRepository.changeUsername(newUsername: newUsername);
  }

  Future<Result<Map<String, dynamic>>> requestChangeEmail() async {
    return await _authRepository.requestChangeEmail();
  }

  Future<Result<Map<String, dynamic>>> confirmChangeEmail({
    required String pin,
  }) async {
    return await _authRepository.confirmChangeEmail(pin: pin);
  }

  Future<Result<Map<String, dynamic>>> submitNewEmail({
    required String newEmail,
    required String changeMailAuthHashCode,
  }) async {
    return await _authRepository.submitNewEmail(
      newEmail: newEmail,
      changeMailAuthHashCode: changeMailAuthHashCode,
    );
  }

  Future<Result<Map<String, dynamic>>> completeChangeEmail({
    required String pin,
  }) async {
    return await _authRepository.completeChangeEmail(pin: pin);
  }

  Future<Result<void>> deactivateAccount() async {
    return await _authRepository.deactivateAccount();
  }

  Future<Result<void>> reactivateAccount({
    required String email,
    required String password,
  }) async {
    return await _authRepository.reactivateAccount(
      email: email,
      password: password,
    );
  }

  Future<bool> isLoggedIn() async {
    return await _authRepository.isLoggedIn();
  }

  Future<User?> getCurrentUser() async {
    return await _authRepository.getCurrentUser();
  }

  Future<void> clearTokens() async {
    await _authRepository.clearTokens();
  }

  Future<Result<OfflineHistoryEntity>> saveOfflineHistory({
    required int score,
    required int moves,
    required int timeElapsed,
    required String difficulty,
    required bool isWin,
  }) async {
    return await _saveOfflineHistoryUseCase(
      score: score,
      moves: moves,
      timeElapsed: timeElapsed,
      difficulty: difficulty,
      isWin: isWin,
    );
  }

  // Get một history theo ID (cả offline và online)
  Future<Result<HistoryEntity>> getHistory(String id) async {
    return await _getHistoryUseCase(id);
  }

  // Get tất cả histories (cả offline và online)
  Future<Result<HistoriesResponse>> getHistories({
    int page = 1,
    int limit = 10,
    String? difficulty,
    bool? isWin,
    String? type, // 'offline', 'online', hoặc null (tất cả)
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) async {
    return await _getHistoriesUseCase(
      page: page,
      limit: limit,
      difficulty: difficulty,
      isWin: isWin,
      type: type,
      sortBy: sortBy,
      order: order,
    );
  }

  Future<Result<SoloDuelHistoriesResponse>> getSoloDuelHistories({
    int page = 1,
    int limit = 10,
    bool? isWin,
    String sortBy = 'datePlayed',
    String order = 'desc',
  }) async {
    return await _getSoloDuelHistoriesUseCase(
      page: page,
      limit: limit,
      isWin: isWin,
      sortBy: sortBy,
      order: order,
    );
  }

  Future<Result<SoloDuelHistoryEntity>> getSoloDuelHistory(String id) async {
    return await _getSoloDuelHistoryUseCase(id);
  }

  Future<Result<bool>> refreshToken() async {
    return await _authRepository.refreshToken();
  }

  void dispose() {
    (_httpClient as dynamic).dispose?.call();
  }
}
