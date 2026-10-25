import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/pdf_generator_service.dart';
import '../payment_page.dart';

/// Neo-Brutalist Cyber Invoicing System for AUDIRA Customers
class CustomerTagihanTab extends StatefulWidget {
  const CustomerTagihanTab({super.key});

  @override
  State<CustomerTagihanTab> createState() => _CustomerTagihanTabState();
}

class _CustomerTagihanTabState extends State<CustomerTagihanTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBills();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);

    try {
      final currentUserData = AuthService.instance.currentUserData;
      if (currentUserData == null) {
        if (mounted) setState(() { _bills = _getSampleBills(); _isLoading = false; });
        return;
      }

      final customerData = await FirebaseService.instance.getCustomerByUserId(
        currentUserData['id'].toString(),
      );

      if (customerData == null) {
        if (mounted) setState(() { _bills = _getSampleBills(); _isLoading = false; });
        return;
      }

      final bills = await FirebaseService.instance.getBillsByCustomerId(
        customerData['id'].toString(),
      );

      if (mounted) {
        setState(() {
          _bills = bills.isEmpty ? _getSampleBills() : bills;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bills = _getSampleBills();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getSampleBills() {
    return [
      {
        'id': 'INV-2026-11-0089',
        'billMonth': 'November 2026',
        'amount': 250000,
        'dueDate': '20 Nov 2026',
        'status': 'unpaid',
      },
      {
        'id': 'INV-2026-10-0089',
        'billMonth': 'Oktober 2026',
        'amount': 250000,
        'dueDate': '20 Okt 2026',
        'status': 'paid',
        'paidAt': '15 Okt 2026',
      },
      {
        'id': 'INV-2026-09-0089',
        'billMonth': 'September 2026',
        'amount': 250000,
        'dueDate': '20 Sep 2026',
        'status': 'paid',
        'paidAt': '18 Sep 2026',
      },
    ];
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    final number = value is num ? value : (int.tryParse(value.toString()) ?? 0);
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    if (date is Timestamp) {
      final dt = date.toDate();
      return '${dt.day} ${_getMonthName(dt.month)} ${dt.year}';
    }
    return date.toString();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  void _copyText(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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

    final activeBills = _bills.where((b) {
      final matchesStatus = b['status'] != 'paid';
      final matchesQuery = _searchQuery.isEmpty ||
          (b['billMonth']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (b['id']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesStatus && matchesQuery;
    }).toList();

    final paidBills = _bills.where((b) {
      final matchesStatus = b['status'] == 'paid';
      final matchesQuery = _searchQuery.isEmpty ||
          (b['billMonth']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (b['id']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesStatus && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Page Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TAGIHAN & PEMBAYARAN',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '// INVOICE_LEDGER_SYSTEM',
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
                          color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF00F0FF).withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${activeBills.length} PENDING',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00F0FF),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Bar
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor, width: 1.2),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: TextStyle(fontSize: 13, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Cari bulan tagihan atau nomor invoice...',
                        hintStyle: TextStyle(fontSize: 12.5, color: textSecondary),
                        prefixIcon: Icon(LucideIcons.search, size: 16, color: textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Neo-Brutalist Tab Selector
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF05070D) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: isDark ? const Color(0xFF0C2B45) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFF00F0FF).withValues(alpha: 0.2)
                                : const Color(0xFF0F172A).withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      labelColor: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                      unselectedLabelColor: textSecondary,
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                      unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      tabs: [
                        Tab(text: 'Tagihan Aktif (${activeBills.length})'),
                        Tab(text: 'Riwayat Lunas (${paidBills.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildActiveBillsView(
                          activeBills,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          cardBg: cardBg,
                          borderColor: borderColor,
                        ),
                        _buildPaidBillsView(
                          paidBills,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          cardBg: cardBg,
                          borderColor: borderColor,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBillsView(
    List<Map<String, dynamic>> bills, {
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color cardBg,
    required Color borderColor,
  }) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00FF9D).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFF00FF9D), width: 1.5),
              ),
              child: const Icon(LucideIcons.checkCircle2, size: 40, color: Color(0xFF00FF9D)),
            ),
            const SizedBox(height: 14),
            Text(
              'SELURUH TAGIHAN LUNAS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Terima kasih! Koneksi fiber Anda berjalan optimal tanpa tunggakan.',
              style: TextStyle(fontSize: 12, color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final topBill = bills.first;
    final topBillId = topBill['id']?.toString() ?? 'INV-001';
    final topMonth = topBill['billMonth']?.toString() ?? 'Bulan Ini';
    final topAmount = topBill['amount'] ?? 250000;
    final topDueDate = _formatDate(topBill['dueDate']);

    return RefreshIndicator(
      onRefresh: _loadBills,
      color: const Color(0xFF00F0FF),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Unpaid Bill Hero Bento
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.5) : const Color(0xFF0F172A),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                        : const Color(0xFF0F172A).withValues(alpha: 0.1),
                    offset: const Offset(5, 5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top alert ribbon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.alertTriangle, size: 14, color: Color(0xFFFFB800)),
                              const SizedBox(width: 6),
                              Text(
                                'JATUH TEMPO: $topDueDate',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFFB800),
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _copyText(topBillId, 'No. Invoice'),
                            child: Row(
                              children: [
                                Text(
                                  topBillId,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textSecondary,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(LucideIcons.copy, size: 11, color: textSecondary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tagihan $topMonth',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Layanan Internet Dedicated Fiber 50 Mbps',
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                          const SizedBox(height: 12),

                          // Nominal Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(topAmount),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimary,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '/ Bulan',
                                  style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Instant Payment CTA
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final numAmount = topAmount is num ? topAmount.toDouble() : 250000.0;
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                      billId: topBillId,
                                      billMonth: topMonth,
                                      amount: numAmount,
                                    ),
                                  ),
                                );
                                if (res == true) _loadBills();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF0070F3) : const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isDark ? const Color(0xFF00F0FF) : Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              icon: const Icon(LucideIcons.qrCode, size: 18),
                              label: const Text(
                                'BAYAR SEKARANG (QRIS / VA) ➔',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Rincian Layanan Bento Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.fileSpreadsheet, size: 16, color: Color(0xFF00F0FF)),
                      const SizedBox(width: 8),
                      Text(
                        'RINCIAN ITEM TAGIHAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInvoiceLine('Paket Fiber Ultra 50 Mbps', 'Rp 225.225', textPrimary, textSecondary),
                  const SizedBox(height: 6),
                  _buildInvoiceLine('Sewa ONT Router Wi-Fi 6', 'Rp 0 (FREE)', textPrimary, const Color(0xFF00FF9D)),
                  const SizedBox(height: 6),
                  _buildInvoiceLine('PPN 11%', 'Rp 24.775', textPrimary, textSecondary),
                  const Divider(height: 18, color: Color(0xFF1E293B)),
                  _buildInvoiceLine('Total Pembayaran', _formatCurrency(topAmount), textPrimary, textPrimary, isBold: true),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Instant Payment Rail Chips
            Text(
              'KANAL PEMBAYARAN INSTAN',
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
                _buildPaymentMethodChip('QRIS Instan', LucideIcons.qrCode, const Color(0xFF00F0FF), isDark),
                const SizedBox(width: 8),
                _buildPaymentMethodChip('BCA VA', LucideIcons.building2, const Color(0xFF0070F3), isDark),
                const SizedBox(width: 8),
                _buildPaymentMethodChip('Mandiri VA', LucideIcons.creditCard, const Color(0xFF7928CA), isDark),
                const SizedBox(width: 8),
                _buildPaymentMethodChip('E-Wallet', LucideIcons.wallet, const Color(0xFF00FF9D), isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaidBillsView(
    List<Map<String, dynamic>> bills, {
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color cardBg,
    required Color borderColor,
  }) {
    if (bills.isEmpty) {
      return Center(
        child: Text(
          'Belum ada riwayat pembayaran yang lunas',
          style: TextStyle(fontSize: 13, color: textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBills,
      color: const Color(0xFF00F0FF),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
        itemCount: bills.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bill = bills[index];
          final billId = bill['id']?.toString() ?? 'INV-${index + 1}';
          final month = bill['billMonth']?.toString() ?? 'Tagihan';
          final amount = bill['amount'] ?? 250000;
          final dueDate = _formatDate(bill['dueDate']);
          final paidAt = bill['paidAt'] ?? dueDate;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0xFF0F172A).withValues(alpha: 0.05),
                  offset: const Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          month,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No. $billId',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF00FF9D), width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.check, size: 12, color: Color(0xFF00FF9D)),
                          SizedBox(width: 4),
                          Text(
                            'LUNAS',
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
                const SizedBox(height: 12),
                Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Nominal',
                          style: TextStyle(fontSize: 10.5, color: textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(amount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await PdfGeneratorService.instance.previewPdf({
                          'id': billId,
                          'customerName': 'Budi Pelanggan',
                          'customerId': 'ADN-2026-0889',
                          'billMonth': month,
                          'amount': (amount is num ? amount.toDouble() : 250000.0),
                          'dueDate': dueDate,
                          'status': 'paid',
                          'paidDate': paidAt,
                        });
                      },
                      icon: const Icon(LucideIcons.fileText, size: 14),
                      label: const Text('Unduh Bukti', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.5) : Colors.black,
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Lunas pada: $paidAt',
                  style: TextStyle(fontSize: 10.5, color: textSecondary, fontFamily: 'monospace'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceLine(String label, String value, Color textColor, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodChip(String name, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? color.withValues(alpha: 0.4) : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
