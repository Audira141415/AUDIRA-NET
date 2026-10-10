import 'package:flutter/material.dart';
import 'dart:ui';
import '../../config/routes.dart';
import '../../widgets/app_logo_widget.dart';
import '../../widgets/tech_animation_background.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Professional Tech Background
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

                    // Enhanced Logo with glow effect
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyanAccent.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const AppLogo(
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Enhanced tagline
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Connecting Your Digital Future',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Enhanced section title
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SELECT ACCESS LEVEL',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Enhanced Role Buttons
                    _ProfessionalRoleButton(
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.loginCustomer),
                      icon: Icons.person_rounded,
                      title: 'CUSTOMER PORTAL',
                      subtitle: 'Access your personal dashboard',
                      primaryColor: const Color(0xFF4F46E5),
                      secondaryColor: const Color(0xFF7C3AED),
                    ),

                    const SizedBox(height: 20),

                    _ProfessionalRoleButton(
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.loginAdmin),
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'ADMIN CONSOLE',
                      subtitle: 'System administration panel',
                      primaryColor: const Color(0xFF059669),
                      secondaryColor: const Color(0xFF0891B2),
                    ),

                    const SizedBox(height: 20),

                    _ProfessionalRoleButton(
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.loginTeknisi),
                      icon: Icons.engineering_rounded,
                      title: 'TECH SUPPORT',
                      subtitle: 'Technical operations center',
                      primaryColor: const Color(0xFFDC2626),
                      secondaryColor: const Color(0xFFEA580C),
                    ),

                    const SizedBox(height: 50),

                    // Enhanced footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '© 2025 Audira Digital Network',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
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

class _ProfessionalRoleButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color secondaryColor;

  const _ProfessionalRoleButton({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_ProfessionalRoleButton> createState() =>
      _ProfessionalRoleButtonState();
}

class _ProfessionalRoleButtonState extends State<_ProfessionalRoleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    widget.primaryColor.withValues(alpha: _glowAnimation.value),
                    widget.secondaryColor.withValues(
                      alpha: _glowAnimation.value,
                    ),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.9),
                                Colors.white.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: widget.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            size: 32,
                            color: widget.primaryColor,
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Arrow icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
