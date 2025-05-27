import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:photofilters/photofilters.dart';
import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../services/photoServices/photo_service.dart';
import '../utils/error_handler.dart';
import '../utils/image_utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_card.dart';


class PhotoDetailScreen extends StatefulWidget {
  final Map<String, dynamic> photo;

  const PhotoDetailScreen({Key? key, required this.photo}) : super(key: key);

  @override
  _PhotoDetailScreenState createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  img.Image? editedImage;
  Filter? selectedFilter;
  bool showOriginal = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);
    try {
      final response = await Dio().get(
        '${ApiConstants.baseUrl}/display-photo${widget.photo['imagePath']}',
        options: Options(responseType: ResponseType.bytes),
      );
      editedImage = img.decodeImage(response.data);
    } catch (e) {
      ErrorHandler.handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _applyFilter() async {
    if (selectedFilter == null || editedImage == null) return;
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final filteredImage = img.Image.from(editedImage!);
      selectedFilter!.apply(
        filteredImage.getBytes(),
        filteredImage.width,
        filteredImage.height,
      );

      if (mounted) {
        setState(() {
          editedImage = filteredImage;
          showOriginal = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.handleError(context, e);
      }
    }
  }

  Future<void> _saveImage() async {
    if (editedImage == null) return;
    setState(() => _isLoading = true);
    try {
      final compressedImage =
          await ImageUtils.compressImage(File(widget.photo['imagePath']));
      FormData formData = FormData.fromMap({
        'file':
            MultipartFile.fromBytes(compressedImage, filename: 'edited.jpg'),
      });
      await PhotoService.uploadPhoto(formData);
      Navigator.pop(context, true);
    } catch (e) {
      ErrorHandler.handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteImage() async {
    setState(() => _isLoading = true);
    try {
      await PhotoService.deletePhoto(widget.photo['_id']);
      Navigator.pop(context, true);
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
          title: const Text('Chỉnh sửa ảnh'), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ImageCard(
                    imageUrl:
                        '${ApiConstants.baseUrl}/display-photo${widget.photo['imagePath']}',
                    onTap: () => setState(() => showOriginal = !showOriginal),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: presetFiltersList.length,
                    itemBuilder: (context, index) {
                      final filter = presetFiltersList[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedFilter = filter),
                          child: Text(filter.name),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        label: 'Áp dụng bộ lọc',
                        icon: Icons.filter,
                        onPressed: _applyFilter,
                      ),
                      CustomButton(
                        label: 'Lưu',
                        icon: Icons.save,
                        onPressed: _saveImage,
                      ),
                      CustomButton(
                        label: 'Xóa',
                        icon: Icons.delete,
                        onPressed: _deleteImage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
