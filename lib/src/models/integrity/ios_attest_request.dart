/// Request to register iOS App Attest key.
class IosAttestRequest {
  const IosAttestRequest({
    required this.keyId,
    required this.attestation,
    required this.challenge,
  });

  /// The App Attest key identifier.
  final String keyId;

  /// The attestation data from DCAppAttestService.attestKey().
  final String attestation;

  /// The challenge nonce from the integrity challenge endpoint.
  final String challenge;

  Map<String, dynamic> toJson() => {
        'key_id': keyId,
        'attestation': attestation,
        'challenge': challenge,
      };
}
