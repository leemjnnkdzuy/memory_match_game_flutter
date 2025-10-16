import '../data/models/user_model.dart';
import '../services/request_service.dart';
import '../services/user_local_storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static AuthService get instance => _instance;

  User? _currentUser;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      final requestService = RequestService.instance;
      final loginResult = await requestService.login(
        username: username,
        password: password,
      );

      if (loginResult.isSuccess && loginResult.data != null) {
        final profileResult = await requestService.getProfile();

        if (profileResult.isSuccess && profileResult.data != null) {
          _currentUser = profileResult.data!;
          _isLoggedIn = true;
          await UserLocalStorageService.saveUser(_currentUser!);
        } else {
          _currentUser = loginResult.data!;
          _isLoggedIn = true;
          await UserLocalStorageService.saveUser(_currentUser!);
        }
      } else {
        throw Exception(loginResult.error ?? 'Login failed');
      }
    } catch (e) {
      _currentUser = null;
      _isLoggedIn = false;
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final requestService = RequestService.instance;
      await requestService.logout();
    } catch (e) {
      throw Exception('Logout failed');
    }

    _currentUser = null;
    _isLoggedIn = false;
    await UserLocalStorageService.clearUser();
  }

  Future<void> loginAsGuest() async {
    _currentUser = const User(
      id: 'guest',
      username: 'Guest',
      email: '',
      firstName: 'Guest',
      lastName: 'User',
      isActive: true,
    );
    _isLoggedIn = true;
    await UserLocalStorageService.saveUser(_currentUser!);
  }

  bool get isRealUser => _isLoggedIn && (_currentUser?.id != 'guest');

  Future<void> initialize() async {
    try {
      final localUser = await UserLocalStorageService.loadUser();
      if (localUser != null) {
        _currentUser = localUser;
        _isLoggedIn = true;
      }

      final requestService = RequestService.instance;

      if (await requestService.isLoggedIn()) {
        final currentUser = await requestService.getCurrentUser();
        if (currentUser != null) {
          _currentUser = currentUser;
          _isLoggedIn = true;
          await UserLocalStorageService.saveUser(_currentUser!);
        }
      } else {
        if (_currentUser == null) {
          await UserLocalStorageService.clearUser();
        }
      }
    } catch (e) {
      _currentUser = null;
      _isLoggedIn = false;
      await UserLocalStorageService.clearUser();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    final requestService = RequestService.instance;
    final result = await requestService.updateProfile(profileData);

    if (result.isSuccess && result.data != null) {
      _currentUser = result.data!;
      await UserLocalStorageService.saveUser(_currentUser!);
    } else {
      throw Exception(result.error ?? 'Update profile failed');
    }
  }

  Future<void> updateUser(User user) async {
    _currentUser = user;
    await UserLocalStorageService.saveUser(_currentUser!);
  }

  Future<bool> updateAvatar(String avatarBase64) async {
    try {
      final requestService = RequestService.instance;
      final result = await requestService.updateProfile({
        'avatar': avatarBase64,
      });

      if (result.isSuccess && result.data != null) {
        _currentUser = result.data!;
        await UserLocalStorageService.saveUser(_currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
