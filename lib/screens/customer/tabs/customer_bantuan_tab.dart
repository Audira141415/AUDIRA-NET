import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/firebase_service.dart';
import '../../../services/auth_service.dart';
import '../chatbot_page.dart';

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
        'id': 'TKT-2026-9921',
        'title': 'Pemeriksaan Rutin Redaman Optik ODP',
        'status': 'closed',
        'category': 'Preventive Maintenance',
        'createdAt': '22 Okt 2026',
        'resolvedAt': '22 Okt 2026',
      },
    ];
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
                if (subjectController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tiket gangguan TKT-2026-LIVE berhasil diteruskan ke NOC'),
                      backgroundColor: Color(0xFF00FF9D),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _loadTickets();
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
                        onTap: () => _launchUrl('https://wa.me/6282112001600?text=Halo%20NOC%20Audira,%20saya%20butuh%20bantuan%20koneksi'),
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
                        onTap: () => _launchUrl('tel:1500888'),
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

    return Container(
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
      child: Row(
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
          const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
