import 'overtime_type.dart';

/// Request to submit an overtime request (self-submission).
class SubmitOvertimeRequest {
  const SubmitOvertimeRequest({
    required this.overtimeMasterId,
    required this.overtimeDate,
    required this.overtimeType,
    this.checkinDate,
    this.checkoutDate,
    this.description,
    this.note,
    this.durationMinutes,
  });

  /// ID of the overtime master template.
  final String overtimeMasterId;

  /// Date of the overtime (YYYY-MM-DD).
  final String overtimeDate;

  /// Type of overtime: ci_early, co_late, shift.
  final OvertimeType overtimeType;

  /// Check-in datetime (ISO 8601).
  final String? checkinDate;

  /// Check-out datetime (ISO 8601).
  final String? checkoutDate;

  /// Description of the overtime work.
  final String? description;

  /// Additional note.
  final String? note;

  /// Duration in minutes.
  final int? durationMinutes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'overtime_master_id': overtimeMasterId,
      'overtime_date': overtimeDate,
      'overtime_type': overtimeType.value,
    };
    if (checkinDate != null) map['checkin_date'] = checkinDate;
    if (checkoutDate != null) map['checkout_date'] = checkoutDate;
    if (description != null) map['description'] = description;
    if (note != null) map['note'] = note;
    if (durationMinutes != null) map['duration_minutes'] = durationMinutes;
    return map;
  }
}

/// Request to submit bulk overtime assignment (manager submitting for subordinates).
class SubmitBulkOvertimeRequest {
  const SubmitBulkOvertimeRequest({
    required this.overtimeMasterId,
    required this.overtimeDate,
    required this.overtimeType,
    required this.subordinateIds,
    this.description,
  });

  /// ID of the overtime master template.
  final String overtimeMasterId;

  /// Date of the overtime (YYYY-MM-DD).
  final String overtimeDate;

  /// Type of overtime.
  final OvertimeType overtimeType;

  /// List of subordinate employee IDs to assign overtime to.
  final List<String> subordinateIds;

  /// Description of the overtime work.
  final String? description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'overtime_master_id': overtimeMasterId,
      'overtime_date': overtimeDate,
      'overtime_type': overtimeType.value,
      'subordinate_ids': subordinateIds,
    };
    if (description != null) map['description'] = description;
    return map;
  }
}
