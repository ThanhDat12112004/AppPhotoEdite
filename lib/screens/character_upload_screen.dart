import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../models/character.dart';
import '../services/photoServices/photo_service.dart';
import '../utils/error_handler.dart';
import '../utils/image_utils.dart';
import '../widgets/custom_button.dart';

class CharacterUploadScreen extends StatefulWidget {
  const CharacterUploadScreen({Key? key}) : super(key: key);

  @override
  _CharacterUploadScreenState createState() => _CharacterUploadScreenState();
}

class _CharacterUploadScreenState extends State<CharacterUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  XFile? selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => selectedImage = pickedFile);
    }
  }

  Future<void> _uploadCharacter() async {
    if (selectedImage == null || nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      File rotatedImage = await ImageUtils.rotateImage(selectedImage!.path);
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(rotatedImage.path,
            filename: rotatedImage.path.split('/').last),
        'name': nameController.text,
      });
      final response = await PhotoService.uploadPhoto(formData);
      final character = Character.fromJson(response.toJson());
      Navigator.pop(context, character);
    } catch (e) {
      ErrorHandler.handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Tải lên nhân vật'), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên nhân vật',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                    onPressed: _uploadCharacter,
                  ),
                ],
              ),
            ),
    );
  }
}
