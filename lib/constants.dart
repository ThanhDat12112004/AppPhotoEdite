import 'package:flutter_dotenv/flutter_dotenv.dart';

// Lớp Constants để lưu trữ các URL từ file .env
class ApiConstants {
  
  // URL cơ sở
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  
  // URL xác thực
  static String get authUrl => dotenv.env['AUTH_URL'] ?? 'http://localhost:3000/auth';
  
  // URL cho photos
  static String get photosUrl => dotenv.env['PHOTOS_URL'] ?? 'http://localhost:3000/photos';
  
  // URL cho characters
  static String get charactersUrl => dotenv.env['CHARACTERS_URL'] ?? 'http://localhost:3000/characters';

  // URL cho user-profile
  static String get userProfileUrl => dotenv.env['USER_PROFILE_URL'] ?? 'http://localhost:3000/user_profile';
  
    static String get enhanceURL => dotenv.env['PYTHON_ENHANCE_URL'] ?? 'http://localhost:3000/enhance';

}