import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../models/photo.dart';
import '../services/photoServices/photo_service.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Photo> photos = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPhotos,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        CustomButton(
                          label: 'Tải ảnh mới',
                          icon: Icons.upload,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/photo_edit'),
                        ),
                        CustomButton(
                          label: 'Xóa nền',
                          icon: Icons.delete_sweep,
                          onPressed: () => Navigator.pushNamed(
                              context, '/remove_background'),
                        ),
                        CustomButton(
                          label: 'Cải thiện ảnh',
                          icon: Icons.enhance_photo_translate,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/enhance_photo'),
                        ),
                        CustomButton(
                          label: 'Biểu cảm khuôn mặt',
                          icon: Icons.face,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/face_expression'),
                        ),
                        CustomButton(
                          label: 'Chuyển đổi Anime',
                          icon: Icons.auto_fix_high,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/anime_conversion'),
                        ),
                        CustomButton(
                          label: 'Kết hợp ảnh',
                          icon: Icons.merge_type,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/combine_photo'),
                        ),
                        CustomButton(
                          label: 'Tải nhân vật',
                          icon: Icons.person_add,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/character_upload'),
                        ),
                      ],
                    ),
                    const Text('Ảnh của bạn',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return ImageCard(
                          imageUrl:
                              '${ApiConstants.baseUrl}/display-photo${photo.imagePath}',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/photo_detail',
                            arguments: photo.toJson(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
