import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Function to build a common TextFormField with theme-aware styles
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBackgroundColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6);
    final textStyle = TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color);
    final placeholderColor = isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

    return Container(
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        style: textStyle,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: placeholderColor,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: placeholderColor,
          ),
          suffixIcon: suffixIcon,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                  
                  const SizedBox(height: 50),
                  
                  // First Name and Last Name Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _firstNameController,
                          hintText: 'First Name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _lastNameController,
                          hintText: 'Last Name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Username Field
                  _buildInputField(
                    controller: _usernameController,
                    hintText: 'Username',
                    icon: Icons.alternate_email,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email Field
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Phone Field
                  _buildInputField(
                    controller: _phoneController,
                    hintText: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password Field
                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
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
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  _buildInputField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible 
                          ? Icons.visibility_outlined 
                          : Icons.visibility_off_outlined,
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
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
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Already have account text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
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
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign In',
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
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signup(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('Sign up failed: ', '')),
            backgroundColor: Colors.red,
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
        content: Text('$platform signup not implemented yet'),
        backgroundColor: const Color(0xFF6B7280),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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