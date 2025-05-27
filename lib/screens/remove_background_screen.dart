import 'package:flutter/material.dart';
import 'package:myapp/models/photo.dart';
import 'package:myapp/services/photoServices/photo_service.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/widgets/image_card.dart';
import 'package:myapp/constants/api_constants.dart';
import 'package:myapp/utils/error_handler.dart';

class RemoveBackgroundScreen extends StatefulWidget {
  const RemoveBackgroundScreen({Key? key}) : super(key: key);

  @override
  _RemoveBackgroundScreenState createState() => _RemoveBackgroundScreenState();
}

class _RemoveBackgroundScreenState extends State<RemoveBackgroundScreen> {
  List<Photo> photos = [];
  Photo? selectedPhoto;
  Photo? processedPhoto;
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

  Future<void> _removeBackground() async {
    if (selectedPhoto == null) return;
    setState(() => _isLoading = true);
    try {
      processedPhoto = await PhotoService.removeBackground(
        selectedPhoto!.imagePath,
      );
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
        title: const Text('Xóa nền ảnh'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          isSelected: selectedPhoto?.id == photo.id,
                          onTap: () => setState(() => selectedPhoto = photo),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Xóa nền',
                    icon: Icons.delete_sweep,
                    onPressed: _removeBackground,
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
                  if (processedPhoto != null)
                    Column(
                      children: [
                        const Text('Ảnh đã xóa nền',
                            style: TextStyle(fontSize: 16)),
                        ImageCard(
                          imageUrl:
                              '${ApiConstants.baseUrl}/display-photo${processedPhoto!.imagePath}',
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
