/// Action to take on an approval.
enum ApprovalAction {
  approved('APPROVED'),
  rejected('REJECTED');

  const ApprovalAction(this.value);

  final String value;
}

/// Request to approve or reject an approval request.
///
/// Two callers are possible and they behave differently:
///
/// * **Staged approver** (employee) — [stageId] is required and must be the
///   request's active stage. The decision advances one stage; the request only
///   finalises once the last stage completes.
/// * **Owner** — the backend bypasses the staged flow: every pending approver is
///   skipped and the request finalises immediately. [stageId] is optional and
///   ignored; omit it.
class ApprovalActionRequest {
  const ApprovalActionRequest({
    required this.action,
    this.stageId,
    this.notes,
    this.latitude,
    this.longitude,
    this.geocodedAddress,
  });

  /// The current stage ID being acted upon. Required for a staged approver,
  /// ignored for an owner bypass.
  final String? stageId;

  /// Action to take: APPROVED or REJECTED.
  final ApprovalAction action;

  /// Optional notes explaining the decision.
  final String? notes;

  /// Latitude of the approver's location.
  final double? latitude;

  /// Longitude of the approver's location.
  final double? longitude;

  /// Human-readable address of the approver's location.
  final String? geocodedAddress;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'action': action.value,
    };
    if (stageId != null) map['stage_id'] = stageId;
    if (notes != null) map['notes'] = notes;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (geocodedAddress != null) map['geocoded_address'] = geocodedAddress;
    return map;
  }
}
