import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../models/photo.dart';
import '../services/photoServices/photo_service.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_card.dart';


class AnimeConversionScreen extends StatefulWidget {
  const AnimeConversionScreen({Key? key}) : super(key: key);

  @override
  _AnimeConversionScreenState createState() => _AnimeConversionScreenState();
}

class _AnimeConversionScreenState extends State<AnimeConversionScreen> {
  List<Photo> photos = [];
  Photo? selectedPhoto;
  String selectedModel = 'Shinkai';
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

  Future<void> _convertToAnime() async {
    if (selectedPhoto == null) return;
    setState(() => _isLoading = true);
    try {
      final convertedPhoto =
          await PhotoService.convertToAnime(selectedPhoto!.imagePath, selectedModel);
      setState(() {
        photos.add(convertedPhoto);
        selectedPhoto = convertedPhoto;
      });
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
          title: const Text('Chuyển đổi Anime'), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: selectedModel,
                    items: ['Shinkai', 'Hayao'].map((model) {
                      return DropdownMenuItem(value: model, child: Text(model));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedModel = value!),
                  ),
                  const SizedBox(height: 20),
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
                    label: 'Chuyển đổi',
                    icon: Icons.auto_fix_high,
                    onPressed: _convertToAnime,
                  ),
                  if (selectedPhoto != null)
                    ImageCard(
                      imageUrl:
                          '${ApiConstants.baseUrl}/display-photo${selectedPhoto!.imagePath}',
                      onTap: () {},
                    ),
                ],
              ),
            ),
    );
  }
}
