/// Response from an approval action.
class ApprovalActionResponse {
  const ApprovalActionResponse({
    required this.status,
  });

  /// Result status: "approved", "rejected", or "advanced_to_next_stage".
  final String status;

  factory ApprovalActionResponse.fromJson(Map<String, dynamic> json) {
    return ApprovalActionResponse(
      status: json['status'] as String,
    );
  }

  /// Whether the request is fully approved.
  bool get isApproved => status == 'approved';

  /// Whether the request was rejected.
  bool get isRejected => status == 'rejected';

  /// Whether the request advanced to the next stage.
  bool get isAdvanced => status == 'advanced_to_next_stage';
}
