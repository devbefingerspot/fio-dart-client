import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/attendance/attendance_log.dart';
import '../models/attendance/list_attendance_params.dart';
import '../models/common/paginated_response.dart';

/// Provides employee attendance operations against the mobile backend.
///
/// Owner role: Can view all employees' attendance.
/// Non-owner role: Can only view direct subordinates' attendance.
///
/// Obtain this via [MobileApiClient.employeeAttendance].
class EmployeeAttendanceService {
  EmployeeAttendanceService({
    required Dio backendDio,
  }) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/employee-attendance
  ///
  /// Returns a paginated list of employee attendance logs.
  /// Owner: all employees; Non-owner: direct subordinates only.
  ///
  /// Use [ListAttendanceParams.employeeId] to filter by specific employee
  /// (owner-only).
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<AttendanceLog>> list([
    ListAttendanceParams? params,
  ]) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/employee-attendance',
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

  /// GET /mobile/v1/employee-attendance/{id}
  ///
  /// Returns the detail of a specific employee attendance log.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<AttendanceLog> detail(String id) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/employee-attendance/$id',
      );
      return AttendanceLog.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
