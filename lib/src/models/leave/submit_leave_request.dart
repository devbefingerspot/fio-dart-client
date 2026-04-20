/// Request to submit a leave request.
class SubmitLeaveRequest {
  const SubmitLeaveRequest({
    required this.leaveId,
    required this.startDate,
    required this.endDate,
    this.employeeId,
    this.note,
    this.isNoReason,
  });

  /// ID of the leave type.
  final String leaveId;

  /// Start date (YYYY-MM-DD).
  final String startDate;

  /// End date (YYYY-MM-DD).
  final String endDate;

  /// Employee ID (required when manager submits on behalf of subordinate).
  final String? employeeId;

  /// Additional note.
  final String? note;

  /// Whether to submit without providing a reason.
  final bool? isNoReason;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'leave_id': leaveId,
      'start_date': startDate,
      'end_date': endDate,
    };
    if (employeeId != null) map['employee_id'] = employeeId;
    if (note != null) map['note'] = note;
    if (isNoReason != null) map['is_no_reason'] = isNoReason;
    return map;
  }
}
