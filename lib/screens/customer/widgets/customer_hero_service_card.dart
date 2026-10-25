import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../utils/app_theme.dart';

/// Hero Card Layanan Utama berstandar Neo-Brutalism + Cyberpunk Studio
/// Dilengkapi Speedometer Arc CustomPainter, telemetri fiber optik dBm, dan tagihan bulanan
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
    final packageName = customerData?['packageName'] ?? 'Fiber Ultra 50 Mbps';
    final customerId = customerData?['customerId'] ?? 'ADN-FIBER';
    final monthlyFee = customerData?['monthlyFee'] ?? 250000;
    final isActive = (customerData?['status'] ?? 'active') == 'active';

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
                          color: isActive ? AppTheme.neonGreen : AppTheme.neonAmber,
                          boxShadow: [
                            BoxShadow(
                              color: (isActive ? AppTheme.neonGreen : AppTheme.neonAmber)
                                  .withValues(alpha: 0.8),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? 'LINK ACTIVE' : 'SUSPENDED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: isActive ? const Color(0xFF00FF9D) : const Color(0xFFFFB800),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '// OPTIC: -19.4 dBm',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                          fontFamily: 'monospace',
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
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        fontFamily: 'monospace',
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
                            progress: 0.65,
                            isDark: isDark,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '50',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                                height: 1.0,
                                letterSpacing: -1.0,
                              ),
                            ),
                            Text(
                              'Mbps',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                                letterSpacing: 0.4,
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
                              child: const Text(
                                'ULTRA-FIBER',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'UNLIMITED FUP',
                              style: TextStyle(
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
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Koneksi stabil dedicated 1:1 langsung ke backbone fiber optik.',
                          style: TextStyle(
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
                                Icon(LucideIcons.arrowDown, size: 12, color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF059669)),
                                const SizedBox(width: 3),
                                Text(
                                  '50.8M',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                Icon(LucideIcons.arrowUp, size: 12, color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7)),
                                const SizedBox(width: 3),
                                Text(
                                  '15.4M',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    fontFamily: 'monospace',
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

            // Middle 3 Telemetry Metrics (Pills)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTelemetryBadge(
                    icon: LucideIcons.radio,
                    label: 'Ping CDN',
                    value: '11 ms',
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9),
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
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
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              'Tgl 20',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(monthlyFee),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: onPayPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.signalBlue : const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDark ? AppTheme.neonCyan : Colors.black,
                          width: 1.5,
                        ),
                      ),
                    ),
                    icon: const Icon(LucideIcons.creditCard, size: 15),
                    label: const Text(
                      'Bayar Tagihan',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
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
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontFamily: 'monospace',
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
