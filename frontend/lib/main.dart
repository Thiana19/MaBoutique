import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/nav_bar.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize authentication service
  await AuthService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MaBoutique',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppWrapper(),
          );
        },
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      // Check if user is logged in and token is valid
      final isValid = await AuthService.validateAuthentication();
      
      // Load cart count if authenticated
      if (isValid && mounted) {
        context.read<CartProvider>().loadCartCount(); 
      }
      
      setState(() {
        _isAuthenticated = isValid;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    
    return _isAuthenticated ? const MainNavigationScreen() : const WelcomeScreen();
  }
}