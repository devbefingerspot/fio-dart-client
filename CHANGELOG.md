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
