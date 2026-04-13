# fio_backend_client

A storage-agnostic Dart client for the **Fingerspot.io** auth-service and backend API.

Handles the full mobile authentication flow — login → list companies → issue company token — with automatic silent token refresh, single-flight refresh locking, and typed response models. Works in any Dart environment (Flutter, CLI, etc.).

---

## Features

- **Typed API** — strongly-typed request/response models for every endpoint; no manual JSON parsing required.
- **Storage-agnostic** — token storage and session logic are delegated to your app via `MobileApiAuthHandler` (Hive, SharedPreferences, FlutterSecureStorage — your choice).
- **Dual-token model** — manages identity tokens (issued at login) and company tokens (issued per selected company) independently.
- **Automatic token refresh** — transparently refreshes tokens on HTTP 401 and retries the original request.
- **Single-flight refresh lock** — concurrent 401s all wait on the same `Future`; the refresh endpoint is hit exactly once.
- **Rich error type** — every failure throws `ApiError` with a parsed `message`, optional `code`, raw `details`, and the original `DioException` in `cause`.
- **Runtime-mutable backend URL** — switch the backend base URL at runtime (e.g. per-company URL from the company list).
- **Escape hatch** — direct access to the backend `Dio` instance via `rawBackendClient`.
- **JWT claim parsing** — decode any fio JWT into a typed `FioJwtClaims` model (no signature verification; for client-side reads only).

---

## Installation

```yaml
dependencies:
  fio_backend_client:
    path: ../fio_backend_client   # or pub.dev version when published
```

---

## Getting started

### 1 — Implement `MobileApiAuthHandler`

Implement the handler in your app using whatever storage layer you prefer.

```dart
import 'package:fio_backend_client/fio_backend_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyAuthHandler implements MobileApiAuthHandler {
  final _storage = const FlutterSecureStorage();

  // ── Identity tokens ──────────────────────────────────────────────

  @override
  Future<String?> getIdentityAccessToken() =>
      _storage.read(key: 'identity_access_token');

  @override
  Future<String?> getIdentityRefreshToken() =>
      _storage.read(key: 'identity_refresh_token');

  @override
  Future<void> onIdentityTokenRefreshed({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'identity_access_token', value: accessToken);
    await _storage.write(key: 'identity_refresh_token', value: refreshToken);
  }

  // ── Company tokens ───────────────────────────────────────────────

  @override
  Future<String?> getCompanyAccessToken() =>
      _storage.read(key: 'company_access_token');

  @override
  Future<String?> getCompanyRefreshToken() =>
      _storage.read(key: 'company_refresh_token');

  @override
  Future<void> onCompanyTokenRefreshed({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'company_access_token', value: accessToken);
    await _storage.write(key: 'company_refresh_token', value: refreshToken);
  }

  // ── Session termination ──────────────────────────────────────────

  @override
  Future<void> onLoggedOut() async {
    await _storage.deleteAll();
    // Navigate to login screen
  }

  @override
  Future<void> onCompanyLoggedOut() async {
    await _storage.delete(key: 'company_access_token');
    await _storage.delete(key: 'company_refresh_token');
    // Navigate to company-selection screen
  }
}
```

### 2 — Create the client

```dart
final client = MobileApiClient(
  authBaseUrl: 'https://auth.example.com',
  backendBaseUrl: 'https://backend.example.com', // default; can be changed later
  authHandler: MyAuthHandler(),
);
```

---

## Usage

### Login

```dart
try {
  final response = await client.auth.login(
    LoginRequest(email: 'user@example.com', password: 'secret'),
  );

  // Persist the returned identity tokens via your handler
  await myHandler.onIdentityTokenRefreshed(
    accessToken: response.identityAccessToken,
    refreshToken: response.identityRefreshToken,
  );

  print('Logged in as ${response.userName}');
} on ApiError catch (e) {
  print('Login failed: ${e.message} (HTTP ${e.statusCode})');
}
```

Phone + country code variant:

```dart
final response = await client.auth.login(
  LoginRequest(phone: '81234567890', phoneCode: '+62', password: 'secret'),
);
```

### List companies

```dart
final companies = await client.user.listCompanies();

for (final company in companies) {
  print('${company.name}  role: ${company.role}  url: ${company.baseUrl}');
}
```

### Issue a company token

After the user selects a company, update the backend URL and issue a company-scoped token.

```dart
final selected = companies.first;

// Point the backend client at this company's URL
client.setBackendBaseUrl(selected.baseUrl);

final response = await client.auth.issueCompanyToken(
  IssueCompanyTokenRequest(
    companyId: selected.id,
    role: selected.role,
    deviceUniqueIdentifier: 'device-uuid-here',
    fcmToken: 'fcm-token-here',
  ),
);

// Persist the company tokens
await myHandler.onCompanyTokenRefreshed(
  accessToken: response.accessToken,
  refreshToken: response.refreshToken,
);
```

### Get user profile

```dart
final profile = await client.user.getProfile();

print('Name:  ${profile.user.name}');
print('Email: ${profile.user.email}');

if (profile.company != null) {
  print('Company: ${profile.company!.name}  Role: ${profile.role}');
}
```

### Logout

```dart
await client.auth.logout();
// onLoggedOut() is called by the interceptor — your handler handles navigation.
```

### Parse JWT claims

`parseJwtClaims` decodes the base64url payload of any fio JWT and returns a typed `FioJwtClaims` object. **No signature verification is performed** — this is purely a client-side read for display or routing logic.

```dart
// After login — read identity token claims
final claims = parseJwtClaims(loginResponse.identityAccessToken);
print(claims?.userId);     // UUID of the logged-in user
print(claims?.tokenType);  // "identity_access"
print(claims?.sid);        // session ID

// After issuing a company token — read company-scoped claims
final companyClaims = parseJwtClaims(companyTokenResponse.accessToken);
print(companyClaims?.companyId);  // UUID of the selected company
print(companyClaims?.role);       // e.g. "admin"
print(companyClaims?.platform);   // "mobile"

// Check expiry without making a network call
if (companyClaims?.isExpired ?? false) {
  // token has passed its exp timestamp
}

// Access any claim not yet modelled as a named field
print(companyClaims?.raw['custom_field']);

// Returns null for malformed / non-JWT strings
final bad = parseJwtClaims('not-a-jwt'); // null
```

---

## Error handling

Every service method throws `ApiError` on any non-2xx response.

```dart
try {
  final companies = await client.user.listCompanies();
} on ApiError catch (e) {
  print(e.message);        // human-readable message from the server
  print(e.statusCode);     // HTTP status, e.g. 401
  print(e.code);           // optional application error code
  print(e.details);        // raw response body (Map, List, or String)

  final original = e.cause as DioException?; // original DioException
}
```

---

## Token refresh behaviour

The interceptor handles 401 responses transparently:

1. The first 401 calls `POST /api/v1/auth/refresh`.
2. Any concurrent 401s **while the refresh is in-flight** await the same `Future` — the endpoint is hit exactly once.
3. The original request is retried with the new token.
4. If the refresh itself fails, `onLoggedOut()` / `onCompanyLoggedOut()` is called and all waiting callers receive an `ApiError`.

Identity and company tokens each have their own independent refresh lock.

---

## Runtime backend URL

```dart
client.setBackendBaseUrl(companies.first.baseUrl);
print(client.backendBaseUrl); // current URL
```

---

## Escape hatch — raw `Dio` access

For endpoints not yet covered by a typed service:

```dart
final response = await client.rawBackendClient.get('/api/v1/some/endpoint');
```

The instance already has the company-token refresh interceptor attached.

---

## API reference

### `MobileApiClient`

| Member | Description |
|--------|-------------|
| `auth` | `AuthService` — login, logout, issue company token |
| `user` | `UserService` — get profile, list companies |
| `setBackendBaseUrl(url)` | Change the backend base URL at runtime |
| `backendBaseUrl` | Current backend base URL |
| `rawBackendClient` | Escape hatch: the raw backend `Dio` instance |

### `AuthService`

| Method | Endpoint |
|--------|----------|
| `login(LoginRequest)` | `POST /api/v1/login/mobile` |
| `logout()` | `POST /api/v1/auth/logout` |
| `issueCompanyToken(IssueCompanyTokenRequest)` | `POST /api/v1/mobile/issue-company-token` |

### `UserService`

| Method | Endpoint |
|--------|----------|
| `getProfile()` | `GET /api/v1/user/me` |
| `listCompanies()` | `GET /api/v1/user/mobile-companies` |

### `MobileApiAuthHandler`

| Method | When called |
|--------|-------------|
| `getIdentityAccessToken()` | Before every request on the identity Dio |
| `getIdentityRefreshToken()` | When refreshing the identity token |
| `onIdentityTokenRefreshed(accessToken, refreshToken)` | After a successful identity refresh |
| `getCompanyAccessToken()` | Before every request on the backend Dio |
| `getCompanyRefreshToken()` | When refreshing the company token |
| `onCompanyTokenRefreshed(accessToken, refreshToken)` | After a successful company refresh |
| `onLoggedOut()` | Identity session terminated (logout or irrecoverable 401) |
| `onCompanyLoggedOut()` | Company session terminated (irrecoverable company 401) |

### `ApiError`

| Field | Type | Description |
|-------|------|-------------|
| `message` | `String` | Parsed from `message` or `error` field; fallback `"Request failed"` |
| `statusCode` | `int?` | HTTP status code |
| `code` | `String?` | Application-level error code from `code` field |
| `details` | `Object?` | Raw response body |
| `cause` | `Object?` | Original `DioException` |

### `parseJwtClaims(String token)` → `FioJwtClaims?`

Top-level function. Returns `null` if the string is not a valid three-part JWT or the payload cannot be decoded.

### `FioJwtClaims`

| Field | Type | JWT key | Notes |
|-------|------|---------|-------|
| `iss` | `String?` | `iss` | Issuer |
| `sub` | `String?` | `sub` | Subject (= `user_id` or `panel_user_id`) |
| `aud` | `Object?` | `aud` | Audience (string or list) |
| `iat` | `int?` | `iat` | Issued-at (Unix seconds) |
| `exp` | `int?` | `exp` | Expiry (Unix seconds) |
| `subjectType` | `String?` | `subject_type` | `"app_user"` \| `"panel_user"` |
| `userId` | `String?` | `user_id` | App-user UUID |
| `oldUserId` | `int?` | `old_user_id` | Legacy integer user ID |
| `companyId` | `String?` | `company_id` | Company UUID; empty on identity tokens |
| `oldCompanyId` | `int?` | `old_company_id` | Legacy integer company ID |
| `role` | `String?` | `role` | Role string; set on company tokens |
| `panelUserId` | `String?` | `panel_user_id` | Panel-user UUID; panel tokens only |
| `panelRoles` | `List<String>?` | `panel_roles` | Panel roles; panel tokens only |
| `platform` | `String?` | `platform` | `"new_web"` \| `"old_web"` \| `"mobile"` \| `"payment"` |
| `tokenType` | `String?` | `token_type` | `"access"` \| `"refresh"` \| `"identity_access"` \| `"identity_refresh"` \| `"otc"` |
| `sid` | `String?` | `sid` | Session ID |
| `isMobile` | `bool?` | `is_mobile` | Whether the token was issued for a mobile client |
| `raw` | `Map<String, dynamic>` | — | Full decoded payload |
| `isExpired` | `bool` | — | Computed: `true` if current time ≥ `exp` |
