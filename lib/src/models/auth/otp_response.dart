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
