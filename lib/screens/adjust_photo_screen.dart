import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../services/photoServices/photo_service.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_card.dart';

class AdjustPhotoScreen extends StatefulWidget {
  final String headPath;
  final String vestPath;

  const AdjustPhotoScreen(
      {Key? key, required this.headPath, required this.vestPath})
      : super(key: key);

  @override
  _AdjustPhotoScreenState createState() => _AdjustPhotoScreenState();
}

class _AdjustPhotoScreenState extends State<AdjustPhotoScreen> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  bool _isLoading = false;

  Future<void> _saveCombinedImage() async {
    setState(() => _isLoading = true);
    try {
      FormData formData = FormData.fromMap({
        'head': await MultipartFile.fromFile(widget.headPath),
        'vest': await MultipartFile.fromFile(widget.vestPath),
      });
      await PhotoService.uploadPhoto(formData);
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
          title: const Text('Điều chỉnh ảnh'), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onScaleUpdate: (details) {
                      setState(() {
                        _scale = details.scale;
                        _offset += details.focalPointDelta;
                      });
                    },
                    child: Stack(
                      children: [
                        ImageCard(imageUrl: widget.vestPath, onTap: () {}),
                        Positioned(
                          left: _offset.dx,
                          top: _offset.dy,
                          child: Transform.scale(
                            scale: _scale,
                            child: ImageCard(
                                imageUrl: widget.headPath, onTap: () {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        label: 'Xóa nền',
                        icon: Icons.delete,
                        onPressed: () =>
                            PhotoService.removeBackground(widget.headPath),
                      ),
                      CustomButton(
                        label: 'Lưu',
                        icon: Icons.save,
                        onPressed: _saveCombinedImage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
