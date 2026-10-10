import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Broadcast Notification
class BroadcastNotification {
  final String id;
  final String title;
  final String message;
  final String targetRole; // 'all', 'customer', 'teknisi', 'admin'
  final String? targetZone; // null = all zones
  final String category; // 'announcement', 'maintenance', 'promo', 'emergency'
  final String priority; // 'low', 'medium', 'high', 'critical'
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final String createdBy; // Admin user ID
  final String status; // 'draft', 'scheduled', 'sent', 'cancelled'
  final int? recipientCount;
  final List<String>? recipientIds; // For targeted broadcasts

  BroadcastNotification({
    required this.id,
    required this.title,
    required this.message,
    this.targetRole = 'all',
    this.targetZone,
    this.category = 'announcement',
    this.priority = 'medium',
    required this.scheduledAt,
    this.sentAt,
    required this.createdBy,
    this.status = 'draft',
    this.recipientCount,
    this.recipientIds,
  });

  factory BroadcastNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BroadcastNotification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      targetRole: data['targetRole'] ?? 'all',
      targetZone: data['targetZone'],
      category: data['category'] ?? 'announcement',
      priority: data['priority'] ?? 'medium',
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      sentAt:
          data['sentAt'] != null ? (data['sentAt'] as Timestamp).toDate() : null,
      createdBy: data['createdBy'] ?? '',
      status: data['status'] ?? 'draft',
      recipientCount: data['recipientCount'],
      recipientIds: data['recipientIds'] != null
          ? List<String>.from(data['recipientIds'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'targetRole': targetRole,
      'targetZone': targetZone,
      'category': category,
      'priority': priority,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'createdBy': createdBy,
      'status': status,
      'recipientCount': recipientCount,
      'recipientIds': recipientIds,
    };
  }

  // Get icon based on category
  String get categoryIcon {
    switch (category) {
      case 'maintenance':
        return '🔧';
      case 'promo':
        return '🎉';
      case 'emergency':
        return '🚨';
      default:
        return '📢';
    }
  }

  // Get priority color
  String get priorityColor {
    switch (priority) {
      case 'critical':
        return 'red';
      case 'high':
        return 'orange';
      case 'medium':
        return 'blue';
      default:
        return 'grey';
    }
  }

  // Check if broadcast is ready to send
  bool get isReadyToSend =>
      status == 'scheduled' && DateTime.now().isAfter(scheduledAt);
}
