import '../common/minimal_employee.dart';
import '../common/request_status.dart';
import 'leave.dart';

/// Submission type for leave requests.
enum LeaveSubmissionType {
  /// Self-submitted by employee.
  selfRequested('self_requested'),

  /// Manager submitted on behalf of employee.
  managerSubmitted('manager_submitted');

  const LeaveSubmissionType(this.value);

  final String value;

  static LeaveSubmissionType fromString(String value) {
    return LeaveSubmissionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LeaveSubmissionType.selfRequested,
    );
  }
}

/// Leave request entry.
class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.leaveId,
    required this.startDate,
    required this.endDate,
    this.days,
    this.description,
    this.notes,
    this.isNoReason,
    this.submissionType,
    this.status,
    this.leave,
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
  final String leaveId;
  final DateTime startDate;
  final DateTime endDate;
  final int? days;
  final String? description;
  final String? notes;
  final bool? isNoReason;
  final LeaveSubmissionType? submissionType;
  final RequestStatus? status;
  final Leave? leave;
  final String? approvalRequestId;
  final MinimalEmployee? employee;
  final String? requesterEmployeeId;
  final MinimalEmployee? requesterEmployee;
  final LeaveRequestMetadata? metadata;
  final Map<String, dynamic>? approvalRequest;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      employeeId: json['employee_id'] as String,
      leaveId: json['leave_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      days: json['days'] as int?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      isNoReason: json['is_no_reason'] as bool?,
      submissionType: json['submission_type'] != null
          ? LeaveSubmissionType.fromString(json['submission_type'] as String)
          : null,
      status: json['status'] != null
          ? RequestStatus.fromString(json['status'] as String)
          : null,
      leave: json['leave'] != null
          ? Leave.fromJson(json['leave'] as Map<String, dynamic>)
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
          ? LeaveRequestMetadata.fromJson(
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

/// Metadata for a leave request (photos, attachments).
class LeaveRequestMetadata {
  const LeaveRequestMetadata({
    this.leaveRequestId,
    this.frontPhotoUrl,
    this.additionalPhotos,
    this.attachmentsUrls,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  final String? leaveRequestId;
  final String? frontPhotoUrl;
  final List<String>? additionalPhotos;
  final List<String>? attachmentsUrls;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory LeaveRequestMetadata.fromJson(Map<String, dynamic> json) {
    return LeaveRequestMetadata(
      leaveRequestId: json['leave_request_id'] as String?,
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
