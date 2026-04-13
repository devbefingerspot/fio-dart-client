import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/auth/issue_company_token_request.dart';
import '../models/auth/issue_company_token_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';

/// Provides authentication operations against the auth-service.
///
/// Obtain this via [MobileApiClient.auth].
class AuthService {
  AuthService({
    required Dio plainDio,
    required Dio identityDio,
    required String authBaseUrl,
  })  : _plainDio = plainDio,
        _identityDio = identityDio,
        _authBaseUrl = authBaseUrl;

  final Dio _plainDio;
  final Dio _identityDio;
  final String _authBaseUrl;

  /// POST /api/v1/login/mobile
  ///
  /// Authenticates the user with email/phone + password and returns
  /// identity-scoped tokens. Call [issueCompanyToken] afterwards to obtain
  /// company-scoped tokens.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _plainDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/login/mobile',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/auth/logout
  ///
  /// Terminates the current session. Uses the identity Dio so the auth
  /// interceptor attaches the token automatically (middleware accepts both
  /// identity and company tokens).
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<void> logout() async {
    try {
      await _identityDio.post<void>(
        '$_authBaseUrl/api/v1/auth/logout',
        options: Options(extra: {'skipAuthRetry': true}),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/mobile/issue-company-token
  ///
  /// Issues company-scoped tokens using the identity access token. Call this
  /// after the user selects a company from the list returned by
  /// [UserService.listCompanies].
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<IssueCompanyTokenResponse> issueCompanyToken(
    IssueCompanyTokenRequest request,
  ) async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/mobile/issue-company-token',
        data: request.toJson(),
      );
      return IssueCompanyTokenResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
