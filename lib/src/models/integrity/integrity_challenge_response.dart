/// Response from integrity challenge endpoint.
class IntegrityChallengeResponse {
  const IntegrityChallengeResponse({
    required this.challenge,
    required this.expiresIn,
  });

  /// 64-character hex nonce for device attestation.
  /// Android: Use as requestHash for Play Integrity.
  /// iOS: Use as nonce for App Attest.
  final String challenge;

  /// Time in seconds until the challenge expires (typically 60).
  final int expiresIn;

  factory IntegrityChallengeResponse.fromJson(Map<String, dynamic> json) {
    return IntegrityChallengeResponse(
      challenge: json['challenge'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}
