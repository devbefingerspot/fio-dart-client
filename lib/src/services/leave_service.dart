import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/common/paginated_response.dart';
import '../models/common/pagination_params.dart';
import '../models/leave/leave.dart';
import '../models/leave/leave_request.dart';
import '../models/leave/list_leave_params.dart';
import '../models/leave/submit_leave_request.dart';
import '../models/leave/submit_leave_response.dart';

/// Provides leave request operations against the mobile backend.
///
/// Obtain this via [MobileApiClient.leave].
class LeaveService {
  LeaveService({
    required Dio backendDio,
  }) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/leaves
  ///
  /// Returns available leave types for the company.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<Leave>> listTypes([PaginationParams? params]) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/leaves',
        queryParameters: params?.toQueryParameters(),
      );
      return PaginatedResponse.fromJson(
        response.data!,
        Leave.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/leave-requests
  ///
  /// Returns a paginated list of leave requests.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<LeaveRequest>> list([
    ListLeaveParams? params,
  ]) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/leave-requests',
        queryParameters: params?.toQueryParameters(),
      );
      return PaginatedResponse.fromJson(
        response.data!,
        LeaveRequest.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/leave-requests/{id}
  ///
  /// Returns detailed information about a specific leave request.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<LeaveRequest> detail(String id) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/leave-requests/$id',
      );
      return LeaveRequest.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/leave-requests
  ///
  /// Submits a leave request. Can be self-submission or manager
  /// submitting on behalf of subordinate (set [SubmitLeaveRequest.employeeId]).
  ///
  /// [request] The leave request details.
  /// [photos] Optional list of photos to upload.
  /// [attachments] Optional list of attachment files.
  /// [onSendProgress] Optional callback for upload progress.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<SubmitLeaveResponse> submit(
    SubmitLeaveRequest request, {
    List<MultipartFile>? photos,
    List<MultipartFile>? attachments,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final dynamic data;

      if (photos != null || attachments != null) {
        // Use multipart form for file uploads
        final formData = FormData.fromMap(request.toJson());

        if (photos != null) {
          for (final photo in photos) {
            formData.files.add(MapEntry('photos[]', photo));
          }
        }

        if (attachments != null) {
          for (final file in attachments) {
            formData.files.add(MapEntry('attachments[]', file));
          }
        }

        data = formData;
      } else {
        // Use JSON for simple requests
        data = request.toJson();
      }

      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/leave-requests',
        data: data,
        onSendProgress: onSendProgress,
      );
      return SubmitLeaveResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
