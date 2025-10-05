import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class GetProfileUseCase {
  final AuthRepository _authRepository;

  GetProfileUseCase(this._authRepository);

  Future<Result<User>> call() async {
    return await _authRepository.getProfile();
  }
}
