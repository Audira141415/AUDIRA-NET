import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Card Kepatuhan Kominfo TrustPositif & Proteksi Clean Pipe Anti-DDoS
/// Menampilkan status sinkhole nasional UU ITE, proteksi malware, dan filter ramah keluarga
class TrustpositifShieldCard extends StatelessWidget {
  final VoidCallback? onTap;

  const TrustpositifShieldCard({super.key, this.onTap});

  void _showComplianceDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF070B14) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF0F172A),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF00FF9D).withValues(alpha: 0.2)
                  : const Color(0xFF0F172A).withValues(alpha: 0.15),
              offset: const Offset(0, -6),
              blurRadius: 16,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF9D).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00FF9D).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      color: Color(0xFF00FF9D),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SINKHOLE KOMINFO & CLEAN PIPE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF00FF9D),
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          'Kepatuhan Regulasi & Keamanan ISP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildPillarItem(
                title: 'Kepatuhan UU ITE & Permen Kominfo No. 5/2020',
                description:
                    'Jaringan AUDIRA terhubung langsung secara real-time ke database TrustPositif Kementerian Kominfo RI untuk pemblokiran otomatis situs berbahaya, phising, dan perjudian terlarang.',
                icon: LucideIcons.fileCheck2,
                color: const Color(0xFF00FF9D),
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              _buildPillarItem(
                title: 'Perlindungan Clean Pipe & Anti-DDoS',
                description:
                    'Lalu lintas internet Anda disaring di upstream scrubbing center untuk menangkal serangan flooding DDoS, malware botnet, dan kebocoran DNS (DNSSEC Enforced).',
                icon: LucideIcons.cloudRain,
                color: const Color(0xFF00F0FF),
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              _buildPillarItem(
                title: 'Family SafeSearch & Zero-Phishing',
                description:
                    'Perlindungan keluarga bawaan pada level gateway fiber optik tanpa perlu instalasi aplikasi tambahan pada gawai rumah.',
                icon: LucideIcons.lock,
                color: const Color(0xFFFFB800),
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF00FF9D)
                        : const Color(0xFF059669),
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'MENGERTI & TUTUP',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPillarItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1322) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    height: 1.4,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF09121E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF00FF9D).withValues(alpha: 0.35)
        : const Color(0xFF0F172A);
    final textPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          } else {
            _showComplianceDetails(context);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.6),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0xFF00FF9D).withValues(alpha: 0.08)
                    : const Color(0xFF0F172A).withValues(alpha: 0.06),
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Shield Icon with pulsing dot
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF9D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF00FF9D).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.shieldCheck,
                    color: Color(0xFF00FF9D),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Compliance & Clean Pipe Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF00FF9D,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'KOMINFO TRUSTPOSITIF // AKTIF',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF00FF9D),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF00F0FF,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CLEAN PIPE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF00F0FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Perlindungan Internet Ramah Keluarga & UU ITE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Anti-Malware, Sinkhole Judi Online & Anti-DDoS Otomatis',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: isDark
                    ? const Color(0xFF00FF9D)
                    : const Color(0xFF059669),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
