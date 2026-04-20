/// Response from iOS App Attest registration.
class IosAttestResponse {
  const IosAttestResponse({
    required this.ok,
    required this.keyId,
  });

  /// Whether the registration was successful.
  final bool ok;

  /// The registered key identifier.
  final String keyId;

  factory IosAttestResponse.fromJson(Map<String, dynamic> json) {
    return IosAttestResponse(
      ok: json['ok'] as bool,
      keyId: json['key_id'] as String,
    );
  }
}
