import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/face_registry/face_registry_response.dart';

/// Provides face-registry operations against the mobile backend.
///
/// Obtain this via [MobileApiClient.faceRegistry].
class FaceRegistryService {
  FaceRegistryService({required Dio backendDio}) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/face-registry
  ///
  /// Returns the company-scoped and user-only face-registry records for the
  /// authenticated employee.
  ///
  /// [targetEmployeeId] — optional employee ID to fetch another employee's
  /// records. Only allowed when the actor has the **owner** role.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<FaceRegistryResponse> get({String? targetEmployeeId}) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/face-registry',
        queryParameters: {
          if (targetEmployeeId != null) 'target_employee_id': targetEmployeeId,
        },
      );
      return FaceRegistryResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/face-registry
  ///
  /// Registers or updates a face photo for the authenticated employee (or
  /// another employee when the actor has the **owner** role).
  ///
  /// [image] — face photo file (required).
  ///
  /// [targetEmployeeId] — optional employee ID to register a face for
  /// another employee. Only allowed for the owner role.
  ///
  /// [metadata] — arbitrary JSON string produced by a face-recognition
  /// pipeline (optional).
  ///
  /// [onSendProgress] — optional upload progress callback.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<FaceRegistryResponse> register({
    required MultipartFile image,
    String? targetEmployeeId,
    String? metadata,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': image,
        if (targetEmployeeId != null) 'target_employee_id': targetEmployeeId,
        if (metadata != null) 'metadata': metadata,
      });

      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/face-registry',
        data: formData,
        onSendProgress: onSendProgress,
      );
      return FaceRegistryResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
