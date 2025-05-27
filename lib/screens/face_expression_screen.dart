import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../models/photo.dart';
import '../services/photoServices/photo_service.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_card.dart';


class FaceExpressionScreen extends StatefulWidget {
  const FaceExpressionScreen({Key? key}) : super(key: key);

  @override
  _FaceExpressionScreenState createState() => _FaceExpressionScreenState();
}

class _FaceExpressionScreenState extends State<FaceExpressionScreen> {
  List<Photo> photos = [];
  Photo? selectedPhoto;
  Map<String, dynamic>? expressions;
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

  Future<void> _detectExpression() async {
    if (selectedPhoto == null) return;
    setState(() => _isLoading = true);
    try {
      expressions = await PhotoService.detectExpression(selectedPhoto!.imagePath);
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
          title: const Text('Phát hiện biểu cảm'),
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
                    label: 'Phát hiện',
                    icon: Icons.face,
                    onPressed: _detectExpression,
                  ),
                  if (selectedPhoto != null)
                    ImageCard(
                      imageUrl:
                          '${ApiConstants.baseUrl}/display-photo${selectedPhoto!.imagePath}',
                      onTap: () {},
                    ),
                  if (expressions != null)
                    Column(
                      children: [
                        Text(
                            'Biểu cảm chính: ${expressions!['mainExpression']}',
                            style: const TextStyle(fontSize: 16)),
                        ...expressions!['allExpressions']
                            .map<Widget>((exp) => Text(
                                '${exp['expression']}: ${exp['confidence']}'))
                            .toList(),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
