import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const Color activeIconColor = Colors.black;
  static const Color inactiveIconColor = Color(0xFF6B7280);
  
  int _selectedIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(), // Home content without bottom nav
    const CartScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Refresh cart count when navigating to cart
    if (index == 1) {
      context.read<CartProvider>().refreshCartCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark 
              ? const Color(0xFF1E1E1E) 
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildBagIcon(activeIconColor),
              label: 'Bag',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Wishlist',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.brightness == Brightness.dark ? Colors.white : activeIconColor,
          unselectedItemColor: inactiveIconColor,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  // Helper widget for the bag icon with a badge showing cart count
  Widget _buildBagIcon(Color activeColor) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartCount = cartProvider.cartItemCount;
        
        return Stack(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: _selectedIndex == 1 ? activeColor : inactiveIconColor,
            ),
            if (cartCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
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
              ),
          ],
        );
      },
    );
  }
}