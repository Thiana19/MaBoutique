import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../services/article_service.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  
  List<Category> _categories = [];
  List<Article> _articles = [];
  bool _isLoading = true;
  bool _isCategoriesLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCartCount();
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isCategoriesLoading = true;
    });

    try {
      final categories = await ArticleService.getCategories();
      setState(() {
        _categories = categories;
        _isCategoriesLoading = false;
      });
      
      if (_categories.isNotEmpty) {
        _loadArticles();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isCategoriesLoading = false;
      });
      print('❌ Error loading categories: $e');
    }
  }

  Future<void> _loadArticles() async {
    if (_categories.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final categoryId = _categories[_selectedCategoryIndex].id;
      final articles = await ArticleService.getArticles(categoryId: categoryId);
      
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('❌ Error loading articles: $e');
    }
  }

  void _onCategoryTapped(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    _loadArticles();
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
        shadowColor: isDark ? Colors.transparent : Colors.grey.shade100,
        title: Text(
          'MaBoutique',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.star_border, color: theme.appBarTheme.foregroundColor, size: 20),
            label: Text(
              'For You',
              style: TextStyle(
                color: theme.appBarTheme.foregroundColor, 
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: Column(
        children: [
          // Category Slider
          _isCategoriesLoading
              ? const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedCategoryIndex;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 16.0 : 8.0,
                          right: index == _categories.length - 1 ? 16.0 : 8.0,
                        ),
                        child: GestureDetector(
                          onTap: () => _onCategoryTapped(index),
                          child: Center(
                            child: Text(
                              _categories[index].name,
                              style: TextStyle(
                                color: isSelected 
                                    ? theme.textTheme.bodyLarge?.color 
                                    : (isDark ? Colors.grey.shade500 : const Color(0xFF6B7280)),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: _categories.isEmpty
                      ? 'Search...'
                      : 'Search within ${_categories[_selectedCategoryIndex].name}',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade600 : const Color(0xFF6B7280), 
                    fontSize: 14
                  ),
                  prefixIcon: Icon(
                    Icons.search, 
                    color: isDark ? Colors.grey.shade600 : const Color(0xFF6B7280)
                  ),
                  suffixIcon: Icon(
                    Icons.camera_alt_outlined, 
                    color: isDark ? Colors.grey.shade600 : const Color(0xFF6B7280)
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadArticles,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadArticles,
                        child: ListView(
                          padding: const EdgeInsets.only(top: 16),
                          children: [
                            // Promotional Banner
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 20,
                                      top: 20,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'WINTER SALE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Up to 50% OFF',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 20,
                                      bottom: 20,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.blue.shade700,
                                        ),
                                        child: const Text('Shop Now'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Articles Section
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _categories.isEmpty
                                        ? 'Products'
                                        : '${_categories[_selectedCategoryIndex].name} (${_articles.length})',
                                    style: TextStyle(
                                      color: theme.textTheme.titleLarge?.color,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('See All'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Grid of Articles
                            _articles.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Text(
                                        'No articles found',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.60,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                      itemCount: _articles.length,
                                      itemBuilder: (context, index) {
                                        return _buildArticleCard(_articles[index]);
                                      },
                                    ),
                                  ),
                            
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(article: article),
          ),
        ).then((_) {
          context.read<CartProvider>().refreshCartCount();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
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
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      article.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                // Discount Badge
                if (article.hasDiscount)
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
                        '-${article.discountPercentage.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.favorite_border, 
                        size: 20,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      onPressed: () {
                        print('Add to wishlist: ${article.name}');
                      },
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand
                        if (article.brand != null)
                          Text(
                            article.brand!,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        // Product Name
                        Text(
                          article.name,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Rating and Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              article.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            Text(
                              ' (${article.reviewCount})',
                              style: TextStyle(
                                fontSize: 12, 
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Price
                        Row(
                          children: [
                            if (article.hasDiscount)
                              Text(
                                article.formattedPrice,
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            if (article.hasDiscount) const SizedBox(width: 4),
                            Text(
                              article.formattedDiscountedPrice,
                              style: TextStyle(
                                color: article.hasDiscount ? Colors.red : theme.textTheme.bodyLarge?.color,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
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