import 'overtime_request.dart';

/// Response from submitting an overtime request.
class SubmitOvertimeResponse {
  const SubmitOvertimeResponse({
    required this.overtimeRequest,
    this.metadata,
    this.approvalRequest,
  });

  final OvertimeRequest overtimeRequest;
  final OvertimeRequestMetadata? metadata;
  final Map<String, dynamic>? approvalRequest;

  factory SubmitOvertimeResponse.fromJson(Map<String, dynamic> json) {
    return SubmitOvertimeResponse(
      overtimeRequest: OvertimeRequest.fromJson(
          json['overtime_request'] as Map<String, dynamic>),
      metadata: json['metadata'] != null
          ? OvertimeRequestMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>)
          : null,
      approvalRequest: json['approval_request'] as Map<String, dynamic>?,
    );
  }
}

/// Response from submitting bulk overtime assignment.
class SubmitBulkOvertimeResponse {
  const SubmitBulkOvertimeResponse({
    required this.overtimeRequests,
    this.metadatas,
    this.approvalRequests,
    required this.count,
  });

  final List<OvertimeRequest> overtimeRequests;
  final List<OvertimeRequestMetadata>? metadatas;
  final List<Map<String, dynamic>>? approvalRequests;
  final int count;

  factory SubmitBulkOvertimeResponse.fromJson(Map<String, dynamic> json) {
    return SubmitBulkOvertimeResponse(
      overtimeRequests: (json['overtime_requests'] as List<dynamic>)
          .map((e) => OvertimeRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadatas: (json['metadatas'] as List<dynamic>?)
          ?.map((e) =>
              OvertimeRequestMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      approvalRequests: (json['approval_requests'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      count: json['count'] as int,
    );
  }
}
