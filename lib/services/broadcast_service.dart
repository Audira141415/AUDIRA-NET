import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/broadcast_notification.dart';
import 'firebase_service.dart';
import 'notification_service.dart';
import 'logger_service.dart';

/// Service for handling Broadcast Notifications
class BroadcastService {
  static final BroadcastService instance = BroadcastService._internal();
  factory BroadcastService() => instance;
  BroadcastService._internal();

  final CollectionReference _broadcastsCollection = FirebaseFirestore.instance
      .collection('broadcasts');

  // ==================== MESSAGE TEMPLATES ====================

  final Map<String, Map<String, String>> messageTemplates = {
    'maintenance': {
      'title': '🔧 Jadwal Maintenance',
      'message':
          'Akan ada maintenance pada [TANGGAL] pukul [WAKTU]. Layanan internet akan terganggu selama [DURASI]. Mohon maaf atas ketidaknyamanannya.',
    },
    'promo': {
      'title': '🎉 Promo Spesial!',
      'message':
          'Dapatkan diskon [DISKON]% untuk upgrade paket Anda! Promo berlaku hingga [TANGGAL]. Hubungi CS kami untuk info lebih lanjut.',
    },
    'payment_reminder': {
      'title': '💰 Pengingat Pembayaran',
      'message':
          'Tagihan Anda untuk bulan [BULAN] sebesar Rp [JUMLAH] akan jatuh tempo pada [TANGGAL]. Mohon lakukan pembayaran tepat waktu.',
    },
    'outage': {
      'title': '🚨 Gangguan Jaringan',
      'message':
          'Terjadi gangguan jaringan di area [ZONA]. Tim teknisi sedang bekerja untuk memperbaiki. Estimasi selesai: [WAKTU].',
    },
    'welcome': {
      'title': '👋 Selamat Datang!',
      'message':
          'Terima kasih telah bergabung dengan AudiraNet! Nikmati layanan internet cepat dan stabil. Hubungi kami jika ada pertanyaan.',
    },
  };

  // ==================== CREATE & SCHEDULE ====================

  /// Create a new broadcast notification
  Future<String> createBroadcast({
    required String title,
    required String message,
    required String targetRole,
    String? targetZone,
    required String category,
    required String priority,
    required DateTime scheduledAt,
    required String createdBy,
  }) async {
    try {
      final broadcastData = {
        'title': title,
        'message': message,
        'targetRole': targetRole,
        'targetZone': targetZone,
        'category': category,
        'priority': priority,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'createdBy': createdBy,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _broadcastsCollection.add(broadcastData);

      LoggerService.info('Broadcast created: ${docRef.id}');

      // If scheduled for now or past, send immediately
      if (scheduledAt.isBefore(DateTime.now()) ||
          scheduledAt.difference(DateTime.now()).inMinutes < 1) {
        await sendBroadcast(docRef.id);
      }

      return docRef.id;
    } catch (e) {
      LoggerService.error('Error creating broadcast: $e');
      rethrow;
    }
  }

  /// Send a scheduled broadcast
  Future<void> sendBroadcast(String broadcastId) async {
    try {
      final broadcastDoc = await _broadcastsCollection.doc(broadcastId).get();
      if (!broadcastDoc.exists) {
        throw Exception('Broadcast not found');
      }

      final broadcast = BroadcastNotification.fromFirestore(broadcastDoc);

      // Get target recipients
      final recipients = await _getRecipients(
        broadcast.targetRole,
        broadcast.targetZone,
      );

      if (recipients.isEmpty) {
        LoggerService.warning(
          'No recipients found for broadcast: $broadcastId',
        );
        return;
      }

      // Send notifications to all recipients
      int sentCount = 0;
      for (final userId in recipients) {
        try {
          await NotificationService().showNetworkUpdateNotification(
            title: broadcast.title,
            message: broadcast.message,
          );
          sentCount++;
        } catch (e) {
          LoggerService.error('Failed to send to user $userId: $e');
        }
      }

      // Update broadcast status
      await _broadcastsCollection.doc(broadcastId).update({
        'status': 'sent',
        'sentAt': FieldValue.serverTimestamp(),
        'recipientCount': sentCount,
        'recipientIds': recipients,
      });

      LoggerService.info(
        'Broadcast sent: $broadcastId to $sentCount recipients',
      );
    } catch (e) {
      LoggerService.error('Error sending broadcast: $e');
      rethrow;
    }
  }

  /// Get list of recipient user IDs based on filters
  Future<List<String>> _getRecipients(
    String targetRole,
    String? targetZone,
  ) async {
    try {
      Query query = FirebaseService.instance.usersCollection;

      // Filter by role
      if (targetRole != 'all') {
        query = query.where('role', isEqualTo: targetRole);
      }

      // Filter by zone (for customers and teknisi)
      if (targetZone != null && targetZone.isNotEmpty) {
        query = query.where('zone', isEqualTo: targetZone);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      LoggerService.error('Error getting recipients: $e');
      return [];
    }
  }

  // ==================== QUERY BROADCASTS ====================

  /// Get all broadcasts
  Future<List<BroadcastNotification>> getAllBroadcasts() async {
    try {
      final querySnapshot = await _broadcastsCollection
          .orderBy('scheduledAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BroadcastNotification.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting broadcasts: $e');
      return [];
    }
  }

  /// Get broadcasts by status
  Future<List<BroadcastNotification>> getBroadcastsByStatus(
    String status,
  ) async {
    try {
      final querySnapshot = await _broadcastsCollection
          .where('status', isEqualTo: status)
          .orderBy('scheduledAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BroadcastNotification.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting broadcasts by status: $e');
      return [];
    }
  }

  /// Get scheduled broadcasts that are ready to send
  Future<List<BroadcastNotification>> getReadyBroadcasts() async {
    try {
      final now = Timestamp.now();
      final querySnapshot = await _broadcastsCollection
          .where('status', isEqualTo: 'scheduled')
          .where('scheduledAt', isLessThanOrEqualTo: now)
          .get();

      return querySnapshot.docs
          .map((doc) => BroadcastNotification.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting ready broadcasts: $e');
      return [];
    }
  }

  // ==================== MANAGE BROADCASTS ====================

  /// Cancel a scheduled broadcast
  Future<void> cancelBroadcast(String broadcastId) async {
    try {
      await _broadcastsCollection.doc(broadcastId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      LoggerService.info('Broadcast cancelled: $broadcastId');
    } catch (e) {
      LoggerService.error('Error cancelling broadcast: $e');
      rethrow;
    }
  }

  /// Update a scheduled broadcast
  Future<void> updateBroadcast(
    String broadcastId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _broadcastsCollection.doc(broadcastId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.info('Broadcast updated: $broadcastId');
    } catch (e) {
      LoggerService.error('Error updating broadcast: $e');
      rethrow;
    }
  }

  /// Delete a broadcast
  Future<void> deleteBroadcast(String broadcastId) async {
    try {
      await _broadcastsCollection.doc(broadcastId).delete();
      LoggerService.info('Broadcast deleted: $broadcastId');
    } catch (e) {
      LoggerService.error('Error deleting broadcast: $e');
      rethrow;
    }
  }

  // ==================== STATISTICS ====================

  /// Get broadcast statistics
  Future<Map<String, dynamic>> getBroadcastStats() async {
    try {
      final allBroadcasts = await getAllBroadcasts();

      final totalRecipients = allBroadcasts
          .where((b) => b.recipientCount != null)
          .fold<int>(0, (total, b) => total + (b.recipientCount ?? 0));

      return {
        'total': allBroadcasts.length,
        'scheduled': allBroadcasts.where((b) => b.status == 'scheduled').length,
        'sent': allBroadcasts.where((b) => b.status == 'sent').length,
        'cancelled': allBroadcasts.where((b) => b.status == 'cancelled').length,
        'totalRecipients': totalRecipients,
        'avgRecipients':
            allBroadcasts.where((b) => b.recipientCount != null).isNotEmpty
            ? (totalRecipients /
                      allBroadcasts
                          .where((b) => b.recipientCount != null)
                          .length)
                  .round()
            : 0,
      };
    } catch (e) {
      LoggerService.error('Error getting broadcast stats: $e');
      return {};
    }
  }

  // ==================== AUTO-SEND SCHEDULER ====================

  /// Check and send ready broadcasts (call this periodically)
  Future<void> processScheduledBroadcasts() async {
    try {
      final readyBroadcasts = await getReadyBroadcasts();

      for (final broadcast in readyBroadcasts) {
        await sendBroadcast(broadcast.id);
      }

      if (readyBroadcasts.isNotEmpty) {
        LoggerService.info(
          'Processed ${readyBroadcasts.length} scheduled broadcasts',
        );
      }
    } catch (e) {
      LoggerService.error('Error processing scheduled broadcasts: $e');
    }
  }
}
