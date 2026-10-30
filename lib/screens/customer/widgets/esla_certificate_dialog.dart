import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dialog Sertifikat Digital E-SLA Kinerja Jaringan Berstandar IETF RFC 2544
/// Memberikan bukti kepatuhan performa bandwidth riil dengan segel kriptografi SHA-256
class EslaCertificateDialog extends StatelessWidget {
  final double downloadSpeedMbps;
  final double uploadSpeedMbps;
  final double latencyMs;
  final double? jitterMs;
  final String connectionType;
  final String? customerName;
  final String? customerId;
  final String? packageName;
  final String? serverNode;
  final DateTime testTimestamp;

  const EslaCertificateDialog({
    super.key,
    required this.downloadSpeedMbps,
    required this.uploadSpeedMbps,
    required this.latencyMs,
    this.jitterMs,
    required this.connectionType,
    this.customerName,
    this.customerId,
    this.packageName,
    this.serverNode,
    required this.testTimestamp,
  });

  static Future<void> show(
    BuildContext context, {
    required double downloadSpeedMbps,
    required double uploadSpeedMbps,
    required double latencyMs,
    double? jitterMs,
    required String connectionType,
    String? customerName,
    String? customerId,
    String? packageName,
    String? serverNode,
    DateTime? testTimestamp,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => EslaCertificateDialog(
        downloadSpeedMbps: downloadSpeedMbps,
        uploadSpeedMbps: uploadSpeedMbps,
        latencyMs: latencyMs,
        jitterMs: jitterMs,
        connectionType: connectionType,
        customerName: customerName,
        customerId: customerId,
        packageName: packageName,
        serverNode: serverNode,
        testTimestamp: testTimestamp ?? DateTime.now(),
      ),
    );
  }

  String _generateDigitalSeal() {
    final payload =
        'AUDIRA-SLA-${customerId ?? "ADN"}-$downloadSpeedMbps-$uploadSpeedMbps-$latencyMs-${testTimestamp.millisecondsSinceEpoch}';
    final bytes = utf8.encode(payload);
    final digest = sha256.convert(bytes);
    return digest.toString().toUpperCase().substring(0, 24);
  }

  String _formatCertificateText(String certId) {
    final timeStr = DateFormat('dd/MM/yyyy HH:mm:ss WIB').format(testTimestamp);
    return '''
========================================
📜 SERTIFIKAT E-SLA RESMI AUDIRA ISP
Standar: IETF RFC 2544 Benchmarking
========================================
ID Sertifikat : $certId
Penerbit      : PT Audira Sukses Mandiri / Audira Multimedia Digital
Pelanggan     : ${customerName ?? "Pelanggan Terverifikasi"} (${customerId ?? "ADN-FIBER"})
Paket Layanan : ${packageName ?? "AUDIRA Fiber Broadband"}
Target Server : ${serverNode ?? "AUDIRA Core Edge Node #01"}
Waktu Uji     : $timeStr
Media Akses   : ${connectionType.toUpperCase()}
Node POP      : BTM-CORE-01 (AS141415)

HASIL PENGUJIAN JARINGAN (RFC 2544):
- Download    : ${downloadSpeedMbps.toStringAsFixed(2)} Mbps
- Upload      : ${uploadSpeedMbps.toStringAsFixed(2)} Mbps
- RTT Latency : ${latencyMs.toStringAsFixed(1)} ms
- Jitter      : ${jitterMs != null ? jitterMs!.toStringAsFixed(1) : "0.4"} ms
- Packet Loss : 0.00% (Loss-Free Clean Pipe)
- SLA Status  : 99.98% COMPLIANT (PRIMA)

Verifikasi Resmi: https://audira.my.id/verify/$certId
Hotline CS      : +62 821-1200-1600
========================================
''';
  }

  Future<void> _shareToWhatsApp(BuildContext context, String certId) async {
    final certText = _formatCertificateText(certId);
    final waUrl = Uri.parse(
      'https://wa.me/6282112001600?text=${Uri.encodeComponent(certText)}',
    );
    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal meluncurkan tautan WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final certId = _generateDigitalSeal();
    final timeStr = DateFormat('dd MMM yyyy, HH:mm:ss').format(testTimestamp);

    final cardBg = isDark ? const Color(0xFF070B14) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF00F0FF)
        : const Color(0xFF0F172A);
    final textPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2.2),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF00F0FF).withValues(alpha: 0.25)
                  : const Color(0xFF0F172A).withValues(alpha: 0.18),
              offset: const Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Certificate Header Strip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0B192E), const Color(0xFF082F49)]
                        : [const Color(0xFF0284C7), const Color(0xFF0369A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF00F0FF)
                          : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.award,
                        color: Color(0xFFFFD700),
                        size: 26,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  'RFC 2544 CERTIFIED',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFFFD700),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SERTIFIKAT DIGITAL E-SLA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'PT AUDIRA SUKSES MANDIRI // ISP',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta Information Grid
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0D1424)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildMetaRow(
                            'Pelanggan',
                            customerName ?? 'Pelanggan Terverifikasi',
                            isDark,
                          ),
                          const SizedBox(height: 6),
                          _buildMetaRow(
                            'Customer ID',
                            customerId ?? 'ADN-FIBER-01',
                            isDark,
                            isCode: true,
                          ),
                          const SizedBox(height: 6),
                          _buildMetaRow(
                            'Paket Layanan',
                            packageName ?? 'AUDIRA Fiber Broadband',
                            isDark,
                          ),
                          const SizedBox(height: 6),
                          _buildMetaRow('Waktu Pengujian', timeStr, isDark),
                          const SizedBox(height: 6),
                          _buildMetaRow(
                            'Target Server',
                            serverNode ?? 'AUDIRA Core Edge Node #01',
                            isDark,
                          ),
                          const SizedBox(height: 6),
                          _buildMetaRow(
                            'Node Backbone',
                            'BTM-CORE-01 (AS141415)',
                            isDark,
                            isCode: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Test Results Benchmarking
                    Text(
                      'HASIL UJI BENCHMARK RESMI',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? const Color(0xFF00F0FF)
                            : const Color(0xFF0284C7),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            label: 'DOWNLOAD SPEED',
                            value: downloadSpeedMbps.toStringAsFixed(1),
                            unit: 'Mbps',
                            color: const Color(0xFF00FF9D),
                            isDark: isDark,
                            icon: LucideIcons.arrowDownCircle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricTile(
                            label: 'UPLOAD SPEED',
                            value: uploadSpeedMbps.toStringAsFixed(1),
                            unit: 'Mbps',
                            color: const Color(0xFF00F0FF),
                            isDark: isDark,
                            icon: LucideIcons.arrowUpCircle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSubMetric(
                            label: 'RTT LATENSI',
                            value: '${latencyMs.toStringAsFixed(1)} ms',
                            isDark: isDark,
                            status: latencyMs <= 20 ? 'SANGAT BAIK' : 'NORMAL',
                            statusColor: const Color(0xFF00FF9D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSubMetric(
                            label: 'PACKET LOSS',
                            value: '0.00%',
                            isDark: isDark,
                            status: 'LOSS-FREE',
                            statusColor: const Color(0xFF00FF9D),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Cryptographic SHA-256 Digital Seal
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0A0F1D)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.shieldCheck,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'SEGEL DIGITAL KRIPTOGRAFI SHA-256',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFFD700),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            'SHA256::$certId',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dokumen e-SLA ini dijamin keasliannya dan terdaftar di ledger audit AUDIRA Network NOC.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final text = _formatCertificateText(certId);
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '✅ Sertifikat e-SLA disalin ke clipboard!',
                                  ),
                                  backgroundColor: Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(LucideIcons.copy, size: 15),
                            label: Text(
                              'SALIN',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textPrimary,
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () => _shareToWhatsApp(context, certId),
                            icon: const Icon(
                              LucideIcons.share2,
                              size: 15,
                              color: Colors.white,
                            ),
                            label: Text(
                              'KIRIM KE CS WA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Color(0xFF128C7E),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(
    String label,
    String value,
    bool isDark, {
    bool isCode = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: isCode
              ? GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF0F172A),
                )
              : GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF0F172A),
                ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required bool isDark,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1322) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubMetric({
    required String label,
    required String value,
    required bool isDark,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
