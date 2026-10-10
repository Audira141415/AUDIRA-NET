import 'package:flutter/material.dart';
import '../../services/alert_center_service.dart';
import '../../services/billing_service.dart';
import 'dart:async';

class AdminAlertCenterPage extends StatefulWidget {
  const AdminAlertCenterPage({super.key});

  @override
  State<AdminAlertCenterPage> createState() => _AdminAlertCenterPageState();
}

class _AdminAlertCenterPageState extends State<AdminAlertCenterPage>
    with TickerProviderStateMixin {
  final AlertCenterService _alertService = AlertCenterService();
  final BillingService _billingService = BillingService();

  StreamSubscription<List<SystemAlert>>? _alertSubscription;
  List<SystemAlert> _alerts = [];
  AlertType? _filterType;
  bool _isLoading = true;

  late TabController _tabController;

  Map<String, dynamic> _paymentAnalytics = {};
  List<Map<String, dynamic>> _outstandingReport = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeServices();
    _loadData();
  }

  void _initializeServices() {
    _alertService.startMonitoring();
    _billingService.startAutoBilling();

    _alertSubscription = _alertService.alertStream.listen((alerts) {
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final analytics = await _billingService.getPaymentAnalytics();
      final outstanding = await _billingService.getOutstandingReport();

      setState(() {
        _paymentAnalytics = analytics;
        _outstandingReport = outstanding;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    _alertService.stopMonitoring();
    _billingService.stopAutoBilling();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        title: const Text('Alert Center'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(icon: Icon(Icons.notifications), text: 'Alerts'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Outstanding'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Auto Billing'),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${_alertService.unreadCount}'),
              child: const Icon(Icons.notifications),
            ),
            onPressed: () {
              _alertService.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua alert ditandai dibaca')),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertsTab(),
          _buildAnalyticsTab(),
          _buildOutstandingTab(),
          _buildAutoBillingTab(),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    final filteredAlerts = _filterType == null
        ? _alerts
        : _alerts.where((alert) => alert.type == _filterType).toList();

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Semua',
                  isSelected: _filterType == null,
                  onTap: () => setState(() => _filterType = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Sistem',
                  isSelected: _filterType == AlertType.system,
                  onTap: () => setState(() => _filterType = AlertType.system),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Jaringan',
                  isSelected: _filterType == AlertType.network,
                  onTap: () => setState(() => _filterType = AlertType.network),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Performa',
                  isSelected: _filterType == AlertType.performance,
                  onTap: () =>
                      setState(() => _filterType = AlertType.performance),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pembayaran',
                  isSelected: _filterType == AlertType.payment,
                  onTap: () => setState(() => _filterType = AlertType.payment),
                ),
              ],
            ),
          ),
        ),

        // Alerts list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredAlerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada alert',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = filteredAlerts[index];
                    return _AlertCard(
                      alert: alert,
                      onTap: () => _showAlertDetail(alert),
                      onDismiss: () => _alertService.removeAlert(alert.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _AnalyticsCard(
                title: 'Revenue Bulan Ini',
                value:
                    'Rp ${_formatCurrency(_paymentAnalytics['monthlyRevenue'] ?? 0)}',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              _AnalyticsCard(
                title: 'Success Rate',
                value:
                    '${(_paymentAnalytics['successRate'] ?? 0).toStringAsFixed(1)}%',
                icon: Icons.check_circle,
                color: Colors.blue,
              ),
              _AnalyticsCard(
                title: 'Outstanding',
                value:
                    'Rp ${_formatCurrency(_paymentAnalytics['outstandingAmount'] ?? 0)}',
                icon: Icons.warning,
                color: Colors.orange,
              ),
              _AnalyticsCard(
                title: 'Total Bills',
                value: '${_paymentAnalytics['totalBills'] ?? 0}',
                icon: Icons.receipt,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Payment methods chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Methods',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._buildPaymentMethodsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _outstandingReport.isEmpty
          ? const Center(child: Text('Tidak ada tagihan tertunggak'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _outstandingReport.length,
              itemBuilder: (context, index) {
                final bill = _outstandingReport[index];
                return _OutstandingCard(bill: bill);
              },
            ),
    );
  }

  Widget _buildAutoBillingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auto Billing System',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 32),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Billing Aktif',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Sistem otomatis berjalan normal'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Manual actions
          const Text(
            'Manual Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _ActionCard(
            icon: Icons.receipt_long,
            title: 'Generate Bills Sekarang',
            subtitle: 'Buat tagihan manual untuk bulan ini',
            onTap: () => _generateBillsNow(),
          ),

          _ActionCard(
            icon: Icons.email,
            title: 'Kirim Payment Reminder',
            subtitle: 'Kirim reminder ke semua customer',
            onTap: () => _sendRemindersNow(),
          ),

          _ActionCard(
            icon: Icons.auto_awesome,
            title: 'Setup Auto Promo',
            subtitle: 'Atur promo otomatis untuk customer',
            onTap: () => _setupAutoPromo(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentMethodsList() {
    final methods =
        _paymentAnalytics['paymentMethods'] as List<Map<String, dynamic>>? ??
        [];

    if (methods.isEmpty) {
      return [const Text('Belum ada data payment methods')];
    }

    return methods.map((method) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(method['paymentMethod'] ?? 'Unknown'),
            Text(
              '${method['count']} transaksi',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showAlertDetail(SystemAlert alert) {
    _alertService.markAsRead(alert.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(alert.icon, color: alert.color),
            const SizedBox(width: 8),
            Expanded(child: Text(alert.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: alert.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Prioritas: ${alert.priorityText}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: alert.color,
                    ),
                  ),
                ],
              ),
            ),
            if (alert.details != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Detail:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...alert.details!.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• ${entry.key}: ${entry.value}'),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Waktu: ${_formatDateTime(alert.timestamp)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateBillsNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Generating bills...'),
          ],
        ),
      ),
    );

    await _billingService.generateMonthlyBills();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bills berhasil di-generate!')),
      );
    }
  }

  Future<void> _sendRemindersNow() async {
    await _billingService.sendPaymentReminders();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment reminders berhasil dikirim!')),
      );
    }
  }

  void _setupAutoPromo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Auto Promo'),
        content: const Text('Fitur ini akan segera tersedia!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final SystemAlert alert;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _AlertCard({
    required this.alert,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alert.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alert.isRead
                ? Colors.grey[300]!
                : alert.color.withValues(alpha: 0.3),
            width: alert.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alert.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(alert.icon, color: alert.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: TextStyle(
                              fontWeight: alert.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!alert.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(alert.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} jam lalu';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  final Map<String, dynamic> bill;

  const _OutstandingCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    final daysPastDue = (bill['daysPastDue'] as double? ?? 0).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
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
              Text(
                bill['name'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$daysPastDue hari',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('ID: ${bill['customerId']}'),
          Text('Internet: ${bill['internetNumber']}'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${_formatCurrency(bill['amount'] as int? ?? 0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Due: ${bill['dueDate']}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.blue[700]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
