import '../common/minimal_employee.dart';
import '../common/request_status.dart';
import 'overtime_master.dart';
import 'overtime_type.dart';

/// Overtime request entry.
class OvertimeRequest {
  const OvertimeRequest({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.overtimeDate,
    this.checkinDate,
    this.checkoutDate,
    this.overtimeType,
    this.submissionType,
    this.compensation,
    this.beforeShiftDuration,
    this.afterShiftDuration,
    this.shiftDuration,
    this.breakDuration,
    this.totalDuration,
    this.description,
    this.isBackDate,
    this.status,
    this.overtimeMasterId,
    this.overtimeMaster,
    this.approvalRequestId,
    this.employee,
    this.requesterEmployeeId,
    this.requesterEmployee,
    this.metadata,
    this.approvalRequest,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String employeeId;
  final DateTime overtimeDate;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;
  final OvertimeType? overtimeType;
  final OvertimeSubmissionType? submissionType;
  final String? compensation;
  final int? beforeShiftDuration;
  final int? afterShiftDuration;
  final int? shiftDuration;
  final int? breakDuration;
  final int? totalDuration;
  final String? description;
  final bool? isBackDate;
  final RequestStatus? status;
  final String? overtimeMasterId;
  final OvertimeMaster? overtimeMaster;
  final String? approvalRequestId;
  final MinimalEmployee? employee;
  final String? requesterEmployeeId;
  final MinimalEmployee? requesterEmployee;
  final OvertimeRequestMetadata? metadata;
  final Map<String, dynamic>? approvalRequest;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OvertimeRequest.fromJson(Map<String, dynamic> json) {
    return OvertimeRequest(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      employeeId: json['employee_id'] as String,
      overtimeDate: DateTime.parse(json['overtime_date'] as String),
      checkinDate: json['checkin_date'] != null
          ? DateTime.parse(json['checkin_date'] as String)
          : null,
      checkoutDate: json['checkout_date'] != null
          ? DateTime.parse(json['checkout_date'] as String)
          : null,
      overtimeType: json['overtime_type'] != null
          ? OvertimeType.fromString(json['overtime_type'] as String)
          : null,
      submissionType: json['submission_type'] != null
          ? OvertimeSubmissionType.fromString(json['submission_type'] as String)
          : null,
      compensation: json['compensation'] as String?,
      beforeShiftDuration: json['before_shift_duration'] as int?,
      afterShiftDuration: json['after_shift_duration'] as int?,
      shiftDuration: json['shift_duration'] as int?,
      breakDuration: json['break_duration'] as int?,
      totalDuration: json['total_duration'] as int?,
      description: json['description'] as String?,
      isBackDate: json['is_back_date'] as bool?,
      status: json['status'] != null
          ? RequestStatus.fromString(json['status'] as String)
          : null,
      overtimeMasterId: json['overtime_master_id'] as String?,
      overtimeMaster: json['overtime_master'] != null
          ? OvertimeMaster.fromJson(
              json['overtime_master'] as Map<String, dynamic>)
          : null,
      approvalRequestId: json['approval_request_id'] as String?,
      employee: json['employee'] != null
          ? MinimalEmployee.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      requesterEmployeeId: json['requester_employee_id'] as String?,
      requesterEmployee: json['requester_employee'] != null
          ? MinimalEmployee.fromJson(
              json['requester_employee'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] != null
          ? OvertimeRequestMetadata.fromJson(
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

/// Metadata for an overtime request (photos, notes).
class OvertimeRequestMetadata {
  const OvertimeRequestMetadata({
    this.overtimeRequestId,
    this.frontPhotoUrl,
    this.additionalPhotos,
    this.attachmentsUrls,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  final String? overtimeRequestId;
  final String? frontPhotoUrl;
  final List<String>? additionalPhotos;
  final List<String>? attachmentsUrls;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OvertimeRequestMetadata.fromJson(Map<String, dynamic> json) {
    return OvertimeRequestMetadata(
      overtimeRequestId: json['overtime_request_id'] as String?,
      frontPhotoUrl: json['front_photo_url'] as String?,
      additionalPhotos: (json['additional_photos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      attachmentsUrls: (json['attachments_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
