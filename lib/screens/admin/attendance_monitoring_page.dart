import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

/// Attendance Monitoring Page - Admin & Manager
/// Monitor employee attendance, late arrivals, absences with analytics
class AttendanceMonitoringPage extends StatefulWidget {
  const AttendanceMonitoringPage({super.key});

  @override
  State<AttendanceMonitoringPage> createState() =>
      _AttendanceMonitoringPageState();
}

class _AttendanceMonitoringPageState extends State<AttendanceMonitoringPage> {
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String _viewType = 'daily'; // daily, weekly, monthly

  // Statistics
  int _totalEmployees = 0;
  int _presentToday = 0;
  int _absentToday = 0;
  int _lateToday = 0;
  List<Map<String, dynamic>> _attendanceRecords = [];
  Map<String, int> _monthlyStats = {};

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);
    try {
      // Get total employees
      final employeesSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('status', isEqualTo: 'active')
          .get();
      _totalEmployees = employeesSnapshot.docs.length;

      // Get today's attendance
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final attendanceSnapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      _attendanceRecords = attendanceSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      _presentToday = _attendanceRecords
          .where((r) => r['status'] == 'present')
          .length;
      _lateToday = _attendanceRecords.where((r) => r['isLate'] == true).length;
      _absentToday = _totalEmployees - _presentToday;

      // Load monthly statistics for chart
      await _loadMonthlyStats();

      setState(() => _isLoading = false);
    } catch (e) {
      developer.log(
        'Error loading attendance: $e',
        name: 'AttendanceMonitoring',
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMonthlyStats() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      Map<String, int> stats = {};

      // Initialize all days
      for (int day = 1; day <= endOfMonth.day; day++) {
        stats['$day'] = 0;
      }

      // Query attendance for the month
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .where('status', isEqualTo: 'present')
          .get();

      // Count attendance per day
      for (var doc in snapshot.docs) {
        final date = (doc.data()['date'] as Timestamp).toDate();
        final day = '${date.day}';
        stats[day] = (stats[day] ?? 0) + 1;
      }

      setState(() {
        _monthlyStats = stats;
      });
    } catch (e) {
      developer.log(
        'Error loading monthly stats: $e',
        name: 'AttendanceMonitoring',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Monitoring'),
        actions: [
          // View type selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_module),
            initialValue: _viewType,
            onSelected: (value) {
              setState(() => _viewType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'daily', child: Text('Daily View')),
              const PopupMenuItem(value: 'weekly', child: Text('Weekly View')),
              const PopupMenuItem(
                value: 'monthly',
                child: Text('Monthly View'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
                _loadAttendanceData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendanceData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAttendanceData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Summary Cards
                    _buildSummaryCards(),
                    const SizedBox(height: 24),

                    // Attendance Chart
                    _buildAttendanceChart(),
                    const SizedBox(height: 24),

                    // Late Arrivals Section
                    _buildLateArrivals(),
                    const SizedBox(height: 24),

                    // Attendance Records
                    _buildAttendanceRecords(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showExportDialog();
        },
        icon: const Icon(Icons.download),
        label: const Text('Export Report'),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          title: 'Total Employees',
          value: '$_totalEmployees',
          icon: Icons.people,
          color: Colors.blue,
          subtitle: 'Active Staff',
        ),
        _buildSummaryCard(
          title: 'Present',
          value: '$_presentToday',
          icon: Icons.check_circle,
          color: Colors.green,
          subtitle:
              '${(_presentToday / _totalEmployees * 100).toStringAsFixed(1)}% attendance',
        ),
        _buildSummaryCard(
          title: 'Absent',
          value: '$_absentToday',
          icon: Icons.cancel,
          color: Colors.red,
          subtitle:
              '${(_absentToday / _totalEmployees * 100).toStringAsFixed(1)}% absent',
        ),
        _buildSummaryCard(
          title: 'Late Arrivals',
          value: '$_lateToday',
          icon: Icons.access_time,
          color: Colors.orange,
          subtitle: '$_lateToday employees late',
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, size: 14, color: color),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart() {
    if (_monthlyStats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No attendance data for chart',
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
              'Monthly Attendance Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _totalEmployees.toDouble() * 1.2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
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
                        getTitlesWidget: (value, meta) {
                          // Show every 5th day
                          if (value.toInt() % 5 != 0) return const Text('');
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
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
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _monthlyStats.entries.map((entry) {
                    final day = int.parse(entry.key);
                    final count = entry.value.toDouble();
                    return BarChartGroupData(
                      x: day,
                      barRods: [
                        BarChartRodData(
                          toY: count,
                          color: count >= _totalEmployees * 0.9
                              ? Colors.green
                              : count >= _totalEmployees * 0.7
                              ? Colors.orange
                              : Colors.red,
                          width: 6,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLateArrivals() {
    final lateRecords = _attendanceRecords
        .where((r) => r['isLate'] == true)
        .toList();

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
                  'Late Arrivals Today',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('$_lateToday'),
                  backgroundColor: Colors.orange.shade100,
                  labelStyle: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lateRecords.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.green.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No late arrivals today!',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...lateRecords.map((record) {
                final employeeName = record['employeeName'] ?? 'Unknown';
                final checkInTime = record['checkInTime'] as Timestamp?;
                final minutesLate = record['minutesLate'] as int? ?? 0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(
                      Icons.access_time,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  title: Text(employeeName),
                  subtitle: Text(
                    checkInTime != null
                        ? 'Checked in: ${DateFormat('HH:mm').format(checkInTime.toDate())}'
                        : 'No check-in time',
                  ),
                  trailing: Chip(
                    label: Text('$minutesLate min late'),
                    backgroundColor: Colors.orange.shade50,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecords() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Records',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_attendanceRecords.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No attendance records found',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ..._attendanceRecords.map((record) {
                final employeeName = record['employeeName'] ?? 'Unknown';
                final status = record['status'] ?? 'unknown';
                final checkInTime = record['checkInTime'] as Timestamp?;
                final checkOutTime = record['checkOutTime'] as Timestamp?;
                final isLate = record['isLate'] == true;

                Color statusColor;
                IconData statusIcon;
                switch (status.toLowerCase()) {
                  case 'present':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    break;
                  case 'absent':
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                    break;
                  case 'leave':
                    statusColor = Colors.blue;
                    statusIcon = Icons.event_busy;
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
                  title: Row(
                    children: [
                      Text(employeeName),
                      if (isLate) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LATE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (checkInTime != null)
                        Text(
                          'In: ${DateFormat('HH:mm').format(checkInTime.toDate())}',
                        ),
                      if (checkOutTime != null)
                        Text(
                          'Out: ${DateFormat('HH:mm').format(checkOutTime.toDate())}',
                        ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(status.toUpperCase()),
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Attendance Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting Excel...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
