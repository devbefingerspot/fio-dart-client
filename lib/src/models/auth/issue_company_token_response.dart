/// Response from POST /api/v1/mobile/issue-company-token.
///
/// Contains company-scoped tokens. Store [accessToken] and [refreshToken]
/// via [MobileApiAuthHandler.onCompanyTokenRefreshed].
class IssueCompanyTokenResponse {
  const IssueCompanyTokenResponse({
    required this.message,
    required this.userId,
    required this.companyId,
    required this.companyName,
    required this.role,
    this.oldCompanyId,
    this.oldUserId,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  final String message;
  final String userId;
  final String companyId;
  final String companyName;

  /// `"employee"` or `"owner"`.
  final String role;

  /// Legacy integer company-ID, present when migrated from the old system.
  final int? oldCompanyId;

  /// Legacy integer user-ID, present when migrated from the old system.
  final int? oldUserId;

  final String accessToken;

  /// Unix timestamp (seconds) when [accessToken] expires.
  final int accessTokenExpiresAt;

  final String refreshToken;

  /// Unix timestamp (seconds) when [refreshToken] expires.
  final int refreshTokenExpiresAt;

  factory IssueCompanyTokenResponse.fromJson(Map<String, dynamic> json) {
    return IssueCompanyTokenResponse(
      message: json['message'] as String,
      userId: json['user_id'] as String,
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String,
      role: json['role'] as String,
      oldCompanyId: json['old_company_id'] as int?,
      oldUserId: json['old_user_id'] as int?,
      accessToken: json['access_token'] as String,
      accessTokenExpiresAt: json['access_token_expires_at'] as int,
      refreshToken: json['refresh_token'] as String,
      refreshTokenExpiresAt: json['refresh_token_expires_at'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'user_id': userId,
        'company_id': companyId,
        'company_name': companyName,
        'role': role,
        'old_company_id': oldCompanyId,
        'old_user_id': oldUserId,
        'access_token': accessToken,
        'access_token_expires_at': accessTokenExpiresAt,
        'refresh_token': refreshToken,
        'refresh_token_expires_at': refreshTokenExpiresAt,
      };
}
