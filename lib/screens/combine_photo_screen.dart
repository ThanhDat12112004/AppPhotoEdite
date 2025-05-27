// import 'package:flutter/material.dart';
// import 'package:myapp/models/character.dart';
// import 'package:myapp/models/photo.dart';
// import 'package:myapp/services/photo_service.dart';
// import 'package:myapp/services/api_service.dart';
// import 'package:myapp/widgets/custom_button.dart';
// import 'package:myapp/widgets/image_card.dart';
// import 'package:myapp/constants/api_constants.dart';
// import 'package:myapp/utils/error_handler.dart';

// class CombinePhotoScreen extends StatefulWidget {
//   const CombinePhotoScreen({Key? key}) : super(key: key);

//   @override
//   _CombinePhotoScreenState createState() => _CombinePhotoScreenState();
// }

// class _CombinePhotoScreenState extends State<CombinePhotoScreen> {
//   final PhotoService _photoService = PhotoService(ApiService());
//   List<Photo> photos = [];
//   List<Character> characters = [];
//   Photo? selectedPhoto;
//   Character? selectedCharacter;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     setState(() => _isLoading = true);
//     try {
//       photos = await _photoService.fetchPhotos();
//       final response = await ApiService().get(ApiConstants.charactersUrl);
//       characters = (response.data as List)
//           .map((json) => Character.fromJson(json))
//           .toList();
//     } catch (e) {
//       ErrorHandler.handleError(context, e);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _combinePhotos() {
//     if (selectedPhoto == null || selectedCharacter == null) return;
//     Navigator.pushNamed(context, '/adjust_photo', arguments: {
//       'headPath':
//           '${ApiConstants.baseUrl}/display-photo${selectedPhoto!.imagePath}',
//       'vestPath': selectedCharacter!.imageURL,
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text('Kết hợp ảnh'), backgroundColor: Colors.teal),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Chọn ảnh', style: TextStyle(fontSize: 18)),
//                   SizedBox(
//                     height: 120,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: photos.length,
//                       itemBuilder: (context, index) {
//                         final photo = photos[index];
//                         return ImageCard(
//                           imageUrl:
//                               '${ApiConstants.baseUrl}/display-photo${photo.imagePath}',
//                           isSelected: selectedPhoto?.id == photo.id,
//                           onTap: () => setState(() => selectedPhoto = photo),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text('Chọn nhân vật', style: TextStyle(fontSize: 18)),
//                   SizedBox(
//                     height: 120,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: characters.length,
//                       itemBuilder: (context, index) {
//                         final character = characters[index];
//                         return ImageCard(
//                           imageUrl: '${ApiConstants.baseUrl}/display-photo${character.imageURL}',
//                           isSelected: selectedCharacter?.id == character.id,
//                           onTap: () =>
//                               setState(() => selectedCharacter = character),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   CustomButton(
//                     label: 'Kết hợp',
//                     icon: Icons.merge_type,
//                     onPressed: _combinePhotos,
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
