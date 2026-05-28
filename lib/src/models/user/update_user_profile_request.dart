import 'package:dio/dio.dart';

/// Request body for [UserProfileService.update].
class UpdateUserProfileRequest {
  const UpdateUserProfileRequest({
    this.name,
    this.photo,
  });

  /// New display name. Cannot be empty if provided.
  final String? name;

  /// New profile photo file. Uploaded by the backend; pass `null` to leave unchanged.
  final MultipartFile? photo;

  FormData toFormData() => FormData.fromMap({
        if (name != null) 'name': name,
        if (photo != null) 'photo': photo,
      });
}
