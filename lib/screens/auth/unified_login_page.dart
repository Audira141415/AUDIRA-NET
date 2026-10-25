import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_logo_widget.dart';

/// Role presets for swift development & demo access
enum LoginRolePreset {
  customer('Pelanggan', LucideIcons.user, 'budi@audira.my.id', 'pelanggan123', 'Akses Tagihan & FUP'),
  teknisi('Teknisi', LucideIcons.wrench, 'budi.teknisi@audiranet.id', 'teknisi123', 'Field Ops & Tiket'),
  admin('Admin / NOC', LucideIcons.shieldAlert, 'admin@audiranet.id', 'admin123', 'Command Center');

  final String label;
  final IconData icon;
  final String demoEmail;
  final String demoPassword;
  final String description;

  const LoginRolePreset(this.label, this.icon, this.demoEmail, this.demoPassword, this.description);
}

/// Premium High-Tech Unified Authentication Screen for AUDIRA
/// Blends sleek Apple/Linear utility minimalism with AUDIRA Cyberpunk-Fintech flair
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
        await AuthService.instance.setCurrentUserData(userData);
      } else {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF0A0F1D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryCyan = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7);
    final accentSignal = const Color(0xFF0070F3);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient Gradient Orbs (Depth & High-Tech Atmosphere)
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryCyan.withValues(alpha: isDark ? 0.15 : 0.08),
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
                    accentSignal.withValues(alpha: isDark ? 0.12 : 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand Logo Aura & Header
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryCyan.withValues(alpha: isDark ? 0.4 : 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryCyan.withValues(alpha: isDark ? 0.25 : 0.12),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: const AppLogo(width: 52, height: 52),
                      ),
                      const SizedBox(height: 16),

                      // Brand Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'AUDIRA',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryCyan, accentSignal],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NET',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enterprise Operating System & Fiber Connectivity',
                        style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),

                      // Live Telemetry Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.05),
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
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'GATEWAY • 12ms • OPERATIONAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                fontFamily: 'monospace',
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Role Segmented Controller
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF080D1A) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: LoginRolePreset.values.map((preset) {
                            final isSel = _selectedPreset == preset;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _applyPreset(preset),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSel ? cardBg : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSel
                                        ? Border.all(
                                            color: primaryCyan.withValues(alpha: isDark ? 0.4 : 0.3),
                                            width: 1.2,
                                          )
                                        : null,
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: primaryCyan.withValues(alpha: isDark ? 0.15 : 0.05),
                                              blurRadius: 8,
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
                                        size: 16,
                                        color: isSel ? primaryCyan : textSecondary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        preset.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                          color: isSel ? textPrimary : textSecondary,
                                        ),
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

                      // Main Login Card with Glass Accent
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: borderColor,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Masuk Akun',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: primaryCyan.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _selectedPreset.description,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: primaryCyan,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Email Field
                              Text(
                                'Email Terdaftar',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(fontSize: 14, color: textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'nama@audiranet.id',
                                  hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: primaryCyan.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(LucideIcons.mail, size: 16, color: primaryCyan),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF050811) : const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryCyan, width: 1.5)),
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null,
                              ),
                              const SizedBox(height: 14),

                              // Password Field
                              Text(
                                'Kata Sandi',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: TextStyle(fontSize: 14, color: textPrimary),
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: primaryCyan.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(LucideIcons.lock, size: 16, color: primaryCyan),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye, size: 16, color: textSecondary),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF050811) : const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryCyan, width: 1.5)),
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Kata sandi wajib diisi' : null,
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
                                          activeColor: primaryCyan,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Ingat kredensial', style: TextStyle(fontSize: 12, color: textSecondary)),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: _showForgotPasswordDialog,
                                    child: Text(
                                      'Lupa sandi?',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryCyan),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Submit Button with Vibrant Gradient
                              Container(
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [const Color(0xFF0070F3), const Color(0xFF00F0FF)]
                                        : [const Color(0xFF0284C7), const Color(0xFF0070F3)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryCyan.withValues(alpha: isDark ? 0.35 : 0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _executeLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Masuk ke Sistem',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(LucideIcons.arrowRight, size: 16),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Biometric Fast Pass
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardBg.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _applyPreset(_selectedPreset);
                            _executeLogin();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: primaryCyan.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(LucideIcons.fingerprint, size: 16, color: primaryCyan),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Autentikasi Cepat Biometrik',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Brand Footer
                      Text(
                        'AUDIRA • PT Audira Multimedia Digital / Audira Sukses Mandiri',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'https://audira.my.id',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primaryCyan),
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

  void _showForgotPasswordDialog() {
    final emailResetCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Kata Sandi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tautan reset kata sandi akan dikirim ke alamat email resmi terdaftar:'),
            const SizedBox(height: 12),
            TextField(controller: emailResetCtrl, decoration: const InputDecoration(labelText: 'Email Terdaftar')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              final email = emailResetCtrl.text.trim();
              if (email.isNotEmpty) {
                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await AuthService.instance.resetPassword(email);
                  if (!mounted) return;
                  nav.pop();
                  messenger.showSnackBar(const SnackBar(content: Text('Tautan reset kata sandi telah dikirim!')));
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }
}
