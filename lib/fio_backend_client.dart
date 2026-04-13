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

// Auth models
export 'src/models/auth/login_request.dart';
export 'src/models/auth/login_response.dart';
export 'src/models/auth/issue_company_token_request.dart';
export 'src/models/auth/issue_company_token_response.dart';
export 'src/models/auth/refresh_token_response.dart';
export 'src/models/auth/jwt_claims.dart';

// Utils
export 'src/util/jwt_util.dart';

// User models
export 'src/models/user/user_info_response.dart';
export 'src/models/user/mobile_company.dart';

// Services (exported so callers can type their references)
export 'src/services/auth_service.dart';
export 'src/services/user_service.dart';
