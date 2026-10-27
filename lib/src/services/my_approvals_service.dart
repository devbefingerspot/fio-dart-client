import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/approval/approval_action_request.dart';
import '../models/approval/approval_action_response.dart';
import '../models/approval/approval_request.dart';
import '../models/approval/list_approvals_params.dart';
import '../models/common/paginated_response.dart';

/// Provides "my approvals" operations against the mobile backend.
///
/// The same three endpoints serve two roles:
///
/// * **Employee** — requests where the authenticated employee is listed as an
///   approver. All are shown regardless of the current stage (monitoring view),
///   and [act] advances one stage at a time.
/// * **Owner** — every request of the company (an owner needs no employee
///   record), and [act] bypasses the staged flow: all pending approvers are
///   skipped and the request finalises immediately. The decision is audited and
///   returned in [ApprovalRequest.actions].
///
/// Obtain this via [MobileApiClient.myApprovals].
class MyApprovalsService {
  MyApprovalsService({
    required Dio backendDio,
  }) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/my-approvals
  ///
  /// Returns a paginated list of approval requests.
  ///
  /// Employee: only requests where the employee is an approver; defaults to
  /// PENDING approver rows. Use [ListApprovalsParams.status] = "all" for every
  /// status, or a comma-separated list like "PENDING,APPROVED".
  ///
  /// Owner: every request of the company; defaults to `IN_PROGRESS` requests.
  /// Use [ListApprovalsParams.requestStatus] (`"ALL"` for history) and
  /// [ListApprovalsParams.employeeId] to narrow by requester.
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
  /// Returns detailed information about a specific approval request, including
  /// all stages and approvers, plus [ApprovalRequest.actions] — the audit trail
  /// of decisions taken outside the staged flow.
  ///
  /// Employee: the request must list the employee as an approver, otherwise the
  /// backend answers `403`.
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
  /// Staged approver returns:
  /// - `status: "approved"` — final stage approved, request is complete.
  /// - `status: "rejected"` — request rejected, remaining approvers skipped.
  /// - `status: "pending_other_approvers"` — this stage still awaits others.
  /// - `status: "advanced_to_next_stage"` — stage approved, more stages remain.
  ///
  /// Owner returns one of the two terminal statuses with
  /// [ApprovalActionResponse.bypass] = `true`; the staged flow is skipped, so
  /// never send `stage_id` for an owner.
  ///
  /// Throws [ApiError] on any non-2xx response:
  /// - 400: Invalid action, wrong stage_id, or the request is no longer
  ///   actionable (already terminal).
  /// - 403: Not a pending approver for this stage.
  /// - 404: Request not found (or belongs to another company).
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
