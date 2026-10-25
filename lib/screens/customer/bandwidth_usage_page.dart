import 'package:lucide_icons/lucide_icons.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Penggunaan Bandwidth',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.info,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            onPressed: () => _showInfoDialog(isDark),
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
                    _buildPeriodSelector(isDark),
                    _buildSummaryCards(isDark),
                    _buildChart(isDark),
                    _buildUsageDetails(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildPeriodButton('7 Hari', 'week', isDark)),
          Expanded(child: _buildPeriodButton('30 Hari', 'month', isDark)),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period, bool isDark) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        if (_selectedPeriod != period) {
          setState(() => _selectedPeriod = period);
          _loadBandwidthData();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0284C7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF475569)),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(bool isDark) {
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
                  LucideIcons.activity,
                  const Color(0xFF0284C7),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Rata-rata Harian',
                  '${_averageDaily.toStringAsFixed(1)} GB',
                  LucideIcons.trendingUp,
                  const Color(0xFF10B981),
                  isDark,
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
                  LucideIcons.arrowUp,
                  const Color(0xFFF59E0B),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Tanggal Puncak',
                  _peakDate,
                  LucideIcons.calendar,
                  const Color(0xFF8B5CF6),
                  isDark,
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
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.35)
              : color.withValues(alpha: 0.25),
        ),
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
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
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

  Widget _buildChart(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Penggunaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegend(const Color(0xFF0284C7), 'Download', isDark),
              const SizedBox(width: 16),
              _buildLegend(const Color(0xFF10B981), 'Upload', isDark),
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
                      color: isDark
                          ? const Color(0xFF334155).withValues(alpha: 0.5)
                          : const Color(0xFFE2E8F0),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()} GB',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
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
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
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
                    color: const Color(0xFF0284C7),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    ),
                  ),
                  // Upload line
                  LineChartBarData(
                    spots: _bandwidthData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.upload);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
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

  Widget _buildLegend(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageDetails(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Detail Penggunaan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bandwidthData.take(10).length, // Show last 10 days
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            itemBuilder: (context, index) {
              final data = _bandwidthData[_bandwidthData.length - 1 - index];
              final total = data.download + data.upload;

              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('d').format(data.date),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  DateFormat('EEEE, d MMMM yyyy').format(data.date),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  '↓ ${data.download.toStringAsFixed(2)} GB   ↑ ${data.upload.toStringAsFixed(2)} GB',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                trailing: Text(
                  '${total.toStringAsFixed(2)} GB',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        title: Text(
          'Tentang Bandwidth Usage',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Informasi Penggunaan Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Data diperbarui setiap 1 jam',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              Text(
                '• Penggunaan dihitung dari perangkat rumah Anda',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              Text(
                '• Download: Data yang Anda terima',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              Text(
                '• Upload: Data yang Anda kirim',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tips Menghemat Kuota',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Gunakan WiFi untuk download besar',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              Text(
                '• Matikan auto-update aplikasi',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              Text(
                '• Kurangi kualitas streaming video',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              Text(
                '• Gunakan mode hemat data di browser',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0284C7),
              ),
            ),
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
