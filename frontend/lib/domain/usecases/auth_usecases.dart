import '../entities/user_entity.dart';
import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository repository;

  AuthUseCases(this.repository);

  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    if (username.isEmpty) {
      throw Exception('Username cannot be empty');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    final result = await repository.login(
      username: username,
      password: password,
    );

    if (result.isSuccess && result.data != null) {
      return _convertToUserEntity(result.data!);
    } else {
      throw Exception(result.error ?? 'Login failed');
    }
  }

  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (username.isEmpty) {
      throw Exception('Username cannot be empty');
    }
    if (username.length < 3) {
      throw Exception('Username must be at least 3 characters');
    }
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    final result = await repository.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: '',
      lastName: '',
    );

    if (result.isSuccess) {
      final loginResult = await repository.login(
        username: username,
        password: password,
      );
      if (loginResult.isSuccess && loginResult.data != null) {
        return _convertToUserEntity(loginResult.data!);
      } else {
        throw Exception('Registration successful but login failed');
      }
    } else {
      throw Exception(result.error ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    final result = await repository.logout();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Logout failed');
    }
  }

  Future<UserEntity?> getCurrentUser() async {
    final user = await repository.getCurrentUser();
    return user != null ? _convertToUserEntity(user) : null;
  }

  Future<bool> isLoggedIn() async {
    return await repository.isLoggedIn();
  }

  Future<UserEntity> loginAsGuest() async {
    return const UserEntity(
      id: 'guest',
      username: 'Guest',
      email: 'guest@local.com',
      isGuest: true,
    );
  }

  Future<UserEntity> updateProfile({
    required String userId,
    String? username,
    String? email,
  }) async {
    if (username != null && username.isEmpty) {
      throw Exception('Username cannot be empty');
    }
    if (username != null && username.length < 3) {
      throw Exception('Username must be at least 3 characters');
    }
    if (email != null && email.isNotEmpty && !_isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }

    final profileData = <String, dynamic>{};
    if (username != null) profileData['username'] = username;
    if (email != null) profileData['email'] = email;

    final result = await repository.updateProfile(profileData);

    if (result.isSuccess && result.data != null) {
      return _convertToUserEntity(result.data!);
    } else {
      throw Exception(result.error ?? 'Profile update failed');
    }
  }

  Future<UserEntity> updateGameStats({
    required String userId,
    required int score,
  }) async {
    if (score < 0) {
      throw Exception('Score cannot be negative');
    }

    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    return currentUser.copyWith(
      gamesPlayed: currentUser.gamesPlayed + 1,
      bestScore: score > currentUser.bestScore ? score : currentUser.bestScore,
    );
  }

  Future<void> deleteAccount(String userId) async {
    final result = await repository.deactivateAccount();
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Account deletion failed');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  UserEntity _convertToUserEntity(User user) {
    return UserEntity(
      id: user.id,
      username: user.username,
      email: user.email,
      lastLogin: DateTime.now(),
      isGuest: false,
      gamesPlayed: 0,
      bestScore: 0,
    );
  }
}
