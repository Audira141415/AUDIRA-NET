import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../widgets/app_logo_widget.dart';
import '../../utils/app_theme.dart';
import '../../widgets/cyber_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../config/routes.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// =============================================================================
///                 AUDIRA-NET TACTICAL CYBERPUNK AUTHENTICATION TERMINAL
///                 Designed & Engineered under AUDIRA UI/UX Intelligence
///                 Author: Agus Dwi Rianto (AUDIRA)
///                 Brand: Audira Multimedia Digital / Audira Sukses Mandiri
/// =============================================================================
class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

enum LoginRolePreset {
  customer('PELANGGAN', AppTheme.neonCyan, HugeIcons.strokeRoundedWifi01, 'budi@audira.my.id', 'pelanggan123'),
  teknisi('TEKNISI', AppTheme.neonGreen, HugeIcons.strokeRoundedWrench01, 'budi.teknisi@audiranet.id', 'teknisi123'),
  admin('NOC / ADMIN', AppTheme.neonAmber, HugeIcons.strokeRoundedCpu, 'admin@audiranet.id', 'admin123');

  final String label;
  final Color accentColor;
  final List<List<dynamic>> icon;
  final String demoEmail;
  final String demoPassword;

  const LoginRolePreset(
    this.label,
    this.accentColor,
    this.icon,
    this.demoEmail,
    this.demoPassword,
  );
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginRolePreset _selectedPreset = LoginRolePreset.customer;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = true;
  String _authStepMessage = 'READY FOR IDENTIFICATION';

  // Animation Controllers for Fluid Micro-Interactions
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _gridFlowController;
  late AnimationController _reticleRotationController;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();

    // Default pre-fill demo customer for instantaneous testing
    _emailController.text = LoginRolePreset.customer.demoEmail;
    _passwordController.text = LoginRolePreset.customer.demoPassword;

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _gridFlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _reticleRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _gridFlowController.dispose();
    _reticleRotationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _applyQuickPreset(LoginRolePreset preset) {
    setState(() {
      _selectedPreset = preset;
      _emailController.text = preset.demoEmail;
      _passwordController.text = preset.demoPassword;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: preset.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: preset.accentColor.withValues(alpha: 0.5)),
              ),
              child: HugeIcon(icon: preset.icon, color: preset.accentColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRESET ${preset.label} AKTIF',
                    style: TextStyle(
                      color: preset.accentColor,
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    preset.demoEmail,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.cyberObsidian,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 28, left: 18, right: 18),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: preset.accentColor.withValues(alpha: 0.8), width: 1.2),
        ),
      ),
    );
  }

  Future<void> _executeLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _authStepMessage = 'MEMVERIFIKASI ENKRIPSI SESI...';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      setState(() => _authStepMessage = 'MENGHUBUNGI GATEWAY AUDIRA...');

      // Step 1: Authenticate with Firebase Auth (or seamless demo fallback)
      dynamic authResult;
      try {
        authResult = await AuthService.instance.signInWithEmail(email, password);
      } catch (authError) {
        // Check for verified demo preset accounts
        final isDemoCustomer = (email == 'budi@audira.my.id' || email == 'customer1@gmail.com') &&
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

      setState(() => _authStepMessage = 'MENDETEKSI HAK AKSES ROLE...');

      // Step 2: Determine role & user data
      Map<String, dynamic>? userData;
      if (authResult != null) {
        userData = await FirebaseService.instance.getUserById(authResult.uid);
      }

      if (!mounted) return;

      String role = _selectedPreset.name;
      if (userData != null && userData['role'] != null) {
        role = userData['role'].toString().toLowerCase();
        await AuthService.instance.setCurrentUserData(userData);
      } else {
        // Fallback demo user payload based on email or preset
        if (email.contains('admin') || email.contains('noc')) {
          role = 'admin';
        } else if (email.contains('teknisi') || email.contains('tech')) {
          role = 'teknisi';
        } else {
          role = 'customer';
        }

        final displayName = role == 'admin'
            ? 'ADMIN NOC AUDIRA'
            : role == 'teknisi'
                ? 'BUDI TEKNISI'
                : 'BUDI PELANGGAN';

        await AuthService.instance.setCurrentUserData({
          'id': 'usr-${DateTime.now().millisecondsSinceEpoch}',
          'name': displayName,
          'email': email,
          'role': role,
        });
      }

      setState(() => _authStepMessage = 'AKSES DITERIMA. MEMUAT TERMINAL...');
      await Future.delayed(const Duration(milliseconds: 300));

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selamat datang di AUDIRANET, ${email.split('@').first}!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppTheme.neonGreen.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        _showCyberErrorDialog('LOGIN FAILED // ACCESS DENIED', e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _authStepMessage = 'READY FOR IDENTIFICATION';
        });
      }
    }
  }

  void _triggerBiometricScan() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BiometricScannerSheet(
        preset: _selectedPreset,
        onAuthenticated: () {
          Navigator.pop(context);
          _applyQuickPreset(_selectedPreset);
          _executeLogin();
        },
      ),
    );
  }

  void _showCyberErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF080D1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.neonCrimson, width: 1.5),
        ),
        title: Row(
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedAlert02, color: AppTheme.neonCrimson, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'TUTUP',
              style: TextStyle(
                color: AppTheme.neonCrimson,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailResetCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF080D1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.neonCyan, width: 1.2),
        ),
        title: const Row(
          children: [
            HugeIcon(icon: HugeIcons.strokeRoundedLockKey, color: AppTheme.neonCyan, size: 20),
            SizedBox(width: 8),
            Text(
              'RESET ACCESS KEY',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tautan reset kata sandi akan dikirim ke alamat email resmi yang terdaftar:',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailResetCtrl,
              style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 14, fontFamily: 'monospace'),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF040713),
                hintText: 'user@audiranet.id',
                hintStyle: const TextStyle(color: Color(0xFF475569)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: HugeIcon(icon: HugeIcons.strokeRoundedMail02, color: AppTheme.neonCyan, size: 18),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.neonCyan),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: Color(0xFF64748B), fontFamily: 'monospace')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailResetCtrl.text.isNotEmpty) {
                try {
                  await AuthService.instance.resetPassword(emailResetCtrl.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tautan reset kata sandi telah dikirim ke email!'),
                        backgroundColor: AppTheme.neonGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengirim: $e'), backgroundColor: AppTheme.neonCrimson),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonCyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('KIRIM TAUTAN', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF080D1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.neonCyan, width: 2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedCustomerService, color: AppTheme.neonCyan, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'AUDIRA OFFICIAL NOC HELPDESK',
                    style: TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Layanan dukungan teknis, aktivasi fiber, dan billing resmi AUDIRA.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 20),
              _buildHelpContactTile(
                icon: HugeIcons.strokeRoundedBubbleChatQuestion,
                color: AppTheme.neonGreen,
                title: 'WhatsApp Hotline Resmi (24/7)',
                value: '+62 821-1200-1600',
              ),
              const SizedBox(height: 10),
              _buildHelpContactTile(
                icon: HugeIcons.strokeRoundedGlobe02,
                color: AppTheme.neonCyan,
                title: 'Official Domain & Portal',
                value: 'https://audira.my.id',
              ),
              const SizedBox(height: 10),
              _buildHelpContactTile(
                icon: HugeIcons.strokeRoundedMail02,
                color: AppTheme.neonViolet,
                title: 'Executive Founder & Support',
                value: 'agusdwirianto@gmail.com',
              ),
              const SizedBox(height: 10),
              _buildHelpContactTile(
                icon: HugeIcons.strokeRoundedShieldCheck,
                color: AppTheme.neonAmber,
                title: 'Entitas Kepemilikan Sistem',
                value: 'Audira Multimedia Digital / Audira Sukses Mandiri',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CyberActionButton(
                  label: 'TUTUP PUSAT BANTUAN',
                  icon: LucideIcons.x,
                  color: const Color(0xFF94A3B8),
                  isSecondary: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpContactTile({
    required dynamic icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF040713),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: icon is IconData
                ? Icon(icon, color: color, size: 18)
                : icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final activeAccent = _selectedPreset.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          // 1. Dynamic Cyber Background Matrix, Telemetry Packets & Scanlines
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberBackgroundGridPainter(
                gridFlow: _gridFlowController.value,
                accentColor: activeAccent,
              ),
            ),
          ),

          // 2. Ambient Top Radial Energy Glow
          Positioned(
            top: -140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      activeAccent.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Main Scrollable Interface
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // HUD Telemetry Header Strip
                      _buildTopTelemetryStrip(activeAccent),
                      const SizedBox(height: 22),

                      // Holographic App Brand Reticle
                      _buildBrandIdentity(activeAccent),
                      const SizedBox(height: 26),

                      // Tactical Role Quick-Matrix Chips
                      _buildRoleSelectorMatrix(),
                      const SizedBox(height: 20),

                      // The Tactical Obsidian Form Card
                      _buildObsidianAuthCard(activeAccent),
                      const SizedBox(height: 18),

                      // Biometric / Fast Touch Access
                      _buildBiometricAccessRow(activeAccent),
                      const SizedBox(height: 20),

                      // System Help & Legal Footprint
                      _buildFooterSupport(),
                      const SizedBox(height: 12),
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

  // Top Status Bar: Latency & Node ID
  Widget _buildTopTelemetryStrip(Color activeAccent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEE090E20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonCyan.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CyberPulseDot(color: AppTheme.neonGreen, size: 8),
          SizedBox(width: 8),
          Text(
            'NODE: AUD-JKT01',
            style: TextStyle(
              color: Color(0xFFE2E8F0),
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF475569),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            'ENC: TLS 1.3',
            style: TextStyle(
              color: AppTheme.neonCyan,
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF475569),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            'PING: 14ms',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF475569),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            'NOC: ON',
            style: TextStyle(
              color: AppTheme.neonCyan,
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // Holographic Glowing Reticle Logo & Title with Rotating Radar
  Widget _buildBrandIdentity(Color activeAccent) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Ambient outer glow
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    activeAccent.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Rotating Tactical Radar Reticle
            AnimatedBuilder(
              animation: _reticleRotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _reticleRotationController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: const Size(116, 116),
                    painter: _RadarReticlePainter(accentColor: activeAccent),
                  ),
                );
              },
            ),

            // Outer Pulsing Neon Ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: activeAccent.withValues(alpha: 0.4 * _pulseController.value + 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeAccent.withValues(alpha: 0.35 * _pulseController.value),
                        blurRadius: 30 * _pulseController.value,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Inner Obsidian Circle with Logo
            Container(
              width: 86,
              height: 86,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF060B18),
                shape: BoxShape.circle,
                border: Border.all(color: activeAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: activeAccent.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const AppLogo(
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Brand Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'AUDIRA',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: Color(0xFFF8FAFC),
                letterSpacing: 5.0,
              ),
            ),
            Text(
              'NET',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: activeAccent,
                letterSpacing: 5.0,
                shadows: [
                  Shadow(color: activeAccent.withValues(alpha: 0.9), blurRadius: 20),
                  Shadow(color: activeAccent, blurRadius: 8),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Subtitle Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: activeAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: activeAccent.withValues(alpha: 0.45), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: activeAccent.withValues(alpha: 0.15),
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(
            '// TACTICAL ISP & NOC TERMINAL GATEWAY',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
              color: activeAccent,
              letterSpacing: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  // Tactical Role Matrix
  Widget _buildRoleSelectorMatrix() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF070B16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: LoginRolePreset.values.map((preset) {
          final isSelected = _selectedPreset == preset;
          return Expanded(
            child: GestureDetector(
              onTap: () => _applyQuickPreset(preset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? preset.accentColor.withValues(alpha: 0.22)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? preset.accentColor : Colors.transparent,
                    width: 1.4,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: preset.accentColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: preset.icon,
                      size: 15,
                      color: isSelected ? preset.accentColor : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      preset.label,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected ? const Color(0xFFF8FAFC) : const Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // The Tactical Obsidian Form Card with HUD Corner Brackets
  Widget _buildObsidianAuthCard(Color activeAccent) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080D1E).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeAccent.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activeAccent.withValues(alpha: 0.16),
            blurRadius: 32,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Color(0xEE000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Tactical HUD corner reticles
          Positioned(
            top: 10,
            left: 10,
            child: _buildHudCorner(activeAccent, isTop: true, isLeft: true),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _buildHudCorner(activeAccent, isTop: true, isLeft: false),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: _buildHudCorner(activeAccent, isTop: false, isLeft: true),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: _buildHudCorner(activeAccent, isTop: false, isLeft: false),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: activeAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: activeAccent,
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'TERMINAL ACCESS',
                                style: TextStyle(
                                  color: Color(0xFFF8FAFC),
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Masuk untuk mengelola bandwidth & akun',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: activeAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: activeAccent.withValues(alpha: 0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: activeAccent.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: activeAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PORT: 443',
                              style: TextStyle(
                                color: activeAccent,
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Field 1: User Identifier / Email
                  _buildCyberInputField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    isFocused: _isEmailFocused,
                    label: 'IDENTIFIER / EMAIL PELANGGAN',
                    hintText: 'nama@audira.my.id',
                    icon: HugeIcons.strokeRoundedMail02,
                    keyboardType: TextInputType.emailAddress,
                    accentColor: activeAccent,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Alamat email wajib diisi';
                      if (!val.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Field 2: Password with Reveal Toggle
                  _buildCyberInputField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    isFocused: _isPasswordFocused,
                    label: 'SECURITY KEY / SANDI',
                    hintText: '••••••••',
                    icon: HugeIcons.strokeRoundedSecurityLock,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    accentColor: activeAccent,
                    onToggleVisibility: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Kata sandi wajib diisi';
                      if (val.length < 6) return 'Minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Remember Me & Forgot Password Row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _rememberMe
                                    ? activeAccent.withValues(alpha: 0.25)
                                    : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _rememberMe ? activeAccent : const Color(0xFF334155),
                                  width: 1.5,
                                ),
                              ),
                              child: _rememberMe
                                  ? Icon(LucideIcons.check, size: 13, color: activeAccent)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Kunci Sesi',
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showForgotPasswordDialog,
                        child: Text(
                          'Lupa Sandi?',
                          style: TextStyle(
                            color: activeAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            shadows: [
                              Shadow(color: activeAccent.withValues(alpha: 0.5), blurRadius: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // The Action Shimmer Button
                  _buildActionShimmerButton(activeAccent),
                  const SizedBox(height: 14),

                  // Auto Role Detection Notice
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: activeAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: activeAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedSparkles, color: activeAccent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLoading ? _authStepMessage : 'Role otomatis terdeteksi dari database saat masuk.',
                            style: TextStyle(
                              color: _isLoading ? activeAccent : const Color(0xFF94A3B8),
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: _isLoading ? FontWeight.bold : FontWeight.normal,
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
        ],
      ),
    );
  }

  // Tactical HUD corner reticles
  Widget _buildHudCorner(Color color, {required bool isTop, required bool isLeft}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: color.withValues(alpha: 0.65), width: 1.8) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: color.withValues(alpha: 0.65), width: 1.8) : BorderSide.none,
          left: isLeft ? BorderSide(color: color.withValues(alpha: 0.65), width: 1.8) : BorderSide.none,
          right: !isLeft ? BorderSide(color: color.withValues(alpha: 0.65), width: 1.8) : BorderSide.none,
        ),
      ),
    );
  }

  // Tactile Cyber Input Field (Pure Dark Glass)
  Widget _buildCyberInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required String hintText,
    required List<List<dynamic>> icon,
    required Color accentColor,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monospace Field Label
        Row(
          children: [
            Text(
              '// $label',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isFocused ? accentColor : const Color(0xFF94A3B8),
              ),
            ),
            if (isFocused) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: accentColor, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // Input Container with OLED Dark styling
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF040713),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFocused ? accentColor : const Color(0xFF1E293B),
              width: isFocused ? 1.6 : 1.0,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: isPassword && !isPasswordVisible,
            validator: validator,
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              letterSpacing: 0.8,
            ),
            cursorColor: accentColor,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.transparent,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: HugeIcon(
                  icon: icon,
                  color: isFocused ? accentColor : const Color(0xFF64748B),
                  size: 19,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: HugeIcon(
                        icon: isPasswordVisible
                            ? HugeIcons.strokeRoundedViewOffSlash
                            : HugeIcons.strokeRoundedView,
                        color: isFocused ? accentColor : const Color(0xFF64748B),
                        size: 19,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // Action Shimmer Button
  Widget _buildActionShimmerButton(Color activeAccent) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                activeAccent,
                activeAccent.withValues(alpha: 0.85),
                AppTheme.signalBlue,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: activeAccent.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _executeLogin,
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.white.withValues(alpha: 0.25),
              child: Center(
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'MENGAUTENTIKASI...',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              fontSize: 13,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MASUK KE SISTEM NOC',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              fontSize: 13.5,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            color: Colors.black,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Biometric Quick Access Button
  Widget _buildBiometricAccessRow(Color activeAccent) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF080D1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _triggerBiometricScan,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: activeAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: activeAccent.withValues(alpha: 0.45)),
                  ),
                  child: HugeIcon(icon: HugeIcons.strokeRoundedFingerPrint, color: activeAccent, size: 20),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Autentikasi Biometrik Cepat',
                        style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sentuh sensor sidik jari atau gunakan Face ID',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Footer & Helpdesk Trigger
  Widget _buildFooterSupport() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showSupportDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.neonCyan.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCustomerService,
                  color: AppTheme.neonCyan,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Butuh Bantuan Akses? Buka NOC Support',
                  style: TextStyle(
                    color: AppTheme.neonCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'AUDIRA Ecosystem © 2026 • Agus Dwi Rianto • audira.my.id',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10.5,
            fontFamily: 'monospace',
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// =============================================================================
///                 BIOMETRIC SCANNER BOTTOM SHEET (TACTICAL HUD)
/// =============================================================================
class _BiometricScannerSheet extends StatefulWidget {
  final LoginRolePreset preset;
  final VoidCallback onAuthenticated;

  const _BiometricScannerSheet({
    required this.preset,
    required this.onAuthenticated,
  });

  @override
  State<_BiometricScannerSheet> createState() => _BiometricScannerSheetState();
}

class _BiometricScannerSheetState extends State<_BiometricScannerSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Auto simulate scan success after 1.8 seconds
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _isSuccess = true);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) widget.onAuthenticated();
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.preset.accentColor;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Color(0xFF080D1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: AppTheme.neonCyan,
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Scanning Holographic Fingerprint Ring
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isSuccess
                              ? AppTheme.neonGreen
                              : accent.withValues(alpha: _scanController.value),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isSuccess ? AppTheme.neonGreen : accent)
                                .withValues(alpha: 0.3 * _scanController.value),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    HugeIcon(
                      icon: _isSuccess ? HugeIcons.strokeRoundedTick01 : HugeIcons.strokeRoundedFingerPrint,
                      size: 46,
                      color: _isSuccess ? AppTheme.neonGreen : accent,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            Text(
              _isSuccess ? 'SIDIK JARI TERVERIFIKASI!' : 'MEMINDAI IDENTITAS BIOMETRIK...',
              style: TextStyle(
                color: _isSuccess ? AppTheme.neonGreen : const Color(0xFFF8FAFC),
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isSuccess
                  ? 'Kredensial ${widget.preset.label} siap dimuat.'
                  : 'Tempelkan jari Anda pada sensor perangkat',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Gunakan Kata Sandi Biasa',
                style: TextStyle(color: Color(0xFF64748B), fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =============================================================================
///                 RADAR RETICLE PAINTER (HOLOGRAPHIC BRAND RING)
/// =============================================================================
class _RadarReticlePainter extends CustomPainter {
  final Color accentColor;
  _RadarReticlePainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final arcPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Draw 4 tactical corner arc segments (radar brackets)
    const arcLength = math.pi / 3; // 60 degrees
    for (int i = 0; i < 4; i++) {
      final startAngle = i * (math.pi / 2) + (math.pi / 12);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcLength,
        false,
        arcPaint,
      );
    }

    // Small tick marks on the 4 cardinal directions
    final tickPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.8)
      ..strokeWidth = 2.0;
    for (int i = 0; i < 4; i++) {
      final angle = i * (math.pi / 2);
      final p1 = Offset(center.dx + (radius - 5) * math.cos(angle), center.dy + (radius - 5) * math.sin(angle));
      final p2 = Offset(center.dx + (radius + 2) * math.cos(angle), center.dy + (radius + 2) * math.sin(angle));
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarReticlePainter oldDelegate) => oldDelegate.accentColor != accentColor;
}

/// =============================================================================
///                 CYBER BACKGROUND MATRIX PAINTER (TELEMETRY GRID & SCANLINE)
/// =============================================================================
class _CyberBackgroundGridPainter extends CustomPainter {
  final double gridFlow;
  final Color accentColor;

  _CyberBackgroundGridPainter({
    required this.gridFlow,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid Line Paints
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    final boldLinePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.12)
      ..strokeWidth = 1.4;

    final dotPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    const double step = 36.0;

    // Vertical grid lines
    int xIndex = 0;
    for (double x = 0; x < size.width; x += step, xIndex++) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        (xIndex % 4 == 0) ? boldLinePaint : linePaint,
      );
    }

    // Horizontal grid lines
    int yIndex = 0;
    for (double y = 0; y < size.height; y += step, yIndex++) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        (yIndex % 4 == 0) ? boldLinePaint : linePaint,
      );
    }

    // Floating telemetry packets / dots along the grid
    final random = math.Random(42);
    for (int i = 0; i < 22; i++) {
      final rx = random.nextDouble() * size.width;
      final ry = (random.nextDouble() * size.height + gridFlow * 90) % size.height;
      canvas.drawCircle(Offset(rx, ry), 1.6, dotPaint);
    }

    // Subtle laser scanline sweeping down
    final scanY = (gridFlow * size.height * 1.4) % (size.height + 120) - 60;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          accentColor.withValues(alpha: 0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, scanY, size.width, 36));
    canvas.drawRect(Rect.fromLTWH(0, scanY, size.width, 36), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _CyberBackgroundGridPainter oldDelegate) {
    return oldDelegate.gridFlow != gridFlow ||
        oldDelegate.accentColor != accentColor;
  }
}

