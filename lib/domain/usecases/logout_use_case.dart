import '../repositories/auth_repository.dart';

/// Logout use case
class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<Result<void>> call() async {
    return await _authRepository.logout();
  }
}
