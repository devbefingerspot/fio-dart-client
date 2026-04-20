import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/approval/approval_action_request.dart';
import '../models/approval/approval_action_response.dart';
import '../models/approval/approval_request.dart';
import '../models/approval/list_approvals_params.dart';
import '../models/common/paginated_response.dart';

/// Provides "my approvals" operations against the mobile backend.
///
/// Returns approval requests where the authenticated employee is listed as
/// an approver. All shown regardless of current stage (monitoring view).
///
/// Obtain this via [MobileApiClient.myApprovals].
class MyApprovalsService {
  MyApprovalsService({
    required Dio backendDio,
  }) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/my-approvals
  ///
  /// Returns a paginated list of approval requests where the authenticated
  /// employee is an approver.
  ///
  /// By default, only PENDING requests are returned. Use
  /// [ListApprovalsParams.status] = "all" for all statuses, or specify
  /// specific statuses like "PENDING,APPROVED".
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<ApprovalRequest>> list([
    ListApprovalsParams? params,
  ]) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/my-approvals',
        queryParameters: params?.toQueryParameters(),
      );
      return PaginatedResponse.fromJson(
        response.data!,
        ApprovalRequest.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/my-approvals/{id}
  ///
  /// Returns detailed information about a specific approval request,
  /// including all stages and approvers.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<ApprovalRequest> detail(String id) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/my-approvals/$id',
      );
      return ApprovalRequest.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/my-approvals/{id}/act
  ///
  /// Approves or rejects an approval request.
  ///
  /// [id] The approval request ID.
  /// [request] The action to take (approve/reject with optional notes and
  ///   geolocation).
  ///
  /// Returns:
  /// - `status: "approved"` — Final stage approved, request is complete.
  /// - `status: "rejected"` — Request rejected, all remaining approvers skipped.
  /// - `status: "advanced_to_next_stage"` — Stage approved, more stages remain.
  ///
  /// Throws [ApiError] on any non-2xx response:
  /// - 400: Invalid action or wrong stage_id.
  /// - 403: Not a pending approver for this stage.
  /// - 404: Request not found.
  Future<ApprovalActionResponse> act(
    String id,
    ApprovalActionRequest request,
  ) async {
    try {
      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/my-approvals/$id/act',
        data: request.toJson(),
      );
      return ApprovalActionResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
