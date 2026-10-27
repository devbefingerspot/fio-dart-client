/// Response from an approval action.
class ApprovalActionResponse {
  const ApprovalActionResponse({
    required this.status,
    this.bypass = false,
  });

  /// Result status: `"approved"`, `"rejected"`, `"pending_other_approvers"`,
  /// or `"advanced_to_next_stage"`.
  final String status;

  /// `true` when the decision skipped the staged flow.
  ///
  /// Only an owner can trigger a bypass; the request is final immediately, so
  /// [isApproved] or [isRejected] is authoritative for that call.
  final bool bypass;

  factory ApprovalActionResponse.fromJson(Map<String, dynamic> json) {
    return ApprovalActionResponse(
      status: json['status'] as String,
      bypass: (json['bypass'] as bool?) ?? false,
    );
  }

  /// Whether the request is fully approved.
  bool get isApproved => status == 'approved';

  /// Whether the request was rejected.
  bool get isRejected => status == 'rejected';

  /// Whether the request advanced to the next stage.
  bool get isAdvanced => status == 'advanced_to_next_stage';

  /// Whether the stage is still waiting for other approvers (ALL rule).
  bool get isPendingOtherApprovers => status == 'pending_other_approvers';

  /// `true` when this decision skipped the staged approval flow.
  bool get isBypass => bypass;
}
