import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              
              // App Logo - switches based on theme
              Container(
                height: 200,
                width: 200,
                child: Image.asset(
                  isDark ? 'assets/images/logo_white.png' : 'assets/images/logo_dark.png',
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Illustration
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main figure
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.person,
                        color: isDark ? Colors.white : Colors.black,
                        size: 40,
                      ),
                    ),
                    
                    // Question mark indicating forgot password
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        width: 30,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? Colors.white : Colors.black,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '?',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _emailController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Terms and conditions text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'By continuing, you agree to the Terms and Conditions',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Forgot Password Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle forgot password logic
                    if (_emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your email address'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Show success message and pop back
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link sent to your email'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Back to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Remember your password? ",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
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
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}