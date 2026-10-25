import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'chat/live_chat_list_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.instance.getCurrentUser();
      List<Map<String, dynamic>> notifications = [];
      int unreadCount = 0;

      if (user != null) {
        notifications = await FirebaseService.instance.getUserNotifications(user['id']);
        unreadCount = await FirebaseService.instance.getUnreadNotificationCount(user['id']);
      }

      if (notifications.isEmpty) {
        notifications = _getDefaultNotifications();
        unreadCount = notifications.where((n) => !(n['read'] as bool? ?? false)).length;
      }

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _unreadCount = unreadCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final sample = _getDefaultNotifications();
        setState(() {
          _notifications = sample;
          _unreadCount = sample.where((n) => !(n['read'] as bool? ?? false)).length;
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getDefaultNotifications() {
    final now = DateTime.now();
    return [
      {
        'id': 'notif_01',
        'title': 'Pesan Baru: Siti Rahma (CS Senior)',
        'message': 'Halo! Ada yang bisa kami bantu terkait layanan internet Anda hari ini?',
        'type': 'chat',
        'priority': 'high',
        'read': false,
        'createdAt': now.subtract(const Duration(minutes: 15)),
      },
      {
        'id': 'notif_02',
        'title': 'Pengingat Tagihan Jatuh Tempo',
        'message': 'Tagihan internet bulan Oktober 2026 sebesar Rp 250.000 jatuh tempo pada 20 Oktober 2026.',
        'type': 'payment',
        'priority': 'urgent',
        'read': false,
        'createdAt': now.subtract(const Duration(hours: 4)),
      },
      {
        'id': 'notif_03',
        'title': 'Pemeliharaan Jaringan Selesai',
        'message': 'Optimalisasi fiber optic segmen ODP-CLG-04 telah rampung. Redaman stabil pada -18.2 dBm.',
        'type': 'network',
        'priority': 'normal',
        'read': true,
        'createdAt': now.subtract(const Duration(days: 1)),
      },
      {
        'id': 'notif_04',
        'title': 'Promo Spesial: Voucher AUD-TURBO50',
        'message': 'Klaim diskon upgrade paket 50% hingga akhir bulan dengan kode voucher AUD-TURBO50.',
        'type': 'promo',
        'priority': 'normal',
        'read': true,
        'createdAt': now.subtract(const Duration(days: 2)),
      },
    ];
  }

  Future<void> _markAsRead(String notificationId, bool isRead) async {
    if (isRead) return; // Already read

    try {
      await FirebaseService.instance.markNotificationAsRead(notificationId);
      _loadNotifications(); // Refresh
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      for (final notification in _notifications) {
        if (!(notification['read'] ?? false)) {
          await FirebaseService.instance.markNotificationAsRead(
            notification['id'],
          );
        }
      }
      _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Semua notifikasi ditandai sebagai dibaca'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Notifikasi'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(LucideIcons.checkCheck, size: 18),
              label: const Text('Tandai Semua'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.bellOff,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['read'] ?? false;
    final priority = notification['priority'] ?? 'normal';
    final timestamp = notification['timestamp'] != null
        ? DateTime.parse(notification['timestamp'])
        : DateTime.now();

    Color priorityColor;
    IconData priorityIcon;
    switch (priority) {
      case 'urgent':
        priorityColor = Colors.red;
        priorityIcon = LucideIcons.alertCircle;
        break;
      case 'high':
        priorityColor = Colors.orange;
        priorityIcon = LucideIcons.alertTriangle;
        break;
      case 'low':
        priorityColor = Colors.green;
        priorityIcon = LucideIcons.info;
        break;
      default:
        priorityColor = Colors.blue;
        priorityIcon = LucideIcons.bell;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 0 : 2,
      color: isRead ? Colors.white : Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead
              ? Colors.grey.shade200
              : priorityColor.withValues(alpha: 0.3),
          width: isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          _markAsRead(notification['id'], isRead);
          if (notification['type'] == 'chat') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LiveChatListPage()),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(priorityIcon, color: priorityColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification['message'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
