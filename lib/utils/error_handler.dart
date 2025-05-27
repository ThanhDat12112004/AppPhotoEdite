import 'package:flutter/material.dart';

class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
    if (error is Exception) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      errorMessage = error;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}
