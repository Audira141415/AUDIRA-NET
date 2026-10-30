import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/firebase_service.dart';
import '../../../utils/theme_provider.dart';
import '../../../config/routes.dart';
import '../../about_page.dart';
import '../package_upgrade_page.dart';
import '../loyalty_rewards_page.dart';
import '../widgets/esla_certificate_dialog.dart';

/// Neo-Brutalist Cyber Profile & Device Hub for AUDIRA Customers
class CustomerProfilTab extends StatefulWidget {
  const CustomerProfilTab({super.key});

  @override
  State<CustomerProfilTab> createState() => _CustomerProfilTabState();
}

class _CustomerProfilTabState extends State<CustomerProfilTab> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _customerData;
  bool _isLoading = true;
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      _userData = AuthService.instance.currentUserData;
      _userData ??= {
        'id': 'usr-customer-01',
        'name': 'Budi Pelanggan',
        'email': 'budi@audira.my.id',
        'role': 'customer',
      };

      final customer = await FirebaseService.instance.getCustomerByUserId(
        _userData!['id'].toString(),
      );

      if (mounted) {
        setState(() {
          _customerData = customer ?? FirebaseService.getDefaultCustomerData(
            userId: _userData!['id'].toString(),
            email: _userData!['email'].toString(),
            name: _userData!['name'].toString(),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmLogout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFFEF4444) : Colors.black,
            width: 2,
          ),
        ),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Apakah Anda yakin ingin mengakhiri sesi dan keluar dari aplikasi AUDIRA?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              nav.pop();
              await AuthService.instance.logout();
              if (!mounted) return;
              nav.pushNamedAndRemoveUntil(Routes.unifiedLogin, (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF0A0E1A) : Colors.white;

    final name = _userData?['name'] ?? 'Budi Pelanggan';
    final email = _userData?['email'] ?? 'budi@audira.my.id';
    final customerId = _customerData?['customerId'] ?? 'ADN-2026-0889';
    final packageName = _customerData?['packageName'] ?? 'Fiber Ultra 50 Mbps';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 95),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AKUN & IDENTITAS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '// PROFILE_HARDWARE_SYSTEM',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF00F0FF), width: 1),
                          ),
                          child: Text(
                            'TIER 1 USER',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF00F0FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Cyber Persona Digital ID Card (Hero)
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.5) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                                : const Color(0xFF0F172A).withValues(alpha: 0.1),
                            offset: const Offset(5, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          children: [
                            // Card Top Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              color: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.fingerprint, size: 16, color: Color(0xFF00F0FF)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'AUDIRA DIGITAL PASS',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: textPrimary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'VERIFIED',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF00FF9D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00F0FF), Color(0xFF0070F3), Color(0xFF7928CA)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'B',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: textPrimary,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          email,
                                          style: TextStyle(fontSize: 12, color: textSecondary),
                                        ),
                                        const SizedBox(height: 6),
                                        GestureDetector(
                                          onTap: () => _copyToClipboard(customerId, 'ID Pelanggan'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF162032) : const Color(0xFFE2E8F0),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  customerId,
                                                  style: GoogleFonts.jetBrainsMono(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Icon(LucideIcons.copy, size: 12, color: textSecondary),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Plan Upgrade Strip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PAKET LANGGANAN',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        packageName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const PackageUpgradePage()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                                      foregroundColor: isDark ? const Color(0xFF05070D) : Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Upgrade ➔', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Loyalty Rewards Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E1435), const Color(0xFF0F172A)]
                              : [const Color(0xFFF3E8FF), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFFA855F7) : const Color(0xFF7C3AED),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA855F7).withValues(alpha: 0.12),
                            offset: const Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                              border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
                            ),
                            child: const Icon(LucideIcons.award, size: 22, color: Color(0xFFA855F7)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'AUDIRA LOYALTY',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? const Color(0xFFA855F7) : const Color(0xFF7C3AED),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFB800).withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'GOLD VIP',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFFFB800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '1.250 Poin Terkumpul',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'Tukar diskon tagihan & booster kecepatan',
                                  style: TextStyle(fontSize: 10.5, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoyaltyRewardsPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA855F7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Redeem ➔',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Hardware & Network Bento
                    Text(
                      'PERANGKAT ROUTER ONT & JARINGAN',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDeviceRow('Model Perangkat', 'Huawei Wi-Fi 6 ONT (HG8245H5)', LucideIcons.router, textPrimary, textSecondary),
                          const Divider(height: 16, color: Color(0xFF1E293B)),
                          _buildDeviceRow('MAC Address', '70:2E:22:A9:1B:4F', LucideIcons.cpu, textPrimary, textSecondary, isMono: true),
                          const Divider(height: 16, color: Color(0xFF1E293B)),
                          _buildDeviceRow('Gateway Lokal', '192.168.1.1', LucideIcons.network, textPrimary, textSecondary, isMono: true),
                          const Divider(height: 16, color: Color(0xFF1E293B)),
                          _buildDeviceRow('Redaman Optik', '-19.4 dBm (Sangat Baik)', LucideIcons.activity, textPrimary, const Color(0xFF00FF9D)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Preferences & Security Bento
                    Text(
                      'PREFERENSI & KEAMANAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Dark Mode Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isDark ? LucideIcons.moon : LucideIcons.sun,
                                    size: 18,
                                    color: const Color(0xFF00F0FF),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mode OLED Midnight',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
                                      ),
                                      Text(
                                        isDark ? 'Tema gelap kontras tinggi aktif' : 'Tema terang aktif',
                                        style: TextStyle(fontSize: 11, color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: isDark,
                                activeThumbColor: const Color(0xFF00F0FF),
                                onChanged: (val) => themeProvider.toggleTheme(context),
                              ),
                            ],
                          ),
                          const Divider(height: 16, color: Color(0xFF1E293B)),

                          // Biometric Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.fingerprint, size: 18, color: Color(0xFF00FF9D)),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Login Biometrik / Passkey',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
                                      ),
                                      Text(
                                        'Sidik jari & Face ID instan',
                                        style: TextStyle(fontSize: 11, color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: _biometricEnabled,
                                activeThumbColor: const Color(0xFF00FF9D),
                                onChanged: (val) => setState(() => _biometricEnabled = val),
                              ),
                            ],
                          ),
                          const Divider(height: 16, color: Color(0xFF1E293B)),

                          // E-Contract Viewer
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(LucideIcons.fileText, size: 18, color: Color(0xFF00F0FF)),
                            title: Text('Kontrak Layanan Digital (E-Contract)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary)),
                            subtitle: Text('No: CTR-2026-0889-FIBER • Ditandatangani Digital', style: TextStyle(fontSize: 11, color: textSecondary)),
                            trailing: const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF94A3B8)),
                            onTap: () {
                              EslaCertificateDialog.show(
                                context,
                                downloadSpeedMbps: 50.4,
                                uploadSpeedMbps: 48.9,
                                latencyMs: 11.2,
                                jitterMs: 0.8,
                                connectionType: 'GPON 1:1 Dedicated Fiber',
                                customerName: name,
                                customerId: customerId,
                                packageName: packageName,
                                serverNode: 'OpenIXP Jakarta (Core-01)',
                              );
                            },
                          ),
                          const Divider(height: 16, color: Color(0xFF1E293B)),

                          // Active Sessions Manager
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(LucideIcons.shieldCheck, size: 18, color: Color(0xFF00FF9D)),
                            title: Text('Sesi Perangkat Aktif', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary)),
                            subtitle: Text('2 Perangkat Aktif • Android 14 (Sesi Ini)', style: TextStyle(fontSize: 11, color: textSecondary)),
                            trailing: TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: isDark ? const Color(0xFF00FF9D) : Colors.black, width: 2),
                                    ),
                                    title: const Text('PUTUSKAN SESI LAIN?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                                    content: const Text(
                                      'Seluruh sesi login selain perangkat ini (Android 14) akan otomatis dicabut hak aksesnya dan diwajibkan autentikasi ulang.',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('✅ Sesi di perangkat lain berhasil diputuskan via Auth Server.'),
                                              backgroundColor: Color(0xFF059669),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
                                        child: const Text('Cabut Sesi ➔', style: TextStyle(fontWeight: FontWeight.w800)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Logout Lain', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
                            ),
                          ),
                          const Divider(height: 16, color: Color(0xFF1E293B)),

                          // About AUDIRA
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(LucideIcons.info, size: 18, color: Color(0xFF7928CA)),
                            title: Text('Tentang AUDIRA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary)),
                            subtitle: Text('Versi 2.4.0 • PT Audira Multimedia Digital', style: TextStyle(fontSize: 11, color: textSecondary)),
                            trailing: const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF94A3B8)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AboutPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Brutalist Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _confirmLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                          foregroundColor: const Color(0xFFEF4444),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
                          ),
                        ),
                        icon: const Icon(LucideIcons.logOut, size: 18),
                        label: const Text(
                          'KELUAR DARI AKUN',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDeviceRow(String label, String value, IconData icon, Color textPrimary, Color textSecondary, {bool isMono = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF00F0FF)),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: isMono
              ? GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                )
              : GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
        ),
      ],
    );
  }
}
