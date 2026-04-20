import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/invitation/company_invitation.dart';

/// Provides company invitation operations against the auth service.
///
/// Obtain this via [MobileApiClient.invitations].
class InvitationService {
  InvitationService({
    required Dio identityDio,
    required String authBaseUrl,
  })  : _identityDio = identityDio,
        _authBaseUrl = authBaseUrl;

  final Dio _identityDio;
  final String _authBaseUrl;

  /// GET /api/v1/user-company/invitations
  ///
  /// Returns a list of pending company invitations for the authenticated user.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<List<CompanyInvitation>> list() async {
    try {
      final response = await _identityDio.get<List<dynamic>>(
        '$_authBaseUrl/api/v1/user-company/invitations',
      );
      final list = response.data ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(CompanyInvitation.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/user-company/invitation/{invitationId}/accept
  ///
  /// Accepts a company invitation.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<void> accept(String invitationId) async {
    try {
      await _identityDio.post<void>(
        '$_authBaseUrl/api/v1/user-company/invitation/$invitationId/accept',
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/user-company/invitation/{invitationId}/reject
  ///
  /// Rejects a company invitation.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<void> reject(String invitationId) async {
    try {
      await _identityDio.post<void>(
        '$_authBaseUrl/api/v1/user-company/invitation/$invitationId/reject',
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
