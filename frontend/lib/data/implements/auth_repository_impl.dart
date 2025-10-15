import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../domain/auth/session.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../services/token_storage_service.dart';
import '../../core/error/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  @override
  Future<Result<Map<String, dynamic>>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
      );

      if (response.success) {
        return Result.success(response.data ?? {});
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<User>> login({
    String? username,
    String? email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        username: username,
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        await _tokenStorage.saveTokens(
          accessToken: response.data!.accessToken,
          refreshToken: response.data!.refreshToken,
          accessTokenExpiresAt: response.data!.accessTokenExpiresAt,
          refreshTokenExpiresAt: response.data!.refreshTokenExpiresAt,
        );

        return Result.success(response.data!.user);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<void>> verifyEmail({required String code}) async {
    try {
      final response = await _remoteDataSource.verifyEmail(code: code);

      if (response.success) {
        return Result.success(null);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<bool>> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        return Result.error('No refresh token available');
      }

      final response = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );

      if (response.success && response.data != null) {
        await _tokenStorage.saveTokens(
          accessToken: response.data!['accessToken'],
          refreshToken: response.data!['refreshToken'],
          accessTokenExpiresAt: response.data!['accessTokenExpiresAt'],
          refreshTokenExpiresAt: response.data!['refreshTokenExpiresAt'],
        );

        return Result.success(true);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<void>> forgotPassword({required String email}) async {
    try {
      final response = await _remoteDataSource.forgotPassword(email: email);

      if (response.success) {
        return Result.success(null);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<String>> verifyResetPin({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _remoteDataSource.verifyResetPin(
        email: email,
        code: code,
      );

      if (response.success && response.data != null) {
        return Result.success(response.data!['resetToken']);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String password,
    required String confirmPassword,
    required String resetToken,
  }) async {
    try {
      final response = await _remoteDataSource.resetPassword(
        password: password,
        confirmPassword: confirmPassword,
        resetToken: resetToken,
      );

      if (response.success) {
        return Result.success(null);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

      if (response.success) {
        return Result.success(null);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<User>> getProfile() async {
    try {
      if (await _tokenStorage.isAccessTokenExpired()) {
        final refreshResult = await refreshToken();
        if (!refreshResult.isSuccess) {
          return Result.error('Authentication failed');
        }
      }

      final response = await _remoteDataSource.getProfile();

      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<User>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      if (await _tokenStorage.isAccessTokenExpired()) {
        final refreshResult = await refreshToken();
        if (!refreshResult.isSuccess) {
          return Result.error('Authentication failed');
        }
      }

      final response = await _remoteDataSource.updateProfile(profileData);

      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<User>> getPublicUser(String idOrUsername) async {
    try {
      final response = await _remoteDataSource.getPublicUser(idOrUsername);

      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken != null) {
        await _remoteDataSource.logout(refreshToken: refreshToken);
      }

      await _tokenStorage.clearTokens();
      return Result.success(null);
    } catch (e) {
      await _tokenStorage.clearTokens();
      return Result.success(null);
    }
  }

  @override
  Future<Result<void>> logoutAll() async {
    try {
      await _remoteDataSource.logoutAll();
      await _tokenStorage.clearTokens();
      return Result.success(null);
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<List<Session>>> getActiveSessions() async {
    try {
      final response = await _remoteDataSource.getActiveSessions();

      if (response.success && response.data != null) {
        final sessions = response.data!
            .map((session) => session.toEntity())
            .toList();
        return Result.success(sessions);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<void>> revokeSession(String sessionId) async {
    try {
      final response = await _remoteDataSource.revokeSession(sessionId);

      if (response.success) {
        return Result.success(null);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<bool>> checkUsernameExists(String username) async {
    try {
      final response = await _remoteDataSource.checkUsernameExists(username);

      if (response.success && response.data != null) {
        return Result.success(response.data!['exists'] ?? false);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<User>> changeUsername({required String newUsername}) async {
    try {
      if (await _tokenStorage.isAccessTokenExpired()) {
        final refreshResult = await refreshToken();
        if (!refreshResult.isSuccess) {
          return Result.error('Authentication failed');
        }
      }

      final response = await _remoteDataSource.changeUsername(
        newUsername: newUsername,
      );

      if (response.success && response.data != null) {
        final userData = response.data!['user'] as Map<String, dynamic>;
        return Result.success(User.fromJson(userData));
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<void>> resendVerificationEmail({required String email}) async {
    try {
      final response = await _remoteDataSource.resendVerificationEmail(
        email: email,
      );

      if (response.success) {
        return Result.success(null);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> requestChangeEmail() async {
    try {
      final response = await _remoteDataSource.requestChangeEmail();

      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> confirmChangeEmail({
    required String pin,
  }) async {
    try {
      final response = await _remoteDataSource.confirmChangeEmail(pin: pin);

      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> submitNewEmail({
    required String newEmail,
    required String changeMailAuthHashCode,
  }) async {
    try {
      final response = await _remoteDataSource.submitNewEmail(
        newEmail: newEmail,
        changeMailAuthHashCode: changeMailAuthHashCode,
      );

      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> completeChangeEmail({
    required String pin,
  }) async {
    try {
      final response = await _remoteDataSource.completeChangeEmail(pin: pin);

      if (response.success && response.data != null) {
        return Result.success(response.data!);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<void>> deactivateAccount() async {
    try {
      final response = await _remoteDataSource.deactivateAccount();

      if (response.success) {
        await _tokenStorage.clearTokens();
        return Result.success(null);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<Result<void>> reactivateAccount({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.reactivateAccount(
        email: email,
        password: password,
      );

      if (response.success) {
        return Result.success(null);
      } else {
        return Result.error(response.message);
      }
    } on ApiException catch (e) {
      return Result.error(e.message);
    } on NetworkException catch (e) {
      return Result.error(e.message);
    } catch (e) {
      return Result.error('Unexpected error: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  @override
  Future<void> clearTokens() async {
    await _tokenStorage.clearTokens();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      if (!await isLoggedIn()) return null;

      final result = await getProfile();
      return result.isSuccess ? result.data : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> loginAsGuest() async {
    throw UnimplementedError('Guest login not implemented in new API');
  }

  @override
  Future<User> updateGameStats({
    required String userId,
    required int score,
  }) async {
    throw UnimplementedError('Game stats API not implemented yet');
  }

  @override
  Future<void> deleteAccount(String userId) async {
    final result = await deactivateAccount();
    if (!result.isSuccess) {
      throw Exception(result.error);
    }
  }
}
