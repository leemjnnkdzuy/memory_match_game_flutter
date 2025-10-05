import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<Result<User>> call({
    String? username,
    String? email,
    required String password,
  }) async {
    if (username == null && email == null) {
      return Result.error('Either username or email must be provided');
    }

    if (password.isEmpty) {
      return Result.error('Password cannot be empty');
    }

    return await _authRepository.login(
      username: username,
      email: email,
      password: password,
    );
  }
}
