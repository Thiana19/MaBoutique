import 'article.dart';

class CartItem {
  final int id;
  final int userId;
  final int articleId;
  final int quantity;
  final String? size;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Article article;

  CartItem({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.quantity,
    this.size,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    required this.article,
  });

  // Calculate item total price (with discount)
  double get itemTotal {
    return article.discountedPrice * quantity;
  }

  // Calculate original total (without discount)
  double get originalTotal {
    return article.price * quantity;
  }

  // Calculate total savings
  double get savings {
    return originalTotal - itemTotal;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['user_id'],
      articleId: json['article_id'],
      quantity: json['quantity'],
      size: json['size'],
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      article: Article.fromJson(json['article']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'article_id': articleId,
      'quantity': quantity,
      'size': size,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'article': article.toJson(),
    };
  }
}

class CartSummary {
  final int totalItems;
  final double subtotal;
  final double totalDiscount;
  final double total;
  final List<CartItem> items;

  CartSummary({
    required this.totalItems,
    required this.subtotal,
    required this.totalDiscount,
    required this.total,
    required this.items,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      totalItems: json['total_items'],
      subtotal: (json['subtotal'] as num).toDouble(),
      totalDiscount: (json['total_discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedDiscount => '\$${totalDiscount.toStringAsFixed(2)}';
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
}