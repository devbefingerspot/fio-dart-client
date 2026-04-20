import 'approval_status.dart';

/// Parameters for listing approval requests.
class ListApprovalsParams {
  const ListApprovalsParams({
    this.page = 1,
    this.pageSize = 20,
    this.status,
    this.permissionType,
    this.startDate,
    this.endDate,
  });

  /// Page number (1-indexed). Default: 1.
  final int page;

  /// Items per page. Default: 20. Max: 100.
  final int pageSize;

  /// Filter by approver status. Use "all" for all statuses.
  /// Supports comma-separated values: "PENDING,APPROVED".
  /// Default: PENDING only.
  final String? status;

  /// Filter by permission type: OVERTIME, LEAVE, GPS_ATTENDANCE.
  final PermissionType? permissionType;

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
    if (permissionType != null) map['permission_type'] = permissionType!.value;
    if (startDate != null) map['start_date'] = startDate;
    if (endDate != null) map['end_date'] = endDate;
    return map;
  }
}
