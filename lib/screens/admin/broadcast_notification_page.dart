import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class BroadcastNotificationPage extends StatefulWidget {
  const BroadcastNotificationPage({super.key});

  @override
  State<BroadcastNotificationPage> createState() =>
      _BroadcastNotificationPageState();
}

class _BroadcastNotificationPageState extends State<BroadcastNotificationPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedTarget = 'all';
  String _selectedPriority = 'normal';
  bool _isSending = false;
  List<Map<String, dynamic>> _notificationHistory = [];
  bool _loadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationHistory();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final history = await FirebaseService.instance
          .getBroadcastNotifications();
      if (mounted) {
        setState(() {
          _notificationHistory = history;
          _loadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingHistory = false);
      }
    }
  }

  Future<void> _sendBroadcast() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan pesan tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final admin = await AuthService.instance.getCurrentUser();
      final recipientCount = await FirebaseService.instance.sendBroadcast(
        title: _titleController.text,
        message: _messageController.text,
        target: _selectedTarget,
        priority: _selectedPriority,
        senderId: admin?['id'] ?? 'unknown',
        senderName: admin?['name'] ?? 'Admin',
      );

      if (mounted) {
        setState(() => _isSending = false);
        _titleController.clear();
        _messageController.clear();
        _loadNotificationHistory();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Broadcast terkirim ke $recipientCount user!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Broadcast Notifications'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Send Broadcast Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        const Text(
                          'Kirim Broadcast',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Title Input
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Notifikasi',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message Input
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Isi Pesan',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.message),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target Selection
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.group, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'Target Penerima',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildTargetChip(
                                'all',
                                'Semua User',
                                Icons.people,
                              ),
                              _buildTargetChip(
                                'customer',
                                'Customer',
                                Icons.person,
                              ),
                              _buildTargetChip(
                                'teknisi',
                                'Teknisi',
                                Icons.engineering,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Priority Selection
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.priority_high,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Prioritas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildPriorityChip('low', 'Rendah', Colors.green),
                              _buildPriorityChip(
                                'normal',
                                'Normal',
                                Colors.blue,
                              ),
                              _buildPriorityChip(
                                'high',
                                'Tinggi',
                                Colors.orange,
                              ),
                              _buildPriorityChip(
                                'urgent',
                                'Urgent',
                                Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _sendBroadcast,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          _isSending ? 'Mengirim...' : 'Kirim Broadcast',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notification History
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Riwayat Broadcast',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_loadingHistory)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_notificationHistory.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat broadcast',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notificationHistory.length,
                itemBuilder: (context, index) {
                  final notification = _notificationHistory[index];
                  return _buildHistoryCard(notification);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetChip(String value, String label, IconData icon) {
    final isSelected = _selectedTarget == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      onSelected: (selected) {
        setState(() => _selectedTarget = value);
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color) {
    final isSelected = _selectedPriority == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() => _selectedPriority = value);
      },
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      side: BorderSide(color: isSelected ? color : Colors.grey.shade300),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> notification) {
    final timestamp = notification['timestamp'] != null
        ? DateTime.parse(notification['timestamp'])
        : DateTime.now();
    final priority = notification['priority'] ?? 'normal';
    final target = notification['target'] ?? 'all';

    Color priorityColor;
    switch (priority) {
      case 'urgent':
        priorityColor = Colors.red;
        break;
      case 'high':
        priorityColor = Colors.orange;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: priorityColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    target == 'all'
                        ? 'SEMUA'
                        : target == 'customer'
                        ? 'CUSTOMER'
                        : 'TEKNISI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM, HH:mm').format(timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification['title'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              notification['message'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  notification['senderName'] ?? 'Admin',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${notification['recipientCount'] ?? 0} penerima',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
