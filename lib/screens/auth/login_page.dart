import 'package:flutter/material.dart';
import '../../widgets/app_logo_widget.dart';
import '../../widgets/tech_animation_background.dart';
import '../../widgets/modern_ui_components.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../config/routes.dart';

class LoginPage extends StatefulWidget {
  final bool isAdmin;
  final bool isTeknisi;

  const LoginPage({super.key, this.isAdmin = false, this.isTeknisi = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Determine user role based on login type
      UserRole targetRole;
      if (widget.isAdmin) {
        targetRole = UserRole.admin;
      } else if (widget.isTeknisi) {
        targetRole = UserRole.teknisi;
      } else {
        targetRole = UserRole.customer;
      }

      // Attempt login with AuthService
      final success = await AuthService.instance.login(
        _emailController.text.trim(),
        _passwordController.text,
        targetRole,
      );

      if (mounted) {
        if (success) {
          // Navigate based on successful role authentication
          if (widget.isAdmin) {
            Navigator.pushReplacementNamed(context, Routes.adminHome);
          } else if (widget.isTeknisi) {
            Navigator.pushReplacementNamed(context, Routes.teknisiHome);
          } else {
            Navigator.pushReplacementNamed(context, Routes.customerHome);
          }
        } else {
          _showErrorDialog(
            'Login gagal. Periksa email, password, dan pastikan Anda login dengan role yang benar.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Please contact administrator to reset your password.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.cyanAccent)),
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
                          fontSize: 16,
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
                            Text(
                              widget.isAdmin
                                  ? 'ADMIN ACCESS'
                                  : widget.isTeknisi
                                  ? 'TECHNICIAN PORTAL'
                                  : 'CUSTOMER LOGIN',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              widget.isAdmin
                                  ? 'System Administration Panel'
                                  : widget.isTeknisi
                                  ? 'Technical Support Interface'
                                  : 'Access Your Digital Services',
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

                            // Remember Me Checkbox
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
                              text: 'ACCESS SYSTEM',
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Back button
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white70,
                        size: 16,
                      ),
                      label: const Text(
                        'Back to Role Selection',
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
