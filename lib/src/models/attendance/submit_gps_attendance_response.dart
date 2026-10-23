import 'attendance_log.dart';

/// Response from submitting GPS attendance.
class SubmitGpsAttendanceResponse {
  const SubmitGpsAttendanceResponse({
    required this.attendanceLog,
    this.permissionRequest,
    this.uploadToken,
    this.uploadExpiresIn,
    this.evidenceExpiresAt,
    this.replayed = false,
  });

  /// The created attendance log entry.
  final AttendanceLog attendanceLog;

  /// The approval workflow request, if applicable.
  final Map<String, dynamic>? permissionRequest;

  /// Token for uploading evidence (photos/attachments). Valid for [uploadExpiresIn] seconds.
  final String? uploadToken;

  /// Duration in seconds until the upload token expires.
  final int? uploadExpiresIn;

  /// Absolute deadline for the outstanding evidence upload.
  final DateTime? evidenceExpiresAt;

  /// True when the backend recognised [SubmitGpsAttendanceRequest
  /// .clientSubmissionId] and returned the record created by an earlier
  /// attempt (HTTP 200) instead of creating a new one.
  final bool replayed;

  factory SubmitGpsAttendanceResponse.fromJson(
    Map<String, dynamic> json, {
    bool replayed = false,
  }) {
    return SubmitGpsAttendanceResponse(
      attendanceLog: AttendanceLog.fromJson(
          json['attendance_log'] as Map<String, dynamic>),
      permissionRequest: json['permission_request'] as Map<String, dynamic>?,
      uploadToken: json['upload_token'] as String?,
      uploadExpiresIn: json['upload_expires_in'] as int?,
      evidenceExpiresAt: json['evidence_expires_at'] != null
          ? DateTime.parse(json['evidence_expires_at'] as String)
          : null,
      replayed: replayed,
    );
  }
}
