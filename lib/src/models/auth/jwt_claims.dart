/// Typed representation of the JWT payload produced by the fio auth-service.
///
/// All fields are nullable because a given token type (identity, company, panel)
/// only populates a subset of claims. Access [raw] for the full untyped map.
///
/// Use [parseJwtClaims] from `package:fio_backend_client/fio_backend_client.dart`
/// to decode a JWT string into this model — no signature verification is performed
/// (that is the server's responsibility).
class FioJwtClaims {
  const FioJwtClaims({
    // Standard claims
    this.iss,
    this.sub,
    this.aud,
    this.iat,
    this.exp,
    // fio custom claims
    this.subjectType,
    this.userId,
    this.oldUserId,
    this.companyId,
    this.oldCompanyId,
    this.role,
    this.panelUserId,
    this.panelRoles,
    this.platform,
    this.tokenType,
    this.sid,
    this.isMobile,
    required this.raw,
  });

  // ── Standard JWT claims ─────────────────────────────────────────────────────

  /// Issuer.
  final String? iss;

  /// Subject — set to `user_id` (or `panel_user_id` for panel tokens).
  final String? sub;

  /// Audience. The auth-service may emit a single string or a list of strings;
  /// stored as-is from the JSON payload.
  final Object? aud;

  /// Issued-at (Unix seconds).
  final int? iat;

  /// Expiry (Unix seconds).
  final int? exp;

  // ── fio custom claims ───────────────────────────────────────────────────────

  /// Subject type: `"app_user"` | `"panel_user"`.
  final String? subjectType;

  /// App-user UUID. Present on identity, company access/refresh, and OTC tokens.
  final String? userId;

  /// Legacy integer user ID.
  final int? oldUserId;

  /// Company UUID. Present on company access/refresh tokens; empty on identity tokens.
  final String? companyId;

  /// Legacy integer company ID.
  final int? oldCompanyId;

  /// Role string. Present on company access/refresh tokens.
  final String? role;

  /// Panel-user UUID. Present on panel tokens only.
  final String? panelUserId;

  /// Panel role list. Present on panel tokens only.
  final List<String>? panelRoles;

  /// Origin platform: `"new_web"` | `"old_web"` | `"mobile"` | `"payment"`.
  final String? platform;

  /// Token type: `"access"` | `"refresh"` | `"identity_access"` |
  /// `"identity_refresh"` | `"otc"`.
  final String? tokenType;

  /// Session ID.
  final String? sid;

  /// Whether the token was issued for a mobile client.
  final bool? isMobile;

  // ── Raw payload ─────────────────────────────────────────────────────────────

  /// Full decoded JWT payload — all claims, including any future additions not
  /// yet modelled as named fields.
  final Map<String, dynamic> raw;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Whether the token has passed its expiry time according to the local clock.
  ///
  /// Returns `false` when [exp] is null (unknown expiry).
  bool get isExpired {
    if (exp == null) return false;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp!;
  }

  factory FioJwtClaims.fromJson(Map<String, dynamic> json) {
    List<String>? panelRoles;
    final rawRoles = json['panel_roles'];
    if (rawRoles is List) {
      panelRoles = rawRoles.map((e) => e.toString()).toList();
    }

    return FioJwtClaims(
      iss: json['iss'] as String?,
      sub: json['sub'] as String?,
      aud: json['aud'],
      iat: _parseInt(json['iat']),
      exp: _parseInt(json['exp']),
      subjectType: json['subject_type'] as String?,
      userId: json['user_id'] as String?,
      oldUserId: _parseInt(json['old_user_id']),
      companyId: json['company_id'] as String?,
      oldCompanyId: _parseInt(json['old_company_id']),
      role: json['role'] as String?,
      panelUserId: json['panel_user_id'] as String?,
      panelRoles: panelRoles,
      platform: json['platform'] as String?,
      tokenType: json['token_type'] as String?,
      sid: json['sid'] as String?,
      isMobile: json['is_mobile'] as bool?,
      raw: json,
    );
  }

  static int? _parseInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
