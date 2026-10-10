import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import 'package:intl/intl.dart';

class UsageAnalyticsPage extends StatefulWidget {
  const UsageAnalyticsPage({super.key});

  @override
  State<UsageAnalyticsPage> createState() => _UsageAnalyticsPageState();
}

class _UsageAnalyticsPageState extends State<UsageAnalyticsPage> {
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  Map<String, dynamic> _usageStats = {};
  Map<String, dynamic> _recommendation = {};
  // Map<String, dynamic>? _customerData; // Reserved for future use
  bool _isLoading = true;
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userData = AuthService.instance.currentUserData;
      if (userData == null) return;

      // Get customer data
      final customer = await FirebaseService.instance.getCustomerByUserId(
        userData['id'].toString(),
      );

      if (customer != null) {
        final stats = await _analyticsService.getCustomerUsageStats(
          customer['id'],
          days: _selectedDays,
        );

        final recommendation = await _analyticsService.getPackageRecommendation(
          customer['id'],
        );

        setState(() {
          // _customerData = customer; // Reserved for future use
          _usageStats = stats;
          _recommendation = recommendation;
        });
      }
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

  List<FlSpot> _getDailyUsageChartData() {
    if (_usageStats.isEmpty || _usageStats['dailyUsage'] == null) {
      return [];
    }

    final dailyUsage = _usageStats['dailyUsage'] as Map<String, dynamic>;
    final sortedDates = dailyUsage.keys.toList()..sort();

    return sortedDates.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final dateKey = entry.value;
      final usage = dailyUsage[dateKey] as Map<String, dynamic>;
      final totalGB =
          ((usage['download'] ?? 0) + (usage['upload'] ?? 0)) / 1024;
      return FlSpot(index, totalGB);
    }).toList();
  }

  List<BarChartGroupData> _getHourlyDistributionData() {
    if (_usageStats.isEmpty || _usageStats['hourlyDistribution'] == null) {
      return [];
    }

    final hourlyUsage = _usageStats['hourlyDistribution'] as Map<int, double>;

    return List.generate(24, (hour) {
      final usageGB = (hourlyUsage[hour] ?? 0) / 1024;
      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: usageGB,
            color: hour == _usageStats['peakHour']
                ? Colors.red
                : Colors.blue.shade400,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Usage Analytics'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (days) {
              setState(() => _selectedDays = days);
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('7 Hari')),
              const PopupMenuItem(value: 30, child: Text('30 Hari')),
              const PopupMenuItem(value: 90, child: Text('90 Hari')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.cloud_download,
                            label: 'Download',
                            value:
                                '${(_usageStats['totalDownloadGB'] ?? 0.0).toStringAsFixed(1)} GB',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.cloud_upload,
                            label: 'Upload',
                            value:
                                '${(_usageStats['totalUploadGB'] ?? 0.0).toStringAsFixed(1)} GB',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.data_usage,
                            label: 'Total Usage',
                            value:
                                '${(_usageStats['totalUsageGB'] ?? 0.0).toStringAsFixed(1)} GB',
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.speed,
                            label: 'Avg Speed',
                            value:
                                '${(_usageStats['avgSpeedMbps'] ?? 0.0).toStringAsFixed(1)} Mbps',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Package Recommendation
                    if (_recommendation.isNotEmpty) ...[
                      const Text(
                        'Rekomendasi Paket',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _RecommendationCard(recommendation: _recommendation),
                      const SizedBox(height: 24),
                    ],

                    // Daily Usage Chart
                    const Text(
                      'Pemakaian Harian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 200,
                          child: _getDailyUsageChartData().isEmpty
                              ? const Center(child: Text('Tidak ada data'))
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
                                          reservedSize: 40,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              '${value.toInt()} GB',
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 5,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              'D${value.toInt() + 1}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _getDailyUsageChartData(),
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.blue.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Hourly Distribution
                    const Text(
                      'Distribusi Per Jam (Peak Hours)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Peak Hour: ${_usageStats['peakHour'] ?? 0}:00',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: _getHourlyDistributionData().isEmpty
                                  ? const Center(child: Text('Tidak ada data'))
                                  : BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  '${value.toInt()}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 3,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  '${value.toInt()}h',
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: _getHourlyDistributionData(),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Usage Insights
                    const Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InsightCard(
                      icon: Icons.info_outline,
                      title: 'Pemakaian Per Hari',
                      value:
                          '${((_usageStats['totalUsageGB'] ?? 0.0) / _selectedDays).toStringAsFixed(2)} GB',
                      color: Colors.blue,
                    ),
                    _InsightCard(
                      icon: Icons.trending_up,
                      title: 'Utilisasi Kecepatan',
                      value:
                          '${(_recommendation['speedUtilization'] ?? 0.0).toStringAsFixed(1)}%',
                      color: Colors.green,
                    ),
                    _InsightCard(
                      icon: Icons.data_usage,
                      title: 'Total Data Points',
                      value: '${_usageStats['dataPointsCount'] ?? 0}',
                      color: Colors.orange,
                    ),
                  ],
                ),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;

  const _RecommendationCard({required this.recommendation});

  Color _getRecommendationColor() {
    switch (recommendation['recommendation']) {
      case 'upgrade':
        return Colors.green;
      case 'downgrade':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getRecommendationIcon() {
    switch (recommendation['recommendation']) {
      case 'upgrade':
        return Icons.arrow_upward;
      case 'downgrade':
        return Icons.arrow_downward;
      default:
        return Icons.check_circle;
    }
  }

  String _getRecommendationTitle() {
    switch (recommendation['recommendation']) {
      case 'upgrade':
        return 'Rekomendasi: Upgrade Paket';
      case 'downgrade':
        return 'Rekomendasi: Hemat Biaya';
      default:
        return 'Paket Sudah Optimal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRecommendationColor();

    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getRecommendationIcon(), color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getRecommendationTitle(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation['reason'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
            if (recommendation['recommendation'] != 'current') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Paket Saat Ini',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${recommendation['currentSpeed']} Mbps',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${NumberFormat('#,###', 'id_ID').format(recommendation['currentPrice'])}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Rekomendasi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${recommendation['recommendedSpeed']} Mbps',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              'Rp ${NumberFormat('#,###', 'id_ID').format(recommendation['recommendedPrice'])}',
                              style: TextStyle(fontSize: 12, color: color),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (recommendation['savingsPerMonth'] > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.savings,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hemat Rp ${NumberFormat('#,###', 'id_ID').format(recommendation['savingsPerMonth'])}/bulan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
