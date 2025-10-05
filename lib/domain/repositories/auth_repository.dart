import '../auth/user.dart';
import '../auth/session.dart';

class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data) : error = null, isSuccess = true;
  Result.error(this.error) : data = null, isSuccess = false;
}

abstract class AuthRepository {
  Future<Result<Map<String, dynamic>>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  });

  Future<Result<User>> login({
    String? username,
    String? email,
    required String password,
  });

  Future<Result<void>> verifyEmail({required String code});
  Future<Result<bool>> refreshToken();

  Future<Result<void>> forgotPassword({required String email});
  Future<Result<String>> verifyResetPin({
    required String email,
    required String code,
  });
  Future<Result<void>> resetPassword({
    required String password,
    required String confirmPassword,
    required String resetToken,
  });
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<Result<User>> getProfile();
  Future<Result<User>> updateProfile(Map<String, dynamic> profileData);
  Future<Result<User>> getPublicUser(String idOrUsername);

  Future<Result<void>> logout();
  Future<Result<void>> logoutAll();
  Future<Result<List<Session>>> getActiveSessions();
  Future<Result<void>> revokeSession(String sessionId);

  Future<Result<bool>> checkUsernameExists(String username);
  Future<Result<User>> changeUsername({required String newUsername});
  Future<Result<void>> resendVerificationEmail({required String email});

  Future<Result<Map<String, dynamic>>> requestChangeEmail();
  Future<Result<Map<String, dynamic>>> confirmChangeEmail({
    required String pin,
  });
  Future<Result<Map<String, dynamic>>> submitNewEmail({
    required String newEmail,
    required String changeMailAuthHashCode,
  });
  Future<Result<Map<String, dynamic>>> completeChangeEmail({
    required String pin,
  });

  Future<Result<void>> deactivateAccount();
  Future<Result<void>> reactivateAccount({
    required String email,
    required String password,
  });

  Future<bool> isLoggedIn();
  Future<void> clearTokens();
  Future<User?> getCurrentUser();

  Future<User> loginAsGuest();
  Future<User> updateGameStats({required String userId, required int score});
  Future<void> deleteAccount(String userId);
}
