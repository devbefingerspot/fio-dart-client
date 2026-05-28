import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/user/update_user_profile_request.dart';

/// Provides user-profile update operations against the mobile backend.
///
/// Obtain this via [MobileApiClient.userProfile].
class UserProfileService {
  UserProfileService({required Dio backendDio}) : _backendDio = backendDio;

  final Dio _backendDio;

  /// POST /mobile/v1/user/update
  ///
  /// Updates the authenticated user's display name and/or profile photo.
  /// At least one field in [request] must be non-null.
  ///
  /// The photo file (if provided) is uploaded server-side before being
  /// persisted — pass a [MultipartFile] in [UpdateUserProfileRequest.photo].
  ///
  /// The update applies globally to the user account across all companies.
  ///
  /// [onSendProgress] — optional upload progress callback.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<void> update(
    UpdateUserProfileRequest request, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/user/update',
        data: request.toFormData(),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
