import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../speed_test_page.dart';
import '../wifi_management_page.dart';
import '../bandwidth_usage_page.dart';

/// Bilah Menu Pintar Pelanggan berstandar Cyber-Utility
/// Dilengkapi indikator status real-time, badge telemetri, dan kontainer ikon gradien
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
        subtitle: 'Uji Latensi & Speed',
        badge: 'REAL-TIME',
        badgeColor: const Color(0xFF0284C7),
        gradientColors: [const Color(0xFF0284C7), const Color(0xFF06B6D4)],
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
        subtitle: 'SSID & Sandi Router',
        badge: 'ACTIVE',
        badgeColor: const Color(0xFF10B981),
        gradientColors: [const Color(0xFF059669), const Color(0xFF10B981)],
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
        subtitle: 'Analisis FUP & Log',
        badge: 'UNLIMITED',
        badgeColor: const Color(0xFF8B5CF6),
        gradientColors: [const Color(0xFF7C3AED), const Color(0xFFA855F7)],
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
        subtitle: 'Tiket & NOC Support',
        badge: '24/7 SIAP',
        badgeColor: const Color(0xFFF59E0B),
        gradientColors: [const Color(0xFFD97706), const Color(0xFFF59E0B)],
        onTap: onHelpPressed,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Akses Cepat Layanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '4 MODUL TERSEDIA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.05,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final item = actions[index];
            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : borderColor,
                  width: 1.1,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: item.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: item.gradientColors.first.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(item.icon, size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: item.badgeColor.withValues(alpha: isDark ? 0.15 : 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.badge,
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: item.badgeColor,
                                    letterSpacing: 0.4,
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
  final String badge;
  final Color badgeColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.gradientColors,
    required this.onTap,
  });
}
