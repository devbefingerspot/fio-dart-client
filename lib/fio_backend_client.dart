/// Fingerspot.io backend client.
///
/// A storage-agnostic Dart package that provides typed API access to the
/// auth-service and fio-web-desktop-backend, with automatic token refresh and
/// single-flight refresh locking.
///
/// ## Quick start
/// ```dart
/// import 'package:fio_backend_client/fio_backend_client.dart';
///
/// final client = MobileApiClient(
///   authBaseUrl: 'https://auth.example.com',
///   backendBaseUrl: 'https://backend.example.com',
///   authHandler: MyAuthHandler(),
/// );
/// ```
library;

// Core entry point
export 'src/mobile_api_client.dart';

// Auth handler interface — implement this in your app
export 'src/handler/mobile_api_auth_handler.dart';

// Error type
export 'src/models/api_error.dart';

// ── Common models ─────────────────────────────────────────────────────────────

export 'src/models/common/pagination_meta.dart';
export 'src/models/common/paginated_response.dart';
export 'src/models/common/pagination_params.dart';
export 'src/models/common/minimal_user.dart';
export 'src/models/common/minimal_employee.dart';
export 'src/models/common/request_status.dart';

// ── Auth models ───────────────────────────────────────────────────────────────

export 'src/models/auth/login_request.dart';
export 'src/models/auth/login_response.dart';
export 'src/models/auth/issue_company_token_request.dart';
export 'src/models/auth/issue_company_token_response.dart';
export 'src/models/auth/refresh_token_response.dart';
export 'src/models/auth/jwt_claims.dart';

// ── User models ───────────────────────────────────────────────────────────────

export 'src/models/user/user_info_response.dart';
export 'src/models/user/mobile_company.dart';
export 'src/models/user/update_user_profile_request.dart';

// ── Attendance models ─────────────────────────────────────────────────────────

export 'src/models/attendance/attendance_type.dart';
export 'src/models/attendance/attendance_log.dart';
export 'src/models/attendance/gps_settings_response.dart';
export 'src/models/attendance/submit_gps_attendance_request.dart';
export 'src/models/attendance/submit_gps_attendance_response.dart';
export 'src/models/attendance/list_attendance_params.dart';

// ── Employee models ───────────────────────────────────────────────────────────

export 'src/models/employee/employee_list_item.dart';
export 'src/models/employee/employee_detail.dart';
export 'src/models/employee/list_employees_params.dart';

// ── Overtime models ───────────────────────────────────────────────────────────

export 'src/models/overtime/overtime_type.dart';
export 'src/models/overtime/overtime_master.dart';
export 'src/models/overtime/overtime_request.dart';
export 'src/models/overtime/submit_overtime_request.dart';
export 'src/models/overtime/submit_overtime_response.dart';
export 'src/models/overtime/list_overtime_params.dart';

// ── Leave models ──────────────────────────────────────────────────────────────

export 'src/models/leave/leave.dart';
export 'src/models/leave/leave_request.dart';
export 'src/models/leave/submit_leave_request.dart';
export 'src/models/leave/submit_leave_response.dart';
export 'src/models/leave/list_leave_params.dart';

// ── Approval models ───────────────────────────────────────────────────────────

export 'src/models/approval/approval_status.dart';
export 'src/models/approval/approval_stage.dart';
export 'src/models/approval/approval_request.dart';
export 'src/models/approval/approval_action_request.dart';
export 'src/models/approval/approval_action_response.dart';
export 'src/models/approval/list_approvals_params.dart';

// ── Integrity models ──────────────────────────────────────────────────────────

export 'src/models/integrity/integrity_challenge_response.dart';
export 'src/models/integrity/ios_attest_request.dart';
export 'src/models/integrity/ios_attest_response.dart';

// ── Invitation models ─────────────────────────────────────────────────────────

export 'src/models/invitation/company_invitation.dart';
// ── Face registry models ───────────────────────────────────────────────

export 'src/models/face_registry/face_registry_record.dart';
export 'src/models/face_registry/face_registry_response.dart';
// ── Services ──────────────────────────────────────────────────────────────────

export 'src/services/auth_service.dart';
export 'src/services/user_service.dart';
export 'src/services/integrity_service.dart';
export 'src/services/gps_attendance_service.dart';
export 'src/services/my_attendance_service.dart';
export 'src/services/employee_attendance_service.dart';
export 'src/services/employee_service.dart';
export 'src/services/overtime_service.dart';
export 'src/services/leave_service.dart';
export 'src/services/my_approvals_service.dart';
export 'src/services/invitation_service.dart';

// ── Utils ─────────────────────────────────────────────────────────────────────

export 'src/util/jwt_util.dart';
