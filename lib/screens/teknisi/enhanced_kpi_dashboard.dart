import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';

/// Enhanced KPI Dashboard untuk Teknisi dengan grafik performa dan badges
class EnhancedKPIDashboard extends StatefulWidget {
  const EnhancedKPIDashboard({super.key});

  @override
  State<EnhancedKPIDashboard> createState() => _EnhancedKPIDashboardState();
}

class _EnhancedKPIDashboardState extends State<EnhancedKPIDashboard> {
  bool _isLoading = true;
  String _selectedPeriod = 'week'; // 'week', 'month', 'year'

  // KPI Data
  Map<String, dynamic> _kpiData = {};
  List<Map<String, dynamic>> _performanceHistory = [];
  List<Map<String, dynamic>> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadKPIData();
  }

  Future<void> _loadKPIData() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = AuthService.instance.currentUserData;
      if (currentUser == null) return;

      // Generate sample KPI data
      _kpiData = await _generateKPIData();
      _performanceHistory = _generatePerformanceHistory();
      _achievements = _generateAchievements();
    } catch (e) {
      debugPrint('Error loading KPI data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>> _generateKPIData() async {
    // Dalam implementasi real, ambil dari database
    return {
      'totalTickets': 45,
      'resolvedTickets': 42,
      'avgResponseTime': 23, // minutes
      'avgResolutionTime': 185, // minutes
      'customerSatisfaction': 4.7,
      'installationsCompleted': 12,
      'currentStreak': 7,
      'totalPoints': 850,
      'ranking': 3,
      'totalTechnicians': 15,
    };
  }

  List<Map<String, dynamic>> _generatePerformanceHistory() {
    final List<Map<String, dynamic>> history = [];
    final now = DateTime.now();
    final days = _selectedPeriod == 'week' ? 7 : 30;

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final tickets = 3 + (i % 5);
      final satisfaction = 4.0 + (i % 10) * 0.1;

      history.add({
        'date': date,
        'ticketsResolved': tickets,
        'satisfaction': satisfaction > 5.0 ? 5.0 : satisfaction,
        'points': tickets * 10 + (satisfaction * 5).toInt(),
      });
    }

    return history;
  }

  List<Map<String, dynamic>> _generateAchievements() {
    return [
      {
        'id': 1,
        'title': 'Speed Demon',
        'description': 'Selesaikan 10 tiket dalam sehari',
        'icon': Icons.flash_on,
        'color': Colors.yellow,
        'unlocked': true,
        'unlockedDate': '2025-11-20',
      },
      {
        'id': 2,
        'title': 'Customer Hero',
        'description': 'Rating 5.0 dari 20 customer',
        'icon': Icons.star,
        'color': Colors.orange,
        'unlocked': true,
        'unlockedDate': '2025-11-18',
      },
      {
        'id': 3,
        'title': 'Streak Master',
        'description': 'Check-in 7 hari berturut-turut',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
        'unlocked': true,
        'unlockedDate': '2025-11-24',
      },
      {
        'id': 4,
        'title': 'Installation Expert',
        'description': 'Selesaikan 50 instalasi',
        'icon': Icons.router,
        'color': Colors.blue,
        'unlocked': false,
        'progress': 0.24, // 12/50
      },
      {
        'id': 5,
        'title': 'Perfect Month',
        'description': 'Rating 4.8+ selama 1 bulan',
        'icon': Icons.emoji_events,
        'color': Colors.purple,
        'unlocked': false,
        'progress': 0.60,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('KPI Dashboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadKPIData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewSection(),
                    _buildPerformanceChart(),
                    _buildTrendAnalysis(),
                    _buildAchievementsSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performa Anda',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Periode Bulan Ini',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Rank #${_kpiData['ranking']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  '${_kpiData['resolvedTickets']}/${_kpiData['totalTickets']}',
                  'Tiket Selesai',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKPICard(
                  '${_kpiData['customerSatisfaction']}',
                  'Rating',
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  '${_kpiData['avgResponseTime']} min',
                  'Avg Response',
                  Icons.access_time,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKPICard(
                  '${_kpiData['currentStreak']} hari',
                  'Streak',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grafik Performa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
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
                      reservedSize: 25,
                      interval: _selectedPeriod == 'week' ? 1 : 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= _performanceHistory.length) {
                          return const SizedBox();
                        }
                        final date =
                            _performanceHistory[value.toInt()]['date']
                                as DateTime;
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
                  LineChartBarData(
                    spots: _performanceHistory.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value['ticketsResolved'] as int).toDouble(),
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
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
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
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton('7D', 'week'),
          _buildPeriodButton('30D', 'month'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        if (_selectedPeriod != period) {
          setState(() {
            _selectedPeriod = period;
            _performanceHistory = _generatePerformanceHistory();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    final ticketTrend = '+12%';
    final satisfactionTrend = '+0.3';
    final responseTrend = '-5 min';

    return Container(
      margin: const EdgeInsets.all(16),
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
          const Text(
            'Trend Analisis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTrendItem('Tiket Selesai', ticketTrend, true, 'vs minggu lalu'),
          const SizedBox(height: 12),
          _buildTrendItem(
            'Customer Rating',
            satisfactionTrend,
            true,
            'vs bulan lalu',
          ),
          const SizedBox(height: 12),
          _buildTrendItem('Response Time', responseTrend, true, 'lebih cepat'),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
    String label,
    String value,
    bool isPositive,
    String comparison,
  ) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          comparison,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pencapaian',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _achievements.length,
            itemBuilder: (context, index) {
              final achievement = _achievements[index];
              return _AchievementCard(achievement: achievement);
            },
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang KPI Dashboard'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Metrik Performa:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Tiket Selesai: Total tiket yang berhasil diselesaikan'),
              Text('• Rating: Rata-rata kepuasan customer'),
              Text('• Avg Response: Waktu rata-rata respon tiket'),
              Text('• Streak: Hari berturut-turut check-in'),
              SizedBox(height: 16),
              Text(
                'Pencapaian:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Dapatkan badge dengan menyelesaikan target tertentu'),
              Text('Badge akan meningkatkan ranking Anda'),
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

/// Widget Achievement Card
class _AchievementCard extends StatelessWidget {
  final Map<String, dynamic> achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement['unlocked'] ?? false;
    final color = achievement['color'] as Color;
    final icon = achievement['icon'] as IconData;

    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? color.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? color.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: unlocked ? color : Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  achievement['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: unlocked ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: unlocked ? Colors.black54 : Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!unlocked && achievement['progress'] != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: achievement['progress'],
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(achievement['progress'] * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (unlocked)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
