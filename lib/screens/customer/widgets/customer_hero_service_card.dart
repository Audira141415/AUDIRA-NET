import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../utils/app_theme.dart';

/// Card Layanan Utama Pelanggan berstandar Cyber-Utility / Linear Fintech
/// Menyajikan telemetri jaringan fiber optic, status FUP, dan tagihan bulanan
class CustomerHeroServiceCard extends StatelessWidget {
  final Map<String, dynamic>? customerData;
  final VoidCallback onPayPressed;

  const CustomerHeroServiceCard({
    super.key,
    required this.customerData,
    required this.onPayPressed,
  });

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    final number = value is num ? value : (int.tryParse(value.toString()) ?? 0);
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packageName = customerData?['packageName'] ?? 'Fiber Home 50 Mbps';
    final customerId = customerData?['customerId'] ?? 'ADN-FIBER';
    final monthlyFee = customerData?['monthlyFee'] ?? 250000;
    final isActive = (customerData?['status'] ?? 'active') == 'active';

    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardInnerBg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.neonCyan.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Telemetry Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0284C7).withValues(alpha: 0.08)
                    : const Color(0xFF0284C7).withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Live Connection Status
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          boxShadow: [
                            BoxShadow(
                              color: (isActive
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B))
                                  .withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? 'LAYANAN AKTIF' : 'TERISOLIR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isActive
                              ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                              : const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  OPTICAL -19.4 dBm',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  // Monospace ID Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      customerId,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Plan & Bandwidth Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              packageName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Koneksi Fiber Optic Dedicated Tanpa Batas Kuota (FUP Unlimited)',
                              style: TextStyle(
                                fontSize: 13,
                                color: textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF0284C7).withValues(alpha: 0.25),
                                    const Color(0xFF06B6D4).withValues(alpha: 0.25),
                                  ]
                                : [
                                    const Color(0xFFE0F2FE),
                                    const Color(0xFFCCFBF1),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF0284C7).withValues(alpha: 0.5)
                                : const Color(0xFF0284C7).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.zap,
                              size: 14,
                              color: isDark ? AppTheme.neonCyan : const Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'GIGABIT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.neonCyan : const Color(0xFF0284C7),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: borderColor),

            // Lower Section: Billing & Telemetry Metrics
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardInnerBg,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Tagihan Berjalan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Jatuh Tempo: 20 Bln Ini',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(monthlyFee),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF0284C7),
                                    const Color(0xFF0369A1),
                                  ]
                                : [
                                    const Color(0xFF0284C7),
                                    const Color(0xFF0369A1),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onPayPressed,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(LucideIcons.creditCard, size: 16, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Bayar Tagihan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
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

                  const SizedBox(height: 16),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 14),

                  // 3 Real Telemetry Badges
                  Row(
                    children: [
                      _buildMetricCol(
                        'Kecepatan',
                        '50 Mbps',
                        LucideIcons.zap,
                        const Color(0xFF0284C7),
                        textSecondary,
                        textPrimary,
                      ),
                      _buildDivider(borderColor),
                      _buildMetricCol(
                        'Latensi CDN',
                        '11 ms',
                        LucideIcons.radio,
                        const Color(0xFF10B981),
                        textSecondary,
                        textPrimary,
                      ),
                      _buildDivider(borderColor),
                      _buildMetricCol(
                        'SLA Jaringan',
                        '99.9%',
                        LucideIcons.shieldCheck,
                        const Color(0xFF8B5CF6),
                        textSecondary,
                        textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textSecondary,
    Color textPrimary,
  ) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      width: 1,
      height: 24,
      color: color,
    );
  }
}
