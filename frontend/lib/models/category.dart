class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}