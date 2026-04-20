import '../common/minimal_employee.dart';
import 'approval_stage.dart';
import 'approval_status.dart';

/// Approval request (permission request).
class ApprovalRequest {
  const ApprovalRequest({
    required this.id,
    required this.companyId,
    this.requestNumber,
    this.permissionType,
    this.templateId,
    this.requester,
    this.requestableType,
    this.requestableId,
    this.requestable,
    this.currentStageId,
    this.currentStage,
    this.status,
    this.requestData,
    this.submittedAt,
    this.completedAt,
    this.latitude,
    this.longitude,
    this.geocodedAddress,
    this.stages,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String? requestNumber;
  final PermissionType? permissionType;
  final String? templateId;
  final MinimalEmployee? requester;
  final String? requestableType;
  final String? requestableId;
  final Map<String, dynamic>? requestable;
  final String? currentStageId;
  final ApprovalStage? currentStage;
  final ApprovalRequestStatus? status;
  final Map<String, dynamic>? requestData;
  final DateTime? submittedAt;
  final DateTime? completedAt;
  final double? latitude;
  final double? longitude;
  final String? geocodedAddress;
  final List<ApprovalStage>? stages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    return ApprovalRequest(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      requestNumber: json['request_number'] as String?,
      permissionType: json['permission_type'] != null
          ? PermissionType.fromString(json['permission_type'] as String)
          : null,
      templateId: json['template_id'] as String?,
      requester: json['requester'] != null
          ? MinimalEmployee.fromJson(json['requester'] as Map<String, dynamic>)
          : null,
      requestableType: json['requestable_type'] as String?,
      requestableId: json['requestable_id'] as String?,
      requestable: json['requestable'] as Map<String, dynamic>?,
      currentStageId: json['current_stage_id'] as String?,
      currentStage: json['current_stage'] != null
          ? ApprovalStage.fromJson(
              json['current_stage'] as Map<String, dynamic>)
          : null,
      status: json['status'] != null
          ? ApprovalRequestStatus.fromString(json['status'] as String)
          : null,
      requestData: json['request_data'] as Map<String, dynamic>?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      geocodedAddress: json['geocoded_address'] as String?,
      stages: (json['stages'] as List<dynamic>?)
          ?.map((e) => ApprovalStage.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
