/// Storage-agnostic auth delegate.
///
/// Implement this in your app (e.g. using SharedPreferences, Hive, SecureStorage,
/// or any other persistence layer) and pass it to [MobileApiClient].
///
/// ## Multi-company token storage
///
/// Company tokens are keyed by [companyId], allowing users to switch between
/// multiple companies without logging out. Your storage implementation should
/// store tokens per-company, e.g.:
///
/// ```dart
/// Future<String?> getCompanyAccessToken(String companyId) async {
///   return _storage.read(key: 'company_${companyId}_access_token');
/// }
/// ```
abstract class MobileApiAuthHandler {
  // ── Identity token (no company context) ────────────────────────────────────

  /// Returns the stored identity access token, or `null` if not available.
  Future<String?> getIdentityAccessToken();

  /// Returns the stored identity refresh token, or `null` if not available.
  Future<String?> getIdentityRefreshToken();

  /// Called after a successful identity token refresh.
  ///
  /// Persist [accessToken] and [refreshToken] in your storage.
  Future<void> onIdentityTokenRefreshed({
    required String accessToken,
    required String refreshToken,
  });

  // ── Company token (company-scoped session) ──────────────────────────────────

  /// Returns the stored company access token for [companyId], or `null` if not available.
  ///
  /// Store tokens per-company using [companyId] as part of the key.
  Future<String?> getCompanyAccessToken(String companyId);

  /// Returns the stored company refresh token for [companyId], or `null` if not available.
  ///
  /// Store tokens per-company using [companyId] as part of the key.
  Future<String?> getCompanyRefreshToken(String companyId);

  /// Called after a successful company token refresh for [companyId].
  ///
  /// Persist [accessToken] and [refreshToken] keyed by [companyId].
  Future<void> onCompanyTokenRefreshed({
    required String companyId,
    required String accessToken,
    required String refreshToken,
  });

  // ── Session termination ─────────────────────────────────────────────────────

  /// Called when the identity session is terminated (logout or irrecoverable 401).
  ///
  /// Clear all stored tokens and navigate to the login screen.
  Future<void> onLoggedOut();

  /// Called when the company session for [companyId] is terminated.
  ///
  /// Clear stored company tokens for [companyId] and navigate to the
  /// company-selection screen.
  Future<void> onCompanyLoggedOut(String companyId);
}
