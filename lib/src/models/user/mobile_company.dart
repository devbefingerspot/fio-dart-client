/// A single company entry from GET /api/v1/user/mobile-companies.
class MobileCompany {
  const MobileCompany({
    required this.id,
    this.oldId,
    required this.name,
    required this.email,
    this.logoUrl,
    this.phone,
    required this.role,
    required this.backendMode,
    required this.baseUrl,
  });

  final String id;

  /// Legacy integer company-ID, present when migrated from the old system.
  final int? oldId;

  final String name;
  final String email;
  final String? logoUrl;
  final String? phone;

  /// `"employee"` or `"owner"`.
  final String role;

  /// `"new_web"` or `"old_web"` — determines which backend URL scheme to use.
  final String backendMode;

  /// The base URL of the backend for this company.
  final String baseUrl;

  factory MobileCompany.fromJson(Map<String, dynamic> json) {
    return MobileCompany(
      id: json['id'] as String,
      oldId: json['old_id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      logoUrl: json['logo_url'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      backendMode: json['backend_mode'] as String,
      baseUrl: json['base_url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'old_id': oldId,
        'name': name,
        'email': email,
        'logo_url': logoUrl,
        'phone': phone,
        'role': role,
        'backend_mode': backendMode,
        'base_url': baseUrl,
      };
}
