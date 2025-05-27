class Photo {
  final String id;
  final String imagePath;

  Photo({
    required this.id,
    required this.imagePath,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['_id'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imagePath': imagePath,
    };
  }
}