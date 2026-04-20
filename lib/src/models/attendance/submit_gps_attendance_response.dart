import 'attendance_log.dart';

/// Response from submitting GPS attendance.
class SubmitGpsAttendanceResponse {
  const SubmitGpsAttendanceResponse({
    required this.attendanceLog,
    this.permissionRequest,
    this.uploadToken,
    this.uploadExpiresIn,
  });

  /// The created attendance log entry.
  final AttendanceLog attendanceLog;

  /// The approval workflow request, if applicable.
  final Map<String, dynamic>? permissionRequest;

  /// Token for uploading evidence (photos/attachments). Valid for [uploadExpiresIn] seconds.
  final String? uploadToken;

  /// Duration in seconds until the upload token expires (typically 1800 = 30 minutes).
  final int? uploadExpiresIn;

  factory SubmitGpsAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return SubmitGpsAttendanceResponse(
      attendanceLog: AttendanceLog.fromJson(
          json['attendance_log'] as Map<String, dynamic>),
      permissionRequest: json['permission_request'] as Map<String, dynamic>?,
      uploadToken: json['upload_token'] as String?,
      uploadExpiresIn: json['upload_expires_in'] as int?,
    );
  }
}
