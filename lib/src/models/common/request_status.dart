/// Status of a leave or overtime request.
enum RequestStatus {
  /// Request has been approved.
  approved('approved'),

  /// Request is pending approval.
  inApproval('in_approval'),

  /// Request has been rejected.
  rejected('rejected'),

  /// Request is in draft state.
  draft('draft'),

  /// Request was auto-approved (no approval workflow needed).
  autoApproved('auto_approved'),

  /// Request is waiting for confirmation.
  waitingConfirm('waiting_confirm');

  const RequestStatus(this.value);

  /// The string value sent to/from the API.
  final String value;

  /// Parses a status string from the API.
  static RequestStatus fromString(String value) {
    return RequestStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RequestStatus.draft,
    );
  }
}
