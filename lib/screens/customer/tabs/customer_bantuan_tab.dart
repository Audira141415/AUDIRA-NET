import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../chatbot_page.dart';

class CustomerBantuanTab extends StatefulWidget {
  const CustomerBantuanTab({super.key});

  @override
  State<CustomerBantuanTab> createState() => _CustomerBantuanTabState();
}

class _CustomerBantuanTabState extends State<CustomerBantuanTab> {
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final currentUserData = AuthService.instance.currentUserData;
      final userId = currentUserData?['id']?.toString() ?? '1';
      final customerData = await FirebaseService.instance.getCustomerByUserId(userId);
      final customerId = customerData?['id']?.toString() ?? '1';

      final tickets = await FirebaseService.instance.getTicketsByCustomerId(customerId);
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    String selectedPriority = 'medium';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Buat Tiket Gangguan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kategori Masalah',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  items: const [
                    DropdownMenuItem(value: 'Internet Lambat', child: Text('Internet Lambat / FUP')),
                    DropdownMenuItem(value: 'Lampu LOS Merah', child: Text('Lampu LOS Merah / Kabel Putus')),
                    DropdownMenuItem(value: 'Wi-Fi Tidak Terdeteksi', child: Text('Wi-Fi Tidak Terdeteksi')),
                    DropdownMenuItem(value: 'Lainnya', child: Text('Kendala Lainnya')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCategory = val);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Judul Kendala',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Internet mati sejak pagi',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Deskripsi Lengkap',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan kondisi lampu indikator router...',
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
            FilledButton(
              onPressed: () async {
                if (subjectController.text.trim().isEmpty) return;
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);

                final currentUserData = AuthService.instance.currentUserData;
                final userId = currentUserData?['id']?.toString() ?? '1';
                final customerData = await FirebaseService.instance.getCustomerByUserId(userId);

                await FirebaseService.instance.createTicket({
                  'customerId': customerData?['id']?.toString() ?? '1',
                  'customerName': customerData?['name'] ?? currentUserData?['name'] ?? 'Pelanggan',
                  'subject': subjectController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'category': selectedCategory,
                  'priority': selectedPriority,
                  'status': 'open',
                  'zone': 'Batam Center',
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Laporan gangguan berhasil dikirim. Teknisi kami akan segera memproses.'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                  _loadTickets();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
              ),
              child: const Text('Kirim Laporan'),
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
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTickets,
          color: const Color(0xFF0284C7),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Pusat Bantuan & Layanan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kami siap membantu menyelesaikan kendala koneksi Anda 24/7',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 18),

                // Report Ticket Primary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.alertCircle, color: Color(0xFF0284C7), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ada Gangguan Koneksi?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Buat tiket bantuan untuk ditangani teknisi lapangan',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _showCreateTicketDialog,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Buat Tiket', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Support Channels Grid
                Text(
                  'Hubungi Kami Langsung',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildChannelCard(
                        title: 'WhatsApp CS',
                        subtitle: 'Respon Cepat',
                        icon: LucideIcons.messageSquare,
                        iconColor: const Color(0xFF10B981),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () => _launchUrl('https://wa.me/6282112001600'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildChannelCard(
                        title: 'Call Center',
                        subtitle: AppConstants.csCallCenter,
                        icon: LucideIcons.phoneCall,
                        iconColor: const Color(0xFF0284C7),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () => _launchUrl('tel:${AppConstants.csCallCenter.replaceAll('-', '')}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildChannelCard(
                        title: 'Tanya Audi',
                        subtitle: 'Asisten AI',
                        icon: LucideIcons.bot,
                        iconColor: const Color(0xFF8B5CF6),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
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

                const SizedBox(height: 24),

                // Tickets List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Tiket Bantuan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary),
                    ),
                    Text(
                      '${_tickets.length} Tiket',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(strokeWidth: 2)))
                else if (_tickets.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(LucideIcons.checkCircle2, size: 36, color: const Color(0xFF10B981)),
                          const SizedBox(height: 10),
                          Text(
                            'Semua Layanan Normal',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tidak ada tiket kendala aktif saat ini.',
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _tickets.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      final subject = ticket['subject'] ?? 'Kendala Teknis';
                      final status = ticket['status'] ?? 'open';
                      final ticketId = ticket['id'] ?? 'TKT-${index + 1}';

                      final isResolved = status == 'resolved' || status == 'closed';
                      final statusColor = isResolved
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B);
                      final statusLabel = isResolved ? 'SELESAI' : 'PROSES';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'No. $ticketId • ${ticket['category'] ?? 'Umum'}',
                                    style: TextStyle(fontSize: 11, color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
