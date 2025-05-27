
import '../../models/auth.dart';
import '../../models/user.dart';
import '../../models/user_profile.dart';
import '../authServices/auth_service.dart';
import 'user_profile_service.dart';

class CombinedUserService {

  static Future<User> fetchCompleteUser() async {
    try {
      // Fetch profile (which includes auth info from backend)
      final profile = await UserProfileService.fetchProfile();
      return User.fromUserProfile(profile);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Auth> fetchAuth() async {
    try {
      return await AuthService.getAuthInfo();
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserProfile> fetchProfile() async {
    try {
      return await UserProfileService.fetchProfile();
    } catch (e) {
      rethrow;
    }
  }

  static Future<User> updateUser(User user) async {
    try {
      // Update profile only (auth info is not updatable via profile)
      final profileData = {
        'fullName': user.fullName,
        'dateOfBirth': user.dateOfBirth?.toIso8601String(),
        'gender': user.gender,
        'phoneNumber': user.phoneNumber,
        'address': user.address,
        'avatar': user.avatar,
        'bio': user.bio,
        'isPublic': user.isPublic,
      };

      // Remove null values
      profileData.removeWhere((key, value) => value == null);

      final updatedProfile = await UserProfileService.updateProfile(
        UserProfile(
          id: '', // Will be ignored by backend
          authId: user.id,
          fullName: user.fullName,
          dateOfBirth: user.dateOfBirth,
          gender: user.gender,
          phoneNumber: user.phoneNumber,
          address: user.address,
          avatar: user.avatar,
          bio: user.bio,
          isPublic: user.isPublic,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          username: user.username,
          email: user.email,
        ),
      );

      return User.fromUserProfile(updatedProfile);
    } catch (e) {
      rethrow;
    }
  }
}
