import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

/// Bilah metrik kinerja teknisi berstandar utilitas (Linear-inspired clean metric bar)
class TeknisiMetricBar extends StatelessWidget {
  final int activeTickets;
  final int pendingInstallations;
  final int completedToday;
  final VoidCallback onActiveTicketsTap;
  final VoidCallback onPendingInstallationsTap;

  const TeknisiMetricBar({
    super.key,
    required this.activeTickets,
    required this.pendingInstallations,
    required this.completedToday,
    required this.onActiveTicketsTap,
    required this.onPendingInstallationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final dividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Metrik 1: Tiket Aktif
            Expanded(
              child: _MetricItem(
                count: activeTickets,
                label: 'Tiket Aktif',
                badgeText: activeTickets > 0 ? 'Perlu Dikerjakan' : 'Nihil',
                accentColor: AppTheme.signalBlue,
                labelColor: labelColor,
                onTap: onActiveTicketsTap,
              ),
            ),
            VerticalDivider(
              color: dividerColor,
              thickness: 1.5,
              width: 1.5,
              indent: 14,
              endIndent: 14,
            ),
            // Metrik 2: Pasang Baru
            Expanded(
              child: _MetricItem(
                count: pendingInstallations,
                label: 'Pasang Baru',
                badgeText: pendingInstallations > 0 ? 'Jadwal Hari Ini' : 'Nihil',
                accentColor: const Color(0xFF0284C7),
                labelColor: labelColor,
                onTap: onPendingInstallationsTap,
              ),
            ),
            VerticalDivider(
              color: dividerColor,
              thickness: 1.5,
              width: 1.5,
              indent: 14,
              endIndent: 14,
            ),
            // Metrik 3: Selesai
            Expanded(
              child: _MetricItem(
                count: completedToday,
                label: 'Selesai',
                badgeText: 'Hari Ini',
                accentColor: const Color(0xFF10B981),
                labelColor: labelColor,
                onTap: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final int count;
  final String label;
  final String badgeText;
  final Color accentColor;
  final Color labelColor;
  final VoidCallback? onTap;

  const _MetricItem({
    required this.count,
    required this.label,
    required this.badgeText,
    required this.accentColor,
    required this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
