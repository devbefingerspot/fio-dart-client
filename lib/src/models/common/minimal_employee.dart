import 'minimal_user.dart';

/// Minimal employee information used in nested responses.
class MinimalEmployee {
  const MinimalEmployee({
    required this.id,
    required this.fullName,
    this.customId,
    this.nip,
    this.userId,
    this.user,
    this.isActive,
  });

  /// Employee UUID.
  final String id;

  /// Employee's full name.
  final String fullName;

  /// Company-defined employee ID.
  final String? customId;

  /// Employee identification number (NIP).
  final String? nip;

  /// Associated user UUID, if linked.
  final String? userId;

  /// Associated user details, if available.
  final MinimalUser? user;

  /// Whether the employee's employment is active.
  final bool? isActive;

  factory MinimalEmployee.fromJson(Map<String, dynamic> json) {
    return MinimalEmployee(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      customId: json['custom_id'] as String?,
      nip: json['nip'] as String?,
      userId: json['user_id'] as String?,
      user: json['user'] != null
          ? MinimalUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'full_name': fullName,
    };
    if (customId != null) map['custom_id'] = customId;
    if (nip != null) map['nip'] = nip;
    if (userId != null) map['user_id'] = userId;
    if (user != null) map['user'] = user!.toJson();
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
}
