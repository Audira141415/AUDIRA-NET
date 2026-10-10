import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Halaman Bandwidth Usage dengan grafik penggunaan data
class BandwidthUsagePage extends StatefulWidget {
  final String customerId;

  const BandwidthUsagePage({super.key, required this.customerId});

  @override
  State<BandwidthUsagePage> createState() => _BandwidthUsagePageState();
}

class _BandwidthUsagePageState extends State<BandwidthUsagePage> {
  String _selectedPeriod = 'month'; // 'week' or 'month'
  bool _isLoading = true;
  List<BandwidthData> _bandwidthData = [];

  // Summary data
  double _totalUsage = 0;
  double _averageDaily = 0;
  double _peakUsage = 0;
  String _peakDate = '';

  @override
  void initState() {
    super.initState();
    _loadBandwidthData();
  }

  Future<void> _loadBandwidthData() async {
    setState(() => _isLoading = true);

    try {
      // Generate sample bandwidth data
      _bandwidthData = _generateBandwidthData();

      // Calculate summary
      _calculateSummary();
    } catch (e) {
      debugPrint('Error loading bandwidth data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<BandwidthData> _generateBandwidthData() {
    final List<BandwidthData> data = [];
    final now = DateTime.now();
    final days = _selectedPeriod == 'week' ? 7 : 30;

    // Generate sample data based on realistic usage patterns
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Higher usage on weekends and evenings
      final isWeekend = date.weekday >= 6;
      final baseUsage = isWeekend ? 15.0 : 10.0;

      // Add some randomness
      final random = (date.day * 7 + date.hour) % 10;
      final usage = baseUsage + random.toDouble();

      data.add(
        BandwidthData(
          date: date,
          upload: usage * 0.2, // Upload is typically 20% of download
          download: usage,
        ),
      );
    }

    return data;
  }

  void _calculateSummary() {
    if (_bandwidthData.isEmpty) return;

    _totalUsage = _bandwidthData.fold(
      0.0,
      (sum, item) => sum + item.download + item.upload,
    );

    _averageDaily = _totalUsage / _bandwidthData.length;

    // Find peak usage
    BandwidthData peak = _bandwidthData[0];
    for (var data in _bandwidthData) {
      if ((data.download + data.upload) > (peak.download + peak.upload)) {
        peak = data;
      }
    }

    _peakUsage = peak.download + peak.upload;
    _peakDate = DateFormat('d MMM').format(peak.date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Penggunaan Bandwidth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBandwidthData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildPeriodSelector(),
                    _buildSummaryCards(),
                    _buildChart(),
                    _buildUsageDetails(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildPeriodButton('7 Hari', 'week')),
          Expanded(child: _buildPeriodButton('30 Hari', 'month')),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        if (_selectedPeriod != period) {
          setState(() => _selectedPeriod = period);
          _loadBandwidthData();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Penggunaan',
                  '${_totalUsage.toStringAsFixed(1)} GB',
                  Icons.data_usage,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Rata-rata Harian',
                  '${_averageDaily.toStringAsFixed(1)} GB',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Puncak Penggunaan',
                  '${_peakUsage.toStringAsFixed(1)} GB',
                  Icons.arrow_upward,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Tanggal Puncak',
                  _peakDate,
                  Icons.calendar_today,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            'Grafik Penggunaan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegend(Colors.blue, 'Download'),
              const SizedBox(width: 16),
              _buildLegend(Colors.green, 'Upload'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()} GB',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _selectedPeriod == 'week' ? 1 : 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= _bandwidthData.length) {
                          return const SizedBox();
                        }
                        final date = _bandwidthData[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('d/M').format(date),
                            style: const TextStyle(fontSize: 10),
                          ),
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
                  // Download line
                  LineChartBarData(
                    spots: _bandwidthData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.download);
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
                  // Upload line
                  LineChartBarData(
                    spots: _bandwidthData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.upload);
                    }).toList(),
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
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = _bandwidthData[spot.x.toInt()].date;
                        final type = spot.barIndex == 0 ? 'Download' : 'Upload';
                        return LineTooltipItem(
                          '$type\n${DateFormat('d MMM').format(date)}\n${spot.y.toStringAsFixed(2)} GB',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildUsageDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Detail Penggunaan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bandwidthData.take(10).length, // Show last 10 days
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = _bandwidthData[_bandwidthData.length - 1 - index];
              final total = data.download + data.upload;

              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('d').format(data.date),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  DateFormat('EEEE, d MMMM yyyy').format(data.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '↓ ${data.download.toStringAsFixed(2)} GB  ↑ ${data.upload.toStringAsFixed(2)} GB',
                ),
                trailing: Text(
                  '${total.toStringAsFixed(2)} GB',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Bandwidth Usage'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Informasi Penggunaan Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Data diperbarui setiap 1 jam'),
              Text('• Penggunaan dihitung dari perangkat rumah Anda'),
              Text('• Download: Data yang Anda terima'),
              Text('• Upload: Data yang Anda kirim'),
              SizedBox(height: 12),
              Text(
                'Tips Menghemat Kuota',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Gunakan WiFi untuk download besar'),
              Text('• Matikan auto-update aplikasi'),
              Text('• Kurangi kualitas streaming video'),
              Text('• Gunakan mode hemat data di browser'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

/// Model data untuk bandwidth usage
class BandwidthData {
  final DateTime date;
  final double download; // in GB
  final double upload; // in GB

  BandwidthData({
    required this.date,
    required this.download,
    required this.upload,
  });
}
