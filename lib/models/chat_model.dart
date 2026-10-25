/// Chat Models for AUDIRA Real-time Live Chat System
/// Supports Customer ↔ CS and Customer ↔ Teknisi communication

class ChatRoom {
  final String id;
  final String title;
  final String type; // 'customer_cs' | 'customer_teknisi'
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String status; // 'online' | 'standby' | 'in_field'
  final String? ticketId;
  final String? avatarLetter;

  ChatRoom({
    required this.id,
    required this.title,
    required this.type,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.status = 'online',
    this.ticketId,
    this.avatarLetter,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      title: map['title'] ?? 'Customer Support',
      type: map['type'] ?? 'customer_cs',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] is DateTime
              ? map['lastMessageTime'] as DateTime
              : DateTime.tryParse(map['lastMessageTime'].toString()) ?? DateTime.now())
          : DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
      status: map['status'] ?? 'online',
      ticketId: map['ticketId'],
      avatarLetter: map['avatarLetter'] ?? 'CS',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'status': status,
      'ticketId': ticketId,
      'avatarLetter': avatarLetter,
    };
  }

  bool get isCustomerCs => type == 'customer_cs';
  bool get isCustomerTeknisi => type == 'customer_teknisi';
}

class LiveChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'customer' | 'technician' | 'cs' | 'admin'
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'text' | 'image' | 'system'

  LiveChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
  });

  factory LiveChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return LiveChatMessage(
      id: id,
      roomId: map['roomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Pengguna',
      senderRole: map['senderRole'] ?? 'customer',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is DateTime
              ? map['timestamp'] as DateTime
              : DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now())
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  bool isFromMe(String myId) => senderId == myId;
}
