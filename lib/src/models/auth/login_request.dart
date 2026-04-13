/// Request body for POST /api/v1/login/mobile.
///
/// Either [email] or [phone] + [phoneCode] must be provided.
class LoginRequest {
  const LoginRequest({
    this.email,
    this.phone,
    this.phoneCode,
    required this.password,
  }) : assert(
          email != null || phone != null,
          'Either email or phone must be provided.',
        );

  final String? email;
  final String? phone;

  /// Required when [phone] is provided (e.g. "+62").
  final String? phoneCode;
  final String password;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'password': password};
    if (email != null) map['email'] = email;
    if (phone != null) map['phone'] = phone;
    if (phoneCode != null) map['phone_code'] = phoneCode;
    return map;
  }
}
