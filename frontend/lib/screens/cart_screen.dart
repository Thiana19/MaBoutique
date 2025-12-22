import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartSummary? _cartSummary;
  bool _isLoading = true;
  bool _isUpdating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (!AuthService.isLoggedIn) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please login to view cart';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cart = await CartService.getCart();
      setState(() {
        _cartSummary = cart;
        _isLoading = false;
      });
      
      if (mounted) {
        context.read<CartProvider>().refreshCartCount();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) {
      _removeItem(item);
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await CartService.updateCartItem(
        cartItemId: item.id,
        quantity: newQuantity,
      );
      await _loadCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _removeItem(CartItem item) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await CartService.removeFromCart(item.id);
      await _loadCart();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _checkout() {
    if (_cartSummary == null || _cartSummary!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checkout coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _cartSummary != null 
              ? 'My Bag (${_cartSummary!.totalItems})' 
              : 'My Bag',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: theme.appBarTheme.foregroundColor),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      if (!AuthService.isLoggedIn)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Login'),
                        ),
                    ],
                  ),
                )
              : _cartSummary == null || _cartSummary!.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Your bag is empty',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Start Shopping'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Sync Banner
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email_outlined, size: 16, color: theme.textTheme.bodyLarge?.color),
                              const SizedBox(width: 8),
                              Text(
                                "Don't lose your bag! Sync it to your email.",
                                style: TextStyle(fontSize: 12, color: theme.textTheme.bodyLarge?.color),
                              ),
                            ],
                          ),
                        ),

                        // Cart Items List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 180),
                            itemCount: _cartSummary!.items.length,
                            itemBuilder: (context, index) {
                              return _buildCartItem(_cartSummary!.items[index]);
                            },
                          ),
                        ),
                      ],
                    ),
      bottomSheet: _cartSummary != null && _cartSummary!.items.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              _cartSummary!.formattedTotal,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.keyboard_arrow_down, color: theme.textTheme.bodyLarge?.color),
                          onPressed: () {
                            _showPriceBreakdown();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCartItem(CartItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.article.imageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item.article.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Price
                Row(
                  children: [
                    Text(
                      item.article.formattedDiscountedPrice,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: item.article.hasDiscount ? Colors.red : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (item.article.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        item.article.formattedPrice,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade500 : const Color(0xFF6B7280),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Discount Banner
                if (item.article.hasDiscount)
                  Text(
                    '50-99% Off EVERYTHING! Prices As Marked',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 8),

                // Size and Color
                Row(
                  children: [
                    Text(
                      'Size: ${item.size ?? "N/A"}',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade500 : const Color(0xFF6B7280), 
                        fontSize: 12
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '|', 
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade500 : const Color(0xFF6B7280)
                      )
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Color: ',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade500 : const Color(0xFF6B7280), 
                        fontSize: 12
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down, 
                        size: 16, 
                        color: theme.textTheme.bodyLarge?.color
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Stock Warning
                if (item.article.stockQuantity < 10)
                  Row(
                    children: [
                      Icon(Icons.warning_amber, size: 14, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Hurry! Just a few left',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                // Quantity Controls and Wishlist
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove, 
                              size: 18,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            onPressed: _isUpdating 
                                ? null 
                                : () => _updateQuantity(item, item.quantity - 1),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add, 
                              size: 18,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            onPressed: _isUpdating 
                                ? null 
                                : () => _updateQuantity(item, item.quantity + 1),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Move to Wishlist
                    IconButton(
                      icon: Icon(
                        Icons.favorite_border, 
                        size: 22,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      onPressed: () {
                        // TODO: Move to wishlist
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPriceBreakdown() {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              _buildPriceRow('Subtotal', _cartSummary!.formattedSubtotal),
              if (_cartSummary!.totalDiscount > 0) ...[
                const SizedBox(height: 12),
                _buildPriceRow(
                  'Discount',
                  '-${_cartSummary!.formattedDiscount}',
                  color: Colors.green,
                ),
              ],
              Divider(height: 32, color: theme.dividerColor),
              _buildPriceRow(
                'Total',
                _cartSummary!.formattedTotal,
                isBold: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color? color}) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}