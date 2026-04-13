/// Storage-agnostic auth delegate.
///
/// Implement this in your app (e.g. using SharedPreferences, Hive, SecureStorage,
/// or any other persistence layer) and pass it to [MobileApiClient].
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

  /// Returns the stored company access token, or `null` if not available.
  Future<String?> getCompanyAccessToken();

  /// Returns the stored company refresh token, or `null` if not available.
  Future<String?> getCompanyRefreshToken();

  /// Called after a successful company token refresh.
  ///
  /// Persist [accessToken] and [refreshToken] in your storage.
  Future<void> onCompanyTokenRefreshed({
    required String accessToken,
    required String refreshToken,
  });

  // ── Session termination ─────────────────────────────────────────────────────

  /// Called when the identity session is terminated (logout or irrecoverable 401).
  ///
  /// Clear all stored tokens and navigate to the login screen.
  Future<void> onLoggedOut();

  /// Called when the company session is terminated (irrecoverable company 401).
  ///
  /// Clear stored company tokens and navigate to the company-selection screen.
  Future<void> onCompanyLoggedOut();
}
