## 0.0.1

* Initial release.
* Storage-agnostic Dio wrapper for Fingerspot.io auth-service and fio-web-desktop-backend.
* Full mobile authentication flow: login → list companies → issue company token.
* Automatic silent token refresh with single-flight refresh lock (concurrent 401s resolved by a single refresh call).
* Typed request/response models for all endpoints (`LoginRequest`, `LoginResponse`, `IssueCompanyTokenRequest`, `IssueCompanyTokenResponse`, `UserInfoResponse`, etc.).
* `MobileApiAuthHandler` interface for storage-agnostic token persistence (Hive, SharedPreferences, FlutterSecureStorage, etc.).
* `ApiError` type with parsed `message`, optional `code`, raw `details`, and original `DioException` in `cause`.
* Runtime-mutable backend base URL via `MobileApiClient.backendBaseUrl`.
* Direct access to the underlying `Dio` instance via `rawBackendClient`.
* JWT claim decoding via `FioJwtClaims` (client-side only, no signature verification).
