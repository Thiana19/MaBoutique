import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Article article;

  const ProductDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color primaryTextColor = Colors.black;
  static const Color secondaryTextColor = Color(0xFF6B7280);
  
  int _currentImageIndex = 0;
  String? _selectedSize;
  bool _isInWishlist = false;
  bool _isAddingToCart = false;
  bool _isTogglingWishlist = false;

  // Mock sizes - in real app, these would come from the article
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    if (AuthService.isLoggedIn) {
      try {
        final isInList = await WishlistService.isInWishlist(widget.article.id);
        setState(() {
          _isInWishlist = isInList;
        });
      } catch (e) {
        print('Error checking wishlist status: $e');
      }
    }
  }

  Future<void> _toggleWishlist() async {
    if (!AuthService.isLoggedIn) {
      _showLoginRequired();
      return;
    }

    setState(() {
      _isTogglingWishlist = true;
    });

    try {
      final result = await WishlistService.toggleWishlist(widget.article.id);
      setState(() {
        _isInWishlist = result;
        _isTogglingWishlist = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ? 'Added to wishlist' : 'Removed from wishlist'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isTogglingWishlist = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addToCart() async {
    if (!AuthService.isLoggedIn) {
      _showLoginRequired();
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await CartService.addToCart(
        articleId: widget.article.id,
        quantity: 1,
        size: _selectedSize,
      );
      
      // Refresh cart count
      if (mounted) {
        context.read<CartProvider>().refreshCartCount();
      }
      
      setState(() {
        _isAddingToCart = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to bag!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isAddingToCart = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to continue'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showProductDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Product Details Header
                Row(
                  children: [
                    Icon(Icons.description_outlined, color: primaryTextColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Brand
                if (widget.article.brand != null) ...[
                  _buildDetailRow('Brand', widget.article.brand!),
                  const Divider(height: 32),
                ],

                // Description
                _buildDetailRow('Description', widget.article.description ?? 'No description available'),
                const Divider(height: 32),

                // Stock Status
                _buildDetailRow(
                  'Stock Status',
                  widget.article.inStock ? 'In Stock (${widget.article.stockQuantity} available)' : 'Out of Stock',
                ),
                const Divider(height: 32),

                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.article.rating.toStringAsFixed(1)} (${widget.article.reviewCount})',
                          style: const TextStyle(color: primaryTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Shipping Info
                _buildDetailRow('Shipping', 'Free Shipping USD \$125+\nEstimated Delivery Friday, Dec. 19'),
                const Divider(height: 32),

                // Returns
                _buildDetailRow('Returns', '30-day Returns: Store Credit'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: primaryTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  Stack(
                    children: [
                        IconButton(
                        icon: const Icon(Icons.shopping_bag_outlined, color: primaryTextColor),
                        onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CartScreen()),
                            ).then((_) {
                            // Refresh cart count when returning from cart
                            context.read<CartProvider>().refreshCartCount();
                            });
                        },
                        ),
                        Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                            final cartCount = cartProvider.cartItemCount;
                            
                            if (cartCount == 0) return const SizedBox.shrink();
                            
                            return Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                                ),
                                child: Text(
                                cartCount > 99 ? '99+' : '$cartCount',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                ),
                            ),
                            );
                        },
                        ),
                    ],
                    ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Gallery
                    Stack(
                      children: [
                        Container(
                          height: 500,
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: Image.network(
                            widget.article.imageUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        
                        // NEW Badge
                        if (widget.article.isFeatured)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NEW!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                        // Share Button
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share_outlined),
                              onPressed: () {},
                            ),
                          ),
                        ),

                        // Image Indicators
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _currentImageIndex 
                                      ? Colors.white 
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Product Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            widget.article.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Rating
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < widget.article.rating.floor() 
                                      ? Icons.star 
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                '(${widget.article.reviewCount})',
                                style: TextStyle(color: secondaryTextColor),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _showProductDetails,
                                icon: Icon(Icons.wb_auto, size: 16, color: primaryTextColor),
                                label: const Text(
                                  'See Summary',
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Price
                          Row(
                            children: [
                              Text(
                                widget.article.formattedDiscountedPrice,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: widget.article.hasDiscount ? Colors.red : primaryTextColor,
                                ),
                              ),
                              if (widget.article.hasDiscount) ...[
                                const SizedBox(width: 12),
                                Text(
                                  widget.article.formattedPrice,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: secondaryTextColor,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Discount Banner
                          if (widget.article.hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                '50-99% Off EVERYTHING! Prices As Marked',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Size Selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Size',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryTextColor,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'View Size Guide',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Size Buttons
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _sizes.map((size) {
                              final isSelected = _selectedSize == size;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSize = size;
                                  });
                                },
                                child: Container(
                                  width: 60,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.black : Colors.white,
                                    border: Border.all(
                                      color: isSelected ? Colors.black : Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : primaryTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Shipping Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Shipping',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.local_shipping_outlined, size: 20, color: secondaryTextColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Get it by THU, DEC. 11 with International Express',
                                        style: TextStyle(color: secondaryTextColor, fontSize: 14),
                                      ),
                                    ),
                                    Icon(Icons.info_outline, size: 18, color: secondaryTextColor),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.card_giftcard_outlined, size: 20, color: secondaryTextColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'International Standard',
                                            style: TextStyle(color: secondaryTextColor, fontSize: 14),
                                          ),
                                          Text(
                                            'Free Shipping USD \$125+',
                                            style: TextStyle(color: secondaryTextColor, fontSize: 12),
                                          ),
                                          Text(
                                            'Estimated Delivery Friday, Dec. 19',
                                            style: TextStyle(color: secondaryTextColor, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.info_outline, size: 18, color: secondaryTextColor),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.sync_outlined, size: 20, color: secondaryTextColor),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '30-day Returns: Store Credit',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Product Details Button
                          InkWell(
                            onTap: _showProductDetails,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.description_outlined, color: primaryTextColor),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Product Details',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: primaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.chevron_right, color: secondaryTextColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 100), // Space for bottom buttons
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Action Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Wishlist Button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: _isInWishlist ? Colors.red : primaryTextColor,
                      ),
                      onPressed: _isTogglingWishlist ? null : _toggleWishlist,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Add to Bag Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAddingToCart ? null : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _isAddingToCart
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Add to bag',
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
          ),
        ],
      ),
    );
  }
}