import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/user/mobile_company.dart';
import '../models/user/user_info_response.dart';

/// Which access token to use when calling [UserService.getProfile].
enum UserProfileTokenType {
  /// Use the identity access token. [UserInfoResponse.company] and
  /// [UserInfoResponse.role] will be `null` (no company context).
  identity,

  /// Use the currently selected company's access token. The response will
  /// include company and role information.
  company,
}

/// Provides user-info operations against the auth-service.
///
/// Obtain this via [MobileApiClient.user].
class UserService {
  UserService({
    required Dio identityDio,
    required Dio backendDio,
    required String authBaseUrl,
  })  : _identityDio = identityDio,
        _backendDio = backendDio,
        _authBaseUrl = authBaseUrl;

  final Dio _identityDio;
  final Dio _backendDio;
  final String _authBaseUrl;

  /// GET /api/v1/user/me
  ///
  /// Returns the authenticated user's profile. By default the identity
  /// access token is used; pass [tokenType] = [UserProfileTokenType.company]
  /// to call the endpoint with the currently selected company's token
  /// (which causes the server to include company and role information).
  ///
  /// When [tokenType] is [UserProfileTokenType.identity],
  /// [UserInfoResponse.company] and [UserInfoResponse.role] will be `null`.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<UserInfoResponse> getProfile({
    UserProfileTokenType tokenType = UserProfileTokenType.identity,
  }) async {
    try {
      final dio = tokenType == UserProfileTokenType.company
          ? _backendDio
          : _identityDio;
      final response = await dio.get<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/user/me',
      );
      return UserInfoResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /api/v1/user/mobile-companies
  ///
  /// Returns the list of companies the user can access on mobile (roles
  /// `employee` and `owner` only; admin/subadmin are excluded by the server).
  ///
  /// Each [MobileCompany.baseUrl] is the backend URL for that company — pass
  /// it to [MobileApiClient.setBackendBaseUrl] after issuing a company token.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<List<MobileCompany>> listCompanies() async {
    try {
      final response = await _identityDio.get<List<dynamic>>(
        '$_authBaseUrl/api/v1/user/mobile-companies',
      );
      final list = response.data ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(MobileCompany.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/user/change-email
  ///
  /// Mengubah email user setelah memverifikasi OTP.
  /// OTP harus diminta terlebih dahulu via [AuthService.requestChangeEmailOTP].
  /// Syarat: email lama sudah terverifikasi (EmailVerifiedAt != nil).
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<void> changeEmail(String newEmail, String otpCode) async {
    try {
      await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/user/change-email',
        data: {
          'new_email': newEmail,
          'otp_code': otpCode,
        },
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/user/change-phone
  ///
  /// Mengubah nomor telepon user setelah memverifikasi OTP.
  /// OTP harus diminta terlebih dahulu via [AuthService.requestChangePhoneOTP].
  /// Syarat: nomor telepon lama sudah terverifikasi (PhoneVerifiedAt != nil).
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<void> changePhone(
    String newPhoneCode,
    String newPhone,
    String otpCode,
  ) async {
    try {
      await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/user/change-phone',
        data: {
          'new_phone_code': newPhoneCode,
          'new_phone': newPhone,
          'otp_code': otpCode,
        },
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
