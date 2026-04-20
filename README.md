# fio_backend_client

A storage-agnostic Dart client for the **Fingerspot.io** API.

Handles the full mobile authentication flow — login → list companies → issue company token — with automatic silent token refresh, single-flight refresh locking, and typed response models. Works in any Dart environment (Flutter, CLI, etc.).

---

## Features

- **Typed API** — strongly-typed request/response models for every endpoint; no manual JSON parsing required.
- **Storage-agnostic** — token storage and session logic are delegated to your app via `MobileApiAuthHandler` (Hive, SharedPreferences, FlutterSecureStorage — your choice).
- **Multi-company token model** — a single user can be logged into multiple companies simultaneously; tokens are stored and retrieved per `companyId`.
- **Automatic token refresh** — transparently refreshes tokens on HTTP 401 and retries the original request.
- **Single-flight refresh lock** — concurrent 401s all wait on the same `Future`; the refresh endpoint is hit exactly once.
- **Rich error type** — every failure throws `ApiError` with a parsed `message`, optional `code`, raw `details`, and the original `DioException` in `cause`.
- **Runtime-mutable backend URL** — switch the backend base URL at runtime (e.g. per-company URL from the company list).
- **Escape hatch** — direct access to the backend `Dio` instance via `rawBackendClient`.
- **JWT claim parsing** — decode any fio JWT into a typed `FioJwtClaims` model (no signature verification; for client-side reads only).

### Included services

| Service | Purpose |
|---------|---------|
| `auth` | Login, logout, issue company token |
| `user` | Get profile, list companies |
| `integrity` | Device integrity challenges (Play Integrity, App Attest) |
| `gpsAttendance` | GPS attendance settings and submission |
| `myAttendance` | Current user's attendance logs (paginated) |
| `employeeAttendance` | All employee attendance logs (admin view) |
| `employees` | Employee list and detail |
| `overtime` | Overtime requests: list/submit/review |
| `leave` | Leave requests: active leaves, submit, balance, review |
| `myApprovals` | Pending approvals for the current user |
| `invitations` | Company invitations: list/accept/decline |

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

  // ── Company tokens (per companyId) ──────────────────────────────

  @override
  Future<String?> getCompanyAccessToken(String companyId) =>
      _storage.read(key: 'company_access_token_$companyId');

  @override
  Future<String?> getCompanyRefreshToken(String companyId) =>
      _storage.read(key: 'company_refresh_token_$companyId');

  @override
  Future<void> onCompanyTokenRefreshed({
    required String companyId,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'company_access_token_$companyId', value: accessToken);
    await _storage.write(key: 'company_refresh_token_$companyId', value: refreshToken);
  }

  // ── Session termination ──────────────────────────────────────────

  @override
  Future<void> onLoggedOut() async {
    await _storage.deleteAll();
    // Navigate to login screen
  }

  @override
  Future<void> onCompanyLoggedOut(String companyId) async {
    await _storage.delete(key: 'company_access_token_$companyId');
    await _storage.delete(key: 'company_refresh_token_$companyId');
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

After the user selects a company, set it as current and issue a company-scoped token.

```dart
final selected = companies.first;

// Point the backend client at this company's URL and store the companyId
client.setBackendBaseUrl(selected.baseUrl);
client.setCurrentCompany(selected.id);

final response = await client.auth.issueCompanyToken(
  IssueCompanyTokenRequest(
    companyId: selected.id,
    role: selected.role,
    deviceUniqueIdentifier: 'device-uuid-here',
    fcmToken: 'fcm-token-here',
  ),
);

// Persist the company tokens — handler stores them keyed by companyId
await myHandler.onCompanyTokenRefreshed(
  companyId: selected.id,
  accessToken: response.accessToken,
  refreshToken: response.refreshToken,
);
```

### Switch between companies

If the user has tokens for multiple companies, switch context by calling:

```dart
client.setBackendBaseUrl(otherCompany.baseUrl);
client.setCurrentCompany(otherCompany.id);
// All subsequent company-scoped calls now use company B's token
```

To clear the company context (back to identity-only mode):

```dart
client.clearCurrentCompany();
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

## More usage examples

### GPS attendance

```dart
// Get GPS settings for the current company
final settings = await client.gpsAttendance.getGpsSettings();
print('Radius: ${settings.radius}m');

// Submit GPS check-in
final result = await client.gpsAttendance.submit(SubmitGpsAttendanceRequest(
  type: AttendanceType.checkIn,
  latitude: -6.200000,
  longitude: 106.816666,
  photo: 'base64-encoded-jpeg',
));
print('Submitted at ${result.time}');
```

### My attendance history

```dart
// List current user's attendance (paginated)
final page = await client.myAttendance.list(ListAttendanceParams(
  page: 1,
  limit: 20,
  dateFrom: DateTime(2025, 1, 1),
  dateTo: DateTime(2025, 1, 31),
));
print('Total records: ${page.meta.total}');
for (final log in page.data) {
  print('${log.date}: ${log.type}');
}
```

### Employees

```dart
// List employees
final employees = await client.employees.list(ListEmployeesParams(page: 1, limit: 50));

// Get detail
final detail = await client.employees.getDetail(employees.data.first.id);
print('${detail.name} — ${detail.position}');
```

### Overtime requests

```dart
// List overtime types
final types = await client.overtime.listMasters();

// Submit overtime request
final res = await client.overtime.submit(SubmitOvertimeRequest(
  overtimeTypeId: types.first.id,
  date: DateTime.now(),
  startTime: '18:00',
  endTime: '21:00',
  description: 'Client delivery',
));
print('Request ID: ${res.id}');
```

### Leave requests

```dart
// Submit leave request
final res = await client.leave.submit(SubmitLeaveRequest(
  submissionType: LeaveSubmissionType.leave,
  leaveTypeId: 'lt_uuid',
  startDate: DateTime(2025, 2, 1),
  endDate: DateTime(2025, 2, 3),
  notes: 'Family event',
));

// Check leave balance
final balance = await client.leave.getBalance();
```

### Approvals

```dart
// List pending approvals for current user
final pending = await client.myApprovals.list(ListApprovalsParams(
  status: ApproverStatus.pending,
));

// Approve a request
await client.myApprovals.approve(ApprovalActionRequest(
  requestId: pending.data.first.id,
  stage: pending.data.first.currentStage,
));
```

### Company invitations

```dart
// List invitations
final invites = await client.invitations.list();

// Accept an invitation
await client.invitations.accept(invites.first.id);
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
| `integrity` | `IntegrityService` — device integrity challenges |
| `gpsAttendance` | `GpsAttendanceService` — GPS attendance settings and submission |
| `myAttendance` | `MyAttendanceService` — current user's attendance logs |
| `employeeAttendance` | `EmployeeAttendanceService` — all employee attendance (admin) |
| `employees` | `EmployeeService` — employee list and detail |
| `overtime` | `OvertimeService` — overtime requests |
| `leave` | `LeaveService` — leave requests and balance |
| `myApprovals` | `MyApprovalsService` — pending approvals |
| `invitations` | `InvitationService` — company invitations |
| `setBackendBaseUrl(url)` | Change the backend base URL at runtime |
| `backendBaseUrl` | Current backend base URL |
| `setCurrentCompany(id)` | Set the current company context (for per-company token lookup) |
| `clearCurrentCompany()` | Clear the company context |
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

### `IntegrityService`

| Method | Endpoint |
|--------|----------|
| `getChallenge()` | `GET /api/v1/integrity/challenge` |
| `attestIos(IosAttestRequest)` | `POST /api/v1/integrity/attest/ios` |

### `GpsAttendanceService`

| Method | Endpoint |
|--------|----------|
| `getGpsSettings()` | `GET /api/v1/gps-attendance/settings` |
| `submit(SubmitGpsAttendanceRequest)` | `POST /api/v1/gps-attendance/submit` |

### `MyAttendanceService`

| Method | Endpoint |
|--------|----------|
| `list(ListAttendanceParams)` | `GET /api/v1/my-attendance` |

### `EmployeeAttendanceService`

| Method | Endpoint |
|--------|----------|
| `list(ListAttendanceParams)` | `GET /api/v1/attendance` (admin view) |

### `EmployeeService`

| Method | Endpoint |
|--------|----------|
| `list(ListEmployeesParams)` | `GET /api/v1/employees` |
| `getDetail(String id)` | `GET /api/v1/employees/:id` |

### `OvertimeService`

| Method | Endpoint |
|--------|----------|
| `listMasters()` | `GET /api/v1/overtime/masters` |
| `list(ListOvertimeParams)` | `GET /api/v1/overtime/requests` |
| `submit(SubmitOvertimeRequest)` | `POST /api/v1/overtime/requests` |

### `LeaveService`

| Method | Endpoint |
|--------|----------|
| `listActive()` | `GET /api/v1/leave/active` |
| `list(ListLeaveParams)` | `GET /api/v1/leave/requests` |
| `submit(SubmitLeaveRequest)` | `POST /api/v1/leave/requests` |
| `getBalance()` | `GET /api/v1/leave/balance` |

### `MyApprovalsService`

| Method | Endpoint |
|--------|----------|
| `list(ListApprovalsParams)` | `GET /api/v1/my-approvals` |
| `approve(ApprovalActionRequest)` | `POST /api/v1/my-approvals/approve` |
| `reject(ApprovalActionRequest)` | `POST /api/v1/my-approvals/reject` |

### `InvitationService`

| Method | Endpoint |
|--------|----------|
| `list()` | `GET /api/v1/invitations` |
| `accept(String id)` | `POST /api/v1/invitations/:id/accept` |
| `decline(String id)` | `POST /api/v1/invitations/:id/decline` |

### `MobileApiAuthHandler`

| Method | When called |
|--------|-------------|
| `getIdentityAccessToken()` | Before every request on the identity Dio |
| `getIdentityRefreshToken()` | When refreshing the identity token |
| `onIdentityTokenRefreshed(accessToken, refreshToken)` | After a successful identity refresh |
| `getCompanyAccessToken(companyId)` | Before every request on the backend Dio |
| `getCompanyRefreshToken(companyId)` | When refreshing the company token |
| `onCompanyTokenRefreshed(companyId, accessToken, refreshToken)` | After a successful company refresh |
| `onLoggedOut()` | Identity session terminated (logout or irrecoverable 401) |
| `onCompanyLoggedOut(companyId)` | Company session terminated (irrecoverable company 401) |

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
