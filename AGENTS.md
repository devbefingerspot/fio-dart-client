
Always write all code, comments, documentation, changelogs, and commit messages in English. Do not use Indonesian or any other language.

---

## Architecture Overview

`MobileApiClient` wraps three Dio instances:

| Instance | Auth | Token Refresh | Purpose |
|---|---|---|---|
| `_plainDio` | None | None | Login, token-refresh calls |
| `_identityDio` | Identity access token | Identity token → `/api/v1/auth/refresh` | User profile, companies, invitations |
| `_backendDio` | Company access token | Company token → `/api/v1/auth/refresh` | Attendance, leave, overtime, approvals, etc. |

**Token refresh** uses single-flight locking (`TokenRefreshLock`) — concurrent 401s share one refresh request. All errors are wrapped as `ApiError`.

Auth flow: Login → identity tokens → list companies → `setBackendBaseUrl()` → `issueCompanyToken()` → `setCurrentCompany()` → use backend services.

---

## Directory Map

```
lib/
  fio_backend_client.dart          ← barrel file (all public exports)
  src/
    mobile_api_client.dart         ← MobileApiClient class
    handler/
      mobile_api_auth_handler.dart ← storage-agnostic auth delegate interface
    interceptor/
      token_refresh_interceptor.dart
      refresh_lock.dart
    util/
      jwt_util.dart                ← parseJwtClaims() helper
    services/                      ← one file per domain
    models/                        ← one subdirectory per domain
```

---

## Sync Pattern: When Backend Adds a New Endpoint

When the backend adds a new mobile API endpoint, follow this checklist:

### 1. Identify the domain
- Auth-service endpoints → `AuthService` or `UserService` (uses `_identityDio` or `_plainDio`)
- Backend endpoints → new or existing `*Service` (uses `_backendDio`)

### 2. Create/update the model(s)
- One model file per DTO under `lib/src/models/<domain>/`
- Use `factory Model.fromJson(Map<String, dynamic> json)` for responses
- Use `Map<String, dynamic> toJson()` for request bodies
- Always annotate JSON keys explicitly: `@JsonKey(name: 'snake_case')` or manual `fromJson`/`toJson`
- Nullable fields → `?` type, omit from `toJson()` when `null`
- Enums → define in the same file as the model that owns them
- Date fields → `DateTime` type, parse with `DateTime.parse()` in `fromJson`

### 3. Create/update the service
- One service class per domain under `lib/src/services/<domain>_service.dart`
- Constructor takes the relevant Dio instances only (no global state)
- Methods return `Future<T>` and throw `ApiError` on failure
- Multipart endpoints → build `FormData` with correctly named fields

### 4. Wire into `MobileApiClient`
- Add the service property in `mobile_api_client.dart`
- Instantiate in the constructor with the correct Dio
- Add a doc comment listing its public methods

### 5. Export in the barrel file
- Add `export 'src/models/<domain>/<model>.dart'` to `fio_backend_client.dart`
- Add `export 'src/services/<service>.dart'` if it's a new service

### 6. Update CHANGELOG.md
- Add entry under `## Unreleased` or the next version header
- Follow existing format: `* **`Service.method()`** — `VERB /path`\n  Description.`

---

## Multipart Upload Pattern

When a service method sends files, build `FormData` like this:

```dart
final formData = FormData.fromMap({
  'field_name': optionalString,
  'files[]': files.map((f) => MultipartFile.fromFileSync(...)).toList(),
});
```

**Existing multipart endpoints and their field names:**

| Service | Endpoint | Fields |
|---|---|---|
| `GpsAttendanceService.uploadEvidence` | `POST .../{id}/evidence` | `front_photo` (required), `back_photos` (optional list), `attachments` (optional list), `note` (optional), header: `X-Upload-Token` |
| `LeaveService.submit` | `POST /leave-requests` | `photos[]`, `attachments[]` (optional lists) |
| `FaceRegistryService.register` | `POST /face-registry` | `image` (required), `metadata` (optional string) |
| `UserProfileService.update` | `POST /user/update` | `name` (optional), `photo` (optional) |

**Rule**: field names in `FormData` must match backend parser expectations exactly. No `[]` suffix unless the backend expects it.

---

## Enum Conventions

- Define enums in the same file as the primary model that uses them
- Use string values that match the backend's wire format exactly
- Export enums from the barrel file via the model file that defines them

```dart
enum FieldRequirementStatus {
  optional,
  required,
  hidden,
}
```

---

## Service Catalog (Quick Reference)

### Auth-Scoped (identity Dio)

| Service | Endpoints | Dio |
|---|---|---|
| `AuthService` | login, logout, issueCompanyToken, otp*, changePassword | plain + identity |
| `UserService` | getProfile, listCompanies, changeEmail, changePhone | identity + backend |
| `InvitationService` | list, accept, reject | identity |

### Backend-Scoped (company Dio)

| Service | Endpoints |
|---|---|
| `IntegrityService` | getChallenge, registerIosKey |
| `GpsAttendanceService` | getSettings, submit, uploadEvidence |
| `MyAttendanceService` | list, detail |
| `EmployeeAttendanceService` | list, detail |
| `EmployeeService` | list, detail |
| `OvertimeService` | listMasters, list, detail, submit, submitBulk |
| `LeaveService` | listTypes, list, detail, submit |
| `MyApprovalsService` | list, detail, act |
| `UserProfileService` | update (multipart) |
| `FaceRegistryService` | get, register (multipart) |
| `OfficeService` | getMyOffices |

---

## Pagination Convention

All list endpoints return `PaginatedResponse<T>` with `PaginationMeta`. Query params use `PaginationParams`:

```dart
final response = await client.overtime.list(
  ListOvertimeParams(page: 1, pageSize: 20, startDate: '2026-01-01'),
);
// response.data  → List<OvertimeRequest>
// response.meta   → PaginationMeta (page, pageSize, total, totalPage)
```

Defaults: `page=1`, `pageSize=20`, max `pageSize=100`.

---

## Subagents

if you are DeepSeek Agent, always try to use fingerspot-code/deepseek-v4-flash model for running runSubagent function.
