

import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  static Future<Response> get(String path, {bool requiresAuth = true}) async {
    try {
      final options = await _getOptions(requiresAuth);
      return await _dio.get(path, options: options);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> post(String path, dynamic data,
      {bool requiresAuth = true}) async {
    try {
      if (requiresAuth) {
        final options = await _getOptions(requiresAuth);
        return await _dio.post(path, data: data, options: options);
      } else {
        await _dio.post(path, data: data);
        
        return await _dio.post(path, data: data);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> put(String path, dynamic data,
      {bool requiresAuth = true}) async {
    try {
      final options = await _getOptions(requiresAuth);
      return await _dio.put(path, data: data, options: options);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> delete(String path, {bool requiresAuth = true}) async {
    try {
      final options = await _getOptions(requiresAuth);
      return await _dio.delete(path, options: options);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Options> _getOptions(bool requiresAuth) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  static Exception _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      String? message;

      if (response?.data != null && response!.data is Map<String, dynamic>) {
        message = response.data['message'] ??
            response.data['error'] ??
            'Lỗi không xác định từ server';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message ??= 'Hết thời gian kết nối. Vui lòng kiểm tra mạng.';
          break;
        case DioExceptionType.receiveTimeout:
          message ??= 'Hết thời gian nhận dữ liệu. Vui lòng thử lại.';
          break;
        case DioExceptionType.badResponse:
          message ??= 'Lỗi server: ${response?.statusCode}';
          break;
        default:
          message ??= 'Lỗi mạng: Vui lòng kiem tra kết nối!';
      }
      return Exception(message);
    }
    return Exception(error.toString());
  }
}
