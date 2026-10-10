import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:developer' as developer;

/// Network Operations Center (NOC) Dashboard
/// Real-time monitoring of network infrastructure, customers, and services
class NOCDashboardPage extends StatefulWidget {
  const NOCDashboardPage({super.key});

  @override
  State<NOCDashboardPage> createState() => _NOCDashboardPageState();
}

class _NOCDashboardPageState extends State<NOCDashboardPage> {
  // Real-time streams
  StreamSubscription? _customersSubscription;
  StreamSubscription? _ticketsSubscription;
  StreamSubscription? _networksSubscription;

  // Dashboard data
  int _totalCustomers = 0;
  int _activeCustomers = 0;
  int _inactiveCustomers = 0;
  int _openTickets = 0;
  int _criticalTickets = 0;
  List<Map<String, dynamic>> _recentAlerts = [];
  List<Map<String, dynamic>> _bandwidthData = [];

  // Network status
  final Map<String, dynamic> _networkStatus = {
    'uptime': '99.8%',
    'totalBandwidth': 10000, // Mbps
    'usedBandwidth': 6500,
    'activeConnections': 245,
  };

  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _setupRealTimeStreams();
    _loadNetworkData();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadNetworkData();
    });
  }

  @override
  void dispose() {
    _customersSubscription?.cancel();
    _ticketsSubscription?.cancel();
    _networksSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupRealTimeStreams() {
    // Monitor customers
    _customersSubscription = FirebaseFirestore.instance
        .collection('customers')
        .snapshots()
        .listen((snapshot) {
          if (mounted) {
            setState(() {
              _totalCustomers = snapshot.docs.length;
              _activeCustomers = snapshot.docs
                  .where(
                    (doc) => (doc.data()['status'] ?? 'inactive') == 'active',
                  )
                  .length;
              _inactiveCustomers = _totalCustomers - _activeCustomers;
            });
          }
        });

    // Monitor tickets
    _ticketsSubscription = FirebaseFirestore.instance
        .collection('tickets')
        .where('status', whereIn: ['open', 'pending'])
        .snapshots()
        .listen((snapshot) {
          if (mounted) {
            setState(() {
              _openTickets = snapshot.docs.length;
              _criticalTickets = snapshot.docs
                  .where((doc) => (doc.data()['priority'] ?? '') == 'critical')
                  .length;
            });
          }
        });
  }

  Future<void> _loadNetworkData() async {
    setState(() => _isLoading = true);
    try {
      // Load bandwidth usage history
      final bandwidthSnapshot = await FirebaseFirestore.instance
          .collection('bandwidth_logs')
          .orderBy('timestamp', descending: true)
          .limit(24) // Last 24 hours
          .get();

      _bandwidthData = bandwidthSnapshot.docs
          .map((doc) => doc.data())
          .toList()
          .reversed
          .toList();

      // Load recent alerts
      final alertsSnapshot = await FirebaseFirestore.instance
          .collection('network_alerts')
          .where('status', isEqualTo: 'active')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      _recentAlerts = alertsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      developer.log('Error loading NOC data: $e', name: 'NOCDashboard');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOC Dashboard'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNetworkData,
          ),
          // Filter/Settings
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Report'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Dashboard Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNetworkData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Banner
                    _buildStatusBanner(),
                    const SizedBox(height: 20),

                    // KPI Cards
                    _buildKPICards(),
                    const SizedBox(height: 20),

                    // Network Status
                    _buildNetworkStatus(),
                    const SizedBox(height: 20),

                    // Bandwidth Chart
                    _buildBandwidthChart(),
                    const SizedBox(height: 20),

                    // Customer Distribution
                    _buildCustomerDistribution(),
                    const SizedBox(height: 20),

                    // Recent Alerts
                    _buildRecentAlerts(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final uptime = double.parse(
      _networkStatus['uptime'].toString().replaceAll('%', ''),
    );
    final isHealthy = uptime >= 99.5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHealthy
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.warning,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHealthy
                      ? 'Network Status: Healthy'
                      : 'Network Status: Warning',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uptime: ${_networkStatus['uptime']} • Last updated: ${DateFormat('HH:mm').format(DateTime.now())}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildKPICard(
          title: 'Total Customers',
          value: '$_totalCustomers',
          subtitle: '$_activeCustomers active',
          icon: Icons.people,
          color: Colors.blue,
          trend: '+5.2%',
        ),
        _buildKPICard(
          title: 'Open Tickets',
          value: '$_openTickets',
          subtitle: '$_criticalTickets critical',
          icon: Icons.support_agent,
          color: Colors.orange,
          trend: '-2.1%',
        ),
        _buildKPICard(
          title: 'Bandwidth Usage',
          value:
              '${((_networkStatus['usedBandwidth'] / _networkStatus['totalBandwidth']) * 100).toStringAsFixed(1)}%',
          subtitle:
              '${_networkStatus['usedBandwidth']} / ${_networkStatus['totalBandwidth']} Mbps',
          icon: Icons.speed,
          color: Colors.purple,
          trend: '+12%',
        ),
        _buildKPICard(
          title: 'Active Connections',
          value: '${_networkStatus['activeConnections']}',
          subtitle: 'Concurrent sessions',
          icon: Icons.device_hub,
          color: Colors.green,
          trend: '+8%',
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    final isPositive = trend.startsWith('+');
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 10,
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Network Infrastructure',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusRow('Core Router', 'Online', Colors.green, '99.9%'),
            _buildStatusRow(
              'Distribution Switch',
              'Online',
              Colors.green,
              '100%',
            ),
            _buildStatusRow('Access Points', 'Partial', Colors.orange, '95.2%'),
            _buildStatusRow('Fiber Links', 'Online', Colors.green, '99.5%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    String name,
    String status,
    Color color,
    String uptime,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Text(
            uptime,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBandwidthChart() {
    if (_bandwidthData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No bandwidth data available',
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
              'Bandwidth Usage (Last 24 Hours)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2000,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 6,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 6 != 0) return const Text('');
                          final index = value.toInt();
                          if (index >= 0 && index < _bandwidthData.length) {
                            final timestamp =
                                _bandwidthData[index]['timestamp']
                                    as Timestamp?;
                            if (timestamp != null) {
                              return Text(
                                DateFormat('HH:mm').format(timestamp.toDate()),
                                style: const TextStyle(fontSize: 9),
                              );
                            }
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
                      spots: _bandwidthData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['usage'] as num?)?.toDouble() ?? 0,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
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

  Widget _buildCustomerDistribution() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Distribution',
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
                        sections: [
                          PieChartSectionData(
                            value: _activeCustomers.toDouble(),
                            title: '$_activeCustomers',
                            color: Colors.green,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: _inactiveCustomers.toDouble(),
                            title: '$_inactiveCustomers',
                            color: Colors.red,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        'Active',
                        Colors.green,
                        _activeCustomers,
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        'Inactive',
                        Colors.red,
                        _inactiveCustomers,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentAlerts() {
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
                  'Recent Alerts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to alerts page
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentAlerts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No active alerts',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ..._recentAlerts.take(5).map((alert) {
                final severity = alert['severity'] as String? ?? 'info';
                Color alertColor;
                IconData alertIcon;
                switch (severity.toLowerCase()) {
                  case 'critical':
                    alertColor = Colors.red;
                    alertIcon = Icons.error;
                    break;
                  case 'warning':
                    alertColor = Colors.orange;
                    alertIcon = Icons.warning;
                    break;
                  default:
                    alertColor = Colors.blue;
                    alertIcon = Icons.info;
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(alertIcon, color: alertColor),
                  title: Text(alert['message'] ?? 'Unknown alert'),
                  subtitle: Text(
                    alert['timestamp'] != null
                        ? DateFormat(
                            'dd MMM, HH:mm',
                          ).format((alert['timestamp'] as Timestamp).toDate())
                        : '',
                  ),
                  trailing: Chip(
                    label: Text(
                      severity.toUpperCase(),
                      style: TextStyle(fontSize: 10, color: alertColor),
                    ),
                    backgroundColor: alertColor.withValues(alpha: 0.1),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
