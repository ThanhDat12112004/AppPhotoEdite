import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../models/photo.dart';
import '../services/photoServices/photo_service.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_card.dart';


class EnhancePhotoScreen extends StatefulWidget {
  const EnhancePhotoScreen({Key? key}) : super(key: key);

  @override
  _EnhancePhotoScreenState createState() => _EnhancePhotoScreenState();
}

class _EnhancePhotoScreenState extends State<EnhancePhotoScreen> {
  List<Photo> photos = [];
  Photo? selectedPhoto;
  Photo? enhancedPhoto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    setState(() => _isLoading = true);
    try {
      photos = await PhotoService.fetchPhotos();
    } catch (e) {
      ErrorHandler.handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enhancePhoto() async {
    if (selectedPhoto == null) return;
    setState(() => _isLoading = true);
    try {
      enhancedPhoto = await PhotoService.enhancePhoto(selectedPhoto!.imagePath);
      setState(() {});
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
          title: const Text('Tăng chất lượng ảnh'),
          backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Chọn ảnh', style: TextStyle(fontSize: 18)),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return ImageCard(
                          imageUrl:
                              '${ApiConstants.baseUrl}/display-photo${photo.imagePath}',
                          isSelected: selectedPhoto?.imagePath == photo.imagePath,
                          onTap: () => setState(() => selectedPhoto = photo),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Cải thiện',
                    icon: Icons.enhance_photo_translate,
                    onPressed: _enhancePhoto,
                  ),
                  const SizedBox(height: 20),
                  if (selectedPhoto != null)
                    Column(
                      children: [
                        const Text('Ảnh gốc', style: TextStyle(fontSize: 16)),
                        ImageCard(
                          imageUrl:
                              '${ApiConstants.baseUrl}/display-photo${selectedPhoto!.imagePath}',
                          onTap: () {},
                        ),
                      ],
                    ),
                  if (enhancedPhoto != null)
                    Column(
                      children: [
                        const Text('Ảnh cải thiện',
                            style: TextStyle(fontSize: 16)),
                        ImageCard(
                          imageUrl:
                              '${ApiConstants.baseUrl}/display-photo${enhancedPhoto!.imagePath}',
                          onTap: () {},
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
