/// Type of overtime request.
enum OvertimeType {
  /// Early check-in (before shift starts).
  ciEarly('ci_early'),

  /// Late check-out (after shift ends).
  coLate('co_late'),

  /// Full shift overtime.
  shift('shift');

  const OvertimeType(this.value);

  final String value;

  static OvertimeType fromString(String value) {
    return OvertimeType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OvertimeType.shift,
    );
  }
}

/// Submission type for overtime requests.
enum OvertimeSubmissionType {
  /// Self-submitted by employee.
  selfRequested('self_requested'),

  /// Manager-assigned overtime.
  managerAssigned('manager_assigned');

  const OvertimeSubmissionType(this.value);

  final String value;

  static OvertimeSubmissionType fromString(String value) {
    return OvertimeSubmissionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OvertimeSubmissionType.selfRequested,
    );
  }
}
