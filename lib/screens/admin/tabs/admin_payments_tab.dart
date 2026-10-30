import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Clean Apple/Linear Transactions & Network Monitoring Tab for AUDIRA Admin
class AdminPaymentsTab extends StatefulWidget {
  const AdminPaymentsTab({super.key});

  @override
  State<AdminPaymentsTab> createState() => _AdminPaymentsTabState();
}

class _AdminPaymentsTabState extends State<AdminPaymentsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _speedTests = [];
  bool _isLoadingPayments = true;
  bool _isLoadingSpeedTests = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPayments();
    _loadSpeedTests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoadingPayments = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('payments')
          .limit(50)
          .get();

      final payments = snap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'customerName': data['customerName'] ?? data['name'] ?? 'Pelanggan',
          'billMonth': data['billMonth'] ?? data['month'] ?? '-',
          'paymentStatus': (data['paymentStatus'] ?? data['status'] ?? 'paid').toString().toLowerCase(),
          'method': data['paymentMethod'] ?? data['method'] ?? 'Online',
          'amount': data['amount'] ?? 0,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _payments = payments;
          _isLoadingPayments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPayments = false);
    }
  }

  Future<void> _loadSpeedTests() async {
    setState(() => _isLoadingSpeedTests = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('speed_tests')
          .limit(30)
          .get();

      final tests = snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      if (mounted) {
        setState(() {
          _speedTests = tests;
          _isLoadingSpeedTests = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSpeedTests = false);
    }
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
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaksi & Monitoring',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Log pembayaran & riwayat uji kecepatan pelanggan',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.refreshCw, size: 18, color: textPrimary),
                    onPressed: () {
                      _loadPayments();
                      _loadSpeedTests();
                    },
                    tooltip: 'Refresh Data',
                  ),
                ],
              ),
            ),

            // Tab Segment Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(3),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  labelColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                  unselectedLabelColor: textSecondary,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.creditCard, size: 16),
                          SizedBox(width: 8),
                          Text('Pembayaran'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.gauge, size: 16),
                          SizedBox(width: 8),
                          Text('Speed Test'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Pembayaran
                  _isLoadingPayments
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : RefreshIndicator(
                          onRefresh: _loadPayments,
                          color: const Color(0xFF0284C7),
                          child: _payments.isEmpty
                              ? _buildEmptyState(
                                  icon: LucideIcons.receipt,
                                  title: 'Belum Ada Riwayat Transaksi',
                                  subtitle: 'Semua transaksi pembayaran pelanggan akan tercatat di sini',
                                  cardBg: cardBg,
                                  borderColor: borderColor,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  itemCount: _payments.length,
                                  itemBuilder: (context, index) {
                                    return _PaymentCardItem(
                                      payment: _payments[index],
                                      isDark: isDark,
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                    );
                                  },
                                ),
                        ),

                  // Tab 2: Speed Tests
                  _isLoadingSpeedTests
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : RefreshIndicator(
                          onRefresh: _loadSpeedTests,
                          color: const Color(0xFF0284C7),
                          child: _speedTests.isEmpty
                              ? _buildEmptyState(
                                  icon: LucideIcons.gauge,
                                  title: 'Belum Ada Hasil Speed Test',
                                  subtitle: 'Hasil pengujian kecepatan jaringan dari pelanggan akan muncul di sini',
                                  cardBg: cardBg,
                                  borderColor: borderColor,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  itemCount: _speedTests.length,
                                  itemBuilder: (context, index) {
                                    return _SpeedTestCardItem(
                                      test: _speedTests[index],
                                      isDark: isDark,
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                    );
                                  },
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: textSecondary),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCardItem extends StatelessWidget {
  final Map<String, dynamic> payment;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _PaymentCardItem({
    required this.payment,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final amount = (payment['amount'] as num?)?.toInt() ?? 0;
    final customerName = payment['customerName'] as String? ?? 'Pelanggan';
    final customerId = payment['customerId'] as String? ?? '-';
    final billMonth = payment['billMonth'] as String? ?? '-';
    final paymentStatus = payment['paymentStatus'] as String? ?? 'paid';
    final isPaid = paymentStatus == 'paid';

    final formattedAmount = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
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
                    customerName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: $customerId • Periode: $billMonth',
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPaid ? 'LUNAS' : 'PENDING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metode: ${payment['paymentMethod'] ?? 'Online'}',
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
              Text(
                'Rp $formattedAmount',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedTestCardItem extends StatelessWidget {
  final Map<String, dynamic> test;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _SpeedTestCardItem({
    required this.test,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final download = (test['downloadSpeed'] as num?)?.toDouble() ?? 0.0;
    final upload = (test['uploadSpeed'] as num?)?.toDouble() ?? 0.0;
    final ping = (test['ping'] as num?)?.toInt() ?? 0;
    final customerName = test['customerName'] as String? ?? 'Pelanggan';
    final testDate = test['testDate'] as String? ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customerName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              Text(
                testDate,
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SpeedValue(label: 'Download', value: '${download.toStringAsFixed(1)} Mbps', color: const Color(0xFF0284C7), isDark: isDark, textSecondary: textSecondary),
              _SpeedValue(label: 'Upload', value: '${upload.toStringAsFixed(1)} Mbps', color: const Color(0xFF10B981), isDark: isDark, textSecondary: textSecondary),
              _SpeedValue(label: 'Ping', value: '$ping ms', color: const Color(0xFFF59E0B), isDark: isDark, textSecondary: textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedValue extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final Color textSecondary;

  const _SpeedValue({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
