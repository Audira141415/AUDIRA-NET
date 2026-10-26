import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Card Pemeliharaan Jaringan Proaktif dengan Standar Neo-Brutalism Cyberpunk
/// Menampilkan alert jika ada maintenance riil, atau status prima jika tidak ada gangguan
class CustomerMaintenanceCard extends StatelessWidget {
  final Map<String, dynamic>? maintenanceData;

  const CustomerMaintenanceCard({
    super.key,
    this.maintenanceData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActive = maintenanceData?['hasActiveMaintenance'] == true;

    final title = maintenanceData?['title']?.toString() ??
        (hasActive ? 'Pemeliharaan Jaringan Berkala' : 'Layanan Prima & Jaringan Optimal');
    final description = maintenanceData?['description']?.toString() ??
        (hasActive
            ? 'Optimasi jalur fiber optik sedang berlangsung di area Anda.'
            : 'Seluruh sentral backbone dan OLT beroperasi 100% tanpa kendala.');
    final affectedArea = maintenanceData?['affectedArea']?.toString();
    final impact = maintenanceData?['impact']?.toString();

    final cardBg = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final borderColor = hasActive
        ? const Color(0xFFFFB800)
        : (isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.3) : const Color(0xFF0F172A));
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final accentColor = hasActive ? const Color(0xFFFFB800) : const Color(0xFF00FF9D);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: hasActive
                ? const Color(0xFFFFB800).withValues(alpha: 0.15)
                : (isDark
                    ? const Color(0xFF00F0FF).withValues(alpha: 0.08)
                    : const Color(0xFF0F172A).withValues(alpha: 0.06)),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1),
                ),
                child: Icon(
                  hasActive ? LucideIcons.alertTriangle : LucideIcons.shieldCheck,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            hasActive ? 'INFO PEMELIHARAAN' : 'SLA 99.9% TERJAMIN',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasActive && (affectedArea != null || impact != null)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 13, color: Color(0xFFFFB800)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Area: ${affectedArea ?? "Wilayah Pelanggan"} • ${impact ?? "Koneksi beroperasi"}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
