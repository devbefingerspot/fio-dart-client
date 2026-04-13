/// Response from POST /api/v1/login/mobile.
///
/// Contains identity-scoped tokens only. Use [MobileApiClient.auth.issueCompanyToken]
/// to obtain company-scoped tokens after selecting a company.
class LoginResponse {
  const LoginResponse({
    required this.message,
    required this.userId,
    required this.userName,
    this.oldUserId,
    required this.identityAccessToken,
    required this.identityAccessTokenExpiresAt,
    required this.identityRefreshToken,
    required this.identityRefreshTokenExpiresAt,
  });

  final String message;
  final String userId;
  final String userName;

  /// Legacy integer user-ID, present when migrated from the old system.
  final int? oldUserId;

  final String identityAccessToken;

  /// Unix timestamp (seconds) when [identityAccessToken] expires.
  final int identityAccessTokenExpiresAt;

  final String identityRefreshToken;

  /// Unix timestamp (seconds) when [identityRefreshToken] expires.
  final int identityRefreshTokenExpiresAt;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      oldUserId: json['old_user_id'] as int?,
      identityAccessToken: json['identity_access_token'] as String,
      identityAccessTokenExpiresAt:
          json['identity_access_token_expires_at'] as int,
      identityRefreshToken: json['identity_refresh_token'] as String,
      identityRefreshTokenExpiresAt:
          json['identity_refresh_token_expires_at'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'user_id': userId,
        'user_name': userName,
        'old_user_id': oldUserId,
        'identity_access_token': identityAccessToken,
        'identity_access_token_expires_at': identityAccessTokenExpiresAt,
        'identity_refresh_token': identityRefreshToken,
        'identity_refresh_token_expires_at': identityRefreshTokenExpiresAt,
      };
}
