import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/firebase_service.dart';
import '../../../services/auth_service.dart';
import '../chatbot_page.dart';
import '../../chat/live_chat_list_page.dart';
import '../../chat/live_chat_room_page.dart';
import '../../../models/chat_model.dart';

/// Neo-Brutalist Cyber NOC Support & Incident Command for AUDIRA Customers
class CustomerBantuanTab extends StatefulWidget {
  const CustomerBantuanTab({super.key});

  @override
  State<CustomerBantuanTab> createState() => _CustomerBantuanTabState();
}

class _CustomerBantuanTabState extends State<CustomerBantuanTab> {
  List<Map<String, dynamic>> _tickets = [];
  int? _expandedFaqIndex;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Lampu LOS pada Router Berkedip Merah?',
      'a': 'Lampu LOS merah menandakan hilangnya sinyal optik dari kabel drop. Pastikan kabel hitam tidak tertekuk. Jika tetap berkedip, segera buat tiket gangguan agar teknisi lapangan mengecek sambungan ODP.',
    },
    {
      'q': 'Bagaimana Cara Restart Router dari Jarak Jauh?',
      'a': 'Buka menu Beranda > Kelola Router & Wi-Fi > pilih Reboot Perangkat. Router ONT akan melakukan sinkronisasi ulang sinyal dalam 60-90 detik.',
    },
    {
      'q': 'Apakah AUDIRA Fiber Menerapkan Kuota / FUP?',
      'a': 'Layanan AUDIRA Ultra Fiber berstatus UNLIMITED FUP. Kecepatan 1:1 dedicated tanpa penurunan bandwidth di akhir bulan.',
    },
    {
      'q': 'Kapan Tagihan Jatuh Tempo Setiap Bulannya?',
      'a': 'Tagihan diterbitkan setiap tanggal 1 dan jatuh tempo pada tanggal 20 setiap bulannya. Pembayaran dapat melalui QRIS, Virtual Account, atau E-Wallet.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final currentUserData = AuthService.instance.currentUserData;
      final userId = currentUserData?['id']?.toString() ?? '1';
      final customerData = await FirebaseService.instance.getCustomerByUserId(userId);
      final customerId = customerData?['id']?.toString() ?? '1';

      final tickets = await FirebaseService.instance.getTicketsByCustomerId(customerId);
      if (mounted) {
        setState(() {
          _tickets = tickets.isEmpty ? _getSampleTickets() : tickets;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tickets = _getSampleTickets();
        });
      }
    }
  }

  List<Map<String, dynamic>> _getSampleTickets() {
    return [
      {
        'id': 'TKT-2026-1042',
        'title': 'Optimasi Redaman Sinyal ONT Drop Cable',
        'status': 'in_progress',
        'category': 'Sinyal & Kabel',
        'createdAt': '26 Okt 2026, 06:40 WIB',
        'technician': 'Ahmad Fauzi (NOC-FIELD-02)',
        'slaRemaining': '35 Menit',
        'step': 2,
      },
      {
        'id': 'TKT-2026-9921',
        'title': 'Pemeriksaan Rutin Redaman Optik ODP',
        'status': 'closed',
        'category': 'Preventive Maintenance',
        'createdAt': '22 Okt 2026',
        'resolvedAt': '22 Okt 2026',
      },
    ];
  }




  void _showWhatsAppNocModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: const Color(0xFF00FF9D),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00FF9D), width: 1.5),
                  ),
                  child: const Icon(LucideIcons.messageSquare, color: Color(0xFF00FF9D), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHATSAPP NOC EMERGENCY',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
                        '// FAST RESPONSE < 3 MENIT • 24/7 SIAGA',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF00FF9D),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.white70 : Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HOTLINE WHATSAPP RESMI:',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '+62 821-1200-1600',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00FF9D),
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: '+6282112001600'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Nomor WhatsApp NOC disalin ke clipboard!'),
                              backgroundColor: Color(0xFF059669),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF9D),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(LucideIcons.copy, size: 14),
                        label: const Text('Salin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.info, size: 16, color: Color(0xFF00F0FF)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pesan Otomatis: "Halo NOC AUDIRA, saya butuh bantuan darurat untuk kendala koneksi internet fiber."',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  const url = 'https://wa.me/6282112001600?text=Halo%20NOC%20Audira,%20saya%20butuh%20bantuan%20darurat%20koneksi%20fiber';
                  final uri = Uri.parse(url);
                  try {
                    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                    if (!launched) {
                      Clipboard.setData(const ClipboardData(text: '+6282112001600'));
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Nomor WA +6282112001600 disalin ke clipboard.'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    }
                  } catch (_) {
                    Clipboard.setData(const ClipboardData(text: '+6282112001600'));
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Nomor WA +6282112001600 disalin ke clipboard.'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF9D),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(LucideIcons.externalLink, size: 18),
                label: const Text(
                  'BUKA CHAT WHATSAPP LANGSUNG ➔',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallCenterModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: const Color(0xFF00F0FF),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
                  ),
                  child: const Icon(LucideIcons.phoneCall, color: Color(0xFF00F0FF), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CALL CENTER BEBAS PULSA',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
                        '// OPERATOR NOC ON-DUTY • 24 JAM SIAGA',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF00F0FF),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.white70 : Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HOTLINE TOLL-FREE:', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: 'monospace')),
                          SizedBox(height: 2),
                          Text(
                            '1500-888',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00F0FF), fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: '1500888'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Nomor 1500-888 disalin!'), backgroundColor: Color(0xFF0284C7)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00F0FF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(LucideIcons.copy, size: 14),
                        label: const Text('Salin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFF1E293B)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LINE HUNTING PSTN:', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: 'monospace')),
                          const SizedBox(height: 2),
                          Text(
                            '(021) 555-8900',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: '0215558900'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Nomor (021) 555-8900 disalin!'), backgroundColor: Color(0xFF0284C7)),
                          );
                        },
                        icon: const Icon(LucideIcons.copy, size: 13, color: Color(0xFF94A3B8)),
                        label: const Text('Salin', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final uri = Uri.parse('tel:1500888');
                  try {
                    await launchUrl(uri);
                  } catch (_) {
                    Clipboard.setData(const ClipboardData(text: '1500888'));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F0FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(LucideIcons.phone, size: 18),
                label: const Text(
                  'HUBUNGI OPERATOR SEKARANG ➔',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDetailModal(Map<String, dynamic> ticket) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = ticket['id'] ?? 'TKT-LIVE';
    final title = ticket['title'] ?? 'Tiket Kendala Jaringan';
    final status = ticket['status'] ?? 'open';
    final isClosed = status == 'closed' || status == 'resolved' || status == 'selesai';
    final tech = ticket['technician'] ?? 'Ahmad Fauzi (NOC-FIELD-02)';
    final category = ticket['category'] ?? 'Kendala Fiber Optik';
    final createdAt = ticket['createdAt'] ?? '29 Okt 2026, 14:10 WIB';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      id,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00F0FF),
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isClosed ? const Color(0xFF00FF9D) : const Color(0xFFFFB800)).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isClosed ? const Color(0xFF00FF9D) : const Color(0xFFFFB800),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isClosed ? 'SELESAI // TUNTAS' : 'PROSES NOC // TEKNISI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isClosed ? const Color(0xFF00FF9D) : const Color(0xFFFFB800),
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.white70 : Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '// Kategori: $category • Dilaporkan: $createdAt',
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Technical Telemetry Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TELEMETRI & TITIK FIBER OPTIK (TR-069):',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF00F0FF), fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildTelemetryCell('Redaman Optik Rx', '-18.4 dBm', const Color(0xFF00FF9D), isDark),
                              const SizedBox(width: 8),
                              _buildTelemetryCell('Titik ODP Distribusi', 'ODP-PLG-04/12', const Color(0xFF00F0FF), isDark),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildTelemetryCell('OLT Core Backbone', 'GPON-01/04', const Color(0xFF7928CA), isDark),
                              const SizedBox(width: 8),
                              _buildTelemetryCell('Model ONT Router', 'ZTE F670L Wi-Fi 6', Colors.amberAccent, isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Multi-Step SLA Tracker
                    const Text(
                      'TIMELINE PENANGANAN SLA REALTIME:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 10),
                    _buildTimelineStep(1, 'Laporan Tiket Diterima', 'Dispatched otomatis ke Sistem Pemantauan NOC', isClosed || true, isDark),
                    _buildTimelineStep(2, 'Analisis Telemetri OLT', 'Pengecekan redaman laser & port optical core', isClosed || true, isDark),
                    _buildTimelineStep(3, 'Penugasan Teknisi Lapangan', 'Teknisi ditugaskan: $tech', isClosed || !isClosed, isDark),
                    _buildTimelineStep(4, 'Investigasi & Splicing Optik', 'Penyambungan core kabel drop di lokasi', isClosed, isDark),
                    _buildTimelineStep(5, 'Verifikasi & Tiket Tuntas', 'Redaman optimal terpantau stabil, layanan normal', isClosed, isDark),
                    const SizedBox(height: 18),

                    // Assigned Technician Contact Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1527) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF0070F3), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0070F3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.userCheck, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tech,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                ),
                                const Text(
                                  'Petugas Reaksi Cepat • URC Fiber Team',
                                  style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final techRoom = ChatRoom(
                        id: 'room_${id.replaceAll('-', '_').toLowerCase()}',
                        title: 'Teknisi Lapangan - $tech',
                        type: 'customer_teknisi',
                        participants: ['customer', 'technician_01'],
                        lastMessage: 'Halo, saya sedang menangani tiket $id.',
                        lastMessageTime: DateTime.now(),
                        ticketId: id,
                        status: 'in_field',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LiveChatRoomPage(room: techRoom)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF9D),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                    icon: const Icon(LucideIcons.messageSquare, size: 18),
                    label: const Text('CHAT TEKNISI ➔', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Tutup', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCell(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(int stepNum, String title, String desc, bool isDone, bool isDark) {
    final color = isDone ? const Color(0xFF00FF9D) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? const Color(0xFF00FF9D).withValues(alpha: 0.2) : Colors.transparent,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: isDone
                  ? const Icon(LucideIcons.check, size: 12, color: Color(0xFF00FF9D))
                  : Text('$stepNum', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDone ? (isDark ? Colors.white : const Color(0xFF0F172A)) : const Color(0xFF94A3B8),
                  ),
                ),
                Text(desc, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTicketDialog() {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Internet Lambat';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? const Color(0xFF00F0FF) : Colors.black,
              width: 2,
            ),
          ),
          title: Row(
            children: [
              const Icon(LucideIcons.alertTriangle, color: Color(0xFF00F0FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'BUAT TIKET GANGGUAN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '// KATEGORI_KENDALA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  items: const [
                    DropdownMenuItem(value: 'Internet Lambat', child: Text('Internet Lambat / Latensi Tinggi')),
                    DropdownMenuItem(value: 'Lampu LOS Merah', child: Text('Lampu LOS Merah / Kabel Putus')),
                    DropdownMenuItem(value: 'Wi-Fi Tidak Terdeteksi', child: Text('Wi-Fi Tidak Terdeteksi')),
                    DropdownMenuItem(value: 'Kendala Tagihan', child: Text('Kendala Pembayaran / Tagihan')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCategory = val);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '// JUDUL_KELUHAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Koneksi drop sejak pagi',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '// DESKRIPSI_DETAIL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan kondisi lampu indikator router atau kendala spesifik...',
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = subjectController.text.trim();
                if (title.isNotEmpty) {
                  final now = DateTime.now();
                  final ticketNo = 'TKT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(1000 + now.millisecond).toString()}';
                  Navigator.pop(context);
                  setState(() {
                    _tickets.insert(0, {
                      'id': ticketNo,
                      'title': title,
                      'status': 'open',
                      'category': selectedCategory,
                      'createdAt': 'Baru saja',
                      'technician': 'Ahmad Fauzi (NOC-FIELD-02)',
                      'slaRemaining': '35 Menit',
                      'step': 2,
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tiket $ticketNo berhasil diteruskan ke NOC & Teknisi Siaga!'),
                      backgroundColor: const Color(0xFF00FF9D),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF0070F3) : Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Kirim ke NOC ➔', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.3) : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTickets,
          color: const Color(0xFF00F0FF),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PUSAT BANTUAN & NOC',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '// 24/7_NETWORK_OPERATION_CENTER',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF00FF9D), width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.radio, size: 12, color: Color(0xFF00FF9D)),
                          SizedBox(width: 4),
                          Text(
                            'NOC SIAGA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00FF9D),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // NOC Network Status Hero Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF00FF9D).withValues(alpha: 0.4) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFF00FF9D).withValues(alpha: 0.12)
                            : const Color(0xFF0F172A).withValues(alpha: 0.08),
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                              border: Border.all(color: const Color(0xFF00FF9D), width: 1.5),
                            ),
                            child: const Icon(LucideIcons.shieldCheck, size: 24, color: Color(0xFF00FF9D)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'JARINGAN FIBER NORMAL',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Core Backbone Jakarta-01 beroperasi 100% tanpa gangguan masal.',
                                  style: TextStyle(fontSize: 11.5, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNocTelemetryItem('Latensi Core', '11 ms', const Color(0xFF00F0FF), isDark),
                          _buildNocTelemetryItem('Packet Loss', '0.0 %', const Color(0xFF00FF9D), isDark),
                          _buildNocTelemetryItem('Uptime SLA', '99.98 %', const Color(0xFF7928CA), isDark),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Report Incident Button (Big Neo-Brutalist CTA)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showCreateTicketDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                      foregroundColor: isDark ? const Color(0xFF05070D) : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? Colors.white : Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    icon: const Icon(LucideIcons.plusCircle, size: 20),
                    label: const Text(
                      'BUAT TIKET GANGGUAN BARU ➔',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Live Chat Siaga (CS & Teknisi) Banner Card
                _buildLiveChatBanner(isDark, cardBg, textPrimary, textSecondary),

                const SizedBox(height: 20),

                // Quick Contact Channels Bento
                Text(
                  'KANAL HUBUNGI KAMI 24/7',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // WhatsApp Hotline
                    Expanded(
                      child: _buildContactChannelCard(
                        title: 'WhatsApp NOC',
                        subtitle: '+62 821-1200-1600',
                        badge: 'RESPON CEPAT',
                        icon: LucideIcons.messageSquare,
                        accentColor: const Color(0xFF00FF9D),
                        isDark: isDark,
                        onTap: _showWhatsAppNocModal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Call Center
                    Expanded(
                      child: _buildContactChannelCard(
                        title: 'Call Center',
                        subtitle: '1500-888',
                        badge: 'BEBAS PULSA',
                        icon: LucideIcons.phoneCall,
                        accentColor: const Color(0xFF00F0FF),
                        isDark: isDark,
                        onTap: _showCallCenterModal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tanya Audi AI
                    Expanded(
                      child: _buildContactChannelCard(
                        title: 'Tanya Audi',
                        subtitle: 'AI Diagnostik',
                        badge: '24/7 SIAGA',
                        icon: LucideIcons.bot,
                        accentColor: const Color(0xFF7928CA),
                        isDark: isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChatbotPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Riwayat Tiket Kendala
                Text(
                  'RIWAYAT TIKET GANGGUAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 10),
                if (_tickets.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text(
                        'Tidak ada tiket kendala aktif saat ini.',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ),
                  )
                else
                  ..._tickets.map((t) => _buildTicketItem(t, isDark, textPrimary, textSecondary, cardBg)),

                const SizedBox(height: 22),

                // FAQ Accordion
                Text(
                  'PANDUAN & PERTANYAAN UMUM (FAQ)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(_faqs.length, (idx) {
                  final faq = _faqs[idx];
                  final isExpanded = _expandedFaqIndex == idx;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isExpanded
                            ? (isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A))
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                        width: isExpanded ? 1.5 : 1.0,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _expandedFaqIndex = isExpanded ? null : idx;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    faq['q']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                                  size: 16,
                                  color: textSecondary,
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 8),
                              Text(
                                faq['a']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNocTelemetryItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildContactChannelCard({
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? accentColor.withValues(alpha: 0.35) : const Color(0xFFCBD5E1),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? accentColor.withValues(alpha: 0.1)
                  : const Color(0xFF0F172A).withValues(alpha: 0.05),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, size: 18, color: accentColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketItem(
    Map<String, dynamic> ticket,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color cardBg,
  ) {
    final id = ticket['id'] ?? 'TKT-001';
    final title = ticket['title'] ?? 'Tiket Gangguan';
    final status = ticket['status'] ?? 'open';
    final isClosed = status == 'closed' || status == 'resolved';

    return InkWell(
      onTap: () => _showTicketDetailModal(ticket),
      borderRadius: BorderRadius.circular(14),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
      ),
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
                    Row(
                      children: [
                        Text(
                          id,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00F0FF),
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: (isClosed ? const Color(0xFF00FF9D) : const Color(0xFFFFB800)).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isClosed ? 'SELESAI' : 'PROSES NOC',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isClosed ? const Color(0xFF00FF9D) : const Color(0xFFFFB800),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Direct Action to Chat with Technician
              InkWell(
                onTap: () {
                  final techRoom = ChatRoom(
                    id: 'room_tech_tkt9921',
                    title: 'Teknisi Lapangan - Rian Pratama',
                    type: 'customer_teknisi',
                    participants: ['customer', 'technician_01'],
                    lastMessage: 'Pengecekan ODP sedang berlangsung',
                    lastMessageTime: DateTime.now(),
                    ticketId: id,
                    status: 'in_field',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveChatRoomPage(room: techRoom),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF00FF9D).withValues(alpha: 0.15) : const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF059669),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.messageSquare,
                        size: 13,
                        color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF059669),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Chat Teknisi',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!isClosed) ...[
            const SizedBox(height: 10),
            // SLA Progress Tracker Bar (Full width across card)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.timer, size: 12, color: Color(0xFFFFB800)),
                          const SizedBox(width: 5),
                          Text(
                            'SLA ESTIMASI: ${ticket['slaRemaining'] ?? '45 Menit'}',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFB800),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ticket['technician'] ?? 'Tim Lapangan',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildSlaStepDot('Diterima', true, isDark),
                      _buildSlaConnector(true),
                      _buildSlaStepDot('NOC', true, isDark),
                      _buildSlaConnector(true),
                      _buildSlaStepDot('Teknisi', true, isDark),
                      _buildSlaConnector(false),
                      _buildSlaStepDot('Selesai', false, isDark),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
  }

  Widget _buildLiveChatBanner(
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LiveChatListPage()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1527) : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF00F0FF).withValues(alpha: 0.18)
                  : const Color(0xFF0070F3).withValues(alpha: 0.12),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F0FF), Color(0xFF0070F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(LucideIcons.messagesSquare, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF9D).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF00FF9D), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.circleDot, size: 10, color: Color(0xFF00FF9D)),
                            SizedBox(width: 4),
                            Text(
                              'CS & TEKNISI SIAGA',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF00FF9D),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pusat Live Chat Real-Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chat langsung dengan tim CS Siaga 24/7 & Teknisi penanganan tiket Anda.',
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? Colors.white : Colors.black, width: 1.2),
              ),
              child: Icon(
                LucideIcons.arrowRight,
                size: 16,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlaStepDot(String label, bool isDone, bool isDark) {
    final activeColor = const Color(0xFF00FF9D);
    final inactiveColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? activeColor : inactiveColor,
            border: Border.all(
              color: isDone ? activeColor : inactiveColor,
              width: 1.5,
            ),
            boxShadow: isDone
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: isDone
              ? const Icon(LucideIcons.check, size: 9, color: Colors.black)
              : null,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: isDone ? FontWeight.w800 : FontWeight.w500,
            color: isDone
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSlaConnector(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 12),
        color: isDone
            ? const Color(0xFF00FF9D)
            : const Color(0xFF334155).withValues(alpha: 0.4),
      ),
    );
  }
}
