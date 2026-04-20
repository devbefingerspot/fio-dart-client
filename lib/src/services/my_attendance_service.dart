import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/attendance/attendance_log.dart';
import '../models/attendance/list_attendance_params.dart';
import '../models/common/paginated_response.dart';

/// Provides "my attendance" operations against the mobile backend.
///
/// Returns attendance logs for the authenticated employee.
///
/// Obtain this via [MobileApiClient.myAttendance].
class MyAttendanceService {
  MyAttendanceService({
    required Dio backendDio,
  }) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/my-attendance
  ///
  /// Returns a paginated list of the authenticated employee's attendance logs.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<AttendanceLog>> list([
    ListAttendanceParams? params,
  ]) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/my-attendance',
        queryParameters: params?.toQueryParameters(),
      );
      return PaginatedResponse.fromJson(
        response.data!,
        AttendanceLog.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/my-attendance/{id}
  ///
  /// Returns the detail of a specific attendance log.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<AttendanceLog> detail(String id) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/my-attendance/$id',
      );
      return AttendanceLog.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
