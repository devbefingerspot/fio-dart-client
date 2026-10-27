import 'approval_status.dart';

/// Parameters for listing approval requests.
///
/// The backend interprets some fields per role:
///
/// * **Employee** — only requests where the employee is listed as an approver,
///   filtered by [status] (approver status, default `PENDING`).
/// * **Owner** — every request of the company, filtered by [requestStatus]
///   (request status, default `IN_PROGRESS`) and [employeeId] (requester).
///   [status] is ignored for an owner because an owner is not a staged approver.
class ListApprovalsParams {
  const ListApprovalsParams({
    this.page = 1,
    this.pageSize = 20,
    this.status,
    this.requestStatus,
    this.permissionType,
    this.employeeId,
    this.startDate,
    this.endDate,
  });

  /// Page number (1-indexed). Default: 1.
  final int page;

  /// Items per page. Default: 20. Max: 100.
  final int pageSize;

  /// Filter by approver status — employee only. Use "all" for all statuses.
  /// Supports comma-separated values: "PENDING,APPROVED".
  /// Default: PENDING only.
  final String? status;

  /// Filter by request status — owner only.
  ///
  /// Accepts any [ApprovalRequestStatus] value (`DRAFT`, `IN_PROGRESS`,
  /// `APPROVED`, `REJECTED`, `CANCELLED`) or `"ALL"`. When omitted the backend
  /// returns `IN_PROGRESS` requests, which is the owner's actionable queue.
  final String? requestStatus;

  /// Filter by permission type: OVERTIME, LEAVE, GPS_ATTENDANCE.
  final PermissionType? permissionType;

  /// Filter by requester — owner only.
  final String? employeeId;

  /// Filter: start date (inclusive), format: YYYY-MM-DD. Filters submitted_at.
  final String? startDate;

  /// Filter: end date (inclusive), format: YYYY-MM-DD. Filters submitted_at.
  final String? endDate;

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (status != null) map['status'] = status;
    if (requestStatus != null) map['request_status'] = requestStatus;
    if (permissionType != null) map['permission_type'] = permissionType!.value;
    if (employeeId != null) map['employee_id'] = employeeId;
    if (startDate != null) map['start_date'] = startDate;
    if (endDate != null) map['end_date'] = endDate;
    return map;
  }
}
