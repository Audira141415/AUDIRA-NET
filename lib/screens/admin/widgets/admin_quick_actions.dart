import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../admin_alert_center_page.dart';
import '../admin_broadcast_page.dart';
import '../admin_reporting_page.dart';
import '../attendance_monitoring_page.dart';
import '../financial_dashboard_page.dart';
import '../mikrotik_manager_page.dart';
import '../modem_manager_page.dart';
import '../noc_dashboard_page.dart';

/// Clean Apple/Linear Operational Action Grid for AUDIRA Admin
class AdminQuickActions extends StatelessWidget {
  const AdminQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final actions = [
      _ActionItem(
        icon: LucideIcons.activity,
        label: 'NOC Monitor',
        desc: 'Backbone & OLT',
        color: const Color(0xFF0284C7),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NOCDashboardPage()),
        ),
      ),
      _ActionItem(
        icon: LucideIcons.server,
        label: 'MikroTik',
        desc: 'Queue & Traffic',
        color: const Color(0xFF0D9488),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MikroTikManagerPage()),
        ),
      ),
      _ActionItem(
        icon: LucideIcons.radio,
        label: 'Modem ONT',
        desc: 'Power & Status',
        color: const Color(0xFF6366F1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ModemManagerPage()),
        ),
      ),
      _ActionItem(
        icon: LucideIcons.bellRing,
        label: 'Alert Center',
        desc: 'Peringatan Sistem',
        color: const Color(0xFFEF4444),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminAlertCenterPage()),
        ),
      ),
      _ActionItem(
        icon: LucideIcons.userCheck,
        label: 'Presensi Tim',
        desc: 'Absensi Teknisi',
        color: const Color(0xFF10B981),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AttendanceMonitoringPage()),
        ),
      ),
      _ActionItem(
        icon: LucideIcons.wallet,
        label: 'Keuangan',
        desc: 'Laporan Billing',
        color: const Color(0xFFF59E0B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FinancialDashboardPage()),
        ),
      ),
      _ActionItem(
        icon: LucideIcons.fileSpreadsheet,
        label: 'Laporan',
        desc: 'Audit & Ekspor',
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminReportingPage()),
        ),
      ),
      _ActionItem(
        icon: LucideIcons.megaphone,
        label: 'Broadcast',
        desc: 'Pesan Massal',
        color: const Color(0xFFEC4899),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminBroadcastPage()),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aksi & Operasional',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '8 Modul Aktif',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final a = actions[index];
            return Material(
              color: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: borderColor, width: 1.1),
              ),
              elevation: isDark ? 0 : 1,
              shadowColor: Colors.black.withValues(alpha: 0.03),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: a.onTap,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: isDark ? 0.15 : 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a.icon, size: 20, color: a.color),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.desc,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
  });
}
