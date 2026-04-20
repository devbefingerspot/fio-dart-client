import '../common/minimal_user.dart';

/// Detailed employee information.
class EmployeeDetail {
  const EmployeeDetail({
    required this.id,
    required this.companyId,
    required this.fullName,
    this.customId,
    this.nip,
    this.photoFileUrl,
    this.gender,
    this.religion,
    this.birthDate,
    this.marriageStatus,
    this.bloodType,
    this.email,
    this.mobilePhone,
    this.homePhone,
    this.workPhone,
    this.address,
    this.governmentNumberId,
    this.officeId,
    this.officeName,
    this.departmentId,
    this.departmentName,
    this.positionId,
    this.positionName,
    this.isActive,
    this.contractType,
    this.joinedAt,
    this.resignAt,
    this.notes,
    this.userId,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String fullName;
  final String? customId;
  final String? nip;
  final String? photoFileUrl;
  final String? gender;
  final String? religion;
  final DateTime? birthDate;
  final String? marriageStatus;
  final String? bloodType;
  final String? email;
  final String? mobilePhone;
  final String? homePhone;
  final String? workPhone;
  final String? address;
  final String? governmentNumberId;
  final String? officeId;
  final String? officeName;
  final String? departmentId;
  final String? departmentName;
  final String? positionId;
  final String? positionName;
  final bool? isActive;
  final String? contractType;
  final DateTime? joinedAt;
  final DateTime? resignAt;
  final String? notes;
  final String? userId;
  final MinimalUser? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory EmployeeDetail.fromJson(Map<String, dynamic> json) {
    return EmployeeDetail(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      fullName: json['full_name'] as String,
      customId: json['custom_id'] as String?,
      nip: json['nip'] as String?,
      photoFileUrl: json['photo_file_url'] as String?,
      gender: json['gender'] as String?,
      religion: json['religion'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      marriageStatus: json['marriage_status'] as String?,
      bloodType: json['blood_type'] as String?,
      email: json['email'] as String?,
      mobilePhone: json['mobile_phone'] as String?,
      homePhone: json['home_phone'] as String?,
      workPhone: json['work_phone'] as String?,
      address: json['address'] as String?,
      governmentNumberId: json['government_number_id'] as String?,
      officeId: json['office_id'] as String?,
      officeName: json['office_name'] as String?,
      departmentId: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
      positionId: json['position_id'] as String?,
      positionName: json['position_name'] as String?,
      isActive: json['is_active'] as bool?,
      contractType: json['contract_type'] as String?,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
      resignAt: json['resign_at'] != null
          ? DateTime.parse(json['resign_at'] as String)
          : null,
      notes: json['notes'] as String?,
      userId: json['user_id'] as String?,
      user: json['user'] != null
          ? MinimalUser.fromJson(json['user'] as Map<String, dynamic>)
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
