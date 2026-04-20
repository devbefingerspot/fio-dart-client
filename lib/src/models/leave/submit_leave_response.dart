import 'leave_request.dart';

/// Response from submitting a leave request.
class SubmitLeaveResponse {
  const SubmitLeaveResponse({
    required this.leaveRequest,
    this.metadata,
    this.approvalRequest,
  });

  final LeaveRequest leaveRequest;
  final LeaveRequestMetadata? metadata;
  final Map<String, dynamic>? approvalRequest;

  factory SubmitLeaveResponse.fromJson(Map<String, dynamic> json) {
    return SubmitLeaveResponse(
      leaveRequest:
          LeaveRequest.fromJson(json['leave_request'] as Map<String, dynamic>),
      metadata: json['metadata'] != null
          ? LeaveRequestMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>)
          : null,
      approvalRequest: json['approval_request'] as Map<String, dynamic>?,
    );
  }
}
