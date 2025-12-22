import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import 'api_service.dart';
import 'auth_service.dart';

class CartService {
  // Get user's cart with summary
  static Future<CartSummary> getCart() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/cart'),
        headers: ApiService.getHeaders(token: token),
      );

      print('📤 Get cart response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CartSummary.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch cart');
      }
    } catch (e) {
      print('❌ Get cart error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Add item to cart
  static Future<CartItem> addToCart({
    required int articleId,
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/cart'),
        headers: ApiService.getHeaders(token: token),
        body: jsonEncode({
          'article_id': articleId,
          'quantity': quantity,
          'size': size,
          'color': color,
        }),
      );

      print('📤 Add to cart response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CartItem.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to add to cart');
      }
    } catch (e) {
      print('❌ Add to cart error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update cart item
  static Future<CartItem> updateCartItem({
    required int cartItemId,
    int? quantity,
    String? size,
    String? color,
  }) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final body = <String, dynamic>{};
      if (quantity != null) body['quantity'] = quantity;
      if (size != null) body['size'] = size;
      if (color != null) body['color'] = color;

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/cart/$cartItemId'),
        headers: ApiService.getHeaders(token: token),
        body: jsonEncode(body),
      );

      print('📤 Update cart item response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CartItem.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to update cart item');
      }
    } catch (e) {
      print('❌ Update cart item error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart(int cartItemId) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/cart/$cartItemId'),
        headers: ApiService.getHeaders(token: token),
      );

      print('📤 Remove from cart response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to remove from cart');
      }
    } catch (e) {
      print('❌ Remove from cart error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Clear entire cart
  static Future<void> clearCart() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/cart'),
        headers: ApiService.getHeaders(token: token),
      );

      print('📤 Clear cart response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to clear cart');
      }
    } catch (e) {
      print('❌ Clear cart error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }
}