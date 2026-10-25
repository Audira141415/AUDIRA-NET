import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../speed_test_page.dart';
import '../wifi_management_page.dart';
import '../bandwidth_usage_page.dart';

class CustomerQuickActions extends StatelessWidget {
  final String? customerId;
  final VoidCallback onHelpPressed;

  const CustomerQuickActions({
    super.key,
    required this.customerId,
    required this.onHelpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final actions = [
      _ActionItem(
        icon: LucideIcons.gauge,
        title: 'Speedtest',
        subtitle: 'Cek performa',
        iconBg: const Color(0xFF0284C7).withValues(alpha: 0.12),
        iconColor: const Color(0xFF0284C7),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SpeedTestPage()),
          );
        },
      ),
      _ActionItem(
        icon: LucideIcons.wifi,
        title: 'Kelola Wi-Fi',
        subtitle: 'Nama & sandi',
        iconBg: const Color(0xFF10B981).withValues(alpha: 0.12),
        iconColor: const Color(0xFF059669),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WiFiManagementPage()),
          );
        },
      ),
      _ActionItem(
        icon: LucideIcons.activity,
        title: 'Trafik Kuota',
        subtitle: 'Riwayat data',
        iconBg: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
        iconColor: const Color(0xFF7C3AED),
        onTap: () {
          if (customerId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BandwidthUsagePage(customerId: customerId!),
              ),
            );
          }
        },
      ),
      _ActionItem(
        icon: LucideIcons.lifeBuoy,
        title: 'Bantuan CS',
        subtitle: 'Lapor kendala',
        iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        iconColor: const Color(0xFFD97706),
        onTap: onHelpPressed,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Pintar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final item = actions[index];
            return InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 20, color: item.iconColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
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
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });
}
