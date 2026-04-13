/// Response from POST /api/v1/auth/refresh.
///
/// Used for both identity-token and company-token refresh — the server uses
/// the same endpoint with rotating refresh tokens.
class RefreshTokenResponse {
  const RefreshTokenResponse({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.tokenType,
  });

  final String accessToken;

  /// Unix timestamp (seconds) when [accessToken] expires.
  final int accessTokenExpiresAt;

  final String refreshToken;

  /// Unix timestamp (seconds) when [refreshToken] expires.
  final int refreshTokenExpiresAt;

  /// Always `"Bearer"`.
  final String tokenType;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['access_token'] as String,
      accessTokenExpiresAt: json['access_token_expires_at'] as int,
      refreshToken: json['refresh_token'] as String,
      refreshTokenExpiresAt: json['refresh_token_expires_at'] as int,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'access_token_expires_at': accessTokenExpiresAt,
        'refresh_token': refreshToken,
        'refresh_token_expires_at': refreshTokenExpiresAt,
        'token_type': tokenType,
      };
}
