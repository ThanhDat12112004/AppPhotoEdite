class Character {
  final String id;
  final String name;
  final String imageURL;
  final DateTime createdAt;

  Character({
    required this.id,
    required this.name,
    required this.imageURL,
    required this.createdAt,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['_id'],
      name: json['name'],
      imageURL: json['imageURL'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'imageURL': imageURL,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
