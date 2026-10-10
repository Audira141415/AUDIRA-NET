import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;

/// Modem Live Monitor - Real-time Monitoring
/// Real-time monitoring of modem status, signal strength, connection quality
class ModemLiveMonitorPage extends StatefulWidget {
  const ModemLiveMonitorPage({super.key});

  @override
  State<ModemLiveMonitorPage> createState() => _ModemLiveMonitorPageState();
}

class _ModemLiveMonitorPageState extends State<ModemLiveMonitorPage> {
  Timer? _updateTimer;
  final List<FlSpot> _signalData = [];
  final List<FlSpot> _downloadData = [];
  final List<FlSpot> _uploadData = [];
  double _currentSignal = -15.0;
  double _currentDownload = 0;
  double _currentUpload = 0;
  int _dataPoints = 0;
  final int _maxDataPoints = 30;

  // Mock device stats
  final int _totalDevices = 156;
  int _onlineDevices = 142;
  int _warningDevices = 8;
  int _offlineDevices = 6;
  final int _criticalAlerts = 2;

  @override
  void initState() {
    super.initState();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    // Simulate real-time data updates
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;

      setState(() {
        _dataPoints++;

        // Simulate signal strength fluctuation (-15 to -25 dBm)
        _currentSignal = -15 + math.Random().nextDouble() * 10;
        if (_signalData.length >= _maxDataPoints) {
          _signalData.removeAt(0);
        }
        _signalData.add(FlSpot(_dataPoints.toDouble(), _currentSignal));

        // Simulate download speed (0-100 Mbps)
        _currentDownload = 30 + math.Random().nextDouble() * 50;
        if (_downloadData.length >= _maxDataPoints) {
          _downloadData.removeAt(0);
        }
        _downloadData.add(FlSpot(_dataPoints.toDouble(), _currentDownload));

        // Simulate upload speed (0-50 Mbps)
        _currentUpload = 10 + math.Random().nextDouble() * 20;
        if (_uploadData.length >= _maxDataPoints) {
          _uploadData.removeAt(0);
        }
        _uploadData.add(FlSpot(_dataPoints.toDouble(), _currentUpload));

        // Randomly update device counts
        if (_dataPoints % 5 == 0) {
          _onlineDevices = 140 + math.Random().nextInt(8);
          _warningDevices = 5 + math.Random().nextInt(6);
          _offlineDevices = _totalDevices - _onlineDevices - _warningDevices;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modem Live Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$_criticalAlerts critical alerts'),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'View',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            },
            tooltip: '$_criticalAlerts alerts',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real-time status banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.live_tv, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Monitoring Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last update: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fiber_manual_record,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Device Status Cards
            const Text(
              'Device Status Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Online',
                    '$_onlineDevices',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    'Warning',
                    '$_warningDevices',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Offline',
                    '$_offlineDevices',
                    Icons.error,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    'Total',
                    '$_totalDevices',
                    Icons.devices,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Signal Strength Monitor
            _buildChartCard(
              'Signal Strength (dBm)',
              _signalData,
              Colors.purple,
              minY: -30,
              maxY: -10,
              formatValue: (value) => '${value.toStringAsFixed(0)} dBm',
              currentValue: _currentSignal,
            ),
            const SizedBox(height: 20),

            // Download Speed Monitor
            _buildChartCard(
              'Download Speed (Mbps)',
              _downloadData,
              Colors.blue,
              minY: 0,
              maxY: 100,
              formatValue: (value) => '${value.toStringAsFixed(1)} Mbps',
              currentValue: _currentDownload,
            ),
            const SizedBox(height: 20),

            // Upload Speed Monitor
            _buildChartCard(
              'Upload Speed (Mbps)',
              _uploadData,
              Colors.green,
              minY: 0,
              maxY: 50,
              formatValue: (value) => '${value.toStringAsFixed(1)} Mbps',
              currentValue: _currentUpload,
            ),
            const SizedBox(height: 20),

            // Critical Alerts
            if (_criticalAlerts > 0) _buildAlertsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
    String title,
    List<FlSpot> data,
    Color color, {
    required double minY,
    required double maxY,
    required String Function(double) formatValue,
    required double currentValue,
  }) {
    return Card(
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    formatValue(currentValue),
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'Waiting for data...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: (maxY - minY) / 5,
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  formatValue(value),
                                  style: const TextStyle(fontSize: 9),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
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
                            spots: data,
                            isCurved: true,
                            color: color,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: color.withValues(alpha: 0.1),
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

  Widget _buildAlertsSection() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Critical Alerts ($_criticalAlerts)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.signal_cellular_alt, color: Colors.red),
              title: const Text('Poor Signal Detected'),
              subtitle: const Text('Device: GPON456789123 - Signal: -28 dBm'),
              trailing: TextButton(onPressed: () {}, child: const Text('View')),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_off, color: Colors.red),
              title: const Text('Device Offline'),
              subtitle: const Text(
                'Device: GPON789123456 - Last seen: 2 days ago',
              ),
              trailing: TextButton(onPressed: () {}, child: const Text('View')),
            ),
          ],
        ),
      ),
    );
  }
}
