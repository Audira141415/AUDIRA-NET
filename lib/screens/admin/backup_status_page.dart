import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

/// Admin - Database Backup Status Page
/// View backup history, status, and size
class BackupStatusPage extends StatefulWidget {
  const BackupStatusPage({super.key});

  @override
  State<BackupStatusPage> createState() => _BackupStatusPageState();
}

class _BackupStatusPageState extends State<BackupStatusPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _latestBackup;
  List<Map<String, dynamic>> _backupHistory = [];

  @override
  void initState() {
    super.initState();
    _loadBackupStatus();
  }

  Future<void> _loadBackupStatus() async {
    setState(() => _isLoading = true);
    try {
      // Get latest backup
      final latestSnapshot = await FirebaseFirestore.instance
          .collection('system_backups')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (latestSnapshot.docs.isNotEmpty) {
        _latestBackup = {
          'id': latestSnapshot.docs.first.id,
          ...latestSnapshot.docs.first.data(),
        };
      }

      // Get backup history (last 30 backups)
      final historySnapshot = await FirebaseFirestore.instance
          .collection('system_backups')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();

      _backupHistory = historySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      developer.log(
        'Error loading backup status: $e',
        name: 'BackupStatusPage',
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Backup Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBackupStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBackupStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Latest Backup Summary Card
                    _buildLatestBackupCard(),
                    const SizedBox(height: 24),

                    // Statistics Cards
                    _buildStatisticsCards(),
                    const SizedBox(height: 24),

                    // Backup History
                    const Text(
                      'Backup History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBackupHistory(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLatestBackupCard() {
    if (_latestBackup == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.orange.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Backup Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No backup data available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final timestamp = _latestBackup!['timestamp'] as Timestamp?;
    final status = _latestBackup!['status'] as String? ?? 'unknown';
    final size = _latestBackup!['sizeInMB'] as num? ?? 0;
    final duration = _latestBackup!['durationInSeconds'] as num? ?? 0;
    final type = _latestBackup!['backupType'] as String? ?? 'manual';

    Color statusColor;
    IconData statusIcon;
    String statusText;
    switch (status.toLowerCase()) {
      case 'success':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Successful';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Failed';
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        statusText = 'In Progress';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = 'Unknown';
    }

    return Card(
      elevation: 4,
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status Icon
            CircleAvatar(
              radius: 40,
              backgroundColor: statusColor.withValues(alpha: 0.2),
              child: Icon(statusIcon, size: 40, color: statusColor),
            ),
            const SizedBox(height: 16),

            // Status Text
            Text(
              statusText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),

            // Timestamp
            if (timestamp != null)
              Text(
                DateFormat('dd MMM yyyy, HH:mm:ss').format(timestamp.toDate()),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            const SizedBox(height: 16),

            // Details
            Divider(color: statusColor.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  icon: Icons.storage,
                  label: 'Size',
                  value: '${size.toStringAsFixed(2)} MB',
                  color: statusColor,
                ),
                _buildDetailItem(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: '${duration}s',
                  color: statusColor,
                ),
                _buildDetailItem(
                  icon: Icons.category,
                  label: 'Type',
                  value: type.toUpperCase(),
                  color: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    final successCount = _backupHistory
        .where((b) => b['status'] == 'success')
        .length;
    final failedCount = _backupHistory
        .where((b) => b['status'] == 'failed')
        .length;
    final totalSize = _backupHistory.fold<double>(
      0,
      (sum, b) => sum + ((b['sizeInMB'] as num?)?.toDouble() ?? 0),
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            title: 'Success',
            value: '$successCount',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.error,
            title: 'Failed',
            value: '$failedCount',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.data_usage,
            title: 'Total Size',
            value: '${totalSize.toStringAsFixed(1)} MB',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupHistory() {
    if (_backupHistory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No backup history available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    return Column(
      children: _backupHistory.map((backup) {
        final timestamp = backup['timestamp'] as Timestamp?;
        final status = backup['status'] as String? ?? 'unknown';
        final size = backup['sizeInMB'] as num? ?? 0;
        final type = backup['backupType'] as String? ?? 'manual';

        IconData statusIcon;
        Color statusColor;
        switch (status.toLowerCase()) {
          case 'success':
            statusIcon = Icons.check_circle;
            statusColor = Colors.green;
            break;
          case 'failed':
            statusIcon = Icons.error;
            statusColor = Colors.red;
            break;
          default:
            statusIcon = Icons.info;
            statusColor = Colors.grey;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.2),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            title: Text(
              timestamp != null
                  ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate())
                  : 'Unknown Date',
            ),
            subtitle: Text(
              'Type: ${type.toUpperCase()} • Size: ${size.toStringAsFixed(2)} MB',
            ),
            trailing: Chip(
              label: Text(
                status.toUpperCase(),
                style: TextStyle(fontSize: 10, color: statusColor),
              ),
              backgroundColor: statusColor.withValues(alpha: 0.1),
            ),
          ),
        );
      }).toList(),
    );
  }
}
