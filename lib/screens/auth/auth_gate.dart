import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dart:developer' as developer;
import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_logo_widget.dart';

/// AUDIRA Auth Gate & Splash Session Gate
/// Inspects active Firebase Auth session and routes directly to role dashboards
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _resolveSession();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _resolveSession() async {
    // Provide a short, elegant duration for brand presentation
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        developer.log('Active session detected for uid: ${firebaseUser.uid}', name: 'AuthGate');
        final userData = await FirebaseService.instance.getUserById(firebaseUser.uid);

        if (userData != null) {
          await AuthService.instance.setCurrentUserData(userData);
          if (!mounted) return;
          final role = (userData['role'] ?? 'customer').toString().toLowerCase();

          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, Routes.adminHome);
            return;
          } else if (role == 'teknisi') {
            Navigator.pushReplacementNamed(context, Routes.teknisiHome);
            return;
          } else {
            Navigator.pushReplacementNamed(context, Routes.customerHome);
            return;
          }
        }
      }
    } catch (e) {
      developer.log('Error verifying session in AuthGate: $e', name: 'AuthGate');
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.unifiedLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withValues(alpha: isDark ? 0.35 : 0.2),
                      blurRadius: 36,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const AppLogo(width: 90, height: 90),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'AUDIRA DIGITAL NETWORK',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'High Performance ISP & Operations Hub',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
