import 'attendance_type.dart';

/// Parameters for listing attendance logs.
class ListAttendanceParams {
  const ListAttendanceParams({
    this.page = 1,
    this.pageSize = 20,
    this.startDate,
    this.endDate,
    this.attendanceType,
    this.employeeId,
  });

  /// Page number (1-indexed). Default: 1.
  final int page;

  /// Items per page. Default: 20. Max: 100.
  final int pageSize;

  /// Filter: start date (inclusive), format: YYYY-MM-DD.
  final String? startDate;

  /// Filter: end date (inclusive), format: YYYY-MM-DD.
  final String? endDate;

  /// Filter by attendance type.
  final AttendanceType? attendanceType;

  /// Filter by employee ID (owner-only for employee-attendance endpoint).
  final String? employeeId;

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (startDate != null) map['start_date'] = startDate;
    if (endDate != null) map['end_date'] = endDate;
    if (attendanceType != null) map['attendance_type'] = attendanceType!.value;
    if (employeeId != null) map['employee_id'] = employeeId;
    return map;
  }
}
