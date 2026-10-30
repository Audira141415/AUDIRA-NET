import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../config/routes.dart';
import '../../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_provider.dart';
import '../audit_logs_page.dart';
import '../backup_status_page.dart';
import '../employee_management_page.dart';
import '../payroll_page.dart';

/// Clean Apple/Linear Admin Profile & Settings Tab for AUDIRA Admin
class AdminProfilTab extends StatefulWidget {
  const AdminProfilTab({super.key});

  @override
  State<AdminProfilTab> createState() => _AdminProfilTabState();
}

class _AdminProfilTabState extends State<AdminProfilTab> {
  Map<String, int> _stats = {'customers': 0, 'payments': 0, 'technicians': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final custSnap = await firestore
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .count()
          .get();

      final paySnap = await firestore.collection('payments').count().get();

      final tekSnap = await firestore
          .collection('users')
          .where('role', isEqualTo: 'teknisi')
          .count()
          .get();

      if (mounted) {
        setState(() {
          _stats = {
            'customers': custSnap.count ?? 0,
            'payments': paySnap.count ?? 0,
            'technicians': tekSnap.count ?? 0,
          };
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                'Akun & Pengaturan Sistem',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 18),

              // Admin Identity Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.15),
                      child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF0284C7), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppConstants.adminName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            AppConstants.adminEmail,
                            style: TextStyle(fontSize: 13, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // System Stats Mini Grid
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Pelanggan',
                      value: _isLoading ? '-' : '${_stats['customers']}',
                      icon: LucideIcons.users,
                      color: const Color(0xFF0284C7),
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Transaksi',
                      value: _isLoading ? '-' : '${_stats['payments']}',
                      icon: LucideIcons.creditCard,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Teknisi',
                      value: _isLoading ? '-' : '${_stats['technicians']}',
                      icon: LucideIcons.hardHat,
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Preferensi Tampilan Section
              Text(
                'Preferensi Sistem',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
              ),
              const SizedBox(height: 10),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: borderColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            themeProvider.isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                            color: const Color(0xFF0284C7),
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mode Gelap',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  themeProvider.isDarkMode ? 'Tema OLED Midnight' : 'Tema Clean Slate Canvas',
                                  style: TextStyle(fontSize: 12, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: themeProvider.isDarkMode,
                            activeTrackColor: const Color(0xFF0284C7),
                            onChanged: (val) => themeProvider.toggleTheme(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Kelola SDM & Operasional
              Text(
                'Manajemen SDM & Operasi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
              ),
              const SizedBox(height: 10),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: borderColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.userCheck,
                      title: 'Employee Management (HRM)',
                      subtitle: 'Kelola data teknisi, NOC, dan staf lapangan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmployeeManagementPage()),
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    Divider(height: 1, color: borderColor),
                    _SettingsTile(
                      icon: LucideIcons.badgeDollarSign,
                      title: 'Sistem Payroll & Penggajian',
                      subtitle: 'Slip gaji dan rekap tunjangan tim',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PayrollPage()),
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pemeliharaan & Audit
              Text(
                'Audit & Pemeliharaan Sistem',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
              ),
              const SizedBox(height: 10),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: borderColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.fileText,
                      title: 'Audit Logs',
                      subtitle: 'Rekap jejak aktivitas login dan perubahan data',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AuditLogsPage()),
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    Divider(height: 1, color: borderColor),
                    _SettingsTile(
                      icon: LucideIcons.database,
                      title: 'Status Backup Database',
                      subtitle: 'Pencadangan cloud dan integritas SQLite',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BackupStatusPage()),
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Keluar dari Akun Admin?'),
                        content: const Text('Sesi administrator Anda akan diakhiri.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await AuthService.instance.logout();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Routes.unifiedLogin,
                                  (route) => false,
                                );
                              }
                            },
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                            child: const Text('Keluar'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.logOut, size: 16, color: Color(0xFFEF4444)),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0284C7)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
