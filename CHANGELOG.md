## 0.1.7

### New features

* **`Leave.attachment`** — added `FieldRequirementStatus? attachment` field (JSON: `attachment`) matching the existing `frontPhoto`/`additionalPhoto`/`note` pattern. Indicates whether an attachment is `optional`, `required`, or `hidden` for a given leave type.
* **`OvertimeMaster.attachment`** — added `FieldRequirementStatus? attachment` field (JSON: `attachment`) to `OvertimeMaster`, following the same tri-state pattern as the other media fields.

---

## 0.1.6

### New features

* **`GpsSettingsResponse`** — added two new fields:
  * `maxAttachmentNumber int` (JSON: `max_attachment_number`) — maximum number of file attachments per GPS attendance record.
  * `maxAdditionalPhotoNumber int` (JSON: `max_additional_photo_number`) — maximum number of additional photos per GPS attendance record (defaults to `3` when absent).
* **`GpsSettingsResponse.fromJson`** — `maxAttachmentNumber` falls back to the deprecated `gps_max_attachment_number` key for compatibility with older server versions.

### Deprecated

* **`GpsSettingsResponse.gpsMaxAttachmentNumber`** — deprecated in favour of `maxAttachmentNumber`. The getter still works and delegates to `maxAttachmentNumber`.

---

## 0.1.5

### ⚠ Breaking changes

* **`UpdateUserProfileRequest`** — `photoUrl String?` field removed; replaced with `photo MultipartFile?`.
  The request is now sent as `multipart/form-data` instead of JSON.
  The backend uploads the file and derives the URL server-side.

  **Migration guide:**
  ```dart
  // Before
  client.userProfile.update(UpdateUserProfileRequest(photoUrl: 'https://...'));

  // After
  client.userProfile.update(UpdateUserProfileRequest(
    photo: MultipartFile.fromFileSync('/path/to/photo.jpg', filename: 'photo.jpg'),
  ));
  ```

* **`UserProfileService.update()`** — now accepts an optional `onSendProgress` named parameter.

### New features

* **`UserProfileService`** (`client.userProfile`) — update the authenticated user's display name and/or profile photo.
  * `update(UpdateUserProfileRequest, { ProgressCallback? onSendProgress })` → `Future<void>` — `POST /mobile/v1/user/update` multipart
* **`UpdateUserProfileRequest`** model — `name String?`, `photo MultipartFile?`; at least one must be non-null.
* **`FaceRegistryService`** (`client.faceRegistry`) — manage face-recognition photos per employee.
  * `get({ String? targetEmployeeId })` → `Future<FaceRegistryResponse>` — `GET /mobile/v1/face-registry`
  * `register({ required MultipartFile image, String? targetEmployeeId, String? metadata, ProgressCallback? onSendProgress })` → `Future<FaceRegistryResponse>` — `POST /mobile/v1/face-registry` multipart
* **`FaceRegistryRecord`** model — `id`, `userId`, `companyId?`, `photoUrl`, `metadata?`, `createdAt`, `updatedAt`.
* **`FaceRegistryResponse`** model — `companyRecord FaceRegistryRecord?`, `userOnlyRecord FaceRegistryRecord?`.

---

## 0.1.4

### New features

* **`UserService.getProfile`** — added optional `tokenType` parameter to choose which access token to use:
  * `UserProfileTokenType.identity` (default) — uses the identity access token; `UserInfoResponse.company` and `UserInfoResponse.role` will be `null`.
  * `UserProfileTokenType.company` — uses the currently selected company's access token (via `setCurrentCompany`); response includes company and role information.
* **`UserProfileTokenType` enum** exported from `fio_backend_client.dart` (via `user_service.dart`).

  ```dart
  // Identity context (default, unchanged)
  final me = await client.user.getProfile();

  // Company context — requires setCurrentCompany() to have been called
  final meWithCompany = await client.user.getProfile(
    tokenType: UserProfileTokenType.company,
  );
  ```

---

## 0.1.3

### New features

* **`GpsSettingsResponse`** — added two new fields to reflect attachment settings from the server:
  * `gpsAttachment FieldRequirementStatus` (JSON: `gps_attachment`) — requirement status for file attachments in GPS attendance.
  * `gpsMaxAttachmentNumber int` (JSON: `gps_max_attachment_number`) — maximum number of file attachments allowed per GPS attendance record (defaults to `5` when absent).

### Fixes

* **`GpsAttendanceService.uploadEvidence`** — normalized multipart field names for multi-file uploads to match backend parser expectations:
  * `back_photos[]` -> `back_photos`
  * `attachments[]` -> `attachments`

---

## 0.1.2

### ⚠ Breaking changes

* **`FieldRequirementStatus` enum** — `OvertimeMaster`, `Leave`, and `GpsSettingsResponse` now use the tri-state `FieldRequirementStatus` enum (`optional`, `required`, `hidden`) instead of boolean flags.

  **`OvertimeMaster`** — removed `isPhotoRequired bool?` and `isNoteRequired bool?`; replaced with:
  * `frontPhoto FieldRequirementStatus?` (JSON: `front_photo`)
  * `additionalPhoto FieldRequirementStatus?` (JSON: `additional_photo`)
  * `note FieldRequirementStatus?` (JSON: `note`)

  **`Leave`** — removed `isPhotoRequired bool?` and `isNoteRequired bool?`; replaced with:
  * `frontPhoto FieldRequirementStatus?` (JSON: `front_photo`)
  * `additionalPhoto FieldRequirementStatus?` (JSON: `additional_photo`)
  * `note FieldRequirementStatus?` (JSON: `note`)

  **`GpsSettingsResponse`** — removed `isGpsFrontPhotoRequired bool`, `isGpsAdditionalPhotoRequired bool`, `isGpsNoteRequired bool`; replaced with:
  * `gpsFrontPhoto FieldRequirementStatus` (JSON: `gps_front_photo`)
  * `gpsAdditionalPhoto FieldRequirementStatus` (JSON: `gps_additional_photo`)
  * `gpsNote FieldRequirementStatus` (JSON: `gps_note`)

  **Migration guide** — update your conditional checks:
  ```dart
  // Before
  if (master.isPhotoRequired == true) { ... }
  if (settings.isGpsFrontPhotoRequired) { ... }

  // After
  if (master.frontPhoto == FieldRequirementStatus.required) { ... }
  if (settings.gpsFrontPhoto == FieldRequirementStatus.required) { ... }

  // To hide a field entirely
  if (master.note == FieldRequirementStatus.hidden) { ... }
  ```

### New features

* **`FieldRequirementStatus` enum** exported from `fio_backend_client.dart` (via `overtime_master.dart`). Available values: `FieldRequirementStatus.optional`, `FieldRequirementStatus.required`, `FieldRequirementStatus.hidden`.
* **`Leave.allowMobileRequest`** (`bool?`) — added to reflect whether mobile leave requests are permitted for this leave type.

---

## 0.1.1

### New features

* Added optional request/response logging using `pretty_dio_logger`.
* Added `enableLogging` parameter in `MobileApiClient` (default: `false`).

---

## 0.1.0

### ⚠ Breaking changes

* **Multi-company token architecture** — `MobileApiAuthHandler` methods now require a `companyId` parameter:
  * `getCompanyAccessToken(String companyId)` — was `getCompanyAccessToken()`
  * `getCompanyRefreshToken(String companyId)` — was `getCompanyRefreshToken()`
  * `onCompanyTokenRefreshed({companyId, accessToken, refreshToken})` — added `companyId`
  * `onCompanyLoggedOut(String companyId)` — was `onCompanyLoggedOut()`
  
  Update your handler implementation to store/retrieve tokens keyed by `companyId`.

### New features

* **`MobileApiClient` multi-company methods**:
  * `setCurrentCompany(String companyId)` — set the company context for token lookup
  * `clearCurrentCompany()` — clear the company context

* **9 new services** added to `MobileApiClient`:
  * `integrity` — device integrity challenges (Play Integrity, App Attest)
  * `gpsAttendance` — GPS attendance settings and submission
  * `myAttendance` — current user's attendance history (paginated)
  * `employeeAttendance` — all employee attendance logs (admin view)
  * `employees` — employee list and detail
  * `overtime` — overtime master types, list/submit requests
  * `leave` — active leaves, list/submit requests, balance check
  * `myApprovals` — pending approvals with approve/reject actions
  * `invitations` — company invitation list/accept/decline

* **28 new models** for request/response types:
  * Common: `PaginationMeta`, `PaginatedResponse`, `PaginationParams`, `MinimalUser`, `MinimalEmployee`, `RequestStatus`
  * Attendance: `AttendanceType`, `AttendanceLog`, `GpsSettingsResponse`, `SubmitGpsAttendanceRequest`, `SubmitGpsAttendanceResponse`, `ListAttendanceParams`
  * Employee: `EmployeeListItem`, `EmployeeDetail`, `ListEmployeesParams`
  * Overtime: `OvertimeType`, `OvertimeMaster`, `OvertimeRequest`, `SubmitOvertimeRequest`, `SubmitOvertimeResponse`, `ListOvertimeParams`
  * Leave: `Leave`, `LeaveRequest`, `SubmitLeaveRequest`, `SubmitLeaveResponse`, `ListLeaveParams`, `LeaveSubmissionType`
  * Approval: `ApprovalStatus`, `ApprovalStage`, `ApprovalRequest`, `ApprovalActionRequest`, `ApprovalActionResponse`, `ListApprovalsParams`, `PermissionType`, `ApproverStatus`
  * Integrity: `IntegrityChallengeResponse`, `IosAttestRequest`, `IosAttestResponse`
  * Invitation: `CompanyInvitation`

* **Typed enums** for safer code:
  * `AttendanceType` — `checkIn`, `checkOut`, `breakStart`, `breakEnd`
  * `OvertimeType` — typed overtime categories
  * `LeaveSubmissionType` — `leave`, `permission`, `sick`
  * `PermissionType` — `overtime`, `leave`, `permission`, `sick`
  * `ApproverStatus` — `pending`, `approved`, `rejected`
  * `RequestStatus` — `pending`, `approved`, `rejected`, `cancelled`

---

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
