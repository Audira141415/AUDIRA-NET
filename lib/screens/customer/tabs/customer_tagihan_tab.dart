import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/pdf_generator_service.dart';
import '../payment_page.dart';

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
        setState(() {
          _bills = _getSampleBills();
          _isLoading = false;
        });
        return;
      }

      final customerData = await FirebaseService.instance.getCustomerByUserId(
        currentUserData['id'].toString(),
      );

      if (customerData == null) {
        setState(() {
          _bills = _getSampleBills();
          _isLoading = false;
        });
        return;
      }

      final bills = await FirebaseService.instance.getBillsByCustomerId(
        customerData['id'].toString(),
      );

      if (bills.isEmpty) {
        setState(() {
          _bills = _getSampleBills();
          _isLoading = false;
        });
      } else {
        setState(() {
          _bills = bills;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _bills = _getSampleBills();
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final activeBills = _bills.where((b) {
      final matchesStatus = b['status'] != 'paid';
      final matchesQuery = _searchQuery.isEmpty ||
          (b['billMonth']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesStatus && matchesQuery;
    }).toList();

    final paidBills = _bills.where((b) {
      final matchesStatus = b['status'] == 'paid';
      final matchesQuery = _searchQuery.isEmpty ||
          (b['billMonth']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesStatus && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Page Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tagihan & Pembayaran',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola tagihan bulanan dan riwayat pembayaran',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: TextStyle(fontSize: 13, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Cari bulan atau nomor invoice...',
                        hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                        prefixIcon: Icon(LucideIcons.search, size: 18, color: textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tab Selector
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      labelColor: textPrimary,
                      unselectedLabelColor: textSecondary,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      tabs: [
                        Tab(text: 'Tagihan Aktif (${activeBills.length})'),
                        Tab(text: 'Riwayat Lunas (${paidBills.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBillList(activeBills, isPaid: false, isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary, cardBg: cardBg, borderColor: borderColor),
                        _buildBillList(paidBills, isPaid: true, isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary, cardBg: cardBg, borderColor: borderColor),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillList(
    List<Map<String, dynamic>> bills, {
    required bool isPaid,
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
            Icon(
              isPaid ? LucideIcons.receipt : LucideIcons.checkCircle2,
              size: 48,
              color: textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              isPaid ? 'Belum ada riwayat pembayaran' : 'Tidak ada tagihan tertunda',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              isPaid ? 'Tagihan yang lunas akan muncul di sini' : 'Semua tagihan Anda telah lunas!',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBills,
      color: const Color(0xFF0284C7),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: bills.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bill = bills[index];
          final billId = bill['id']?.toString() ?? 'INV-${index + 1}';
          final month = bill['billMonth']?.toString() ?? 'Tagihan';
          final amount = bill['amount'] ?? 250000;
          final dueDate = _formatDate(bill['dueDate']);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
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
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No. $billId',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPaid ? 'LUNAS' : 'BELUM BAYAR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: isPaid ? const Color(0xFF059669) : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: borderColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Nominal',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(amount),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (!isPaid)
                      FilledButton(
                        onPressed: () async {
                          final numAmount = amount is num ? amount.toDouble() : 250000.0;
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                billId: billId,
                                billMonth: month,
                                amount: numAmount,
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadBills();
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Bayar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () async {
                          await PdfGeneratorService.instance.previewPdf({
                            'id': billId,
                            'customerName': 'Pelanggan AUDIRA',
                            'customerId': 'ADN-2026',
                            'billMonth': month,
                            'amount': (amount is num ? amount.toDouble() : 250000.0),
                            'dueDate': dueDate,
                            'status': 'paid',
                            'paidDate': bill['paidAt'] ?? dueDate,
                          });
                        },
                        icon: const Icon(LucideIcons.fileText, size: 14),
                        label: const Text('Struk', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isPaid ? 'Lunas pada: ${bill['paidAt'] ?? dueDate}' : 'Jatuh tempo: $dueDate',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
