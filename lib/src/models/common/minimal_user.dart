/// Minimal user information used in nested responses.
class MinimalUser {
  const MinimalUser({
    required this.id,
    required this.name,
    this.photoUrl,
  });

  /// User UUID.
  final String id;

  /// User's display name.
  final String name;

  /// User's profile photo URL, if available.
  final String? photoUrl;

  factory MinimalUser.fromJson(Map<String, dynamic> json) {
    return MinimalUser(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
    };
    if (photoUrl != null) map['photo_url'] = photoUrl;
    return map;
  }
}
