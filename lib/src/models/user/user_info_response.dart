/// Detailed user fields returned by GET /api/v1/user/me.
class UserDetail {
  const UserDetail({
    required this.id,
    this.oldId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phoneCode,
    this.phone,
    this.status,
    this.lastLoginAt,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int? oldId;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phoneCode;
  final String? phone;
  final String? status;
  final String? lastLoginAt;
  final String? emailVerifiedAt;
  final String? phoneVerifiedAt;
  final String createdAt;
  final String updatedAt;

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'] as String,
      oldId: json['old_id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photo_url'] as String?,
      phoneCode: json['phone_code'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      lastLoginAt: json['last_login_at'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      phoneVerifiedAt: json['phone_verified_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'old_id': oldId,
        'name': name,
        'email': email,
        'photo_url': photoUrl,
        'phone_code': phoneCode,
        'phone': phone,
        'status': status,
        'last_login_at': lastLoginAt,
        'email_verified_at': emailVerifiedAt,
        'phone_verified_at': phoneVerifiedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

/// Company fields returned inside GET /api/v1/user/me.
///
/// `null` when the request was made with an identity token (no company context).
class CompanyDetail {
  const CompanyDetail({
    required this.id,
    this.oldId,
    required this.name,
    required this.email,
    this.logoUrl,
    this.phone,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int? oldId;
  final String name;
  final String email;
  final String? logoUrl;
  final String? phone;
  final String? dueDate;
  final String createdAt;
  final String updatedAt;

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    return CompanyDetail(
      id: json['id'] as String,
      oldId: json['old_id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      logoUrl: json['logo_url'] as String?,
      phone: json['phone'] as String?,
      dueDate: json['due_date'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'old_id': oldId,
        'name': name,
        'email': email,
        'logo_url': logoUrl,
        'phone': phone,
        'due_date': dueDate,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

/// Response from GET /api/v1/user/me.
///
/// [company] and [role] are `null` when called with an identity token
/// (i.e. before issuing a company token).
class UserInfoResponse {
  const UserInfoResponse({
    required this.user,
    this.company,
    this.role,
  });

  final UserDetail user;
  final CompanyDetail? company;

  /// `"employee"`, `"owner"`, `"subadmin"`, or `"admin"`. `null` for identity sessions.
  final String? role;

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    final companyJson = json['company'];
    CompanyDetail? company;
    // Server returns an empty object `{}` when there is no company context.
    if (companyJson is Map && companyJson.isNotEmpty) {
      company = CompanyDetail.fromJson(
          companyJson.cast<String, dynamic>());
    }

    return UserInfoResponse(
      user: UserDetail.fromJson(
          (json['user'] as Map).cast<String, dynamic>()),
      company: company,
      role: (json['role'] as String?)?.isNotEmpty == true
          ? json['role'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'company': company?.toJson(),
        'role': role,
      };
}
