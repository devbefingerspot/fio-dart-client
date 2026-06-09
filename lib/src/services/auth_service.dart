import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/auth/change_otp_response.dart';
import '../models/auth/issue_company_token_request.dart';
import '../models/auth/issue_company_token_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/otp_response.dart';

/// Provides authentication operations against the auth-service.
///
/// Obtain this via [MobileApiClient.auth].
class AuthService {
  AuthService({
    required Dio plainDio,
    required Dio identityDio,
    required String authBaseUrl,
  })  : _plainDio = plainDio,
        _identityDio = identityDio,
        _authBaseUrl = authBaseUrl;

  final Dio _plainDio;
  final Dio _identityDio;
  final String _authBaseUrl;

  /// POST /api/v1/login/mobile
  ///
  /// Authenticates the user with email/phone + password and returns
  /// identity-scoped tokens. Call [issueCompanyToken] afterwards to obtain
  /// company-scoped tokens.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _plainDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/login/mobile',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/auth/logout
  ///
  /// Terminates the current session. Uses the identity Dio so the auth
  /// interceptor attaches the token automatically (middleware accepts both
  /// identity and company tokens).
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<void> logout() async {
    try {
      await _identityDio.post<void>(
        '$_authBaseUrl/api/v1/auth/logout',
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/mobile/issue-company-token
  ///
  /// Issues company-scoped tokens using the identity access token. Call this
  /// after the user selects a company from the list returned by
  /// [UserService.listCompanies].
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<IssueCompanyTokenResponse> issueCompanyToken(
    IssueCompanyTokenRequest request,
  ) async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/mobile/issue-company-token',
        data: request.toJson(),
      );
      return IssueCompanyTokenResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/otp/request
  ///
  /// Mengirim OTP generic ke user (email/phone sesuai [verifyMode]).
  /// Membutuhkan company context ([companyId]).
  ///
  /// [verifyType] contoh: `"change_password"`, `"change_device"`, `"login"`, dll.
  /// [verifyMode]: `"email"` atau `"phone"`.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<OTPRequestResponse> otpRequest(
    String companyId,
    String verifyType,
    String verifyMode,
  ) async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/otp/request',
        data: {
          'verify_type': verifyType,
          'verify_mode': verifyMode,
        },
        options: Options(headers: {'X-Company-ID': companyId}),
      );
      return OTPRequestResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/otp/verify
  ///
  /// Memverifikasi kode OTP generic.
  /// Membutuhkan company context ([companyId]).
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<OTPVerifyResponse> otpVerify(
    String companyId,
    String code,
    String verifyType,
    String verifyMode,
  ) async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/otp/verify',
        data: {
          'code': code,
          'verify_type': verifyType,
          'verify_mode': verifyMode,
        },
        options: Options(headers: {'X-Company-ID': companyId}),
      );
      return OTPVerifyResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/otp/email/request
  ///
  /// Sends an OTP to the user's email for email verification.
  /// Does not require company context.
  /// Will be rejected if the email is already verified.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<OTPRequestResponse> requestEmailVerificationOTP() async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/otp/email/request',
      );
      return OTPRequestResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/otp/email/verify
  ///
  /// Verifies the OTP code sent to the user's email and sets
  /// `email_verified_at` on success.
  /// Does not require company context.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<OTPVerificationVerifyResponse> verifyEmailOTP(String code) async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/otp/email/verify',
        data: {'code': code},
      );
      return OTPVerificationVerifyResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/otp/phone/request
  ///
  /// Sends an OTP to the user's phone number via WhatsApp for phone
  /// verification.
  /// Does not require company context.
  /// Will be rejected if the phone number is already verified.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<OTPRequestResponse> requestPhoneVerificationOTP() async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/otp/phone/request',
      );
      return OTPRequestResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/otp/phone/verify
  ///
  /// Verifies the OTP code sent to the user's phone and sets
  /// `phone_verified_at` on success.
  /// Does not require company context.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<OTPVerificationVerifyResponse> verifyPhoneOTP(String code) async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/otp/phone/verify',
        data: {'code': code},
      );
      return OTPVerificationVerifyResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/otp/change-email/request
  ///
  /// Mengirim OTP ke email BARU untuk change email.
  /// Syarat: email lama user harus sudah terverifikasi (EmailVerifiedAt != nil).
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<ChangeOTPResponse> requestChangeEmailOTP(String newEmail) async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/otp/change-email/request',
        data: {'new_email': newEmail},
      );
      return ChangeOTPResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/otp/change-phone/request
  ///
  /// Mengirim OTP ke nomor telepon BARU untuk change phone.
  /// Syarat: nomor telepon lama user harus sudah terverifikasi (PhoneVerifiedAt != nil).
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<ChangeOTPResponse> requestChangePhoneOTP(
    String newPhoneCode,
    String newPhone,
  ) async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/otp/change-phone/request',
        data: {
          'new_phone_code': newPhoneCode,
          'new_phone': newPhone,
        },
      );
      return ChangeOTPResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/auth/change-password
  ///
  /// Mengubah password user yang sudah terautentikasi.
  /// OTP harus diminta terlebih dahulu via [otpRequest] dengan
  /// `verifyType = "change_password"`.
  ///
  /// - [currentPassword]: password lama (divalidasi server-side)
  /// - [newPassword]: password baru
  /// - [otpCode]: kode OTP yang sudah dikirim ke email/phone
  /// - [verifyMode]: `"email"` atau `"phone"` (harus sama dengan saat OTP request)
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otpCode,
    required String verifyMode,
  }) async {
    try {
      await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'otp_code': otpCode,
          'verify_mode': verifyMode,
        },
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
