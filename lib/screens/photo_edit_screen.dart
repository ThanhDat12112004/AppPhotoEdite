import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:myapp/services/photoServices/photo_service.dart';

import '../utils/error_handler.dart';
import '../utils/image_utils.dart';
import '../widgets/custom_button.dart';

class PhotoEditScreen extends StatefulWidget {
  const PhotoEditScreen({super.key});

  @override
  _PhotoEditScreenState createState() => _PhotoEditScreenState();
}

class _PhotoEditScreenState extends State<PhotoEditScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => selectedImage = pickedFile);
    }
  }

  Future<void> _uploadImage() async {
    if (selectedImage == null) return;
    setState(() => _isLoading = true);
    try {
      File rotatedImage = await ImageUtils.rotateImage(selectedImage!.path);
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(rotatedImage.path,
            filename: rotatedImage.path.split('/').last),
      });
      
     final result = await PhotoService.uploadPhoto(formData);
      print('Upload successful: ${result.toString()}'); // Debug log
      Navigator.pop(context, true);
    } catch (e) {
      print('Upload error: $e'); // Debug log để xem lỗi cụ thể
      ErrorHandler.handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Tải ảnh mới'), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (selectedImage != null)
                    Image.file(File(selectedImage!.path),
                        height: 200, fit: BoxFit.cover),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        label: 'Chụp ảnh',
                        icon: Icons.camera_alt,
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      CustomButton(
                        label: 'Chọn ảnh',
                        icon: Icons.photo_library,
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Tải lên',
                    icon: Icons.upload,
                    onPressed: _uploadImage,
                  ),
                ],
              ),
            ),
    );
  }
}
