
import '../../constants/api_constants.dart';
import '../../models/user.dart';
import '../../models/user_profile.dart';
import '../appServices/api_service.dart';

class UserService {
  static Future<User> fetchUserProfile() async {
    try {
      final response = await ApiService.get('${ApiConstants.userProfileUrl}/');
      if (response.statusCode == 200) {
        // Tạo UserProfile từ response và convert sang User cho backward compatibility
        final userProfile = UserProfile.fromJson(response.data);
        return User.fromUserProfile(userProfile);
      }
      throw Exception(
          response.data['message'] ?? 'Không thể tải hồ sơ người dùng');
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserProfile> fetchUserProfileNew() async {
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

  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response =
          await ApiService.put('${ApiConstants.userProfileUrl}/', data);
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Cập nhật hồ sơ thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateUserProfileFromUser(User user) async {
    try {
      await updateUserProfile(user.toUpdateJson());
    } catch (e) {
      rethrow;
    }
  }
}
