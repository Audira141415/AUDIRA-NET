import 'package:flutter/material.dart';
import '../../services/scheduling_service.dart';
import '../../services/auth_service.dart';
import '../../models/schedule_model.dart';
import 'package:intl/intl.dart';

class JadwalTeknisiPage extends StatefulWidget {
  const JadwalTeknisiPage({super.key});

  @override
  State<JadwalTeknisiPage> createState() => _JadwalTeknisiPageState();
}

class _JadwalTeknisiPageState extends State<JadwalTeknisiPage> {
  final SchedulingService _schedulingService = SchedulingService.instance;
  List<WorkSchedule> _schedules = [];
  WorkSchedule? _todaySchedule;
  bool _isLoading = true;
  final DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    try {
      final userData = AuthService.instance.currentUserData;
      if (userData == null) return;

      // Use _selectedDate for filtering schedules if needed
      final schedules = await _schedulingService.getUpcomingSchedules(
        userData['id'],
      );
      final todaySchedule = await _schedulingService.getScheduleByDate(
        userData['id'],
        _selectedDate, // Use the selected date
      );

      setState(() {
        _schedules = schedules;
        _todaySchedule = todaySchedule;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeTask(int slotIndex) async {
    if (_todaySchedule == null) return;

    await _schedulingService.completeSlot(_todaySchedule!.id, slotIndex);
    _loadSchedules();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Tugas selesai!'),
          backgroundColor: Colors.green,
        ),
      );
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
        title: const Text('📅 Smart Schedule'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSchedules,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodaySchedule(),
                    const SizedBox(height: 24),
                    _buildUpcomingSchedules(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTodaySchedule() {
    if (_todaySchedule == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tidak ada jadwal hari ini',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final completedTasks = _todaySchedule!.slots
        .where((s) => s.status == 'completed')
        .length;
    final totalTasks = _todaySchedule!.slots.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Hari Ini',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$completedTasks/$totalTasks Selesai',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_todaySchedule!.estimatedDistance?.toStringAsFixed(1) ?? '0'} KM • ${_todaySchedule!.estimatedDuration ?? 0} menit',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    CircularProgressIndicator(
                      value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                      backgroundColor: Colors.white30,
                      color: Colors.white,
                      strokeWidth: 8,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...(_todaySchedule!.slots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          final isCompleted = slot.status == 'completed';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isCompleted ? Colors.green.shade50 : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isCompleted
                    ? Colors.green
                    : slot.priority == 'urgent'
                    ? Colors.red
                    : slot.priority == 'high'
                    ? Colors.orange
                    : Colors.blue,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                slot.customerName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(slot.address),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(slot.timeSlot, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          slot.taskType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _completeTask(index),
                    ),
              onTap: () {
                // Open maps for navigation
              },
            ),
          );
        })),
      ],
    );
  }

  Widget _buildUpcomingSchedules() {
    if (_schedules.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Mendatang',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._schedules.map((schedule) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(schedule.date),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(schedule.date),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              title: Text('${schedule.slots.length} Tugas'),
              subtitle: Text(
                '${schedule.estimatedDistance?.toStringAsFixed(1) ?? '0'} KM • ${schedule.estimatedDuration ?? 0} menit',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Show schedule details
              },
            ),
          );
        }),
      ],
    );
  }
}
