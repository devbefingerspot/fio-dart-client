/// Response dari endpoint OTP request untuk change email / change phone.
///
/// POST /api/v1/otp/change-email/request  → [newEmail] terisi
/// POST /api/v1/otp/change-phone/request  → [newPhone] terisi
class ChangeOTPResponse {
  const ChangeOTPResponse({
    required this.message,
    this.newEmail,
    this.newPhone,
  });

  final String message;
  final String? newEmail;
  final String? newPhone;

  factory ChangeOTPResponse.fromJson(Map<String, dynamic> json) {
    return ChangeOTPResponse(
      message: json['message'] as String,
      newEmail: json['new_email'] as String?,
      newPhone: json['new_phone'] as String?,
    );
  }
}
