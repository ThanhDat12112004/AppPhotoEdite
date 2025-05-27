import 'user_profile.dart';

// Combined User model for backward compatibility
// This combines Auth and UserProfile data
class User {
  final String id; // This will be authId
  final String username;
  final String email;
  final String? password; // Chỉ dùng khi đăng ký, không trả về từ API
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phoneNumber;
  final String? address;
  final String? avatar;
  final String? bio;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  User({
    required this.id,
    required this.username,
    required this.email,
    this.password,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.address,
    this.avatar,
    this.bio,
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create User from UserProfile (which includes auth info)
  factory User.fromUserProfile(UserProfile profile) {
    return User(
      id: profile.authId, // Use authId as user id
      username: profile.username ?? '',
      email: profile.email ?? '',
      fullName: profile.fullName,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      phoneNumber: profile.phoneNumber,
      address: profile.address,
      avatar: profile.avatar,
      bio: profile.bio,
      isPublic: profile.isPublic,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  // For backward compatibility - parse from old API response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['authId'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: null, // Không lấy password từ API
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      avatar: json['avatar'],
      bio: json['bio'],
      isPublic: json['isPublic'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'phoneNumber': phoneNumber,
      'address': address,
      'avatar': avatar,
      'bio': bio,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method để tạo Map cho update profile
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {};

    if (fullName != null) data['fullName'] = fullName;
    if (dateOfBirth != null)
      data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (gender != null) data['gender'] = gender;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address;
    if (avatar != null) data['avatar'] = avatar;
    if (bio != null) data['bio'] = bio;
    data['isPublic'] = isPublic;

    return data;
  }
}
