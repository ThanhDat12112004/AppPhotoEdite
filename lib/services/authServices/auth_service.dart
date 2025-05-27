import 'dart:convert';
import '../../constants/api_constants.dart';
import '../../models/auth.dart';
import '../appServices/api_service.dart';
import '../appServices/storage_service.dart';

class AuthService {
  // Hàm decode JWT để lấy userId
  static Map<String, dynamic> _decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = parts[1];
    final decoded = base64Url.decode(base64Url.normalize(payload));
    return json.decode(utf8.decode(decoded));
  }

  static Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.authUrl}/login',
        {'email': email, 'password': password},
        requiresAuth: false,
      );
      if (response.statusCode == 200) {
        final token = response.data['token'];
        await StorageService.saveToken(token);

        // Decode JWT để lấy userId và lưu vào storage
        final decodedToken = _decodeJWT(token);
        final userId = decodedToken['userId'];
        if (userId != null) {
          await StorageService.saveUserId(userId);
        }
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> register(
      String username, String email, String password) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.authUrl}/register',
        {
          'username': username,
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );
      if (response.statusCode == 201) {
        final token = response.data['token'];
        await StorageService.saveToken(token);

        // Lưu userId từ token
        final decodedToken = _decodeJWT(token);
        final userId = decodedToken['userId'];
        if (userId != null) {
          await StorageService.saveUserId(userId);
        }
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Auth> getAuthInfo() async {
    try {
      final response =
          await ApiService.get('${ApiConstants.authUrl}/auth-info');
      if (response.statusCode == 200) {
        return Auth.fromJson(response.data);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    try {
      await StorageService.clearToken();
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }
}
