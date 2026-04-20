import '../common/minimal_employee.dart';
import 'attendance_type.dart';

/// Attendance log entry returned in list responses.
class AttendanceLog {
  const AttendanceLog({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.attendanceType,
    required this.timestamp,
    this.timestampOriginal,
    this.method,
    this.deviceId,
    this.latitude,
    this.longitude,
    this.distanceTolerance,
    this.description,
    this.approvalRequestId,
    this.fullName,
    this.photoUrl,
    this.officeName,
    this.buildingName,
    this.departmentName,
    this.positionName,
    this.employee,
    this.metadata,
    this.approvalRequest,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String employeeId;
  final AttendanceType attendanceType;
  final DateTime timestamp;
  final DateTime? timestampOriginal;
  final AttendanceMethod? method;
  final String? deviceId;
  final double? latitude;
  final double? longitude;
  final double? distanceTolerance;
  final String? description;
  final String? approvalRequestId;
  final String? fullName;
  final String? photoUrl;
  final String? officeName;
  final String? buildingName;
  final String? departmentName;
  final String? positionName;
  final MinimalEmployee? employee;
  final AttendanceLogMetadata? metadata;
  final Map<String, dynamic>? approvalRequest;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      employeeId: json['employee_id'] as String,
      attendanceType:
          AttendanceType.fromString(json['attendance_type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      timestampOriginal: json['timestamp_original'] != null
          ? DateTime.parse(json['timestamp_original'] as String)
          : null,
      method: json['method'] != null
          ? AttendanceMethod.fromString(json['method'] as String)
          : null,
      deviceId: json['device_id'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceTolerance: (json['distance_tolerance'] as num?)?.toDouble(),
      description: json['description'] as String?,
      approvalRequestId: json['approval_request_id'] as String?,
      fullName: json['full_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      officeName: json['office_name'] as String?,
      buildingName: json['building_name'] as String?,
      departmentName: json['department_name'] as String?,
      positionName: json['position_name'] as String?,
      employee: json['employee'] != null
          ? MinimalEmployee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] != null
          ? AttendanceLogMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>)
          : null,
      approvalRequest: json['approval_request'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

/// Metadata for an attendance log entry (photos, notes, device metrics).
class AttendanceLogMetadata {
  const AttendanceLogMetadata({
    this.attendanceLogId,
    this.frontPhotoUrl,
    this.backPhotoUrls,
    this.attachmentsUrls,
    this.note,
    this.livenessMetrics,
    this.deviceMetrics,
    this.createdAt,
    this.updatedAt,
  });

  final String? attendanceLogId;
  final String? frontPhotoUrl;
  final List<String>? backPhotoUrls;
  final List<String>? attachmentsUrls;
  final String? note;
  final Map<String, dynamic>? livenessMetrics;
  final Map<String, dynamic>? deviceMetrics;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AttendanceLogMetadata.fromJson(Map<String, dynamic> json) {
    return AttendanceLogMetadata(
      attendanceLogId: json['attendance_log_id'] as String?,
      frontPhotoUrl: json['front_photo_url'] as String?,
      backPhotoUrls: (json['back_photo_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      attachmentsUrls: (json['attachments_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      note: json['note'] as String?,
      livenessMetrics: json['liveness_metrics'] as Map<String, dynamic>?,
      deviceMetrics: json['device_metrics'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
