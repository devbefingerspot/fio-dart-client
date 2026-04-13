import 'package:dio/dio.dart';

import 'handler/mobile_api_auth_handler.dart';
import 'interceptor/refresh_lock.dart';
import 'interceptor/token_refresh_interceptor.dart';
import 'services/auth_service.dart';
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
/// ```
class MobileApiClient {
  MobileApiClient({
    required String authBaseUrl,
    required String backendBaseUrl,
    required MobileApiAuthHandler authHandler,
  })  : _authBaseUrl = authBaseUrl,
        _authHandler = authHandler {
    _plainDio = _buildPlainDio();
    _identityDio = _buildIdentityDio(backendBaseUrl: authBaseUrl);
    _backendDio = _buildBackendDio(backendBaseUrl: backendBaseUrl);

    auth = AuthService(
      plainDio: _plainDio,
      identityDio: _identityDio,
      authBaseUrl: authBaseUrl,
    );
    user = UserService(
      identityDio: _identityDio,
      authBaseUrl: authBaseUrl,
    );
  }

  final String _authBaseUrl;
  final MobileApiAuthHandler _authHandler;

  late final Dio _plainDio;
  late final Dio _identityDio;
  late final Dio _backendDio;

  final _identityLock = TokenRefreshLock();
  final _companyLock = TokenRefreshLock();

  /// Auth operations: [AuthService.login], [AuthService.logout],
  /// [AuthService.issueCompanyToken].
  late final AuthService auth;

  /// User-info operations: [UserService.getProfile], [UserService.listCompanies].
  late final UserService user;

  // ── Public API ──────────────────────────────────────────────────────────────

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
    return Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
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
        getAccessToken: _authHandler.getCompanyAccessToken,
        getRefreshToken: _authHandler.getCompanyRefreshToken,
        onTokenRefreshed: _authHandler.onCompanyTokenRefreshed,
        onLoggedOut: _authHandler.onCompanyLoggedOut,
        lock: _companyLock,
        plainDio: _plainDio,
      ),
    );

    return dio;
  }
}
