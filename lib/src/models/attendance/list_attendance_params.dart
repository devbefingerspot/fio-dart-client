import 'attendance_type.dart';
import 'office_radius_status.dart';

/// Parameters for listing attendance logs.
///
/// Multi-select filters are sent as repeated query parameters, e.g.
/// `?attendance_type=CHECK_IN&attendance_type=CHECK_OUT`.
class ListAttendanceParams {
  const ListAttendanceParams({
    this.page = 1,
    this.pageSize = 20,
    this.startDate,
    this.endDate,
    this.attendanceTypes = const [],
    this.methods = const [],
    this.officeRadiusStatuses = const [],
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

  /// Filter by one or more attendance types.
  final List<AttendanceType> attendanceTypes;

  /// Filter by one or more capture methods (fingerprint, gps, face, …).
  final List<AttendanceMethod> methods;

  /// Filter GPS records by office radius outcome. Non-GPS records never match.
  final List<OfficeRadiusStatus> officeRadiusStatuses;

  /// Filter by employee ID (owner-only for employee-attendance endpoint).
  final String? employeeId;

  /// Deprecated: use [attendanceTypes].
  @Deprecated('Use attendanceTypes instead.')
  AttendanceType? get attendanceType =>
      attendanceTypes.length == 1 ? attendanceTypes.first : null;

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (startDate != null) map['start_date'] = startDate;
    if (endDate != null) map['end_date'] = endDate;
    if (attendanceTypes.isNotEmpty) {
      map['attendance_type'] =
          attendanceTypes.map((e) => e.value).toList(growable: false);
    }
    if (methods.isNotEmpty) {
      map['method'] = methods.map((e) => e.value).toList(growable: false);
    }
    if (officeRadiusStatuses.isNotEmpty) {
      map['office_radius_status'] =
          officeRadiusStatuses.map((e) => e.value).toList(growable: false);
    }
    if (employeeId != null) map['employee_id'] = employeeId;
    return map;
  }
}
