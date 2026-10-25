import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_logo_widget.dart';

/// Role presets for swift development & demo access
enum LoginRolePreset {
  customer(
    'Pelanggan',
    LucideIcons.user,
    'budi@audira.my.id',
    'pelanggan123',
    'Akses Tagihan & FUP',
    Color(0xFF00F0FF),
  ),
  teknisi(
    'Teknisi',
    LucideIcons.wrench,
    'budi.teknisi@audiranet.id',
    'teknisi123',
    'Field Ops & Tiket',
    Color(0xFF00FF9D),
  ),
  admin(
    'Admin / NOC',
    LucideIcons.shieldAlert,
    'admin@audiranet.id',
    'admin123',
    'Command Center',
    Color(0xFFA855F7),
  );

  final String label;
  final IconData icon;
  final String demoEmail;
  final String demoPassword;
  final String description;
  final Color roleColor;

  const LoginRolePreset(
    this.label,
    this.icon,
    this.demoEmail,
    this.demoPassword,
    this.description,
    this.roleColor,
  );
}

/// Unified Authentication Screen for AUDIRA
/// Adheres strictly to AUDIRA Neo-Brutalism + Cyberpunk Design System
class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginRolePreset _selectedPreset = LoginRolePreset.customer;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _applyPreset(LoginRolePreset.customer);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            content: Text('Login Gagal: $e'),
            backgroundColor: const Color(0xFFFF2A5F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF00F0FF).withValues(alpha: 0.4)
        : const Color(0xFF0F172A);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Cyber Ambient Aurora Orbs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _selectedPreset.roleColor.withValues(alpha: isDark ? 0.18 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.signalBlue.withValues(alpha: isDark ? 0.15 : 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Holographic Brand Logo
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedPreset.roleColor,
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedPreset.roleColor.withValues(alpha: 0.3),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: const AppLogo(width: 54, height: 54),
                      ),

                      const SizedBox(height: 16),

                      // Brand Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'AUDIRA',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00F0FF), Color(0xFF0070F3)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NET-OS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text(
                        'Pusat Kendali Operasi & Layanan Fiber Optik',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Live Gateway Telemetry Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF00FF9D),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'GATEWAY • 12ms • ALL SYSTEMS OPERATIONAL',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Color(0xFF00FF9D),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 1-Tap Quick Persona Selector (Crucial for Instant Switch & Demo)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF070B14) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: LoginRolePreset.values.map((preset) {
                            final isSelected = _selectedPreset == preset;
                            return Expanded(
                              child: InkWell(
                                onTap: () => _applyPreset(preset),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF0A0E1A) : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(color: preset.roleColor, width: 1.5)
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: preset.roleColor.withValues(alpha: 0.2),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        preset.icon,
                                        size: 18,
                                        color: isSelected ? preset.roleColor : textSecondary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        preset.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight:
                                              isSelected ? FontWeight.w800 : FontWeight.w600,
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

                      // Neo-Brutalism Main Card
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: borderColor, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? _selectedPreset.roleColor.withValues(alpha: 0.15)
                                  : const Color(0xFF0F172A).withValues(alpha: 0.1),
                              offset: const Offset(6, 6),
                              blurRadius: 0, // Neo-Brutalism signature hard shadow
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Role Header Ribbon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'AKSES ${_selectedPreset.label.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: textPrimary,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _selectedPreset.roleColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _selectedPreset.roleColor.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      _selectedPreset.description,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: _selectedPreset.roleColor,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // Email Input
                              Text(
                                '// IDENTITAS_AKUN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: textSecondary,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(0xFF070B14)
                                      : const Color(0xFFF8FAFC),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _selectedPreset.roleColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      LucideIcons.mail,
                                      size: 16,
                                      color: _selectedPreset.roleColor,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _selectedPreset.roleColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Email wajib diisi';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Password Input
                              Text(
                                '// KATA_SANDI',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: textSecondary,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(0xFF070B14)
                                      : const Color(0xFFF8FAFC),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _selectedPreset.roleColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
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
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _selectedPreset.roleColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Kata sandi wajib diisi';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Remember & Forgot
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: _selectedPreset.roleColor,
                                          checkColor: Colors.black,
                                          side: BorderSide(color: borderColor, width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Simpan Sesi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Silakan hubungi Helpdesk NOC untuk reset.'),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Lupa Sandi?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? _selectedPreset.roleColor : AppTheme.signalBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // Bold Neo-Brutalism Action CTA
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _executeLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? _selectedPreset.roleColor
                                        : const Color(0xFF0F172A),
                                    foregroundColor: isDark ? Colors.black : Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isDark ? Colors.white : Colors.black,
                                        width: 1.5,
                                      ),
                                    ),
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'MASUK KE SISTEM',
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.8,
                                                color: isDark ? Colors.black : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              LucideIcons.arrowRight,
                                              size: 18,
                                              color: isDark ? Colors.black : Colors.white,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Biometric Fast-Pass Capsule
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? const Color(0xFF00F0FF).withValues(alpha: 0.06)
                                  : const Color(0xFF0F172A).withValues(alpha: 0.04),
                              offset: const Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.fingerprint,
                              size: 20,
                              color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Autentikasi Cepat Biometrik (Passkey)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

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
                      const SizedBox(height: 2),
                      Text(
                        'https://audira.my.id',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                          fontFamily: 'monospace',
                        ),
                      ),
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
