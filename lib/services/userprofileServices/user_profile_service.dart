

import '../../constants/api_constants.dart';
import '../../models/user_profile.dart';
import '../appServices/api_service.dart';

class UserProfileService {
  static Future<UserProfile> fetchProfile() async {
    try {
      final response = await ApiService.get('${ApiConstants.userProfileUrl}/');
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      }
      throw Exception(
          response.data['message'] ?? 'Không thể tải hồ sơ người dùng');
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final response = await ApiService.put(
        '${ApiConstants.userProfileUrl}/',
        profile.toUpdateJson(),
      );
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data['user']);
      }
      throw Exception(response.data['message'] ?? 'Cập nhật hồ sơ thất bại');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteProfile() async {
    try {
      final response =
          await ApiService.delete('${ApiConstants.userProfileUrl}/');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Xóa hồ sơ thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }
}
