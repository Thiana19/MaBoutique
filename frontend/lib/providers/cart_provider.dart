import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';

class CartProvider extends ChangeNotifier {
  int _cartItemCount = 0;
  
  int get cartItemCount => _cartItemCount;

  // Load cart count
  Future<void> loadCartCount() async {
    if (!AuthService.isLoggedIn) {
      _cartItemCount = 0;
      notifyListeners();
      return;
    }

    try {
      final cart = await CartService.getCart();
      _cartItemCount = cart.totalItems;
      notifyListeners();
    } catch (e) {
      print('Error loading cart count: $e');
      _cartItemCount = 0;
      notifyListeners();
    }
  }

  // Refresh cart count (call this after adding/removing items)
  Future<void> refreshCartCount() async {
    await loadCartCount();
  }

  // Clear cart count (on logout)
  void clearCart() {
    _cartItemCount = 0;
    notifyListeners();
  }
}