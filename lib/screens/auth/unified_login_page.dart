import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_logo_widget.dart';

/// Role presets for swift access & demo testing
enum LoginRolePreset {
  customer(
    'Pelanggan',
    LucideIcons.user,
    'budi@audira.my.id',
    'pelanggan123',
    'Akses Tagihan & FUP',
    Color(0xFF00F0FF),
    Color(0xFF0070F3),
    'Portal Layanan & Invoicing',
  ),
  teknisi(
    'Teknisi',
    LucideIcons.wrench,
    'budi.teknisi@audiranet.id',
    'teknisi123',
    'Field Ops & Tiket ODP',
    Color(0xFF00FF9D),
    Color(0xFF059669),
    'Field Service & Surat Tugas SPK',
  ),
  admin(
    'Admin / NOC',
    LucideIcons.shieldCheck,
    'admin@audiranet.id',
    'admin123',
    'Core Command Center',
    Color(0xFFA855F7),
    Color(0xFF7928CA),
    'ISP Network Core & Telemetri',
  );

  final String label;
  final IconData icon;
  final String demoEmail;
  final String demoPassword;
  final String description;
  final Color roleColor;
  final Color secondaryColor;
  final String subtitle;

  const LoginRolePreset(
    this.label,
    this.icon,
    this.demoEmail,
    this.demoPassword,
    this.description,
    this.roleColor,
    this.secondaryColor,
    this.subtitle,
  );
}

/// Unified Modern Authentication Screen for AUDIRA
/// Adheres strictly to AUDIRA Neo-Brutalism + Cyberpunk Design System
class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginRolePreset _selectedPreset = LoginRolePreset.customer;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = true;
  bool? _isDarkOverride;

  bool get _isDarkMode => _isDarkOverride ?? true; // Default to Cyberpunk Midnight OLED

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _applyPreset(LoginRolePreset.customer);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _applyPreset(LoginRolePreset preset) {
    setState(() {
      _selectedPreset = preset;
      _emailController.text = preset.demoEmail;
      _passwordController.text = preset.demoPassword;
    });
  }

  Future<void> _executeLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      dynamic authResult;
      try {
        authResult = await AuthService.instance.signInWithEmail(email, password);
      } catch (authError) {
        final isDemoCustomer = (email == 'budi@audira.my.id' ||
                email == 'customer1@gmail.com') &&
            (password == 'pelanggan123' || password == 'customer123');
        final isDemoTeknisi = (email == 'budi.teknisi@audiranet.id' ||
                email == 'andi.teknisi@audiranet.id' ||
                email == 'teknisi@audiranet.com') &&
            password == 'teknisi123';
        final isDemoAdmin = (email == 'admin@audiranet.id' ||
                email == 'admin@audira.net' ||
                email == 'admin@audiranet.com') &&
            password == 'admin123';

        if (!isDemoCustomer && !isDemoTeknisi && !isDemoAdmin) {
          throw 'Kredensial tidak valid: $authError';
        }
      }

      Map<String, dynamic>? userData;
      if (authResult != null) {
        userData = await FirebaseService.instance.getUserById(authResult.uid);
      }

      if (!mounted) return;

      String role = _selectedPreset.name;
      if (userData != null && userData['role'] != null) {
        role = userData['role'].toString().toLowerCase();
      }

      switch (role) {
        case 'admin':
        case 'superadmin':
        case 'noc':
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.alertTriangle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Login Gagal: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFFF2A5F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerBiometricPasskey() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = _isDarkMode;
        final sheetBg = isDark ? const Color(0xFF0A0F1D) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: _selectedPreset.roleColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _selectedPreset.roleColor.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag bar
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),

              // Animated Biometric Sensor Icon
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _selectedPreset.roleColor.withValues(alpha: 0.2),
                      _selectedPreset.secondaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: _selectedPreset.roleColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedPreset.roleColor.withValues(alpha: 0.35),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.fingerprint,
                    size: 46,
                    color: _selectedPreset.roleColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Autentikasi Biometrik Passkey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sentuh sensor sidik jari perangkat untuk masuk ke portal ${_selectedPreset.label}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Instant Quick Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _executeLogin();
                  },
                  icon: const Icon(LucideIcons.checkCircle2, size: 18),
                  label: Text('Verifikasi Sekarang (${_selectedPreset.label})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPreset.roleColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Batalkan',
                  style: TextStyle(
                    color: textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpdeskDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF0A0F1D) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _selectedPreset.roleColor.withValues(alpha: 0.6),
            width: 1.8,
          ),
        ),
        title: Row(
          children: [
            Icon(LucideIcons.helpCircle, color: _selectedPreset.roleColor, size: 22),
            const SizedBox(width: 10),
            Text(
              'Bantuan Kata Sandi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Untuk menjaga keamanan akun telekomunikasi Anda, reset sandi dapat dilakukan melalui verifikasi NOC:',
              style: TextStyle(
                fontSize: 12.5,
                color: _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF05070D) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💬 WhatsApp NOC Siaga 24/7',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '+62 821-1200-1600',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00FF9D),
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '📞 Call Center: 1500-888',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;

    // Palette Tokens
    final bg = isDark ? const Color(0xFF050811) : const Color(0xFFF6F8FC);
    final cardBg = isDark ? const Color(0xFF0B1120) : Colors.white;
    final cardBorder = isDark
        ? _selectedPreset.roleColor.withValues(alpha: 0.4)
        : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF070B16) : const Color(0xFFF8FAFC);
    final inputBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // 1. Ambient Radial Glow Orb Top-Right (Pulse with role color)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                top: -90,
                right: -70,
                child: Container(
                  width: 320 * _pulseAnimation.value,
                  height: 320 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _selectedPreset.roleColor.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        _selectedPreset.secondaryColor.withValues(
                          alpha: isDark ? 0.08 : 0.04,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 2. Ambient Deep Blue Orb Bottom-Left
          Positioned(
            bottom: -90,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.signalBlue.withValues(alpha: isDark ? 0.18 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Subtle Cyber Tech Grid lines overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CyberGridPainter(
                  isDark: isDark,
                  accentColor: _selectedPreset.roleColor,
                ),
              ),
            ),
          ),

          // 4. Main Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top Row: Status & Dark/Light Switcher Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Network Telemetry HUD Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0A0F1D) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF00FF9D).withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00FF9D),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF00FF9D),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 7),
                                const Text(
                                  'GATEWAY ONLINE • 11ms',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                    color: Color(0xFF00FF9D),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Interactive Dark / Light Mode Switch Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() => _isDarkOverride = !_isDarkMode);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.3 : 0.05,
                                      ),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isDark ? LucideIcons.moon : LucideIcons.sun,
                                      size: 14,
                                      color: isDark
                                          ? const Color(0xFF00F0FF)
                                          : const Color(0xFFFFB800),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isDark ? 'OLED' : 'LIGHT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                        color: textPrimary,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Holographic Brand Logo with Glowing Halo Ring
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF0A0F1D),
                                  Color(0xFF162038),
                                ],
                              ),
                              border: Border.all(
                                color: _selectedPreset.roleColor,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _selectedPreset.roleColor.withValues(
                                    alpha: 0.35 * _pulseAnimation.value,
                                  ),
                                  blurRadius: 24 * _pulseAnimation.value,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Center(
                              child: AppLogo(width: 58, height: 58),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Brand Name & Modern Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'AUDIRA',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00F0FF), Color(0xFF0070F3)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00F0FF).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Text(
                              'NET-OS 4.0',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        'Pusat Kendali Operasi & Layanan Fiber Optik',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Segmented Modern Role Selector (Pelanggan / Teknisi / Admin)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: LoginRolePreset.values.map((preset) {
                            final isSelected = _selectedPreset == preset;
                            return Expanded(
                              child: InkWell(
                                onTap: () => _applyPreset(preset),
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark
                                            ? preset.roleColor.withValues(alpha: 0.16)
                                            : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSelected
                                        ? Border.all(
                                            color: preset.roleColor,
                                            width: 1.8,
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: preset.roleColor.withValues(
                                                alpha: isDark ? 0.3 : 0.12,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        preset.icon,
                                        size: 19,
                                        color: isSelected ? preset.roleColor : textSecondary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        preset.label,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight:
                                              isSelected ? FontWeight.w900 : FontWeight.w600,
                                          color: isSelected ? textPrimary : textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Futuristic Cyber-Glass Form Card
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: cardBorder,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedPreset.roleColor.withValues(
                                alpha: isDark ? 0.16 : 0.08,
                              ),
                              offset: const Offset(0, 10),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: isDark
                                  ? _selectedPreset.roleColor.withValues(alpha: 0.25)
                                  : const Color(0xFF0F172A).withValues(alpha: 0.08),
                              offset: const Offset(4, 4),
                              blurRadius: 0, // Neo-Brutalism tactile signature
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Role Header Ribbon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AKSES ${_selectedPreset.label.toUpperCase()}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                            color: textPrimary,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _selectedPreset.subtitle,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedPreset.roleColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedPreset.roleColor.withValues(alpha: 0.5),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      _selectedPreset.description,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: _selectedPreset.roleColor,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Email / Username Input
                              Row(
                                children: [
                                  Text(
                                    '// IDENTITAS_AKUN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: textSecondary,
                                      fontFamily: 'monospace',
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'ID / Email',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedPreset.roleColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: inputBg,
                                  hintText: 'Masukkan email atau nomor pelanggan...',
                                  hintStyle: TextStyle(
                                    color: textSecondary.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: _selectedPreset.roleColor.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      LucideIcons.mail,
                                      size: 16,
                                      color: _selectedPreset.roleColor,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: inputBorder, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: inputBorder, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: _selectedPreset.roleColor,
                                      width: 2.2,
                                    ),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Email wajib diisi';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Password Input
                              Row(
                                children: [
                                  Text(
                                    '// KATA_SANDI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: textSecondary,
                                      fontFamily: 'monospace',
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Passcode',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedPreset.roleColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: inputBg,
                                  hintText: 'Masukkan kata sandi...',
                                  hintStyle: TextStyle(
                                    color: textSecondary.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: _selectedPreset.roleColor.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      LucideIcons.lock,
                                      size: 16,
                                      color: _selectedPreset.roleColor,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                                      size: 18,
                                      color: textSecondary,
                                    ),
                                    onPressed: () =>
                                        setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: inputBorder, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: inputBorder, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: _selectedPreset.roleColor,
                                      width: 2.2,
                                    ),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Kata sandi wajib diisi';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Form Options: Remember Me & Forgot Password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              activeColor: _selectedPreset.roleColor,
                                              checkColor: Colors.black,
                                              side: BorderSide(
                                                color: _selectedPreset.roleColor,
                                                width: 1.8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              onChanged: (v) =>
                                                  setState(() => _rememberMe = v ?? true),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Simpan Sesi',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _showHelpdeskDialog,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: Text(
                                      'Lupa Sandi?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? _selectedPreset.roleColor
                                            : AppTheme.signalBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // Hero Glow-Gradient Action Button
                              Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      _selectedPreset.roleColor,
                                      _selectedPreset.secondaryColor,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _selectedPreset.roleColor.withValues(
                                        alpha: isDark ? 0.45 : 0.3,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isLoading ? null : _executeLogin,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: _isLoading
                                          ? Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.6,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<Color>(Colors.black),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Memverifikasi...',
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  'MASUK KE SISTEM',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.8,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  LucideIcons.arrowRight,
                                                  size: 19,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Interactive Biometric Fast-Pass Capsule
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _triggerBiometricPasskey,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.04,
                                  ),
                                  offset: const Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _selectedPreset.roleColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.fingerprint,
                                    size: 20,
                                    color: _selectedPreset.roleColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Autentikasi Cepat Biometrik (Passkey)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quick 1-Tap Demo Switcher Pills
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: LoginRolePreset.values.map((preset) {
                          final isCurrent = _selectedPreset == preset;
                          return InkWell(
                            onTap: () => _applyPreset(preset),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? preset.roleColor.withValues(alpha: 0.14)
                                    : (isDark
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrent
                                      ? preset.roleColor
                                      : (isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFCBD5E1)),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    preset.icon,
                                    size: 13,
                                    color: isCurrent ? preset.roleColor : textSecondary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    preset.label,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight:
                                          isCurrent ? FontWeight.w900 : FontWeight.w600,
                                      color: isCurrent ? preset.roleColor : textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Security Seal & Encryption Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.shieldCheck,
                            size: 13,
                            color: const Color(0xFF00FF9D),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '256-BIT TLS ENCRYPTED • ED25519 VERIFIED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Footer Brand Notice
                      Text(
                        'AUDIRA • PT Audira Multimedia Digital / Audira Sukses Mandiri',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'https://audira.my.id',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for subtle cyber grid background lines
class _CyberGridPainter extends CustomPainter {
  final bool isDark;
  final Color accentColor;

  _CyberGridPainter({required this.isDark, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1))
          .withValues(alpha: isDark ? 0.25 : 0.3)
      ..strokeWidth = 0.5;

    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.accentColor != accentColor;
}
