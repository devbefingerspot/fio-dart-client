/// Response dari endpoint generic OTP request.
///
/// POST /api/v1/otp/request
class OTPRequestResponse {
  const OTPRequestResponse({
    required this.message,
    this.email,
    this.phone,
  });

  final String message;
  final String? email;
  final String? phone;

  factory OTPRequestResponse.fromJson(Map<String, dynamic> json) {
    return OTPRequestResponse(
      message: json['message'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

/// Response dari endpoint generic OTP verify.
///
/// POST /api/v1/otp/verify
class OTPVerifyResponse {
  const OTPVerifyResponse({
    required this.message,
  });

  final String message;

  factory OTPVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OTPVerifyResponse(
      message: json['message'] as String,
    );
  }
}

/// Response dari endpoint OTP verify untuk email/phone verification.
///
/// POST /api/v1/otp/email/verify  → [emailVerifiedAt] terisi
/// POST /api/v1/otp/phone/verify  → [phoneVerifiedAt] terisi
class OTPVerificationVerifyResponse {
  const OTPVerificationVerifyResponse({
    required this.message,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
  });

  final String message;
  final String? emailVerifiedAt;
  final String? phoneVerifiedAt;

  factory OTPVerificationVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OTPVerificationVerifyResponse(
      message: json['message'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      phoneVerifiedAt: json['phone_verified_at'] as String?,
    );
  }
}
