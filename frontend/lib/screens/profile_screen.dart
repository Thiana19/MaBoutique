import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import 'welcome_screen.dart';
import 'cart_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.logout();
              
              // Clear cart count
              if (mounted) {
                context.read<CartProvider>().clearCart();
              }
              
              Navigator.pop(context); // Close dialog
              
              // Navigate to WelcomeScreen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Account',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final cartCount = cartProvider.cartItemCount;
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shopping_bag_outlined, 
                      color: theme.appBarTheme.foregroundColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartCount > 0)
                    Positioned(
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
                          cartCount > 99 ? '9+' : '$cartCount',
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'HI, ${user?.fullName?.toUpperCase() ?? user?.username.toUpperCase() ?? 'GUEST'}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ),

            // Menu Items
            _buildMenuItem(
              context: context,
              icon: Icons.inventory_2_outlined,
              title: 'My Orders',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orders screen coming soon!')),
                );
              },
            ),

            _buildDivider(context),

            // Dark Theme Toggle
            _buildThemeToggle(context),

            _buildDivider(context),

            _buildMenuItem(
              context: context,
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help Center coming soon!')),
                );
              },
            ),

            _buildDivider(context),

            // Country/Region Section
            _buildMenuItem(
              context: context,
              icon: Icons.flag_outlined,
              iconWidget: Image.asset(
                'assets/images/usa_flag.png',
                width: 24,
                height: 24,
                errorBuilder: (ctx, error, stackTrace) {
                  return Icon(
                    Icons.flag_outlined, 
                    size: 24,
                    color: theme.textTheme.bodyLarge?.color,
                  );
                },
              ),
              title: 'USA',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '(USD)',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right, 
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280),
                  ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Country selector coming soon!')),
                );
              },
            ),

            const SizedBox(height: 24),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: InkWell(
                onTap: _signOut,
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      size: 24,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    IconData? icon,
    Widget? iconWidget,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            if (iconWidget != null)
              iconWidget
            else if (icon != null)
              Icon(icon, size: 24, color: theme.textTheme.bodyLarge?.color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right, 
                color: theme.brightness == Brightness.dark 
                    ? Colors.grey.shade400 
                    : const Color(0xFF6B7280),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode_outlined, 
            size: 24, 
            color: theme.textTheme.bodyLarge?.color,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Dark Theme',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? 'Dark theme enabled' : 'Light theme enabled'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: theme.dividerColor,
      ),
    );
  }
}