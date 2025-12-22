import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wishlist_item.dart';
import 'api_service.dart';
import 'auth_service.dart';

class WishlistService {
  // Get user's wishlist
  static Future<List<WishlistItem>> getWishlist() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/wishlist'),
        headers: ApiService.getHeaders(token: token),
      );

      print('📤 Get wishlist response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => WishlistItem.fromJson(item)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch wishlist');
      }
    } catch (e) {
      print('❌ Get wishlist error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Add item to wishlist
  static Future<WishlistItem> addToWishlist(int articleId) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/wishlist'),
        headers: ApiService.getHeaders(token: token),
        body: jsonEncode({
          'article_id': articleId,
        }),
      );

      print('📤 Add to wishlist response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WishlistItem.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to add to wishlist');
      }
    } catch (e) {
      print('❌ Add to wishlist error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Remove item from wishlist
  static Future<void> removeFromWishlist(int articleId) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/wishlist/$articleId'),
        headers: ApiService.getHeaders(token: token),
      );

      print('📤 Remove from wishlist response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to remove from wishlist');
      }
    } catch (e) {
      print('❌ Remove from wishlist error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Clear entire wishlist
  static Future<void> clearWishlist() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/wishlist'),
        headers: ApiService.getHeaders(token: token),
      );

      print('📤 Clear wishlist response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to clear wishlist');
      }
    } catch (e) {
      print('❌ Clear wishlist error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Check if article is in wishlist
  static Future<bool> isInWishlist(int articleId) async {
    try {
      final wishlist = await getWishlist();
      return wishlist.any((item) => item.articleId == articleId);
    } catch (e) {
      return false;
    }
  }

  // Toggle wishlist (add if not present, remove if present)
  static Future<bool> toggleWishlist(int articleId) async {
    try {
      final isInList = await isInWishlist(articleId);
      
      if (isInList) {
        await removeFromWishlist(articleId);
        return false;
      } else {
        await addToWishlist(articleId);
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle wishlist: ${e.toString()}');
    }
  }
}