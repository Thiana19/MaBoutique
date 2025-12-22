import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wishlist_item.dart';
import '../services/wishlist_service.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<WishlistItem> _wishlistItems = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    if (!AuthService.isLoggedIn) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please login to view wishlist';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final items = await WishlistService.getWishlist();
      setState(() {
        _wishlistItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(WishlistItem item) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await WishlistService.removeFromWishlist(item.articleId);
      await _loadWishlist();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from wishlist'),
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
        _isProcessing = false;
      });
    }
  }

  Future<void> _addToCart(WishlistItem item) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await CartService.addToCart(
        articleId: item.articleId,
        quantity: 1,
      );
      
      // Refresh cart count
      if (mounted) {
        context.read<CartProvider>().refreshCartCount();
      }
      
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.article.name} added to bag!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'VIEW BAG',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRemoveConfirmation(WishlistItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Remove from Wishlist?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to remove "${item.article.name}" from your wishlist?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF374151) : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeFromWishlist(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _wishlistItems.isEmpty 
              ? 'My Wishlist' 
              : 'My Wishlist (${_wishlistItems.length})',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_wishlistItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.share_outlined, color: textColor),
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
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: isDark ? const Color(0xFF4B5563) : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF9CA3AF) : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!AuthService.isLoggedIn)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                          ),
                          child: const Text('Login'),
                        ),
                    ],
                  ),
                )
              : _wishlistItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: isDark ? const Color(0xFF374151) : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your wishlist is empty',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? const Color(0xFF9CA3AF) : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Save items you love for later',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.white : Colors.black,
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                            child: const Text('Start Shopping'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadWishlist,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.50,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _wishlistItems.length,
                        itemBuilder: (context, index) {
                          return _buildWishlistCard(_wishlistItems[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildWishlistCard(WishlistItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(article: item.article),
          ),
        ).then((_) => _loadWishlist());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3) 
                  : Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade200,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      item.article.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: isDark ? const Color(0xFF4B5563) : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Discount Badge
                if (item.article.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${item.article.discountPercentage.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Remove Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.red),
                      onPressed: _isProcessing ? null : () => _showRemoveConfirmation(item),
                    ),
                  ),
                ),
              ],
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    if (item.article.brand != null)
                      Text(
                        item.article.brand!,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    // Product Name
                    Text(
                      item.article.name,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          item.article.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          ' (${item.article.reviewCount})',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Row(
                      children: [
                        if (item.article.hasDiscount)
                          Text(
                            item.article.formattedPrice,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (item.article.hasDiscount) const SizedBox(width: 4),
                        Text(
                          item.article.formattedDiscountedPrice,
                          style: TextStyle(
                            color: item.article.hasDiscount ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : () => _addToCart(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isProcessing
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: isDark ? Colors.black : Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Add to Bag',
                                style: TextStyle(
                                  fontSize: 13,
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
      ),
    );
  }
}