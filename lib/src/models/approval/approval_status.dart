/// Permission type for approval requests.
enum PermissionType {
  overtime('OVERTIME'),
  leave('LEAVE'),
  gpsAttendance('GPS_ATTENDANCE');

  const PermissionType(this.value);

  final String value;

  static PermissionType fromString(String value) {
    return PermissionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PermissionType.leave,
    );
  }
}

/// Status of an approval request.
enum ApprovalRequestStatus {
  draft('DRAFT'),
  inProgress('IN_PROGRESS'),
  approved('APPROVED'),
  rejected('REJECTED'),
  cancelled('CANCELLED');

  const ApprovalRequestStatus(this.value);

  final String value;

  static ApprovalRequestStatus fromString(String value) {
    return ApprovalRequestStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ApprovalRequestStatus.draft,
    );
  }
}

/// Status of an individual approver in a stage.
enum ApproverStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED'),
  skipped('SKIPPED');

  const ApproverStatus(this.value);

  final String value;

  static ApproverStatus fromString(String value) {
    return ApproverStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ApproverStatus.pending,
    );
  }
}

/// Approval rule for a stage.
enum ApprovalRule {
  /// Any one approver can approve to advance.
  any('ANY'),

  /// All approvers must approve to advance.
  all('ALL');

  const ApprovalRule(this.value);

  final String value;

  static ApprovalRule fromString(String value) {
    return ApprovalRule.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ApprovalRule.any,
    );
  }
}

/// Type of approver resolution.
enum ApproverResolvedFrom {
  employee('EMPLOYEE'),
  superior('SUPERIOR'),
  admin('ADMIN');

  const ApproverResolvedFrom(this.value);

  final String value;

  static ApproverResolvedFrom fromString(String value) {
    return ApproverResolvedFrom.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ApproverResolvedFrom.employee,
    );
  }
}
