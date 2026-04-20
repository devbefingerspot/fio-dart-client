import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/common/paginated_response.dart';
import '../models/common/pagination_params.dart';
import '../models/overtime/list_overtime_params.dart';
import '../models/overtime/overtime_master.dart';
import '../models/overtime/overtime_request.dart';
import '../models/overtime/submit_overtime_request.dart';
import '../models/overtime/submit_overtime_response.dart';

/// Provides overtime request operations against the mobile backend.
///
/// Obtain this via [MobileApiClient.overtime].
class OvertimeService {
  OvertimeService({
    required Dio backendDio,
  }) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/overtime-request-masters
  ///
  /// Returns available overtime master templates for the company.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<OvertimeMaster>> listMasters([
    PaginationParams? params,
  ]) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/overtime-request-masters',
        queryParameters: params?.toQueryParameters(),
      );
      return PaginatedResponse.fromJson(
        response.data!,
        OvertimeMaster.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/overtime-requests
  ///
  /// Returns a paginated list of overtime requests.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<OvertimeRequest>> list([
    ListOvertimeParams? params,
  ]) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/overtime-requests',
        queryParameters: params?.toQueryParameters(),
      );
      return PaginatedResponse.fromJson(
        response.data!,
        OvertimeRequest.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/overtime-requests/{id}
  ///
  /// Returns detailed information about a specific overtime request.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<OvertimeRequest> detail(String id) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/overtime-requests/$id',
      );
      return OvertimeRequest.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/overtime-requests
  ///
  /// Submits an overtime request for self.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<SubmitOvertimeResponse> submit(SubmitOvertimeRequest request) async {
    try {
      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/overtime-requests',
        data: request.toJson(),
      );
      return SubmitOvertimeResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/overtime-requests
  ///
  /// Submits bulk overtime assignment for subordinates (manager only).
  /// Master type must be manager_assigned_*.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<SubmitBulkOvertimeResponse> submitBulk(
    SubmitBulkOvertimeRequest request,
  ) async {
    try {
      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/overtime-requests',
        data: request.toJson(),
      );
      return SubmitBulkOvertimeResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
