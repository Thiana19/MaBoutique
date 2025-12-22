import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';
import '../widgets/nav_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // App Logo - switches based on theme
                    Container(
                      height: 80,
                      width: 200,
                      child: Image.asset(
                        isDark ? 'assets/images/logo_white.png' : 'assets/images/logo_dark.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Username/Email Field
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _usernameController,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible 
                                ? Icons.visibility_outlined 
                                : Icons.visibility_off_outlined,
                              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Don't have account text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // OR text
                    Text(
                      'or',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Social Login Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(
                          icon: FontAwesomeIcons.facebookF,
                          color: const Color(0xFF1877F2),
                          onTap: () {
                            _showSocialLoginNotImplemented('Facebook');
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: FontAwesomeIcons.instagram,
                          color: const Color(0xFFE4405F),
                          onTap: () {
                            _showSocialLoginNotImplemented('Instagram');
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: FontAwesomeIcons.apple,
                          color: isDark ? Colors.white : Colors.black,
                          onTap: () {
                            _showSocialLoginNotImplemented('Apple');
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: FontAwesomeIcons.twitter,
                          color: const Color(0xFF1DA1F2),
                          onTap: () {
                            _showSocialLoginNotImplemented('Twitter');
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔵 Attempting login with username: ${_usernameController.text.trim()}');
      
      await AuthService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      print('✅ Login successful');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Login error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSocialLoginNotImplemented(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$platform login not implemented yet'),
        backgroundColor: const Color(0xFF9CA3AF),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}