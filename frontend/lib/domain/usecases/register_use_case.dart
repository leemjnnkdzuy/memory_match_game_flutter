import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  Future<Result<Map<String, dynamic>>> call({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    if (username.isEmpty) {
      return Result.error('Username cannot be empty');
    }

    if (email.isEmpty) {
      return Result.error('Email cannot be empty');
    }

    if (!_isValidEmail(email)) {
      return Result.error('Invalid email format');
    }

    if (password.isEmpty) {
      return Result.error('Password cannot be empty');
    }

    if (password.length < 6) {
      return Result.error('Password must be at least 6 characters');
    }

    if (password != confirmPassword) {
      return Result.error('Passwords do not match');
    }

    if (firstName.isEmpty) {
      return Result.error('First name cannot be empty');
    }

    if (lastName.isEmpty) {
      return Result.error('Last name cannot be empty');
    }

    return await _authRepository.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
