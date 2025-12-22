import 'article.dart';

class WishlistItem {
  final int id;
  final int userId;
  final int articleId;
  final DateTime createdAt;
  final Article article;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.createdAt,
    required this.article,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      userId: json['user_id'],
      articleId: json['article_id'],
      createdAt: DateTime.parse(json['created_at']),
      article: Article.fromJson(json['article']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'article_id': articleId,
      'created_at': createdAt.toIso8601String(),
      'article': article.toJson(),
    };
  }
}