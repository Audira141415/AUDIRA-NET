import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../utils/app_theme.dart';

/// Card Status Core Jaringan NOC AUDIRA berstandar Cyber-Utility / Command Center
/// Menyajikan throughput Rx/Tx, latensi router, dan SLA uptime real-time
class AdminNetworkStatusCard extends StatelessWidget {
  final double bandwidth;
  final double upload;
  final int latency;
  final double uptime;
  final String status;
  final VoidCallback? onTap;

  const AdminNetworkStatusCard({
    super.key,
    required this.bandwidth,
    required this.upload,
    required this.latency,
    required this.uptime,
    this.status = 'online',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardInnerBg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final isOnline = status == 'online';

    // Calculate throughput ratio (assumed 2.5 Gbps / 2500 Mbps backbone capacity)
    final rxProgress = (bandwidth / 2500.0).clamp(0.05, 0.95);
    final txProgress = (upload / 2500.0).clamp(0.05, 0.95);

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
                ? AppTheme.neonCyan.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Telemetry Header
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: (isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                  .withValues(alpha: isDark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.router,
                              size: 16,
                              color: isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NOC BACKBONE TELEMETRY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: isDark ? AppTheme.neonCyan : const Color(0xFF0284C7),
                                ),
                              ),
                              Text(
                                'CCR-1036 • SFP+ 10G • ETHER1-TRUNK',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                              .withValues(alpha: isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                        .withValues(alpha: 0.6),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOnline ? 'ACTIVE' : 'OFFLINE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Throughput Load Bars Section
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      // Rx Throughput Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(LucideIcons.arrowDownCircle, size: 14, color: const Color(0xFF0284C7)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Download (Rx Throughput)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
                                  ),
                                ],
                              ),
                              Text(
                                '${bandwidth.toStringAsFixed(0)} Mbps / 2.5 Gbps',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: rxProgress,
                              minHeight: 6,
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tx Throughput Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(LucideIcons.arrowUpCircle, size: 14, color: const Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Upload (Tx Throughput)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
                                  ),
                                ],
                              ),
                              Text(
                                '${upload.toStringAsFixed(0)} Mbps / 2.5 Gbps',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: txProgress,
                              minHeight: 6,
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: borderColor),

                // Lower 4 Metrics Tiles
                Container(
                  color: cardInnerBg,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Throughput',
                          value: '${(bandwidth + upload).toStringAsFixed(0)}M',
                          icon: LucideIcons.activity,
                          color: const Color(0xFF0284C7),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                      Container(width: 1, height: 32, color: borderColor),
                      Expanded(
                        child: _MetricTile(
                          label: 'Latensi',
                          value: '$latency ms',
                          icon: LucideIcons.radio,
                          color: latency < 20 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                      Container(width: 1, height: 32, color: borderColor),
                      Expanded(
                        child: _MetricTile(
                          label: 'SLA Uptime',
                          value: '${uptime.toStringAsFixed(1)}%',
                          icon: LucideIcons.shieldCheck,
                          color: const Color(0xFF8B5CF6),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                      Container(width: 1, height: 32, color: borderColor),
                      Expanded(
                        child: _MetricTile(
                          label: 'CPU Load',
                          value: '24%',
                          icon: LucideIcons.cpu,
                          color: const Color(0xFF06B6D4),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
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
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color textPrimary;
  final Color textSecondary;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
