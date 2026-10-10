import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';
import 'package:intl/intl.dart';

class AdminReportingPage extends StatefulWidget {
  const AdminReportingPage({super.key});

  @override
  State<AdminReportingPage> createState() => _AdminReportingPageState();
}

class _AdminReportingPageState extends State<AdminReportingPage>
    with SingleTickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  late TabController _tabController;

  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _revenueReport = {};
  Map<String, dynamic> _growthReport = {};
  List<Map<String, dynamic>> _teknisiPerformance = [];
  bool _isLoading = true;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dashboardStats = await _analyticsService.getDashboardStats();
      final revenueReport = await _analyticsService.getRevenueReport(
        startDate: _startDate,
        endDate: _endDate,
      );
      final growthReport = await _analyticsService.getCustomerGrowthReport(
        startDate: _startDate,
        endDate: _endDate,
      );
      final teknisiPerformance = await _analyticsService
          .getTeknisiPerformanceReport(
            startDate: _startDate,
            endDate: _endDate,
          );

      setState(() {
        _dashboardStats = dashboardStats;
        _revenueReport = revenueReport;
        _growthReport = growthReport;
        _teknisiPerformance = teknisiPerformance;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Advanced Reporting'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.attach_money), text: 'Revenue'),
            Tab(icon: Icon(Icons.trending_up), text: 'Growth'),
            Tab(icon: Icon(Icons.engineering), text: 'Teknisi'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildRevenueTab(),
                _buildGrowthTab(),
                _buildTeknisiTab(),
              ],
            ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Indicator
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Change'),
                      onPressed: _selectDateRange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Key Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MetricCard(
                  icon: Icons.people,
                  label: 'Total Customers',
                  value: _dashboardStats['totalCustomers']?.toString() ?? '0',
                  growth: _dashboardStats['customerGrowth'],
                  color: Colors.blue,
                ),
                _MetricCard(
                  icon: Icons.attach_money,
                  label: 'Total Revenue',
                  value:
                      'Rp ${NumberFormat('#,###', 'id_ID').format(_dashboardStats['totalRevenue'] ?? 0)}',
                  growth: _dashboardStats['revenueGrowth'],
                  color: Colors.green,
                ),
                _MetricCard(
                  icon: Icons.receipt,
                  label: 'Active Tickets',
                  value: _dashboardStats['activeTickets']?.toString() ?? '0',
                  growth: _dashboardStats['ticketGrowth'],
                  color: Colors.orange,
                ),
                _MetricCard(
                  icon: Icons.pending_actions,
                  label: 'Pending Requests',
                  value:
                      _dashboardStats['pendingPackageRequests']?.toString() ??
                      '0',
                  growth: null,
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Month-over-Month Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ComparisonRow(
                      label: 'Customers',
                      currentValue:
                          _dashboardStats['totalCustomers']?.toString() ?? '0',
                      previousValue:
                          _dashboardStats['previousMonthCustomers']
                              ?.toString() ??
                          '0',
                      growth: _dashboardStats['customerGrowth'],
                    ),
                    const Divider(),
                    _ComparisonRow(
                      label: 'Revenue',
                      currentValue:
                          'Rp ${NumberFormat('#,###', 'id_ID').format(_dashboardStats['totalRevenue'] ?? 0)}',
                      previousValue:
                          'Rp ${NumberFormat('#,###', 'id_ID').format(_dashboardStats['previousMonthRevenue'] ?? 0)}',
                      growth: _dashboardStats['revenueGrowth'],
                    ),
                    const Divider(),
                    _ComparisonRow(
                      label: 'Tickets',
                      currentValue:
                          _dashboardStats['activeTickets']?.toString() ?? '0',
                      previousValue:
                          _dashboardStats['previousMonthTickets']?.toString() ??
                          '0',
                      growth: _dashboardStats['ticketGrowth'],
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

  Widget _buildRevenueTab() {
    final paymentMethods =
        _revenueReport['paymentMethods'] as Map<String, dynamic>? ?? {};

    // Convert Map<String, int> to Map<String, double> if needed
    final dailyRevenueRaw =
        _revenueReport['dailyRevenue'] as Map<String, dynamic>? ?? {};
    final dailyRevenue = dailyRevenueRaw.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Summary Cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.account_balance_wallet,
                    label: 'Total Revenue',
                    value:
                        'Rp ${NumberFormat('#,###', 'id_ID').format(_revenueReport['totalRevenue'] ?? 0)}',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.receipt_long,
                    label: 'Transactions',
                    value:
                        _revenueReport['totalTransactions']?.toString() ?? '0',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              icon: Icons.trending_up,
              label: 'Avg Transaction',
              value:
                  'Rp ${NumberFormat('#,###', 'id_ID').format(_revenueReport['avgTransactionValue'] ?? 0)}',
              color: Colors.purple,
            ),

            const SizedBox(height: 24),

            // Payment Methods Chart
            const Text(
              'Payment Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: paymentMethods.isEmpty
                          ? const Center(child: Text('No data'))
                          : PieChart(
                              PieChartData(
                                sections: paymentMethods.entries.map((entry) {
                                  final colors = {
                                    'transfer': Colors.blue,
                                    'cash': Colors.green,
                                    'ewallet': Colors.purple,
                                    'qris': Colors.orange,
                                  };
                                  return PieChartSectionData(
                                    value: entry.value.toDouble(),
                                    title:
                                        '${((entry.value / (_revenueReport['totalRevenue'] ?? 1)) * 100).toStringAsFixed(1)}%',
                                    color: colors[entry.key] ?? Colors.grey,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: paymentMethods.entries.map((entry) {
                        final colors = {
                          'transfer': Colors.blue,
                          'cash': Colors.green,
                          'ewallet': Colors.purple,
                          'qris': Colors.orange,
                        };
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: colors[entry.key],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.key.toUpperCase()}: Rp ${NumberFormat('#,###', 'id_ID').format(entry.value)}',
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Daily Revenue Chart
            const Text(
              'Daily Revenue Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: dailyRevenue.isEmpty
                      ? const Center(child: Text('No data'))
                      : LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${(value / 1000).toStringAsFixed(0)}K',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= dailyRevenue.length) {
                                      return const SizedBox();
                                    }
                                    return Text(
                                      'D${value.toInt() + 1}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: dailyRevenue.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => FlSpot(
                                        e.key.toDouble(),
                                        e.value.value,
                                      ),
                                    )
                                    .toList(),
                                isCurved: true,
                                color: Colors.green,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.green.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthTab() {
    final packageDist =
        _growthReport['packageDistribution'] as Map<String, int>? ?? {};
    final zoneDist =
        _growthReport['zoneDistribution'] as Map<String, int>? ?? {};
    final dailySignups =
        _growthReport['dailySignups'] as Map<String, int>? ?? {};

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Growth Summary
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.person_add,
                    label: 'New Customers',
                    value: _growthReport['newCustomers']?.toString() ?? '0',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.people,
                    label: 'Active Customers',
                    value: _growthReport['activeCustomers']?.toString() ?? '0',
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Package Distribution
            const Text(
              'Package Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: packageDist.entries.map((entry) {
                    final total = packageDist.values.fold(0, (a, b) => a + b);
                    final percentage = total > 0
                        ? (entry.value / total) * 100
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${entry.key} Mbps'),
                              Text(
                                '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Zone Distribution
            const Text(
              'Zone Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: zoneDist.entries.map((entry) {
                    final total = zoneDist.values.fold(0, (a, b) => a + b);
                    final percentage = total > 0
                        ? (entry.value / total) * 100
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Zone ${entry.key}'),
                              Text(
                                '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.teal,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Daily Signups Chart
            const Text(
              'Daily Signups',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: dailySignups.isEmpty
                      ? const Center(child: Text('No data'))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= dailySignups.length) {
                                      return const SizedBox();
                                    }
                                    return Text(
                                      'D${value.toInt() + 1}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: dailySignups.entries
                                .toList()
                                .asMap()
                                .entries
                                .map(
                                  (e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.value.toDouble(),
                                        color: Colors.blue,
                                        width: 12,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeknisiTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _teknisiPerformance.isEmpty
          ? const Center(child: Text('No teknisi data available'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _teknisiPerformance.length,
              itemBuilder: (context, index) {
                final teknisi = _teknisiPerformance[index];
                final resolutionRate = teknisi['totalTickets'] > 0
                    ? (teknisi['resolvedTickets'] / teknisi['totalTickets']) *
                          100
                    : 0.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        (teknisi['name'] ?? 'T')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      teknisi['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${teknisi['totalTickets']} tickets | ${resolutionRate.toStringAsFixed(1)}% resolved',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _PerformanceRow(
                              icon: Icons.assignment,
                              label: 'Total Tickets',
                              value: teknisi['totalTickets'].toString(),
                            ),
                            _PerformanceRow(
                              icon: Icons.check_circle,
                              label: 'Resolved',
                              value: teknisi['resolvedTickets'].toString(),
                            ),
                            _PerformanceRow(
                              icon: Icons.timer,
                              label: 'Avg Response Time',
                              value:
                                  '${teknisi['avgResponseTimeHours'].toStringAsFixed(1)} hours',
                            ),
                            _PerformanceRow(
                              icon: Icons.percent,
                              label: 'Resolution Rate',
                              value: '${resolutionRate.toStringAsFixed(1)}%',
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: resolutionRate / 100,
                              backgroundColor: Colors.grey.shade200,
                              color: resolutionRate >= 80
                                  ? Colors.green
                                  : resolutionRate >= 60
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double? growth;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.growth,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (growth != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    growth! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 10,
                    color: growth! >= 0 ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${growth!.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: growth! >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String currentValue;
  final String previousValue;
  final double? growth;

  const _ComparisonRow({
    required this.label,
    required this.currentValue,
    required this.previousValue,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currentValue,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Previous: $previousValue',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (growth != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: growth! >= 0
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    growth! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: growth! >= 0 ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${growth!.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: growth! >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PerformanceRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
