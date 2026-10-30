import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../utils/app_theme.dart';
import '../package_upgrade_page.dart';

/// Hero Card Layanan Utama berstandar Neo-Brutalism + Cyberpunk Studio
/// Dilengkapi Speedometer Arc CustomPainter, FUP Multi-Zone Gauge, telemetri fiber optik dBm riil, dan tagihan bulanan
class CustomerHeroServiceCard extends StatelessWidget {
  final Map<String, dynamic>? customerData;
  final Map<String, dynamic>? telemetryData;
  final VoidCallback onPayPressed;

  const CustomerHeroServiceCard({
    super.key,
    required this.customerData,
    this.telemetryData,
    required this.onPayPressed,
  });

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    final intVal = (value is num ? value : (double.tryParse(value.toString()) ?? 0)).round();
    final formatted = intVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic Service & Telemetry Properties
    final packageName = telemetryData?['service']?['packageName'] ??
        customerData?['packageName'] ??
        'AUDIRA Fiber Ultra 50 Mbps';
    final customerId = customerData?['customerId'] ?? 'ADN-FIBER';
    final monthlyFee = telemetryData?['service']?['monthlyFee'] ??
        customerData?['monthlyFee'] ??
        customerData?['price'] ??
        250000;

    final connStatus = (telemetryData?['connectionStatus'] ??
            ((customerData?['status'] ?? 'active') == 'active' ? 'CONNECTED' : 'SUSPENDED'))
        .toString()
        .toUpperCase();
    final isConnected = connStatus == 'CONNECTED';

    // Optical dBm & Health
    final opticalRxStr = telemetryData?['optical']?['rxPower'] != null
        ? '${(telemetryData!['optical']['rxPower'] as num).toStringAsFixed(1)} dBm'
        : (customerData?['rxPower'] ?? '-19.4 dBm');
    final opticalStatus = telemetryData?['optical']?['status'] ?? 'GOOD';
    final opticalColor = opticalStatus == 'CRITICAL'
        ? const Color(0xFFFF0055)
        : (opticalStatus == 'WARN' ? const Color(0xFFFFB800) : const Color(0xFF00FF9D));

    // Speed telemetry
    final speedMbps = telemetryData?['service']?['speedMbps'] is num
        ? (telemetryData!['service']['speedMbps'] as num).toInt()
        : (int.tryParse(customerData?['speed']?.toString().split(' ')[0] ?? '') ?? 50);
    final downloadLive = telemetryData?['service']?['downloadLive']?.toString() ??
        '${(speedMbps * 0.98).toStringAsFixed(1)}M';
    final uploadLive = telemetryData?['service']?['uploadLive']?.toString() ??
        '${(speedMbps * 0.32).toStringAsFixed(1)}M';

    // FUP Quota Data & 3 Color Zones
    final fupPercent = ((telemetryData?['fup']?['usagePercent'] as num?)?.toDouble() ?? 34.2);
    final fupZone = telemetryData?['fup']?['zone'] ??
        (fupPercent > 90 ? 'CRITICAL' : (fupPercent >= 70 ? 'WARNING' : 'SAFE'));
    final fupLabel = telemetryData?['fup']?['label'] ??
        (fupZone == 'SAFE'
            ? 'FUP AMAN • ${fupPercent.toStringAsFixed(1)}%'
            : (fupZone == 'WARNING'
                ? 'MENDEKATI LIMIT • ${fupPercent.toStringAsFixed(1)}%'
                : 'FUP KRITIS • ${fupPercent.toStringAsFixed(1)}%'));

    final fupZoneColor = fupZone == 'CRITICAL'
        ? const Color(0xFFFF0055)
        : (fupZone == 'WARNING' ? const Color(0xFFFFB800) : const Color(0xFF00F0FF));

    final fupUsedGb = telemetryData?['fup']?['usageBytes'] != null
        ? ((telemetryData!['fup']['usageBytes'] as num) / 1073741824).toStringAsFixed(0)
        : '342';
    final fupRemainingGb = telemetryData?['fup']?['remainingBytes'] != null
        ? ((telemetryData!['fup']['remainingBytes'] as num) / 1073741824).toStringAsFixed(0)
        : '658';

    // Latency & SLA
    final latencyMs = telemetryData?['latencyMs']?.toString() ?? '11';

    // Billing Due Date & Status
    final remainingDays = telemetryData?['service']?['remainingDays'] ?? 14;
    final hasUnpaid = telemetryData?['service']?['hasUnpaidInvoice'] ?? true;

    final cardBg = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.35) : borderColor,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF00F0FF).withValues(alpha: 0.12)
                : const Color(0xFF0F172A).withValues(alpha: 0.08),
            offset: const Offset(5, 5),
            blurRadius: 0, // Neo-Brutalism signature hard shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Technical Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected ? const Color(0xFF00FF9D) : const Color(0xFFFFB800),
                          boxShadow: [
                            BoxShadow(
                              color: (isConnected ? const Color(0xFF00FF9D) : const Color(0xFFFFB800))
                                  .withValues(alpha: 0.8),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isConnected ? 'LINK ACTIVE' : 'SUSPENDED',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: isConnected ? const Color(0xFF00FF9D) : const Color(0xFFFFB800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '// OPTIC: $opticalRxStr',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: opticalColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF162032) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      customerId,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Speedometer Arc Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  // Circular Speedometer Arc Widget
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(110, 110),
                          painter: _SpeedGaugePainter(
                            progress: (speedMbps / 150.0).clamp(0.15, 1.0),
                            isDark: isDark,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$speedMbps',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                                height: 1.0,
                                letterSpacing: -1.2,
                              ),
                            ),
                            Text(
                              'Mbps',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Plan Details & Tier Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00F0FF), Color(0xFF0070F3)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ULTRA-FIBER',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'GPON 1:1 DEDICATED',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: textSecondary,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          packageName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Koneksi stabil direct peering ke Tier-1 IIX & OpenIXP.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.arrowDown,
                                  size: 12,
                                  color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF059669),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  downloadLive,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.arrowUp,
                                  size: 12,
                                  color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  uploadLive,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // FUP Quota Telemetry Progress Indicator with 3-Tier Zone Coloration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.activity,
                              size: 13,
                              color: fupZoneColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'KONSUMSI KUOTA FUP',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: fupZoneColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: fupZoneColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            fupLabel,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: fupZoneColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    // Multi-Segment FUP Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        height: 7,
                        width: double.infinity,
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (fupPercent / 100.0).clamp(0.02, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: fupZone == 'CRITICAL'
                                      ? [const Color(0xFFFFB800), const Color(0xFFFF0055)]
                                      : (fupZone == 'WARNING'
                                          ? [const Color(0xFF00F0FF), const Color(0xFFFFB800)]
                                          : [const Color(0xFF00FF9D), const Color(0xFF00F0FF)]),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: fupZoneColor.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$fupUsedGb GB Terpakai',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Total 1.000 GB (Sisa $fupRemainingGb GB)',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Quick Action if nearing or exceeded limit
                    if (fupPercent >= 70.0) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PackageUpgradePage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: fupZoneColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: fupZoneColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.zap, size: 12, color: fupZoneColor),
                              const SizedBox(width: 6),
                              Text(
                                'Kuota Menipis — Tambah Turbo Booster Mulai Rp 15.000 ➔',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: fupZoneColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Middle 3 Telemetry Metrics (Pills)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTelemetryBadge(
                    icon: LucideIcons.radio,
                    label: 'Ping CDN',
                    value: '$latencyMs ms',
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildTelemetryBadge(
                    icon: LucideIcons.shieldCheck,
                    label: 'SLA Uptime',
                    value: '99.9%',
                    color: const Color(0xFF00F0FF),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildTelemetryBadge(
                    icon: LucideIcons.zap,
                    label: 'Jitter',
                    value: '< 1 ms',
                    color: const Color(0xFFA855F7),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Bottom Billing Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9),
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 355;

                  final billInfoWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              hasUnpaid ? 'Tagihan Berjalan' : 'Status Tagihan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: (hasUnpaid ? const Color(0xFF10B981) : const Color(0xFF00FF9D))
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: hasUnpaid
                                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                    : const Color(0xFF00FF9D).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              hasUnpaid ? 'Sisa $remainingDays Hari' : 'LUNAS',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: hasUnpaid ? const Color(0xFF10B981) : const Color(0xFF00FF9D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCurrency(monthlyFee),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  );

                  final boosterButton = OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PackageUpgradePage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(LucideIcons.zap, size: 12),
                    label: Text(
                      'Booster',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  );

                  final payButton = ElevatedButton.icon(
                    onPressed: onPayPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.signalBlue : const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isDark ? AppTheme.neonCyan : Colors.black,
                          width: 1.5,
                        ),
                      ),
                    ),
                    icon: const Icon(LucideIcons.creditCard, size: 13),
                    label: Text(
                      hasUnpaid ? 'Bayar' : 'Detail',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        billInfoWidget,
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: boosterButton),
                            const SizedBox(width: 8),
                            Expanded(flex: 2, child: payButton),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: billInfoWidget),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          boosterButton,
                          const SizedBox(width: 6),
                          payButton,
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF162032) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
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
  }
}

/// CustomPainter for the Futuristic Speedometer Arc Gauge
class _SpeedGaugePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SpeedGaugePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;

    const startAngle = 135.0 * (math.pi / 180.0);
    const sweepAngle = 270.0 * (math.pi / 180.0);

    // 1. Background Arc Track
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // 2. Active Gradient Arc
    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F0FF), Color(0xFF0070F3), Color(0xFF7928CA)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    final currentSweep = sweepAngle * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      activePaint,
    );

    // 3. Pointer Glow Dot
    final dotAngle = startAngle + currentSweep;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);

    final glowPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(Offset(dotX, dotY), 4.5, glowPaint);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(dotX, dotY), 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SpeedGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
