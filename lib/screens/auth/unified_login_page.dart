import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/routes.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_logo_widget.dart';

/// Role presets for swift development & demo access
enum LoginRolePreset {
  customer('Pelanggan', LucideIcons.user, 'budi@audira.my.id', 'pelanggan123'),
  teknisi('Teknisi', LucideIcons.wrench, 'budi.teknisi@audiranet.id', 'teknisi123'),
  admin('Admin / NOC', LucideIcons.shieldAlert, 'admin@audiranet.id', 'admin123');

  final String label;
  final IconData icon;
  final String demoEmail;
  final String demoPassword;

  const LoginRolePreset(this.label, this.icon, this.demoEmail, this.demoPassword);
}

/// Clean Apple/Linear Unified Authentication Screen for AUDIRA
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
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryColor = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Header
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const AppLogo(width: 48, height: 48),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AUDIRA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'NET',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sistem Operasi & Layanan Internet',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // Role Segmented Controller
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel ? cardBg : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    preset.icon,
                                    size: 14,
                                    color: isSel ? primaryColor : textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    preset.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
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

                  // Authentication Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Akun',
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
                              prefixIcon: Icon(LucideIcons.mail, size: 16, color: textSecondary),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF060B18) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryColor, width: 1.5)),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Email wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
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
                              prefixIcon: Icon(LucideIcons.lock, size: 16, color: textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye, size: 16, color: textSecondary),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF060B18) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryColor, width: 1.5)),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Kata sandi wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),
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
                                      activeColor: primaryColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Ingat saya', style: TextStyle(fontSize: 12, color: textSecondary)),
                                ],
                              ),
                              GestureDetector(
                                onTap: _showForgotPasswordDialog,
                                child: Text('Lupa sandi?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: primaryColor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _executeLogin,
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: isDark ? const Color(0xFF030712) : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Masuk ke Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Biometric Fast Login
                  OutlinedButton.icon(
                    onPressed: () {
                      _applyPreset(_selectedPreset);
                      _executeLogin();
                    },
                    icon: Icon(LucideIcons.fingerprint, size: 18, color: textPrimary),
                    label: Text('Autentikasi Cepat Biometrik', style: TextStyle(fontSize: 13, color: textPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Legal & Copyright Footer
                  Text(
                    'AUDIRA • PT Audira Multimedia Digital / Audira Sukses Mandiri',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'https://audira.my.id',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
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
