/// Request body for POST /api/v1/mobile/issue-company-token.
///
/// Must be called with a valid identity access token (see [LoginResponse]).
class IssueCompanyTokenRequest {
  const IssueCompanyTokenRequest({
    required this.companyId,
    required this.role,
    required this.deviceUniqueIdentifier,
    required this.fcmToken,
    this.userAgent,
    this.detail,
  });

  final String companyId;

  /// Must be `"employee"` or `"owner"`.
  final String role;

  /// Unique hardware/installation ID of the device.
  final String deviceUniqueIdentifier;

  /// Firebase Cloud Messaging token for push notifications.
  final String fcmToken;

  final String? userAgent;
  final String? detail;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'company_id': companyId,
      'role': role,
      'device_unique_identifier': deviceUniqueIdentifier,
      'fcm_token': fcmToken,
    };
    if (userAgent != null) map['user_agent'] = userAgent;
    if (detail != null) map['detail'] = detail;
    return map;
  }
}
