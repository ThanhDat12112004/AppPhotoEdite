

import 'package:flutter/material.dart';

import 'screens/adjust_photo_screen.dart';
import 'screens/anime_conversion_screen.dart';
import 'screens/character_upload_screen.dart';
import 'screens/combine_photo.dart';
import 'screens/enhance_photo_screen.dart';
import 'screens/face_expression_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/photo_detail_screen.dart';
import 'screens/photo_edit_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/remove_background_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(
            builder: (_) => HomeScreen(
                  onLogout: () => Navigator.pushReplacementNamed(_, '/login'),
                ));
      case '/adjust_photo':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => AdjustPhotoScreen(
              headPath: args['headPath'],
              vestPath: args['vestPath'],
            ),
          );
        }
        return _errorRoute();
      case '/anime_conversion':
        return MaterialPageRoute(builder: (_) => const AnimeConversionScreen());
      case '/character_upload':
        return MaterialPageRoute(builder: (_) => const CharacterUploadScreen());
      case '/combine_photo':
        return MaterialPageRoute(builder: (_) => const CombinePhotoScreen());
      case '/enhance_photo':
        return MaterialPageRoute(builder: (_) => const EnhancePhotoScreen());
      case '/face_expression':
        return MaterialPageRoute(builder: (_) => const FaceExpressionScreen());
      case '/photo_detail':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => PhotoDetailScreen(photo: args),
          );
        }
        return _errorRoute();
      case '/photo_edit':
        return MaterialPageRoute(builder: (_) => const PhotoEditScreen());
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(
            onLogout: () => Navigator.pushReplacementNamed(_, '/login'),
          ),
        );
      case '/remove_background':
        return MaterialPageRoute(
            builder: (_) => const RemoveBackgroundScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy trang')),
      ),
    );
  }
}
