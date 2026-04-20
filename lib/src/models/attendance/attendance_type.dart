/// Type of attendance log entry.
enum AttendanceType {
  /// Regular check-in.
  checkIn('CHECK_IN'),

  /// Regular check-out.
  checkOut('CHECK_OUT'),

  /// Break start.
  breakIn('BREAK_IN'),

  /// Break end.
  breakOut('BREAK_OUT'),

  /// Overtime check-in.
  overtimeIn('OVERTIME_IN'),

  /// Overtime check-out.
  overtimeOut('OVERTIME_OUT'),

  /// Other attendance type.
  other('OTHER');

  const AttendanceType(this.value);

  /// The string value sent to/from the API.
  final String value;

  /// Parses an attendance type string from the API.
  static AttendanceType fromString(String value) {
    return AttendanceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AttendanceType.other,
    );
  }
}

/// Method used for attendance recording.
enum AttendanceMethod {
  fingerprint('fingerprint'),
  face('face'),
  password('password'),
  card('card'),
  manual('manual'),
  vein('vein'),
  gps('gps'),
  qr('qr'),
  other('other');

  const AttendanceMethod(this.value);

  final String value;

  static AttendanceMethod fromString(String value) {
    return AttendanceMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AttendanceMethod.other,
    );
  }
}
