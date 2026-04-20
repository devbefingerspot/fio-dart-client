/// Action to take on an approval.
enum ApprovalAction {
  approved('APPROVED'),
  rejected('REJECTED');

  const ApprovalAction(this.value);

  final String value;
}

/// Request to approve or reject an approval request.
class ApprovalActionRequest {
  const ApprovalActionRequest({
    required this.stageId,
    required this.action,
    this.notes,
    this.latitude,
    this.longitude,
    this.geocodedAddress,
  });

  /// The current stage ID being acted upon.
  final String stageId;

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
      'stage_id': stageId,
      'action': action.value,
    };
    if (notes != null) map['notes'] = notes;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (geocodedAddress != null) map['geocoded_address'] = geocodedAddress;
    return map;
  }
}
