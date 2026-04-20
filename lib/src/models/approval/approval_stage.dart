import '../common/minimal_employee.dart';
import 'approval_status.dart';

/// An approver in an approval stage.
class Approver {
  const Approver({
    required this.id,
    required this.requestId,
    required this.stageId,
    required this.approverId,
    this.approver,
    this.resolvedFrom,
    this.status,
    this.notes,
    this.actedAt,
    this.latitude,
    this.longitude,
    this.geocodedAddress,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String requestId;
  final String stageId;
  final String approverId;
  final MinimalEmployee? approver;
  final ApproverResolvedFrom? resolvedFrom;
  final ApproverStatus? status;
  final String? notes;
  final DateTime? actedAt;
  final double? latitude;
  final double? longitude;
  final String? geocodedAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Approver.fromJson(Map<String, dynamic> json) {
    return Approver(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      stageId: json['stage_id'] as String,
      approverId: json['approver_id'] as String,
      approver: json['approver'] != null
          ? MinimalEmployee.fromJson(json['approver'] as Map<String, dynamic>)
          : null,
      resolvedFrom: json['resolved_from'] != null
          ? ApproverResolvedFrom.fromString(json['resolved_from'] as String)
          : null,
      status: json['status'] != null
          ? ApproverStatus.fromString(json['status'] as String)
          : null,
      notes: json['notes'] as String?,
      actedAt: json['acted_at'] != null
          ? DateTime.parse(json['acted_at'] as String)
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      geocodedAddress: json['geocoded_address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

/// A stage in the approval workflow.
class ApprovalStage {
  const ApprovalStage({
    required this.id,
    required this.requestId,
    required this.stageId,
    this.stageOrder,
    this.stageName,
    this.approverType,
    this.approvalRule,
    this.approvers,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String requestId;
  final String stageId;
  final int? stageOrder;
  final String? stageName;
  final String? approverType;
  final ApprovalRule? approvalRule;
  final List<Approver>? approvers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ApprovalStage.fromJson(Map<String, dynamic> json) {
    return ApprovalStage(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      stageId: json['stage_id'] as String,
      stageOrder: json['stage_order'] as int?,
      stageName: json['stage_name'] as String?,
      approverType: json['approver_type'] as String?,
      approvalRule: json['approval_rule'] != null
          ? ApprovalRule.fromString(json['approval_rule'] as String)
          : null,
      approvers: (json['approvers'] as List<dynamic>?)
          ?.map((e) => Approver.fromJson(e as Map<String, dynamic>))
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
