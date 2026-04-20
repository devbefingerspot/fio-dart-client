import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/common/paginated_response.dart';
import '../models/employee/employee_detail.dart';
import '../models/employee/employee_list_item.dart';
import '../models/employee/list_employees_params.dart';

/// Provides employee list operations against the mobile backend.
///
/// Owner role: Can view all employees in the company.
/// Non-owner role: Can only view direct subordinates.
///
/// Obtain this via [MobileApiClient.employees].
class EmployeeService {
  EmployeeService({
    required Dio backendDio,
  }) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/employees
  ///
  /// Returns a paginated list of employees.
  /// Owner: all employees; Non-owner: direct subordinates only.
  ///
  /// Use [ListEmployeesParams.search] to filter by full_name, custom_id, or nip.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<EmployeeListItem>> list([
    ListEmployeesParams? params,
  ]) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/employees',
        queryParameters: params?.toQueryParameters(),
      );
      return PaginatedResponse.fromJson(
        response.data!,
        EmployeeListItem.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/employees/{id}
  ///
  /// Returns detailed information about a specific employee.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<EmployeeDetail> detail(String id) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/employees/$id',
      );
      return EmployeeDetail.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
