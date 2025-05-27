class UserProfile {
  final String id;
  final String authId;
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

  // Thông tin từ Auth service (được gộp khi fetch)
  final String? username;
  final String? email;

  UserProfile({
    required this.id,
    required this.authId,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.address,
    this.avatar,
    this.bio,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.username,
    this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'],
      authId: json['authId'],
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
      username: json['username'], // Từ Auth service
      email: json['email'], // Từ Auth service
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'authId': authId,
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

  // Helper method để tạo Map cho update (chỉ các trường được phép)
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
