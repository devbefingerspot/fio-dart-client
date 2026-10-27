import 'approval_status.dart';

/// Account role that took an action outside the staged approval flow.
///
/// Mirrors the backend `user_type` of the acting account.
enum ApprovalActorRole {
  employee('employee'),
  owner('owner'),
  subadmin('subadmin'),
  admin('admin');

  const ApprovalActorRole(this.value);

  final String value;

  static ApprovalActorRole fromString(String? value) {
    return ApprovalActorRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ApprovalActorRole.employee,
    );
  }
}

/// An audited decision taken outside the staged approval flow.
///
/// The backend records one row per bypass: an owner acting from the mobile app
/// (`actorRole == ApprovalActorRole.owner`) or an admin/subadmin acting from the
/// web app. Staged approver decisions are **not** recorded here — they live on
/// [ApprovalStage.approvers], which stays the authoritative source for the
/// normal flow.
class ApprovalAuditAction {
  const ApprovalAuditAction({
    required this.id,
    required this.companyId,
    required this.requestId,
    this.stageId,
    required this.actorUserId,
    this.actorEmployeeId,
    required this.actorRole,
    required this.actorName,
    required this.action,
    required this.isBypass,
    this.notes,
    this.latitude,
    this.longitude,
    this.geocodedAddress,
    this.createdAt,
  });

  final String id;
  final String companyId;
  final String requestId;

  /// Stage that was active when the bypass happened.
  final String? stageId;

  /// User account that performed the bypass.
  final String actorUserId;

  /// Employee record of the actor, when the account is linked to one.
  final String? actorEmployeeId;

  final ApprovalActorRole actorRole;

  /// Display name of the actor, snapshotted at decision time.
  final String actorName;

  /// The decision: [ApproverStatus.approved] or [ApproverStatus.rejected].
  final ApproverStatus action;

  /// Always `true` in the current backend contract: this table only stores
  /// decisions that skipped the staged flow.
  final bool isBypass;

  final String? notes;
  final double? latitude;
  final double? longitude;
  final String? geocodedAddress;

  final DateTime? createdAt;

  factory ApprovalAuditAction.fromJson(Map<String, dynamic> json) {
    return ApprovalAuditAction(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      requestId: json['request_id'] as String,
      stageId: json['stage_id'] as String?,
      actorUserId: json['actor_user_id'] as String,
      actorEmployeeId: json['actor_employee_id'] as String?,
      actorRole: ApprovalActorRole.fromString(json['actor_role'] as String?),
      actorName: (json['actor_name'] as String?) ?? '',
      action: ApproverStatus.fromString(json['action'] as String),
      isBypass: (json['is_bypass'] as bool?) ?? false,
      notes: json['notes'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      geocodedAddress: json['geocoded_address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
