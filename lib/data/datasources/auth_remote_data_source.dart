import '../models/api_response_model.dart';
import '../models/user_model.dart';
import '../models/login_response_model.dart';
import '../models/session_model.dart';
import '../../core/utils/http_client_utils.dart';
import '../../services/token_storage_service.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  });

  Future<ApiResponse<LoginResponseModel>> login({
    String? username,
    String? email,
    required String password,
  });

  Future<ApiResponse<void>> verifyEmail({required String code});

  Future<ApiResponse<Map<String, dynamic>>> refreshToken({
    required String refreshToken,
  });

  Future<ApiResponse<void>> forgotPassword({required String email});
  Future<ApiResponse<Map<String, dynamic>>> verifyResetPin({
    required String email,
    required String code,
  });
  Future<ApiResponse<void>> resetPassword({
    required String password,
    required String confirmPassword,
    required String resetToken,
  });
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<ApiResponse<User>> getProfile();
  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> profileData);
  Future<ApiResponse<User>> getPublicUser(String idOrUsername);

  Future<ApiResponse<void>> logout({required String refreshToken});
  Future<ApiResponse<void>> logoutAll();
  Future<ApiResponse<List<SessionModel>>> getActiveSessions();
  Future<ApiResponse<void>> revokeSession(String sessionId);

  Future<ApiResponse<Map<String, dynamic>>> checkUsernameExists(
    String username,
  );
  Future<ApiResponse<Map<String, dynamic>>> changeUsername({
    required String newUsername,
  });
  Future<ApiResponse<void>> resendVerificationEmail({required String email});

  Future<ApiResponse<Map<String, dynamic>>> requestChangeEmail();
  Future<ApiResponse<Map<String, dynamic>>> confirmChangeEmail({
    required String pin,
  });
  Future<ApiResponse<Map<String, dynamic>>> submitNewEmail({
    required String newEmail,
    required String changeMailAuthHashCode,
  });
  Future<ApiResponse<Map<String, dynamic>>> completeChangeEmail({
    required String pin,
  });

  Future<ApiResponse<void>> deactivateAccount();
  Future<ApiResponse<void>> reactivateAccount({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpClient _httpClient;
  final TokenStorage _tokenStorage;

  AuthRemoteDataSourceImpl({
    required HttpClient httpClient,
    required TokenStorage tokenStorage,
  }) : _httpClient = httpClient,
       _tokenStorage = tokenStorage;

  Future<Map<String, String>> _getAuthHeaders() async {
    final accessToken = await _tokenStorage.getAccessToken();
    return {if (accessToken != null) 'Authorization': 'Bearer $accessToken'};
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    return await _httpClient.post<Map<String, dynamic>>(
      '/users/register',
      body: {
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
  }

  @override
  Future<ApiResponse<LoginResponseModel>> login({
    String? username,
    String? email,
    required String password,
  }) async {
    assert(
      username != null || email != null,
      'Either username or email must be provided',
    );

    final body = <String, String>{'password': password};

    if (username != null) {
      body['username'] = username;
    } else {
      body['email'] = email!;
    }

    return await _httpClient.post<LoginResponseModel>(
      '/users/login',
      body: body,
      fromJson: (data) => LoginResponseModel.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<void>> verifyEmail({required String code}) async {
    return await _httpClient.post<void>('/users/verify', body: {'code': code});
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> refreshToken({
    required String refreshToken,
  }) async {
    return await _httpClient.post<Map<String, dynamic>>(
      '/users/refresh-token',
      body: {'refreshToken': refreshToken},
    );
  }

  @override
  Future<ApiResponse<void>> forgotPassword({required String email}) async {
    return await _httpClient.post<void>(
      '/users/forgot-password',
      body: {'email': email},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> verifyResetPin({
    required String email,
    required String code,
  }) async {
    return await _httpClient.post<Map<String, dynamic>>(
      '/users/verify-reset-pin',
      body: {'email': email, 'code': code},
    );
  }

  @override
  Future<ApiResponse<void>> resetPassword({
    required String password,
    required String confirmPassword,
    required String resetToken,
  }) async {
    return await _httpClient.post<void>(
      '/users/reset-password',
      body: {
        'password': password,
        'confirmPassword': confirmPassword,
        'resetToken': resetToken,
      },
    );
  }

  @override
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    return await _httpClient.post<void>(
      '/users/change-password',
      headers: await _getAuthHeaders(),
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      },
    );
  }

  @override
  Future<ApiResponse<User>> getProfile() async {
    return await _httpClient.get<User>(
      '/users/profile',
      headers: await _getAuthHeaders(),
      fromJson: (data) => User.fromJson(data['user']),
    );
  }

  @override
  Future<ApiResponse<User>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    return await _httpClient.put<User>(
      '/users/profile',
      headers: await _getAuthHeaders(),
      body: profileData,
      fromJson: (data) => User.fromJson(data['user']),
    );
  }

  @override
  Future<ApiResponse<User>> getPublicUser(String idOrUsername) async {
    return await _httpClient.get<User>(
      '/users/user/$idOrUsername',
      fromJson: (data) => User.fromJson(data['user']),
    );
  }

  @override
  Future<ApiResponse<void>> logout({required String refreshToken}) async {
    return await _httpClient.post<void>(
      '/users/logout',
      body: {'refreshToken': refreshToken},
    );
  }

  @override
  Future<ApiResponse<void>> logoutAll() async {
    return await _httpClient.post<void>(
      '/users/logout-all',
      headers: await _getAuthHeaders(),
    );
  }

  @override
  Future<ApiResponse<List<SessionModel>>> getActiveSessions() async {
    return await _httpClient.get<List<SessionModel>>(
      '/users/sessions',
      headers: await _getAuthHeaders(),
      fromJson: (data) => (data['sessions'] as List)
          .map((session) => SessionModel.fromJson(session))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<void>> revokeSession(String sessionId) async {
    return await _httpClient.delete<void>(
      '/users/sessions/$sessionId',
      headers: await _getAuthHeaders(),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> checkUsernameExists(
    String username,
  ) async {
    return await _httpClient.post<Map<String, dynamic>>(
      '/users/check-username-exist',
      body: {'username': username},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> changeUsername({
    required String newUsername,
  }) async {
    return await _httpClient.put<Map<String, dynamic>>(
      '/users/change-username',
      headers: await _getAuthHeaders(),
      body: {'newUsername': newUsername},
    );
  }

  @override
  Future<ApiResponse<void>> resendVerificationEmail({
    required String email,
  }) async {
    return await _httpClient.post<void>(
      '/users/resend-verification-email',
      body: {'email': email},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> requestChangeEmail() async {
    return await _httpClient.get<Map<String, dynamic>>(
      '/users/change-email',
      headers: await _getAuthHeaders(),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> confirmChangeEmail({
    required String pin,
  }) async {
    return await _httpClient.post<Map<String, dynamic>>(
      '/users/confirm-change-email',
      headers: await _getAuthHeaders(),
      body: {'pin': pin},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> submitNewEmail({
    required String newEmail,
    required String changeMailAuthHashCode,
  }) async {
    return await _httpClient.post<Map<String, dynamic>>(
      '/users/change-new-email',
      headers: await _getAuthHeaders(),
      body: {
        'newEmail': newEmail,
        'changeMailAuthHashCode': changeMailAuthHashCode,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> completeChangeEmail({
    required String pin,
  }) async {
    return await _httpClient.put<Map<String, dynamic>>(
      '/users/complete-change-email',
      headers: await _getAuthHeaders(),
      body: {'pin': pin},
    );
  }

  @override
  Future<ApiResponse<void>> deactivateAccount() async {
    return await _httpClient.post<void>(
      '/users/deactivate-account',
      headers: await _getAuthHeaders(),
    );
  }

  @override
  Future<ApiResponse<void>> reactivateAccount({
    required String email,
    required String password,
  }) async {
    return await _httpClient.post<void>(
      '/users/reactivate-account',
      body: {'email': email, 'password': password},
    );
  }
}
