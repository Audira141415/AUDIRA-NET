import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../config/api_config.dart';
import 'logger_service.dart';

/// Realtime Service for bidirectional WebSocket communication with NestJS Backend
/// Supports live notifications, technician GPS tracking, and instant alerts.
class RealtimeService {
  static final RealtimeService instance = RealtimeService._init();
  RealtimeService._init();

  socket_io.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // Stream controllers for reactive UI updates
  final _connectionStateController = StreamController<bool>.broadcast();
  final _paymentEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _ticketEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _alertEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _invoiceEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatEventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<bool> get onConnectionChange => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get onPaymentReceived => _paymentEventController.stream;
  Stream<Map<String, dynamic>> get onTicketUpdated => _ticketEventController.stream;
  Stream<Map<String, dynamic>> get onNetworkAlert => _alertEventController.stream;
  Stream<Map<String, dynamic>> get onInvoiceCreated => _invoiceEventController.stream;
  Stream<Map<String, dynamic>> get chatStream => _chatEventController.stream;

  /// Connect to the Realtime Gateway
  void connect({String role = 'TECHNICIAN', String? userId}) {
    if (_socket != null && _socket!.connected) {
      LoggerService.info('⚡ Realtime WebSocket already connected');
      return;
    }

    final serverUrl = ApiConfig.baseUrl;
    LoggerService.info('🌐 Connecting to Realtime Gateway at $serverUrl...');

    try {
      _socket = socket_io.io(
        serverUrl,
        socket_io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        _connectionStateController.add(true);
        LoggerService.info('✅ Realtime WebSocket connected to $serverUrl');

        // Automatically join appropriate rooms
        final roomName = role == 'TECHNICIAN' ? 'technician_room' : 'admin_room';
        joinRoom(roomName, role: role, userId: userId);

        if (userId != null && userId.isNotEmpty) {
          joinRoom('user_$userId');
        }
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        _connectionStateController.add(false);
        LoggerService.warning('⚠️ Realtime WebSocket disconnected');
      });

      _socket!.onConnectError((err) {
        _isConnected = false;
        _connectionStateController.add(false);
        LoggerService.error('❌ Realtime connection error: $err');
      });

      // Listen to domain events
      _socket!.on('payment_received', (data) {
        if (data is Map) {
          final eventData = Map<String, dynamic>.from(data);
          LoggerService.info('💰 Realtime: Payment received: ${eventData['invoiceNumber']}');
          _paymentEventController.add(eventData);
        }
      });

      _socket!.on('ticket_updated', (data) {
        if (data is Map) {
          final eventData = Map<String, dynamic>.from(data);
          LoggerService.info('🎫 Realtime: Ticket updated: ${eventData['ticketNumber']}');
          _ticketEventController.add(eventData);
        }
      });

      _socket!.on('network_alert', (data) {
        if (data is Map) {
          final eventData = Map<String, dynamic>.from(data);
          LoggerService.warning('🚨 Realtime: Network Alert from ${eventData['device']}');
          _alertEventController.add(eventData);
        }
      });

      _socket!.on('invoice_created', (data) {
        if (data is Map) {
          final eventData = Map<String, dynamic>.from(data);
          LoggerService.info('📄 Realtime: Invoice created: ${eventData['invoiceNumber']}');
          _invoiceEventController.add(eventData);
        }
      });

      _socket!.on('chat_message', (data) {
        if (data is Map) {
          final eventData = Map<String, dynamic>.from(data);
          LoggerService.info('💬 Realtime: Chat message from ${eventData['senderName']}');
          _chatEventController.add(eventData);
        }
      });
    } catch (e) {
      LoggerService.error('❌ Failed to initialize Realtime socket: $e');
    }
  }

  /// Join a specific WebSocket room
  void joinRoom(String room, {String? role, String? userId}) {
    if (_socket == null) return;
    _socket!.emit('join_room', {
      'room': room,
      'role': role,
      'userId': userId,
    });
    LoggerService.info('🚪 Joined room: $room');
  }

  /// Leave a WebSocket room
  void leaveRoom(String room) {
    if (_socket == null) return;
    _socket!.emit('leave_room', room);
    LoggerService.info('🚪 Left room: $room');
  }

  /// Stream field technician GPS coordinates live to Admin Web Dashboard
  void sendTechnicianLocation({
    required String technicianId,
    required double latitude,
    required double longitude,
    String? technicianName,
    double? speed,
  }) {
    if (_socket == null || !_isConnected) {
      LoggerService.warning('Cannot send location: Realtime socket not connected');
      return;
    }

    _socket!.emit('tech_location_update', {
      'technicianId': technicianId,
      'technicianName': technicianName,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send instant chat message
  void sendChatMessage({
    required String message,
    required String senderId,
    required String senderName,
    required String senderRole,
    String? room,
  }) {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('chat_message', {
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'room': room,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Disconnect socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _connectionStateController.add(false);
  }

  /// Dispose stream controllers
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _paymentEventController.close();
    _ticketEventController.close();
    _alertEventController.close();
    _invoiceEventController.close();
    _chatEventController.close();
  }
}
