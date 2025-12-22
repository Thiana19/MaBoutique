class Article {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? brand;
  final int categoryId;
  final String? imageUrl;
  final int stockQuantity;
  final bool isFeatured;
  final bool isActive;
  final double discountPercentage;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.brand,
    required this.categoryId,
    this.imageUrl,
    required this.stockQuantity,
    required this.isFeatured,
    required this.isActive,
    required this.discountPercentage,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate discounted price
  double get discountedPrice {
    if (discountPercentage > 0) {
      return price - (price * discountPercentage / 100);
    }
    return price;
  }

  // Check if article has discount
  bool get hasDiscount => discountPercentage > 0;

  // Check if in stock
  bool get inStock => stockQuantity > 0;

  // Format price as string
  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Format discounted price as string
  String get formattedDiscountedPrice {
    return '\$${discountedPrice.toStringAsFixed(2)}';
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      brand: json['brand'],
      categoryId: json['category_id'],
      imageUrl: json['image_url'],
      stockQuantity: json['stock_quantity'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'brand': brand,
      'category_id': categoryId,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'is_featured': isFeatured,
      'is_active': isActive,
      'discount_percentage': discountPercentage,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}