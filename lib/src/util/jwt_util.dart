import 'dart:convert';

import '../models/auth/jwt_claims.dart';

/// Decodes the payload of a JWT string and returns a [FioJwtClaims] instance.
///
/// **No signature verification is performed.** Verification is the server's
/// responsibility; this function is intended only for reading claims on the
/// client (e.g. to extract `userId`, `companyId`, or check `exp`).
///
/// Returns `null` if [token] is not a valid three-part JWT or if the payload
/// cannot be decoded as JSON.
FioJwtClaims? parseJwtClaims(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    // Base64Url padding: length must be a multiple of 4
    var payload = parts[1];
    switch (payload.length % 4) {
      case 2:
        payload += '==';
      case 3:
        payload += '=';
    }

    final decoded = utf8.decode(base64Url.decode(payload));
    final json = jsonDecode(decoded);
    if (json is! Map<String, dynamic>) return null;

    return FioJwtClaims.fromJson(json);
  } catch (_) {
    return null;
  }
}
