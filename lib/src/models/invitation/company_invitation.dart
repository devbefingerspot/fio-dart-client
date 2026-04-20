/// Company invitation status.
enum InvitationStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  cancelled('cancelled');

  const InvitationStatus(this.value);

  final String value;

  static InvitationStatus fromString(String value) {
    return InvitationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}

/// Company invitation.
class CompanyInvitation {
  const CompanyInvitation({
    required this.id,
    this.status,
    this.companyId,
    this.companyName,
    this.companyLogo,
    this.role,
    this.invitedAt,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final InvitationStatus? status;
  final String? companyId;
  final String? companyName;
  final String? companyLogo;
  final String? role;
  final DateTime? invitedAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CompanyInvitation.fromJson(Map<String, dynamic> json) {
    // Handle nested company_info if present
    final companyInfo = json['company_info'] as Map<String, dynamic>?;

    return CompanyInvitation(
      id: json['id'] as String,
      status: json['status'] != null
          ? InvitationStatus.fromString(json['status'] as String)
          : null,
      companyId:
          companyInfo?['id'] as String? ?? json['company_id'] as String?,
      companyName:
          companyInfo?['name'] as String? ?? json['company_name'] as String?,
      companyLogo:
          companyInfo?['logo'] as String? ?? json['company_logo'] as String?,
      role: json['role'] as String?,
      invitedAt: json['invited_at'] != null
          ? DateTime.parse(json['invited_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
