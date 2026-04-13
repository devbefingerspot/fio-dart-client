import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/user/mobile_company.dart';
import '../models/user/user_info_response.dart';

/// Provides user-info operations against the auth-service.
///
/// Obtain this via [MobileApiClient.user].
class UserService {
  UserService({
    required Dio identityDio,
    required String authBaseUrl,
  })  : _identityDio = identityDio,
        _authBaseUrl = authBaseUrl;

  final Dio _identityDio;
  final String _authBaseUrl;

  /// GET /api/v1/user/me
  ///
  /// Returns the authenticated user's profile. Works with both identity and
  /// company access tokens (the interceptor attaches whichever token is
  /// configured on the identity Dio instance).
  ///
  /// [UserInfoResponse.company] and [UserInfoResponse.role] will be `null`
  /// when called with an identity token (no company context).
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<UserInfoResponse> getProfile() async {
    try {
      final response = await _identityDio.get<Map<String, dynamic>>(
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
}
