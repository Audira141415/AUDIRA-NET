import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import 'dart:async';

/// Halaman Maintenance Alert dengan countdown dan notifikasi
class MaintenanceAlertPage extends StatefulWidget {
  const MaintenanceAlertPage({super.key});

  @override
  State<MaintenanceAlertPage> createState() => _MaintenanceAlertPageState();
}

class _MaintenanceAlertPageState extends State<MaintenanceAlertPage> {
  List<Map<String, dynamic>> _maintenances = [];
  bool _isLoading = true;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadMaintenances();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild untuk update countdown
        });
      }
    });
  }

  Future<void> _loadMaintenances() async {
    setState(() => _isLoading = true);

    try {
      final schedules = await FirebaseService.instance.getUpcomingMaintenance();
      setState(() {
        _maintenances = schedules;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading maintenances: $e');
      setState(() => _isLoading = false);
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
        title: const Text('Jadwal Pemeliharaan'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMaintenances,
              child: _maintenances.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _maintenances.length,
                      itemBuilder: (context, index) {
                        final maintenance = _maintenances[index];
                        return _MaintenanceCard(
                          maintenance: maintenance,
                          onTap: () => _showMaintenanceDetail(maintenance),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Colors.green.shade300,
        ),
        const SizedBox(height: 16),
        const Text(
          'Tidak Ada Pemeliharaan Terjadwal',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Saat ini tidak ada jadwal pemeliharaan yang akan datang. Layanan Anda berjalan normal.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showMaintenanceDetail(Map<String, dynamic> maintenance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MaintenanceDetailSheet(maintenance: maintenance),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Pemeliharaan'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Apa itu Pemeliharaan?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Pemeliharaan adalah kegiatan rutin untuk menjaga dan meningkatkan kualitas layanan internet Anda.',
              ),
              SizedBox(height: 16),
              Text(
                'Jenis Pemeliharaan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Jaringan: Upgrade perangkat dan infrastruktur'),
              Text('• Server: Update sistem dan database'),
              Text('• Darurat: Perbaikan gangguan mendadak'),
              SizedBox(height: 16),
              Text(
                'Dampak Pemeliharaan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Gangguan layanan sementara'),
              Text('• Biasanya dilakukan malam hari'),
              Text('• Durasi 2-4 jam'),
              Text('• Notifikasi H-1 melalui aplikasi'),
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

/// Widget Card untuk Maintenance
class _MaintenanceCard extends StatelessWidget {
  final Map<String, dynamic> maintenance;
  final VoidCallback onTap;

  const _MaintenanceCard({required this.maintenance, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheduledDate = DateTime.parse(maintenance['scheduledDate']);

    final priority = maintenance['priority'] ?? 'medium';
    final maintenanceType = maintenance['maintenanceType'] ?? 'network';

    Color priorityColor;
    IconData typeIcon;

    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    switch (maintenanceType) {
      case 'network':
        typeIcon = Icons.router;
        break;
      case 'server':
        typeIcon = Icons.dns;
        break;
      case 'emergency':
        typeIcon = Icons.warning;
        break;
      default:
        typeIcon = Icons.build;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(typeIcon, color: priorityColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            maintenance['title'] ?? 'Pemeliharaan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getTypeLabel(maintenanceType),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPriorityLabel(priority),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Countdown
                _CountdownWidget(targetDate: scheduledDate),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Info
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(scheduledDate),
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${maintenance['startTime']} - ${maintenance['endTime']} WIB',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        maintenance['affectedAreas'] ?? '-',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'TINGGI';
      case 'medium':
        return 'SEDANG';
      case 'low':
        return 'RENDAH';
      default:
        return 'SEDANG';
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'network':
        return 'Pemeliharaan Jaringan';
      case 'server':
        return 'Pemeliharaan Server';
      case 'emergency':
        return 'Perbaikan Darurat';
      default:
        return 'Pemeliharaan Umum';
    }
  }
}

/// Widget Countdown Timer
class _CountdownWidget extends StatelessWidget {
  final DateTime targetDate;

  const _CountdownWidget({required this.targetDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);

    if (difference.isNegative) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              'Pemeliharaan Selesai',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Dimulai dalam:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit(days.toString(), 'Hari'),
              _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Jam'),
              _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Menit'),
              _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Detik'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

/// Bottom Sheet Detail Maintenance
class _MaintenanceDetailSheet extends StatelessWidget {
  final Map<String, dynamic> maintenance;

  const _MaintenanceDetailSheet({required this.maintenance});

  @override
  Widget build(BuildContext context) {
    final scheduledDate = DateTime.parse(maintenance['scheduledDate']);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  maintenance['title'] ?? 'Detail Pemeliharaan',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Deskripsi:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(maintenance['description'] ?? '-'),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          _buildDetailRow(
            Icons.calendar_today,
            'Tanggal',
            DateFormat('EEEE, d MMMM yyyy').format(scheduledDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time,
            'Waktu',
            '${maintenance['startTime']} - ${maintenance['endTime']} WIB',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.location_on,
            'Area Terdampak',
            maintenance['affectedAreas'] ?? '-',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.info_outline,
            'Status',
            _getStatusLabel(maintenance['status'] ?? 'scheduled'),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                // Set reminder (placeholder)
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengingat telah diatur'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Ingatkan Saya'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'scheduled':
        return 'Terjadwal';
      case 'ongoing':
        return 'Sedang Berlangsung';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Terjadwal';
    }
  }
}
