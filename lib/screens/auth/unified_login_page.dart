import 'package:flutter/material.dart';
import '../../widgets/app_logo_widget.dart';
import '../../widgets/tech_animation_background.dart';
import '../../widgets/modern_ui_components.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../config/routes.dart';

/// Unified Login Page with Auto-Detection Role
/// Single login form for all roles (Customer, Admin, Teknisi)
/// Role is automatically detected from Firestore user data
class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login with auto-detection role
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Step 1: Authenticate with Firebase Auth
      final authResult = await AuthService.instance.signInWithEmail(
        email,
        password,
      );

      if (authResult == null || !mounted) {
        throw 'Authentication failed';
      }

      // Step 2: Get user data from Firestore to determine role
      final userData = await FirebaseService.instance.getUserById(
        authResult.uid,
      );

      if (userData == null || !mounted) {
        throw 'User data not found. Please contact administrator.';
      }

      // Step 3: Extract and validate role
      final role = userData['role']?.toString().toLowerCase() ?? 'customer';
      
      // Save to AuthService for app-wide access
      await AuthService.instance.setCurrentUserData(userData);

      // Step 4: Auto-route based on detected role
      if (!mounted) return;

      switch (role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, Routes.adminHome);
          break;
        
        case 'teknisi':
        case 'tech':
        case 'technician':
          Navigator.pushReplacementNamed(context, Routes.teknisiHome);
          break;
        
        case 'customer':
        case 'pelanggan':
        case 'user':
        default:
          Navigator.pushReplacementNamed(context, Routes.customerHome);
          break;
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${userData['name'] ?? 'User'}!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Login Failed',
          e.toString().contains('user-not-found')
              ? 'No account found with this email.'
              : e.toString().contains('wrong-password')
              ? 'Incorrect password. Please try again.'
              : e.toString().contains('network')
              ? 'Network error. Please check your connection.'
              : 'Login failed: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.cyanAccent, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.3)),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: Colors.cyanAccent, size: 28),
            SizedBox(width: 12),
            Text('Reset Password', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address to receive password reset instructions.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.email, color: Colors.cyanAccent),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyanAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                try {
                  await AuthService.instance.resetPassword(
                    emailController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Technology Background
          const TechAnimationBackground(),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Modern Logo with glow effect
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyanAccent.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const AppLogo(
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    const Text(
                      'AUDIRANET',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: Colors.cyanAccent,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Modern tagline
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'Connecting Your Digital Future',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Glassmorphism Login Form
                    GlassmorphismCard(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Title
                            const Text(
                              'WELCOME BACK',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Sign in to continue',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Animated Email Field
                            AnimatedTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Animated Password Field
                            AnimatedTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Remember Me & Forgot Password Row
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: Colors.cyanAccent,
                                  checkColor: Colors.black,
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Animated Login Button
                            AnimatedLoginButton(
                              onPressed: _login,
                              text: 'LOGIN',
                              isLoading: _isLoading,
                            ),

                            const SizedBox(height: 16),

                            // Info text
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.cyanAccent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.cyanAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your role will be automatically detected',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Help text
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Need Help?',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Support:',
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '📞 Call: 0800-123-4567',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  '📧 Email: support@audiranet.com',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  '💬 WhatsApp: +62 812-3456-7890',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.cyanAccent),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.help_outline,
                        color: Colors.white70,
                        size: 18,
                      ),
                      label: const Text(
                        'Need help signing in?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
