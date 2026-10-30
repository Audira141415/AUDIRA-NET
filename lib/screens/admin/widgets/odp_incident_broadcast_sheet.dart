import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/app_theme.dart';
import '../../../services/auth_service.dart';

/// Bottom Sheet untuk NOC Admin: Broadcast WhatsApp Gangguan per ODP / Klaster
/// Membantu admin & NOC menyusun dan menyebarkan pesan insiden FO Cut, PLN Blackout,
/// atau Maintenance Terencana ke grup WhatsApp pelanggan dalam 1-Klik.
class OdpIncidentBroadcastSheet extends StatefulWidget {
  const OdpIncidentBroadcastSheet({super.key});

  @override
  State<OdpIncidentBroadcastSheet> createState() =>
      _OdpIncidentBroadcastSheetState();
}

class _OdpIncidentBroadcastSheetState extends State<OdpIncidentBroadcastSheet> {
  // Preset ODPs
  final List<String> _odpPresets = [
    'Semua ODP (Seluruh Jaringan)',
    'ODP-BT-01 (Batu Ceper / Poris)',
    'ODP-CK-02 (Cengkareng Timur)',
    'ODP-CL-03 (Ciledug Raya)',
    'ODP-KR-04 (Karawaci Baru)',
    'ODP-CP-05 (Cipondoh Indah)',
    'ODP-PR-06 (Pinang / Kunciran)',
    'ODP-SR-07 (Serpong Utara)',
    'Kustom (Tulis Sendiri)',
  ];

  late String _selectedOdp;
  final TextEditingController _customOdpController = TextEditingController();

  // Incident types
  // 'fo_cut', 'pln_blackout', 'maintenance', 'recovered'
  String _incidentType = 'fo_cut';

  // ETA presets
  final List<String> _etaPresets = [
    '30 Menit',
    '1 Jam',
    '2 Jam',
    '3 Jam',
    '4 Jam',
    'Segera',
  ];
  String _selectedEta = '2 Jam';
  final TextEditingController _customEtaController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _picController = TextEditingController(
    text: 'Tim Reaksi Cepat NOC AUDIRA',
  );

  bool _isSavingToFirestore = false;

  @override
  void initState() {
    super.initState();
    _selectedOdp = _odpPresets[1]; // default ODP-BT-01
    _notesController.text =
        'Mohon untuk tidak mematikan atau mereset perangkat Modem ONT Anda.';
  }

  @override
  void dispose() {
    _customOdpController.dispose();
    _customEtaController.dispose();
    _notesController.dispose();
    _picController.dispose();
    super.dispose();
  }

  String get _currentOdpName {
    if (_selectedOdp == 'Kustom (Tulis Sendiri)') {
      return _customOdpController.text.trim().isNotEmpty
          ? _customOdpController.text.trim()
          : 'ODP / Klaster Khusus';
    }
    return _selectedOdp;
  }

  String get _currentEta {
    if (_customEtaController.text.trim().isNotEmpty) {
      return _customEtaController.text.trim();
    }
    return _selectedEta;
  }

  String get _incidentTitle {
    switch (_incidentType) {
      case 'fo_cut':
        return 'Fiber Optic Cut (Kabel Putus)';
      case 'pln_blackout':
        return 'Pemadaman Listrik PLN (Blackout)';
      case 'maintenance':
        return 'Pemeliharaan Jaringan Terencana';
      case 'recovered':
        return 'Jaringan Telah Pulih (Normalisasi)';
      default:
        return 'Gangguan Jaringan';
    }
  }

  String _generateWhatsAppMessage() {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
    final dateStr = '${now.day}/${now.month}/${now.year}';

    if (_incidentType == 'recovered') {
      return '''
✅ *JARINGAN TELAH NORMAL KEMBALI*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Kepada Yth. Pelanggan Setia *AUDIRA NET*,

Kami menginformasikan bahwa proses perbaikan dan stabilisasi jaringan pada:
📍 *Lokasi/Klaster*: $_currentOdpName
⏰ *Waktu Pulih*: $dateStr pukul $timeStr
👷 *Penanganan*: ${_picController.text.trim()}

Layanan internet Anda telah kembali beroperasi normal. Jika modem ONT Anda belum terhubung:
1. Cabut kabel power adaptor modem
2. Tunggu 10 detik lalu tancapkan kembali
3. Pastikan lampu indikator PON/LOS berwarna hijau stabil

Terima kasih atas kesabaran dan kerja samanya.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
*NOC & Customer Care AUDIRA*
🌐 https://audira.my.id
📞 Hotline WhatsApp: +62 821-1200-1600
''';
    }

    return '''
🚨 *INFORMASI GANGGUAN JARINGAN (NOC AUDIRA)*
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Kepada Yth. Pelanggan Setia *AUDIRA NET*,

Kami menginformasikan bahwa saat ini terdeteksi kendala jaringan pada titik distribusi layanan Anda:

📍 *Titik/Klaster*: $_currentOdpName
⚠️ *Jenis Insiden*: $_incidentTitle
⏰ *Waktu Kejadian*: $dateStr pukul $timeStr
⏳ *Estimasi Selesai (ETA)*: ± $_currentEta
👷 *Tim Lapangan*: ${_picController.text.trim()}

📌 *Catatan Khusus*:
${_notesController.text.trim()}

Tim teknisi & splicer fiber optik AUDIRA saat ini berada di lokasi untuk penanganan cepat. Kami mohon maaf atas ketidaknyamanan aktivitas internet Anda.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
*Layanan Bantuan & Customer Care AUDIRA*
🌐 Website: https://audira.my.id
📞 WhatsApp Hotline: +62 821-1200-1600
''';
  }

  Future<void> _launchWhatsApp() async {
    final message = _generateWhatsAppMessage();
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/?text=$encoded');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: message));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Tidak dapat membuka WhatsApp. Format pesan telah disalin ke clipboard!',
              ),
              backgroundColor: AppTheme.neonAmber,
            ),
          );
        }
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: message));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Format pesan telah disalin ke clipboard. ($e)',
            ),
            backgroundColor: AppTheme.neonAmber,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard() async {
    final message = _generateWhatsAppMessage();
    await Clipboard.setData(ClipboardData(text: message));
    HapticFeedback.lightImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(LucideIcons.checkCheck, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Format WhatsApp berhasil disalin ke Clipboard!'),
            ],
          ),
          backgroundColor: AppTheme.neonGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveIncidentLog() async {
    setState(() => _isSavingToFirestore = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final adminUser = AuthService.instance.currentUser;
      final message = _generateWhatsAppMessage();

      await firestore.collection('broadcasts').add({
        'title': 'GANGGUAN: $_incidentTitle - $_currentOdpName',
        'message': message,
        'targetRole': 'customer',
        'targetZone': _currentOdpName,
        'category': _incidentType == 'recovered' ? 'announcement' : 'emergency',
        'priority': _incidentType == 'recovered' ? 'medium' : 'critical',
        'scheduledAt': Timestamp.now(),
        'sentAt': Timestamp.now(),
        'createdBy': adminUser?.id ?? 'admin-noc',
        'status': 'sent',
        'metadata': {
          'odp': _currentOdpName,
          'incidentType': _incidentType,
          'eta': _currentEta,
          'pic': _picController.text.trim(),
        },
      });

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(LucideIcons.database, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Log insiden berhasil disimpan ke database AUDIRA NOC!'),
              ],
            ),
            backgroundColor: AppTheme.signalBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencatat insiden: $e'),
            backgroundColor: AppTheme.neonCrimson,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingToFirestore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardInnerBg =
        isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.radioTower,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'BROADCAST GANGGUAN ODP',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'WHATSAPP',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF25D366),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pusat Dispatch Notifikasi Massal NOC AUDIRA',
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        size: 20,
                        color: textSecondary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: borderColor),

              // Content Form
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  children: [
                    // 1. Pilih Jenis Insiden
                    Text(
                      '1. KLASIFIKASI INSIDEN / GANGGUAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark
                            ? AppTheme.neonCyan
                            : const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIncidentChip(
                          id: 'fo_cut',
                          label: '⚡ FO Cut (Kabel Putus)',
                          color: const Color(0xFFEF4444),
                        ),
                        _buildIncidentChip(
                          id: 'pln_blackout',
                          label: '🔌 PLN Blackout',
                          color: const Color(0xFFF59E0B),
                        ),
                        _buildIncidentChip(
                          id: 'maintenance',
                          label: '🛠️ Maintenance Terencana',
                          color: const Color(0xFF6366F1),
                        ),
                        _buildIncidentChip(
                          id: 'recovered',
                          label: '✅ Jaringan Pulih (Normal)',
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 2. Pilih Titik ODP / Klaster
                    Text(
                      '2. TITIK ODP / KLASTER TERDAMPAK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark
                            ? AppTheme.neonCyan
                            : const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cardInnerBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedOdp,
                          isExpanded: true,
                          dropdownColor: bg,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                          items: _odpPresets.map((odp) {
                            return DropdownMenuItem<String>(
                              value: odp,
                              child: Row(
                                children: [
                                  Icon(
                                    odp.contains('Semua')
                                        ? LucideIcons.globe
                                        : LucideIcons.mapPin,
                                    size: 16,
                                    color: const Color(0xFF0284C7),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      odp,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedOdp = val);
                            }
                          },
                        ),
                      ),
                    ),

                    if (_selectedOdp == 'Kustom (Tulis Sendiri)') ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _customOdpController,
                        style: TextStyle(fontSize: 13, color: textPrimary),
                        decoration: InputDecoration(
                          hintText:
                              'Contoh: ODP-KR-08 (Perum Citra Blok A-C)',
                          hintStyle:
                              TextStyle(fontSize: 12, color: textSecondary),
                          prefixIcon: const Icon(LucideIcons.edit3, size: 16),
                          filled: true,
                          fillColor: cardInnerBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // 3. Estimasi Waktu (ETA) & PIC
                    if (_incidentType != 'recovered') ...[
                      Text(
                        '3. ESTIMASI SELESAI (ETA) & PIC',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark
                              ? AppTheme.neonCyan
                              : const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(height: 8),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _etaPresets.map((eta) {
                            final isSel = _selectedEta == eta &&
                                _customEtaController.text.isEmpty;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(eta),
                                selected: isSel,
                                selectedColor: const Color(0xFF0284C7)
                                    .withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSel
                                      ? const Color(0xFF0284C7)
                                      : textSecondary,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedEta = eta;
                                    _customEtaController.clear();
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _customEtaController,
                        style: TextStyle(fontSize: 13, color: textPrimary),
                        decoration: InputDecoration(
                          hintText:
                              'Kustom ETA (Contoh: Besok Pukul 09:00 WIB)',
                          hintStyle:
                              TextStyle(fontSize: 12, color: textSecondary),
                          prefixIcon: const Icon(LucideIcons.clock, size: 16),
                          filled: true,
                          fillColor: cardInnerBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // PIC Teknisi
                    TextField(
                      controller: _picController,
                      style: TextStyle(fontSize: 13, color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'PIC / Tim Teknisi Lapangan',
                        labelStyle:
                            TextStyle(fontSize: 12, color: textSecondary),
                        prefixIcon: const Icon(LucideIcons.userCheck, size: 16),
                        filled: true,
                        fillColor: cardInnerBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    // Catatan Khusus
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      style: TextStyle(fontSize: 13, color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Catatan Khusus Pelanggan',
                        labelStyle:
                            TextStyle(fontSize: 12, color: textSecondary),
                        prefixIcon: const Icon(LucideIcons.fileText, size: 16),
                        filled: true,
                        fillColor: cardInnerBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 22),

                    // 4. Preview WhatsApp Message
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PRATINJAU PESAN WHATSAPP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isDark
                                ? AppTheme.neonCyan
                                : const Color(0xFF0284C7),
                          ),
                        ),
                        InkWell(
                          onTap: _copyToClipboard,
                          child: const Row(
                            children: [
                              Icon(
                                LucideIcons.copy,
                                size: 14,
                                color: Color(0xFF0284C7),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Salin Teks',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF060B13)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        _generateWhatsAppMessage(),
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.5,
                          fontFamily: 'monospace',
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 5. Action Buttons
                    Row(
                      children: [
                        // Simpan Log ke DB
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            onPressed:
                                _isSavingToFirestore ? null : _saveIncidentLog,
                            icon: _isSavingToFirestore
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(LucideIcons.save, size: 16),
                            label: const Text(
                              'Simpan Log DB',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: const Color(0xFF0284C7),
                              side: BorderSide(
                                color: const Color(0xFF0284C7)
                                    .withValues(alpha: 0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Launch WhatsApp Button
                        Expanded(
                          flex: 3,
                          child: FilledButton.icon(
                            onPressed: _launchWhatsApp,
                            icon: const Icon(
                              LucideIcons.messageCircle,
                              size: 18,
                            ),
                            label: const Text(
                              'Kirim ke WhatsApp',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncidentChip({
    required String id,
    required String label,
    required Color color,
  }) {
    final isSel = _incidentType == id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _incidentType = id;
          if (id == 'recovered') {
            _notesController.text =
                'Seluruh layanan internet telah kembali beroperasi normal & stabil.';
          } else if (id == 'fo_cut') {
            _notesController.text =
                'Mohon untuk tidak mematikan atau mereset perangkat Modem ONT Anda.';
          } else if (id == 'pln_blackout') {
            _notesController.text =
                'Backbone berjalan menggunakan UPS/genset cadangan sampai PLN pulih.';
          } else if (id == 'maintenance') {
            _notesController.text =
                'Proses optimalisasi infrastruktur untuk peningkatan kecepatan link.';
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSel
              ? color.withValues(alpha: isDark ? 0.25 : 0.15)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
            color: isSel
                ? color
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }
}
