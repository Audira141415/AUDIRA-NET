import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Clean Apple/Linear Network Status & Telemetry Card for AUDIRA Admin
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
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final isOnline = status == 'online';

    return Material(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1.1),
      ),
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                              .withValues(alpha: isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          LucideIcons.router,
                          size: 18,
                          color: isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Core & Jaringan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            'Telemetri real-time backbone ISP',
                            style: TextStyle(fontSize: 11, color: textSecondary),
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
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'ONLINE' : 'OFFLINE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Divider(height: 1, color: borderColor),
              const SizedBox(height: 16),

              // 4 Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Bandwidth',
                      value: '${bandwidth.toStringAsFixed(0)} Mbps',
                      color: const Color(0xFF0284C7),
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                  Container(width: 1, height: 36, color: borderColor),
                  Expanded(
                    child: _MetricTile(
                      label: 'Upload',
                      value: '${upload.toStringAsFixed(0)} Mbps',
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                  Container(width: 1, height: 36, color: borderColor),
                  Expanded(
                    child: _MetricTile(
                      label: 'Latency',
                      value: '$latency ms',
                      color: latency < 20 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                  Container(width: 1, height: 36, color: borderColor),
                  Expanded(
                    child: _MetricTile(
                      label: 'SLA Uptime',
                      value: '${uptime.toStringAsFixed(1)}%',
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
