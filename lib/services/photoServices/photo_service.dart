import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../models/photo.dart';
import '../appServices/api_service.dart';
import '../appServices/storage_service.dart';

class PhotoService {
  static Future<List<Photo>> fetchPhotos() async {
    try {
      final response = await ApiService.get(ApiConstants.photosUrl);
      if (response.statusCode == 200) {
        return (response.data['photos'] as List)
            .map((photo) => Photo.fromJson(photo))
            .toList();
      }
      throw Exception(
          response.data['message'] ?? 'Không thể tải danh sách ảnh');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Photo> uploadPhoto(FormData formData) async {
    try {
      // Add userId to formData
      final userId = await StorageService.getUserId();
      if (userId != null) {
        formData.fields.add(MapEntry('user', userId));
      }

      final response = await ApiService.post(
        '${ApiConstants.photosUrl}/upload',
        formData,
      );
      if (response.statusCode == 201) {
        return Photo.fromJson(response.data);
      }
      throw Exception(response.data['message']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deletePhoto(String photoId) async {
    try {
      final response =
          await ApiService.delete('${ApiConstants.photosUrl}/$photoId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(response.data['message'] ?? 'Xóa ảnh thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Photo> removeBackground(String imagePath) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.photosUrl}/remove-background',
        {'imagePath': imagePath},
      );
      if (response.statusCode == 200) {
        return Photo.fromJson(response.data);
      }
      throw Exception(response.data['message']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Photo> enhancePhoto(String imagePath) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.photosUrl}/enhance',
        {'imagePath': imagePath},
      );
      if (response.statusCode == 200) {
        return Photo.fromJson(response.data);
      }
      throw Exception(response.data['message'] ?? 'Cải thiện ảnh thất bại');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> detectExpression(String imagePath) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.photosUrl}/detect-expression',
        {'imagePath': imagePath},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception(
          response.data['message'] ?? 'Phát hiện biểu cảm thất bại');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Photo> convertToAnime(String imagePath, String model) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.photosUrl}/convert-to-anime',
        {'imagePath': imagePath, 'model': model},
      );
      if (response.statusCode == 200) {
        return Photo.fromJson(response.data);
      }
      throw Exception(response.data['message'] ?? 'Chuyển đổi anime thất bại');
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> extractHeadAndRemoveBackground(String imagePath) async {
    try {
      final response = await ApiService.post(
        '${ApiConstants.photosUrl}/extract-head',
        {'imagePath': imagePath},
      );
      if (response.statusCode == 200) {
        return '${ApiConstants.baseUrl}/display-photo${response.data['imagePath']}';
      }
      throw Exception(
          response.data['message'] ?? 'Cắt phần đầu và xóa nền thất bại');
    } catch (e) {
      rethrow;
    }
  }
}
