## 0.3.0

### New features

* **`FeatureService.getMyFeatures()`** — `GET /mobile/v1/my-features`
  Returns the list of payment features granted to the authenticated employee.

* **`EmployeeFeature`** — model for a single payment feature grant.
  Fields: `itemKey`, `itemName`, `featureType`, `status`, `parentItemKey`.

* **`FeatureType`** — enum (`seat`, `usage`, `flag`, `unknown`) mirroring the
  backend's `feature_type` wire format.

### Breaking changes

* **`LocationService.listGeofences()`** — removed. Replaced by
  **`LocationService.listSpots()`** — `GET /mobile/v1/location/spots`.
  Returns active spot/checkpoint zones (previously the separate geofence
  resource).

* **`Geofence`** / **`GeofenceType`** — removed. Replaced by **`Spot`** /
  **`SpotType`** (`spot`, `guardPatrol`, `workFromHome`). The `radius_meter`
  field is now `radius`.

* **`GeofenceEvent`** / **`GeofenceEventType`** — removed. Replaced by
  **`SpotEvent`** / **`SpotEventType`**. The `geofence_id` field is now
  `spot_id`, and `SubmitPingResponse` / `SubmitBatchResponse` expose
  `spotEvents` (key `spot_events`) instead of `geofenceEvents`.

---

## 0.2.1

### New features

* **`DeviceService.getMyDevices()`** — `GET /api/v1/user/my-devices`
  Returns all registered mobile devices for the authenticated user across
  all companies. Uses the identity access token.

* **`DeviceService.createDeviceChangeRequest()`** — `POST /api/v1/device-change-request`
  Submits a request to change a mobile device. The user specifies which old
  device to replace (by its `device_id`) along with the new device details.
  The request must be reviewed and approved by a web admin before the
  device swap is executed.

* **`MyDevice`** — model for individual registered mobile devices.
  Fields: `deviceId`, `fcmToken`, `companyId`, `createdAt`.

* **`CreateDeviceChangeRequestRequest`** — request body for device change.
  Fields: `oldDeviceId`, `deviceUniqueIdentifier`, `fcmToken`, `userAgent`,
  `detail`, `companyId`.

* **`CreateDeviceChangeRequestResponse`** — response after submitting a
  device change request. Fields: `message`, `id`.

### Breaking changes

* **`AuthService.ChangeEmployeeDevice()`** — removed. The direct
  admin-forced device change endpoint has been replaced by the
  request-approval workflow (`DeviceService.createDeviceChangeRequest()`).

---

## 0.2.0
  Submits a single real-time GPS location ping with automatic geofence
  boundary-crossing detection (enter/exit events).

* **`LocationService.submitBatch()`** — `POST /mobile/v1/location/batch`
  Submits a batch of buffered location pings (max 500 per request).
  Geofence detection is performed per ping.

* **`LocationService.startSession()`** — `POST /mobile/v1/location/sessions`
  Starts a new location tracking session (periodic or trip).

* **`LocationService.updateSession()`** — `PUT /mobile/v1/location/sessions/:id`
  Pauses or completes an active location session. Optionally stores total
  distance and duration.

* **`LocationService.listSessions()`** — `GET /mobile/v1/location/sessions`
  Returns paginated list of location sessions. Self + subordinates for
  managers; all employees for owner.

* **`LocationService.getSessionDetail()`** — `GET /mobile/v1/location/sessions/:id`
  Returns a session with its paginated pings sorted by recorded time.

* **`LocationService.queryHistory()`** — `GET /mobile/v1/location/history`
  Returns paginated location ping history across a date range. Self +
  subordinates for managers; all employees for owner.

* **`LocationService.listGeofences()`** — `GET /mobile/v1/location/geofences`
  Returns all active geofence zones for the company.

* **`LocationPing`** — model for individual GPS location data points.
  Fields: lat/lng, accuracy, altitude, speed, bearing, provider, battery
  level, activity type, mock detection, recorded_at.

* **`LocationSession`** — model for location tracking sessions (periodic/trip).
  Fields: session type, status lifecycle (active/paused/completed), purpose,
  started/ended at, total distance/duration.

* **`Geofence`** — model for circular geofence zones.
  Fields: name, center lat/lng, radius, type (office/client_site/custom).

* **`GeofenceEvent`** — model for geofence boundary-crossing events.
  Fields: event type (enter/exit/dwell), linked to ping and geofence.

---

## 0.2.0

### New features

* **`AuthService.requestEmailVerificationOTP()`** — `POST /api/v1/otp/email/request`
  Sends an OTP to the user's email for email verification.
  Does not require company context.

* **`AuthService.verifyEmailOTP(code)`** — `POST /api/v1/otp/email/verify`
  Verifies the OTP code sent to email and sets `email_verified_at`.
  Does not require company context.

* **`AuthService.requestPhoneVerificationOTP()`** — `POST /api/v1/otp/phone/request`
  Sends an OTP to the user's phone number via WhatsApp for phone verification.
  Does not require company context.

* **`AuthService.verifyPhoneOTP(code)`** — `POST /api/v1/otp/phone/verify`
  Verifies the OTP code sent to phone and sets `phone_verified_at`.
  Does not require company context.

* **`OTPVerificationVerifyResponse`** — model for email/phone verification response.
  Fields: `message`, `emailVerifiedAt` (nullable), `phoneVerifiedAt` (nullable).

---

## 0.1.9

### New features

* **`OfficeService.getMyOffices()`** — `GET /mobile/v1/offices`
  Returns a list of offices based on user role:
  owner/subadmin/admin see all offices, employee only sees their own office.

* **`Office`** model — `id`, `label`, `address`, `latitude`, `longitude`,
  `wifiSsids`, `wifiMacAddresses`, `companyId`.

* **GPS auto-approval fields** — `SubmitGpsAttendanceRequest` now has
  optional `wifiSsid` and `wifiMacAddress` fields to send alongside
  GPS attendance submission. The backend will use this data for
  auto-approval if it matches the office WiFi settings.

* **`GpsSettingsResponse.gpsMaxDistanceFromOfficeMeter`** — new setting
  from the backend for maximum GPS attendance distance from office in meters.

* **`AttendanceLogMetadata`** — added `wifiSsid`, `wifiMacAddress`,
  and `distanceFromOfficeMeter` fields.

## 0.1.8

### New features

* **Change Email / Change Phone** — added full support for the new auth-service flow:

  * **`AuthService.requestChangeEmailOTP(newEmail)`** — `POST /api/v1/otp/change-email/request`
    Sends OTP to the NEW email. Requirement: old email must already be verified.

  * **`AuthService.requestChangePhoneOTP(newPhoneCode, newPhone)`** — `POST /api/v1/otp/change-phone/request`
    Sends OTP to the NEW phone number via WhatsApp. Requirement: old phone number must already be verified.

  * **`UserService.changeEmail(newEmail, otpCode)`** — `POST /api/v1/user/change-email`
    Changes email after OTP verification.

  * **`UserService.changePhone(newPhoneCode, newPhone, otpCode)`** — `POST /api/v1/user/change-phone`
    Changes phone number after OTP verification.

* **`ChangeOTPResponse`** model — response wrapper for both change-email and change-phone OTP request endpoints.

* **`AuthService.changePassword`** — `POST /api/v1/auth/change-password`
  Changes user password. Requires `currentPassword`, `newPassword`, `otpCode`, and `verifyMode` (`'email'` / `'phone'`). OTP must be requested first via [AuthService.otpRequest] with `verifyType = "change_password"`.

* **`AuthService.otpRequest`** — `POST /api/v1/otp/request`
  Sends generic OTP (change_password, change_device, login, etc.). Requires `companyId`, `verifyType`, and `verifyMode`.

* **`AuthService.otpVerify`** — `POST /api/v1/otp/verify`
  Verifies generic OTP code. Requires `companyId`, `code`, `verifyType`, and `verifyMode`.

* **`OTPRequestResponse`** / **`OTPVerifyResponse`** — models for generic OTP request/verify response.

---

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
