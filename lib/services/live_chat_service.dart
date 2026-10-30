import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import 'notification_service.dart';
import 'realtime_service.dart';

/// Real-time Live Chat Service for AUDIRA Fiber Platform
/// Manages Customer ↔ Customer Support and Customer ↔ Teknisi Lapangan communication
class LiveChatService {
  LiveChatService._();
  static final LiveChatService instance = LiveChatService._();

  final FirebaseFirestore? _firestore = _safeGetFirestore();
  static FirebaseFirestore? _safeGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // In-memory state for local instant updates and fallback
  final Map<String, ChatRoom> _rooms = {};
  final Map<String, List<LiveChatMessage>> _messagesByRoom = {};

  final StreamController<List<ChatRoom>> _roomsStreamController =
      StreamController<List<ChatRoom>>.broadcast();

  final Map<String, StreamController<List<LiveChatMessage>>> _roomMessageControllers = {};

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Seed default rooms
    _seedDefaultRooms();

    // Listen to RealtimeService socket messages if available
    try {
      RealtimeService.instance.chatStream.listen((event) {
        _handleIncomingSocketMessage(event);
      });
    } catch (_) {}
  }

  void _seedDefaultRooms() {
    final now = DateTime.now();

    final csRoom = ChatRoom(
      id: 'room_cs_audira',
      title: 'Customer Support Siaga 24/7',
      type: 'customer_cs',
      participants: ['customer', 'cs_support'],
      lastMessage: 'Halo! Ada yang bisa kami bantu terkait layanan internet Anda hari ini?',
      lastMessageTime: now.subtract(const Duration(minutes: 15)),
      unreadCount: 1,
      status: 'online',
      avatarLetter: 'CS',
    );

    final techRoom = ChatRoom(
      id: 'room_tech_tkt9921',
      title: 'Teknisi Lapangan - Rian Pratama',
      type: 'customer_teknisi',
      participants: ['customer', 'technician_01'],
      lastMessage: 'Pagi Pak, pengecekan redaman optik ODP telah selesai, nilai normal -18.2 dBm.',
      lastMessageTime: now.subtract(const Duration(hours: 2)),
      unreadCount: 0,
      status: 'in_field',
      ticketId: 'TKT-2026-9921',
      avatarLetter: 'TK',
    );

    _rooms[csRoom.id] = csRoom;
    _rooms[techRoom.id] = techRoom;

    _messagesByRoom[csRoom.id] = [
      LiveChatMessage(
        id: 'msg_cs_01',
        roomId: csRoom.id,
        senderId: 'system',
        senderName: 'SISTEM AUDIRA',
        senderRole: 'system',
        message: 'Kanal Live Chat Terenkripsi End-to-End dengan Customer Support Siaga.',
        timestamp: now.subtract(const Duration(minutes: 20)),
        isRead: true,
        type: 'system',
      ),
      LiveChatMessage(
        id: 'msg_cs_02',
        roomId: csRoom.id,
        senderId: 'cs_support',
        senderName: 'Siti Rahma (CS Senior)',
        senderRole: 'cs',
        message: 'Halo! Ada yang bisa kami bantu terkait layanan internet Anda hari ini?',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        type: 'text',
      ),
    ];

    _messagesByRoom[techRoom.id] = [
      LiveChatMessage(
        id: 'msg_tk_01',
        roomId: techRoom.id,
        senderId: 'system',
        senderName: 'SISTEM AUDIRA',
        senderRole: 'system',
        message: 'Tiket #TKT-2026-9921 dialokasikan ke Teknisi Rian Pratama.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        type: 'system',
      ),
      LiveChatMessage(
        id: 'msg_tk_02',
        roomId: techRoom.id,
        senderId: 'customer',
        senderName: 'Pelanggan',
        senderRole: 'customer',
        message: 'Selamat pagi Mas Rian, untuk jadwal pengecekan router jam berapa ya?',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        isRead: true,
        type: 'text',
      ),
      LiveChatMessage(
        id: 'msg_tk_03',
        roomId: techRoom.id,
        senderId: 'technician_01',
        senderName: 'Rian Pratama',
        senderRole: 'technician',
        message: 'Pagi Pak, pengecekan redaman optik ODP telah selesai, nilai normal -18.2 dBm.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        type: 'text',
      ),
    ];

    _notifyRooms();
  }

  /// Get stream of all active chat rooms
  Stream<List<ChatRoom>> getRoomsStream({String? role}) {
    initialize();
    // Return current state immediately
    Timer.run(() => _notifyRooms());
    return _roomsStreamController.stream;
  }

  /// Get stream of messages for a specific room
  Stream<List<LiveChatMessage>> getMessagesStream(String roomId) {
    initialize();
    if (!_roomMessageControllers.containsKey(roomId)) {
      _roomMessageControllers[roomId] =
          StreamController<List<LiveChatMessage>>.broadcast();
    }

    Timer.run(() => _notifyRoomMessages(roomId));
    return _roomMessageControllers[roomId]!.stream;
  }

  /// Send message in a chat room
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    String type = 'text',
  }) async {
    initialize();
    final now = DateTime.now();
    final messageId = 'msg_${now.millisecondsSinceEpoch}';

    final newMessage = LiveChatMessage(
      id: messageId,
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      message: message,
      timestamp: now,
      isRead: false,
      type: type,
    );

    // 1. Update in-memory message list
    _messagesByRoom.putIfAbsent(roomId, () => []);
    _messagesByRoom[roomId]!.add(newMessage);
    _notifyRoomMessages(roomId);

    // 2. Update room's last message
    if (_rooms.containsKey(roomId)) {
      final old = _rooms[roomId]!;
      _rooms[roomId] = ChatRoom(
        id: old.id,
        title: old.title,
        type: old.type,
        participants: old.participants,
        lastMessage: message,
        lastMessageTime: now,
        unreadCount: old.unreadCount,
        status: old.status,
        ticketId: old.ticketId,
        avatarLetter: old.avatarLetter,
      );
      _notifyRooms();
    }

    // 3. Emit via RealtimeService socket if connected
    try {
      RealtimeService.instance.sendChatMessage(
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        room: roomId,
        message: message,
      );
    } catch (_) {}

    // 4. Persist to Firestore if available
    if (_firestore != null) {
      try {
        await _firestore
            .collection('chat_rooms')
            .doc(roomId)
            .collection('messages')
            .doc(messageId)
            .set(newMessage.toMap());

        await _firestore.collection('chat_rooms').doc(roomId).set({
          'lastMessage': message,
          'lastMessageTime': now.toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }

    // 5. Simulate intelligent responsive reply from CS or Teknisi (Demo & Offline mode)
    if (senderRole == 'customer') {
      _scheduleAutoReply(roomId, message);
    }
  }

  void _scheduleAutoReply(String roomId, String customerQuery) {
    Timer(const Duration(seconds: 2), () {
      final room = _rooms[roomId];
      if (room == null) return;

      final now = DateTime.now();
      String replyText = '';
      String responderName = '';
      String responderRole = '';

      if (room.isCustomerCs) {
        responderName = 'Siti Rahma (CS Senior)';
        responderRole = 'cs';
        final queryLower = customerQuery.toLowerCase();
        if (queryLower.contains('lambat') || queryLower.contains('lemot') || queryLower.contains('speed')) {
          replyText = 'Baik Kak, kami sudah melakukan re-check jalur optik Anda. Jalur OLT normal. Silakan coba restart modem ONT melalui menu Beranda > Kelola Wi-Fi.';
        } else if (queryLower.contains('bayar') || queryLower.contains('tagihan')) {
          replyText = 'Untuk pembayaran dapat melalui Menu Tagihan dengan scan QRIS instan atau transfer Virtual Account BCA / Mandiri. Konfirmasi otomatis realtime.';
        } else if (queryLower.contains('teknisi') || queryLower.contains('kunjungan')) {
          replyText = 'Kami dapat menjadwalkan kunjungan teknisi lapangan hari ini. Mohon pastikan ada orang di lokasi saat teknisi tiba.';
        } else {
          replyText = 'Pesan Anda telah diterima oleh tim CS AUDIRA Siaga. Kami sedang memvalidasi data sambungan Anda.';
        }
      } else {
        responderName = 'Rian Pratama (Teknisi)';
        responderRole = 'technician';
        final queryLower = customerQuery.toLowerCase();
        if (queryLower.contains('tiba') || queryLower.contains('kapan') || queryLower.contains('dimana')) {
          replyText = 'Siap Pak, saat ini saya berada sekitar 1.2 KM dari lokasi ODP Anda. Estimasi tiba di lokasi dalam 10-15 menit.';
        } else if (queryLower.contains('redaman') || queryLower.contains('optik')) {
          replyText = 'Pengukuran redaman terakhir di port ODP menunjukkan -18.2 dBm (Sangat Baik / Optimal). Saya akan cek konektor dropcore di rumah Anda.';
        } else {
          replyText = 'Baik Pak, segera saya tindak lanjuti di lapangan. Jika butuh darurat silakan hubungi hotline.';
        }
      }

      final replyMessage = LiveChatMessage(
        id: 'msg_reply_${now.millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: responderRole == 'cs' ? 'cs_support' : 'technician_01',
        senderName: responderName,
        senderRole: responderRole,
        message: replyText,
        timestamp: now,
        isRead: false,
        type: 'text',
      );

      _messagesByRoom.putIfAbsent(roomId, () => []);
      _messagesByRoom[roomId]!.add(replyMessage);
      _notifyRoomMessages(roomId);

      // Update room unread count
      final updatedRoom = ChatRoom(
        id: room.id,
        title: room.title,
        type: room.type,
        participants: room.participants,
        lastMessage: replyText,
        lastMessageTime: now,
        unreadCount: room.unreadCount + 1,
        status: room.status,
        ticketId: room.ticketId,
        avatarLetter: room.avatarLetter,
      );
      _rooms[roomId] = updatedRoom;
      _notifyRooms();

      // Trigger Notification Service
      NotificationService().showChatNotification(
        senderName: responderName,
        message: replyText,
        roomId: roomId,
        senderRole: responderRole,
      );
    });
  }

  void _handleIncomingSocketMessage(Map<String, dynamic> data) {
    final roomId = data['room']?.toString();
    if (roomId == null) return;

    final now = DateTime.now();
    final message = LiveChatMessage(
      id: 'msg_sock_${now.millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: data['senderId']?.toString() ?? 'unknown',
      senderName: data['senderName']?.toString() ?? 'Support',
      senderRole: data['senderRole']?.toString() ?? 'cs',
      message: data['message']?.toString() ?? '',
      timestamp: now,
      isRead: false,
    );

    _messagesByRoom.putIfAbsent(roomId, () => []);
    _messagesByRoom[roomId]!.add(message);
    _notifyRoomMessages(roomId);

    if (_rooms.containsKey(roomId)) {
      final old = _rooms[roomId]!;
      _rooms[roomId] = ChatRoom(
        id: old.id,
        title: old.title,
        type: old.type,
        participants: old.participants,
        lastMessage: message.message,
        lastMessageTime: now,
        unreadCount: old.unreadCount + 1,
        status: old.status,
        ticketId: old.ticketId,
        avatarLetter: old.avatarLetter,
      );
      _notifyRooms();
    }
  }

  /// Mark all messages in a room as read
  void markRoomAsRead(String roomId) {
    if (_rooms.containsKey(roomId)) {
      final old = _rooms[roomId]!;
      _rooms[roomId] = ChatRoom(
        id: old.id,
        title: old.title,
        type: old.type,
        participants: old.participants,
        lastMessage: old.lastMessage,
        lastMessageTime: old.lastMessageTime,
        unreadCount: 0,
        status: old.status,
        ticketId: old.ticketId,
        avatarLetter: old.avatarLetter,
      );
      _notifyRooms();
    }
  }

  /// Get total unread chat messages count across all rooms
  int getTotalUnreadCount() {
    return _rooms.values.fold(0, (sum, room) => sum + room.unreadCount);
  }

  void _notifyRooms() {
    if (!_roomsStreamController.isClosed) {
      final sorted = _rooms.values.toList()
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      _roomsStreamController.add(sorted);
    }
  }

  void _notifyRoomMessages(String roomId) {
    final controller = _roomMessageControllers[roomId];
    if (controller != null && !controller.isClosed) {
      final list = List<LiveChatMessage>.from(_messagesByRoom[roomId] ?? []);
      controller.add(list);
    }
  }
}
