import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

/// Financial Dashboard - Admin
/// Monitor revenue, expenses, profit, pending payments
class FinancialDashboardPage extends StatefulWidget {
  const FinancialDashboardPage({super.key});

  @override
  State<FinancialDashboardPage> createState() => _FinancialDashboardPageState();
}

class _FinancialDashboardPageState extends State<FinancialDashboardPage> {
  bool _isLoading = true;
  String _selectedPeriod = 'month'; // day, week, month, year

  // Financial data
  double _totalRevenue = 0;
  double _totalExpenses = 0;
  double _netProfit = 0;
  int _pendingPayments = 0;
  double _pendingAmount = 0;
  List<Map<String, dynamic>> _revenueData = [];
  List<Map<String, dynamic>> _expenseCategories = [];
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() => _isLoading = true);
    try {
      // Calculate date range based on selected period
      final now = DateTime.now();
      DateTime startDate;
      switch (_selectedPeriod) {
        case 'day':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        case 'month':
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      // Load revenue (paid payments)
      final revenueSnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('status', isEqualTo: 'paid')
          .where(
            'paidAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .get();

      _totalRevenue = revenueSnapshot.docs.fold<double>(
        0,
        (total, doc) => total + ((doc.data()['amount'] as num?)?.toDouble() ?? 0),
      );

      // Load pending payments
      final pendingSnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('status', whereIn: ['pending', 'overdue'])
          .get();

      _pendingPayments = pendingSnapshot.docs.length;
      _pendingAmount = pendingSnapshot.docs.fold<double>(
        0,
        (total, doc) => total + ((doc.data()['amount'] as num?)?.toDouble() ?? 0),
      );

      // Load expenses
      final expenseSnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      _totalExpenses = expenseSnapshot.docs.fold<double>(
        0,
        (total, doc) => total + ((doc.data()['amount'] as num?)?.toDouble() ?? 0),
      );

      // Calculate net profit
      _netProfit = _totalRevenue - _totalExpenses;

      // Load revenue trend data
      await _loadRevenueChart(startDate);

      // Load expense categories
      await _loadExpenseCategories(startDate);

      // Load recent transactions
      await _loadRecentTransactions();

      setState(() => _isLoading = false);
    } catch (e) {
      developer.log(
        'Error loading financial data: $e',
        name: 'FinancialDashboard',
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRevenueChart(DateTime startDate) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('status', isEqualTo: 'paid')
          .where(
            'paidAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .orderBy('paidAt')
          .get();

      // Group by date
      Map<String, double> dailyRevenue = {};
      for (var doc in snapshot.docs) {
        final paidAt = (doc.data()['paidAt'] as Timestamp?)?.toDate();
        if (paidAt != null) {
          final dateKey = DateFormat('yyyy-MM-dd').format(paidAt);
          dailyRevenue[dateKey] =
              (dailyRevenue[dateKey] ?? 0) +
              ((doc.data()['amount'] as num?)?.toDouble() ?? 0);
        }
      }

      _revenueData = dailyRevenue.entries
          .map((e) => {'date': e.key, 'amount': e.value})
          .toList();
    } catch (e) {
      developer.log('Error loading revenue chart: $e');
    }
  }

  Future<void> _loadExpenseCategories(DateTime startDate) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      // Group by category
      Map<String, double> categories = {};
      for (var doc in snapshot.docs) {
        final category = doc.data()['category'] as String? ?? 'Other';
        final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0;
        categories[category] = (categories[category] ?? 0) + amount;
      }

      _expenseCategories =
          categories.entries
              .map((e) => {'category': e.key, 'amount': e.value})
              .toList()
            ..sort(
              (a, b) =>
                  (b['amount'] as double).compareTo(a['amount'] as double),
            );
    } catch (e) {
      developer.log('Error loading expense categories: $e');
    }
  }

  Future<void> _loadRecentTransactions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      _recentTransactions = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      developer.log('Error loading recent transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Dashboard'),
        actions: [
          // Period selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadFinancialData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'day', child: Text('Today')),
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
              const PopupMenuItem(value: 'year', child: Text('This Year')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFinancialData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFinancialData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Label
                    Text(
                      _getPeriodLabel(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Summary Cards
                    _buildSummaryCards(),
                    const SizedBox(height: 24),

                    // Revenue vs Expenses Chart
                    _buildRevenueChart(),
                    const SizedBox(height: 24),

                    // Expense Categories
                    _buildExpenseCategories(),
                    const SizedBox(height: 24),

                    // Pending Payments
                    _buildPendingPayments(),
                    const SizedBox(height: 24),

                    // Recent Transactions
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'day':
        return 'Today - ${DateFormat('dd MMM yyyy').format(DateTime.now())}';
      case 'week':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return 'This Week - ${DateFormat('dd MMM').format(startOfWeek)} to ${DateFormat('dd MMM').format(endOfWeek)}';
      case 'year':
        return 'This Year - ${DateTime.now().year}';
      case 'month':
      default:
        return 'This Month - ${DateFormat('MMMM yyyy').format(DateTime.now())}';
    }
  }

  Widget _buildSummaryCards() {
    final profitMargin = _totalRevenue > 0
        ? (_netProfit / _totalRevenue * 100)
        : 0.0;

    return Column(
      children: [
        // Main profit card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _netProfit >= 0
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [Colors.red.shade400, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (_netProfit >= 0 ? Colors.green : Colors.red).withValues(
                  alpha: 0.3,
                ),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Net Profit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    _netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(_netProfit),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Profit Margin: ${profitMargin.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Revenue and Expenses cards
        Row(
          children: [
            Expanded(
              child: _buildFinanceCard(
                title: 'Revenue',
                amount: _totalRevenue,
                icon: Icons.arrow_upward,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinanceCard(
                title: 'Expenses',
                amount: _totalExpenses,
                icon: Icons.arrow_downward,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Pending payments
        _buildFinanceCard(
          title: 'Pending Payments',
          amount: _pendingAmount,
          icon: Icons.pending,
          color: Colors.purple,
          subtitle: '$_pendingPayments invoices pending',
        ),
      ],
    );
  }

  Widget _buildFinanceCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(amount),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (_revenueData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No revenue data available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberFormat.compact().format(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _revenueData.length) {
                            final date = DateTime.parse(
                              _revenueData[index]['date'],
                            );
                            return Text(
                              DateFormat('dd').format(date),
                              style: const TextStyle(fontSize: 9),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _revenueData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['amount'] as double,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.blue,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCategories() {
    if (_expenseCategories.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No expense data available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.purple,
      Colors.pink,
      Colors.indigo,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _expenseCategories.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final data = entry.value;
                          final color = colors[index % colors.length];
                          final percentage =
                              ((data['amount'] as double) /
                              _totalExpenses *
                              100);

                          return PieChartSectionData(
                            value: data['amount'] as double,
                            title: '${percentage.toStringAsFixed(0)}%',
                            color: color,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _expenseCategories.asMap().entries.take(6).map((
                      entry,
                    ) {
                      final index = entry.key;
                      final data = entry.value;
                      final color = colors[index % colors.length];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data['category'],
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPayments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.pending_actions,
                color: Colors.purple.shade700,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_pendingPayments Pending Invoices',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_pendingAmount)}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to pending payments list
              },
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _showAllTransactionsSheet,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentTransactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No recent transactions',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ..._recentTransactions.take(5).map((transaction) {
                final amount = (transaction['amount'] as num?)?.toDouble() ?? 0;
                final status = transaction['status'] ?? 'unknown';
                final customerName = transaction['customerName'] ?? 'Unknown';
                final createdAt = transaction['createdAt'] as Timestamp?;

                Color statusColor;
                IconData statusIcon;
                switch (status.toLowerCase()) {
                  case 'paid':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    break;
                  case 'pending':
                    statusColor = Colors.orange;
                    statusIcon = Icons.schedule;
                    break;
                  case 'overdue':
                    statusColor = Colors.red;
                    statusIcon = Icons.warning;
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusIcon = Icons.help;
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  title: Text(customerName),
                  subtitle: Text(
                    createdAt != null
                        ? DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(createdAt.toDate())
                        : 'No date',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(amount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Chip(
                        label: Text(
                          status.toUpperCase(),
                          style: TextStyle(fontSize: 9, color: statusColor),
                        ),
                        backgroundColor: statusColor.withValues(alpha: 0.1),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showAllTransactionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semua Transaksi (${_recentTransactions.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _recentTransactions.isEmpty
                  ? const Center(child: Text('Tidak ada transaksi tercatat'))
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _recentTransactions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final t = _recentTransactions[index];
                        final amount =
                            (t['amount'] as num?)?.toDouble() ?? 0;
                        final status =
                            (t['status'] ?? 'unknown').toString().toLowerCase();
                        final customerName =
                            t['customerName'] ?? 'Pelanggan';
                        final isPaid = status == 'paid';
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: (isPaid
                                    ? Colors.green
                                    : Colors.orange)
                                .withValues(alpha: 0.1),
                            child: Icon(
                              isPaid ? Icons.check_circle : Icons.schedule,
                              color: isPaid ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Text(
                            customerName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('Status: ${status.toUpperCase()}'),
                          trailing: Text(
                            'Rp ${NumberFormat('#,###').format(amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPaid
                                  ? Colors.green.shade700
                                  : Colors.orange.shade800,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
