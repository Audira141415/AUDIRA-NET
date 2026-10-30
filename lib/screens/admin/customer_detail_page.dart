import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../widgets/enhanced_ui_components.dart';
import 'dart:developer' as developer;

/// Admin - Customer Detail Page
/// Menampilkan detail lengkap customer, bills, tickets, payments
class CustomerDetailPage extends StatefulWidget {
  final Map<String, dynamic> customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoadingBills = false;
  bool _isLoadingTickets = false;
  bool _isLoadingPayments = false;

  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([_loadBills(), _loadTickets(), _loadPayments()]);
  }

  Future<void> _loadBills() async {
    setState(() => _isLoadingBills = true);
    try {
      final customerId = widget.customer['customerId'] as String?;
      if (customerId != null && customerId.isNotEmpty) {
        final snapshot = await FirebaseFirestore.instance
            .collection('bills')
            .where('customerId', isEqualTo: customerId)
            .orderBy('dueDate', descending: true)
            .limit(20)
            .get();

        setState(() {
          _bills = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
      }
    } catch (e) {
      developer.log('Error loading bills: $e', name: 'CustomerDetailPage');
    } finally {
      setState(() => _isLoadingBills = false);
    }
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoadingTickets = true);
    try {
      final customerId = widget.customer['customerId'] as String?;
      if (customerId != null && customerId.isNotEmpty) {
        final snapshot = await FirebaseFirestore.instance
            .collection('tickets')
            .where('customerId', isEqualTo: customerId)
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();

        setState(() {
          _tickets = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
      }
    } catch (e) {
      developer.log('Error loading tickets: $e', name: 'CustomerDetailPage');
    } finally {
      setState(() => _isLoadingTickets = false);
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoadingPayments = true);
    try {
      final customerId = widget.customer['customerId'] as String?;
      if (customerId != null && customerId.isNotEmpty) {
        final snapshot = await FirebaseFirestore.instance
            .collection('payments')
            .where('customerId', isEqualTo: customerId)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get();

        setState(() {
          _payments = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
      }
    } catch (e) {
      developer.log('Error loading payments: $e', name: 'CustomerDetailPage');
    } finally {
      setState(() => _isLoadingPayments = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer['name'] as String? ?? 'Customer Detail'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Info'),
            Tab(icon: Icon(Icons.receipt_outlined), text: 'Bills'),
            Tab(
              icon: Icon(Icons.confirmation_number_outlined),
              text: 'Tickets',
            ),
            Tab(icon: Icon(Icons.payment_outlined), text: 'Payments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildBillsTab(),
          _buildTicketsTab(),
          _buildPaymentsTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    final customer = widget.customer;
    final unpaidBills = customer['unpaidBills'] as int? ?? 0;
    final openTickets = customer['openTickets'] as int? ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Avatar & Basic Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      (customer['name'] as String? ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['name'] as String? ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${customer['customerId'] ?? '-'}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
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

          // Status Alerts
          if (unpaidBills > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$unpaidBills tagihan belum dibayar',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (openTickets > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.report_problem_outlined,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$openTickets tiket terbuka',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Contact Information
          _buildSectionTitle('📞 Informasi Kontak'),
          _buildInfoCard([
            _buildInfoRow('Telepon', customer['phone'] ?? '-', Icons.phone),
            _buildInfoRow('Email', customer['email'] ?? '-', Icons.email),
            _buildInfoRow(
              'Alamat',
              customer['address'] ?? '-',
              Icons.location_on,
            ),
          ]),
          const SizedBox(height: 16),

          // Package Information
          _buildSectionTitle('📦 Informasi Paket'),
          _buildInfoCard([
            _buildInfoRow(
              'Paket',
              customer['packageName'] ?? customer['package'] ?? '-',
              Icons.wifi,
            ),
            _buildInfoRow(
              'Harga',
              'Rp ${_formatCurrency(customer['price'] ?? 0)}',
              Icons.payments,
            ),
            _buildInfoRow(
              'Status',
              (customer['status'] ?? 'active').toString().toUpperCase(),
              Icons.info_outline,
            ),
          ]),
          const SizedBox(height: 16),

          // Account Information
          _buildSectionTitle('👤 Informasi Akun'),
          _buildInfoCard([
            _buildInfoRow('User ID', customer['userId'] ?? '-', Icons.person),
            _buildInfoRow(
              'Tgl Bergabung',
              _formatDate(customer['joinDate']),
              Icons.calendar_today,
            ),
            _buildInfoRow('Role', customer['role'] ?? 'customer', Icons.badge),
          ]),
        ],
      ),
    );
  }

  Widget _buildBillsTab() {
    if (_isLoadingBills) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bills.isEmpty) {
      return const EnhancedEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum Ada Tagihan',
        description: 'Customer ini belum memiliki tagihan.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bills.length,
      itemBuilder: (context, index) {
        final bill = _bills[index];
        final isPaid = (bill['status'] as String?) == 'paid';
        final amount = bill['amount'] as num? ?? 0;
        final billMonth = bill['billMonth'] as String? ?? '-';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPaid
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              child: Icon(
                isPaid ? Icons.check_circle : Icons.warning_amber_rounded,
                color: isPaid ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            title: Text(
              'Tagihan $billMonth',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Rp ${_formatCurrency(amount)}'),
                Text(
                  'Jatuh tempo: ${_formatDate(bill['dueDate'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                isPaid ? 'LUNAS' : 'BELUM BAYAR',
                style: TextStyle(
                  fontSize: 11,
                  color: isPaid ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              backgroundColor: isPaid
                  ? Colors.green.shade50
                  : Colors.red.shade50,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketsTab() {
    if (_isLoadingTickets) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tickets.isEmpty) {
      return const EnhancedEmptyState(
        icon: Icons.confirmation_number_outlined,
        title: 'Belum Ada Tiket',
        description: 'Customer ini belum memiliki tiket support.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        final status = ticket['status'] as String? ?? 'open';
        final issue = ticket['issue'] as String? ?? '-';
        final priority = ticket['priority'] as String? ?? 'normal';

        Color statusColor;
        switch (status.toLowerCase()) {
          case 'open':
            statusColor = Colors.orange;
            break;
          case 'in_progress':
            statusColor = Colors.blue;
            break;
          case 'resolved':
            statusColor = Colors.green;
            break;
          default:
            statusColor = Colors.grey;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.2),
              child: Icon(Icons.confirmation_number, color: statusColor),
            ),
            title: Text(
              issue,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('ID: ${ticket['ticketId'] ?? ticket['id']}'),
                Text(
                  'Dibuat: ${_formatDate(ticket['createdAt'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Chip(
                  label: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: statusColor),
                  ),
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                ),
                if (priority == 'high')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '⚠️ URGENT',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    if (_isLoadingPayments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_payments.isEmpty) {
      return const EnhancedEmptyState(
        icon: Icons.payment_outlined,
        title: 'Belum Ada Pembayaran',
        description: 'Customer ini belum memiliki riwayat pembayaran.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        final amount = payment['amount'] as num? ?? 0;
        final method = payment['method'] as String? ?? '-';
        final status = payment['status'] as String? ?? 'pending';

        final isSuccess = status.toLowerCase() == 'success';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSuccess
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.pending,
                color: isSuccess
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
            title: Text(
              'Rp ${_formatCurrency(amount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Metode: $method'),
                Text(
                  _formatDate(payment['timestamp']),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: isSuccess
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
              backgroundColor: isSuccess
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(num value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';

    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return '-';
      }

      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return '-';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
