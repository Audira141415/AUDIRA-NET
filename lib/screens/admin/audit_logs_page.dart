import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

/// Admin - Audit Logs Page
/// View system activity logs, user actions, security events
class AuditLogsPage extends StatefulWidget {
  const AuditLogsPage({super.key});

  @override
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends State<AuditLogsPage> {
  String _filterAction = 'all';
  String _filterStatus = 'all';
  DateTime? _filterDate;
  bool _isLoading = true;
  List<Map<String, dynamic>> _logs = [];

  final List<String> _actionTypes = [
    'all',
    'login',
    'logout',
    'create',
    'update',
    'delete',
    'payment',
    'ticket',
    'installation',
    'config_change',
  ];

  final List<String> _statusTypes = ['all', 'success', 'failed', 'warning'];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      Query query = FirebaseFirestore.instance
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(100);

      // Apply filters
      if (_filterAction != 'all') {
        query = query.where('action', isEqualTo: _filterAction);
      }
      if (_filterStatus != 'all') {
        query = query.where('status', isEqualTo: _filterStatus);
      }
      if (_filterDate != null) {
        final startOfDay = DateTime(
          _filterDate!.year,
          _filterDate!.month,
          _filterDate!.day,
        );
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay));
      }

      final snapshot = await query.get();
      setState(() {
        _logs = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading audit logs: $e', name: 'AuditLogsPage');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLogs),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          if (_filterAction != 'all' ||
              _filterStatus != 'all' ||
              _filterDate != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filterAction != 'all')
                    Chip(
                      label: Text('Action: $_filterAction'),
                      onDeleted: () {
                        setState(() => _filterAction = 'all');
                        _loadLogs();
                      },
                    ),
                  if (_filterStatus != 'all')
                    Chip(
                      label: Text('Status: $_filterStatus'),
                      onDeleted: () {
                        setState(() => _filterStatus = 'all');
                        _loadLogs();
                      },
                    ),
                  if (_filterDate != null)
                    Chip(
                      label: Text(
                        'Date: ${DateFormat('dd MMM yyyy').format(_filterDate!)}',
                      ),
                      onDeleted: () {
                        setState(() => _filterDate = null);
                        _loadLogs();
                      },
                    ),
                ],
              ),
            ),

          // Logs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No audit logs found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLogs,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return _buildLogCard(log);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final timestamp = log['timestamp'] as Timestamp?;
    final action = log['action'] as String? ?? 'unknown';
    final status = log['status'] as String? ?? 'unknown';
    final userEmail = log['userEmail'] as String? ?? 'system';
    final details = log['details'] as String? ?? '';
    final ipAddress = log['ipAddress'] as String? ?? '';

    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'success':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          action.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('👤 $userEmail'),
            if (timestamp != null)
              Text(
                '🕒 ${DateFormat('dd MMM yyyy, HH:mm:ss').format(timestamp.toDate())}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            status.toUpperCase(),
            style: TextStyle(fontSize: 10, color: statusColor),
          ),
          backgroundColor: statusColor.withValues(alpha: 0.1),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details.isNotEmpty) ...[
                  const Text(
                    'Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(details),
                  const SizedBox(height: 12),
                ],
                if (ipAddress.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.computer,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'IP: $ipAddress',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Logs'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Action Type:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _actionTypes.map((action) {
                  return FilterChip(
                    label: Text(action),
                    selected: _filterAction == action,
                    onSelected: (selected) {
                      setState(() => _filterAction = action);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _statusTypes.map((status) {
                  return FilterChip(
                    label: Text(status),
                    selected: _filterStatus == status,
                    onSelected: (selected) {
                      setState(() => _filterStatus = status);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Date:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _filterDate != null
                      ? DateFormat('dd MMM yyyy').format(_filterDate!)
                      : 'All dates',
                ),
                trailing: _filterDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _filterDate = null);
                        },
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _filterDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _filterDate = date);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterAction = 'all';
                _filterStatus = 'all';
                _filterDate = null;
              });
              Navigator.pop(context);
              _loadLogs();
            },
            child: const Text('Clear All'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _loadLogs();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
