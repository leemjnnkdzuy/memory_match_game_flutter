import '../repositories/auth_repository.dart';
import '../auth/user.dart';

class GetProfileUseCase {
  final AuthRepository _authRepository;

  GetProfileUseCase(this._authRepository);

  Future<Result<User>> call() async {
    return await _authRepository.getProfile();
  }
}
