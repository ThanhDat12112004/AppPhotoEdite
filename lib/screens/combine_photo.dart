import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'adjust_photo_screen.dart';

class CombinePhotoScreen extends StatefulWidget {
  const CombinePhotoScreen({super.key});

  @override
  _CombinePhotoScreenState createState() => _CombinePhotoScreenState();
}

class _CombinePhotoScreenState extends State<CombinePhotoScreen> {
  final Dio dio = Dio();
  final String photoBaseUrl = ApiConstants.photosUrl;
  final String characterBaseUrl = ApiConstants.charactersUrl;
  final String baseUrl = ApiConstants.baseUrl;
  List<dynamic> _userPhotos = [];
  List<dynamic> _characters = [];
  String? _selectedPhotoId;
  String? _selectedCharacterId;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchPhotos();
  }

  Future<void> _loadTokenAndFetchPhotos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    await fetchUserPhotos();
  }

  Future<void> _showLoadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Stack(
            children: [
              ModalBarrier(color: Colors.black.withOpacity(0.5)),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.teal),
                      const SizedBox(height: 15),
                      Text(
                        'Đang xử lý ảnh với AI...',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchUserPhotos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Response response = await dio.get(
        photoBaseUrl,
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );
      setState(() {
        _userPhotos = response.data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải ảnh: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchCharacters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Response response = await dio.get(
        characterBaseUrl,
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );
      setState(() {
        _characters = response.data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải danh sách nhân vật: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> proceedToAdjustPhoto() async {
    if (_selectedPhotoId == null || _selectedCharacterId == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn cả ảnh và nhân vật!';
      });
      return;
    }

    await _showLoadingDialog();

    try {
      final selectedPhoto =
          _userPhotos.firstWhere((photo) => photo['_id'] == _selectedPhotoId);
      Response headResponse = await dio.post(
        '$photoBaseUrl/extract-head',
        data: {'imageUrl': selectedPhoto['imagePath']},
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );

      if (headResponse.statusCode != 200) {
        throw Exception(
            'Lỗi khi trích xuất ảnh đầu: ${headResponse.data['message'] ?? 'Unknown error'}');
      }

      final headImagePath = headResponse.data['imagePath'];

      Response vestResponse = await dio.get(
        '$characterBaseUrl/$_selectedCharacterId',
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );
      if (vestResponse.statusCode != 200) {
        throw Exception(
            'Không tìm thấy nhân vật với ID: $_selectedCharacterId');
      }
      final vestImagePath = vestResponse.data['imageURL'];

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdjustPhotoScreen(
              headPath: headImagePath,
              vestPath: vestImagePath,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          if (e is DioException && e.response != null) {
            _errorMessage =
                'Lỗi từ server: ${e.response!.data['message'] ?? e.message}';
          } else {
            _errorMessage = 'Lỗi khi xử lý: $e';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghép Ảnh Với Nhân Vật', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chọn ảnh của bạn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: _userPhotos.isEmpty
                          ? _buildEmptyCard('Chưa có ảnh nào')
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _userPhotos.length,
                              itemBuilder: (context, index) {
                                final photo = _userPhotos[index];
                                final isSelected = _selectedPhotoId == photo['_id'];
                                return _buildImageCard(
                                  imagePath: photo['imagePath'],
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      _selectedPhotoId = photo['_id'];
                                      _selectedCharacterId = null;
                                      _characters = [];
                                    });
                                    fetchCharacters();
                                  },
                                );
                              },
                            ),
                    ),
                    if (_selectedPhotoId != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Chọn nhân vật',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 160,
                        child: _characters.isEmpty
                            ? _buildEmptyCard('Chưa có nhân vật nào')
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _characters.length,
                                itemBuilder: (context, index) {
                                  final character = _characters[index];
                                  final isSelected = _selectedCharacterId == character['_id'];
                                  return _buildImageCard(
                                    imagePath: character['imageURL'],
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedCharacterId = character['_id'];
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                    if (_selectedCharacterId != null) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: proceedToAdjustPhoto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Tiếp tục điều chỉnh',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildImageCard({
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Container(
          width: 120,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.teal.shade600 : Colors.grey.shade300,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: '$baseUrl/display-photo$imagePath',
              fit: BoxFit.cover,
              httpHeaders: {'Authorization': 'Bearer $_token'},
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}