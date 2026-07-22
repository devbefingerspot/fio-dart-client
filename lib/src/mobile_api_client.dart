import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'handler/mobile_api_auth_handler.dart';
import 'interceptor/refresh_lock.dart';
import 'interceptor/token_refresh_interceptor.dart';
import 'services/auth_service.dart';
import 'services/device_service.dart';
import 'services/employee_attendance_service.dart';
import 'services/employee_service.dart';
import 'services/gps_attendance_service.dart';
import 'services/integrity_service.dart';
import 'services/invitation_service.dart';
import 'services/leave_service.dart';
import 'services/location_service.dart';
import 'services/face_registry_service.dart';
import 'services/my_approvals_service.dart';
import 'services/my_attendance_service.dart';
import 'services/office_service.dart';
import 'services/overtime_service.dart';
import 'services/user_profile_service.dart';
import 'services/user_service.dart';

/// The main entry point for the fio_backend_client package.
///
/// Manages three Dio instances:
/// - **plain** — no auth; used for login and token-refresh calls.
/// - **identity** — attaches identity access token; 401 triggers identity
///   token refresh.
/// - **backend** — attaches company access token; 401 triggers company token
///   refresh. Its base URL can be changed at runtime via [setBackendBaseUrl].
///
/// ## Multi-company support
///
/// Users can be members of multiple companies. Each company has its own
/// token pair stored independently via [MobileApiAuthHandler]. Use
/// [setCurrentCompany] to switch between companies — this updates the
/// company context for all backend services.
///
/// ## Typical flow
/// ```dart
/// final client = MobileApiClient(
///   authBaseUrl: 'https://auth.example.com',
///   backendBaseUrl: 'https://backend.example.com',
///   authHandler: MyAuthHandler(),
/// );
///
/// // 1. Login → get identity tokens
/// final login = await client.auth.login(LoginRequest(email: '...', password: '...'));
/// authHandler.onIdentityTokenRefreshed(accessToken: login.identityAccessToken, ...);
///
/// // 2. List companies
/// final companies = await client.user.listCompanies();
///
/// // 3. Set backend URL for the selected company
/// client.setBackendBaseUrl(companies.first.baseUrl);
///
/// // 4. Issue company token
/// final company = await client.auth.issueCompanyToken(IssueCompanyTokenRequest(...));
/// authHandler.onCompanyTokenRefreshed(
///   companyId: company.companyId,
///   accessToken: company.accessToken,
///   refreshToken: company.refreshToken,
/// );
///
/// // 5. Set current company context for backend services
/// client.setCurrentCompany(company.companyId);
///
/// // 6. Use company-scoped services
/// final settings = await client.gpsAttendance.getSettings();
/// final employees = await client.employees.list();
/// ```
class MobileApiClient {
  MobileApiClient({
    required String authBaseUrl,
    required String backendBaseUrl,
    required MobileApiAuthHandler authHandler,
    bool enableLogging = false,
  })  : _authBaseUrl = authBaseUrl,
        _authHandler = authHandler,
        _enableLogging = enableLogging {
    _plainDio = _buildPlainDio();
    _identityDio = _buildIdentityDio(backendBaseUrl: authBaseUrl);
    _backendDio = _buildBackendDio(backendBaseUrl: backendBaseUrl);

    // Auth services (use identity token)
    auth = AuthService(
      plainDio: _plainDio,
      identityDio: _identityDio,
      authBaseUrl: authBaseUrl,
    );
    user = UserService(
      identityDio: _identityDio,
      backendDio: _backendDio,
      authBaseUrl: authBaseUrl,
    );
    invitations = InvitationService(
      identityDio: _identityDio,
      authBaseUrl: authBaseUrl,
    );
    devices = DeviceService(
      identityDio: _identityDio,
      authBaseUrl: authBaseUrl,
    );

    // Backend services (use company token)
    integrity = IntegrityService(backendDio: _backendDio);
    gpsAttendance = GpsAttendanceService(backendDio: _backendDio);
    myAttendance = MyAttendanceService(backendDio: _backendDio);
    employeeAttendance = EmployeeAttendanceService(backendDio: _backendDio);
    employees = EmployeeService(backendDio: _backendDio);
    overtime = OvertimeService(backendDio: _backendDio);
    leave = LeaveService(backendDio: _backendDio);
    location = LocationService(backendDio: _backendDio);
    myApprovals = MyApprovalsService(backendDio: _backendDio);
    userProfile = UserProfileService(backendDio: _backendDio);
    faceRegistry = FaceRegistryService(backendDio: _backendDio);
    offices = OfficeService(backendDio: _backendDio);
  }

  final String _authBaseUrl;
  final MobileApiAuthHandler _authHandler;
  final bool _enableLogging;

  late final Dio _plainDio;
  late final Dio _identityDio;
  late final Dio _backendDio;

  final _identityLock = TokenRefreshLock();
  final _companyLock = TokenRefreshLock();

  /// The currently active company ID. Set via [setCurrentCompany].
  String? _currentCompanyId;

  // ── Auth services (identity token) ─────────────────────────────────────────

  /// Auth operations: [AuthService.login], [AuthService.logout],
  /// [AuthService.issueCompanyToken].
  late final AuthService auth;

  /// User-info operations: [UserService.getProfile], [UserService.listCompanies].
  late final UserService user;

  /// Company invitation operations: [InvitationService.list],
  /// [InvitationService.accept], [InvitationService.reject].
  late final InvitationService invitations;

  /// Device operations: [DeviceService.getMyDevices],
  /// [DeviceService.createDeviceChangeRequest].
  late final DeviceService devices;

  // ── Backend services (company token) ───────────────────────────────────────

  /// Device integrity operations: [IntegrityService.getChallenge],
  /// [IntegrityService.registerIosKey].
  late final IntegrityService integrity;

  /// GPS attendance operations: [GpsAttendanceService.getSettings],
  /// [GpsAttendanceService.submit], [GpsAttendanceService.uploadEvidence].
  late final GpsAttendanceService gpsAttendance;

  /// My attendance operations: [MyAttendanceService.list],
  /// [MyAttendanceService.detail].
  late final MyAttendanceService myAttendance;

  /// Employee attendance operations: [EmployeeAttendanceService.list],
  /// [EmployeeAttendanceService.detail].
  late final EmployeeAttendanceService employeeAttendance;

  /// Employee list operations: [EmployeeService.list], [EmployeeService.detail].
  late final EmployeeService employees;

  /// Overtime request operations: [OvertimeService.listMasters],
  /// [OvertimeService.list], [OvertimeService.detail],
  /// [OvertimeService.submit], [OvertimeService.submitBulk].
  late final OvertimeService overtime;

  /// Leave request operations: [LeaveService.listTypes], [LeaveService.list],
  /// [LeaveService.detail], [LeaveService.submit].
  late final LeaveService leave;

  /// Location monitoring operations: [LocationService.submitPing],
  /// [LocationService.submitBatch], [LocationService.startSession],
  /// [LocationService.updateSession], [LocationService.listSessions],
  /// [LocationService.getSessionDetail], [LocationService.queryHistory],
  /// [LocationService.listGeofences].
  late final LocationService location;

  /// Approval operations: [MyApprovalsService.list], [MyApprovalsService.detail],
  /// [MyApprovalsService.act].
  late final MyApprovalsService myApprovals;

  /// User profile update operations: [UserProfileService.update].
  late final UserProfileService userProfile;

  /// Office operations: [OfficeService.getMyOffices].
  late final OfficeService offices;

  /// Face registry operations: [FaceRegistryService.get],
  /// [FaceRegistryService.register].
  late final FaceRegistryService faceRegistry;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// The current company ID, or `null` if no company is selected.
  String? get currentCompanyId => _currentCompanyId;

  /// Sets the current company context for all backend services.
  ///
  /// Call this after issuing a company token via [AuthService.issueCompanyToken].
  /// The company token for [companyId] must be stored via your
  /// [MobileApiAuthHandler] implementation.
  ///
  /// This updates the interceptor to use the correct company token for all
  /// subsequent requests to backend services.
  void setCurrentCompany(String companyId) {
    _currentCompanyId = companyId;
  }

  /// Clears the current company context.
  ///
  /// Call this when logging out of a company or returning to the company
  /// selection screen.
  void clearCurrentCompany() {
    _currentCompanyId = null;
  }

  /// Updates the backend base URL at runtime.
  ///
  /// Call this after selecting a company — use [MobileCompany.baseUrl] from
  /// [UserService.listCompanies] as the value.
  void setBackendBaseUrl(String url) {
    _backendDio.options.baseUrl = url;
  }

  /// The backend base URL currently in use.
  String get backendBaseUrl => _backendDio.options.baseUrl;

  /// Escape hatch — direct access to the backend [Dio] instance.
  ///
  /// Use this only when no typed service covers your use-case.
  /// The instance already has the company-token refresh interceptor attached.
  Dio get rawBackendClient => _backendDio;

  // ── Dio factory helpers ──────────────────────────────────────────────────────

  Dio _buildPlainDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _attachLoggerIfEnabled(dio);
    return dio;
  }

  Dio _buildIdentityDio({required String backendBaseUrl}) {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(
      TokenRefreshInterceptor(
        authBaseUrl: _authBaseUrl,
        getAccessToken: _authHandler.getIdentityAccessToken,
        getRefreshToken: _authHandler.getIdentityRefreshToken,
        onTokenRefreshed: _authHandler.onIdentityTokenRefreshed,
        onLoggedOut: _authHandler.onLoggedOut,
        lock: _identityLock,
        plainDio: _plainDio,
      ),
    );

    _attachLoggerIfEnabled(dio);

    return dio;
  }

  Dio _buildBackendDio({required String backendBaseUrl}) {
    final dio = Dio(BaseOptions(
      baseUrl: backendBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(
      TokenRefreshInterceptor(
        authBaseUrl: _authBaseUrl,
        getAccessToken: () async {
          final companyId = _currentCompanyId;
          if (companyId == null) return null;
          return _authHandler.getCompanyAccessToken(companyId);
        },
        getRefreshToken: () async {
          final companyId = _currentCompanyId;
          if (companyId == null) return null;
          return _authHandler.getCompanyRefreshToken(companyId);
        },
        onTokenRefreshed: ({
          required String accessToken,
          required String refreshToken,
        }) async {
          final companyId = _currentCompanyId;
          if (companyId == null) return;
          await _authHandler.onCompanyTokenRefreshed(
            companyId: companyId,
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        },
        onLoggedOut: () async {
          final companyId = _currentCompanyId;
          if (companyId == null) {
            await _authHandler.onLoggedOut();
          } else {
            await _authHandler.onCompanyLoggedOut(companyId);
          }
        },
        lock: _companyLock,
        plainDio: _plainDio,
        companyId: _currentCompanyId,
      ),
    );

    _attachLoggerIfEnabled(dio);

    return dio;
  }

  void _attachLoggerIfEnabled(Dio dio) {
    if (!_enableLogging) return;

    dio.interceptors.add(
      PrettyDioLogger(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }
}
