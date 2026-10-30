import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import 'logger_service.dart';

class TelegramTopicModel {
  final int no;
  final String key;
  final String name;
  final String desc;
  final int threadId;

  TelegramTopicModel({
    required this.no,
    required this.key,
    required this.name,
    required this.desc,
    required this.threadId,
  });

  factory TelegramTopicModel.fromJson(Map<String, dynamic> json) {
    return TelegramTopicModel(
      no: json['no'] as int,
      key: json['key'] as String? ?? '',
      name: json['name'] as String,
      desc: json['desc'] as String,
      threadId: json['threadId'] as int,
    );
  }
}

class TelegramService {
  static final TelegramService instance = TelegramService._init();
  TelegramService._init();

  static const String botToken = String.fromEnvironment(
    'TELEGRAM_BOT_TOKEN',
    defaultValue: '8874323451:AAFJXzKCyqPRkJTqjUR_sCh8EuraqlKOm4k',
  );
  static const String chatId = String.fromEnvironment(
    'TELEGRAM_CHAT_ID',
    defaultValue: '-1004464075869',
  );
  static const String inviteLink = 'https://t.me/+Yx8qadYjUSsxZjQ1';

  final List<TelegramTopicModel> defaultTopics = [
    TelegramTopicModel(no: 1, key: 'ANNOUNCEMENTS', name: '📢 Announcements', desc: 'Pengumuman internal', threadId: 2),
    TelegramTopicModel(no: 2, key: 'BILLING_PAYMENT', name: '💳 Billing & Payment', desc: 'Tagihan dan pembayaran', threadId: 4),
    TelegramTopicModel(no: 3, key: 'CUSTOMER_MANAGEMENT', name: '👥 Customer Management', desc: 'Registrasi dan pengelolaan pelanggan', threadId: 6),
    TelegramTopicModel(no: 4, key: 'NETWORK_MONITORING', name: '🌐 Network Monitoring', desc: 'Status jaringan dan perangkat', threadId: 8),
    TelegramTopicModel(no: 5, key: 'NETWORK_INCIDENTS', name: '🚨 Network Incidents', desc: 'Gangguan jaringan', threadId: 10),
    TelegramTopicModel(no: 6, key: 'SUPPORT_TICKETS', name: '🎫 Support Tickets', desc: 'Keluhan dan tiket pelanggan', threadId: 12),
    TelegramTopicModel(no: 7, key: 'FIELD_OPERATIONS', name: '🛠️ Field Operations', desc: 'Pekerjaan teknisi', threadId: 14),
    TelegramTopicModel(no: 8, key: 'INSTALLATION_ACTIVATION', name: '🔌 Installation & Activation', desc: 'Instalasi dan aktivasi pelanggan', threadId: 16),
    TelegramTopicModel(no: 9, key: 'INFRASTRUCTURE', name: '📡 Infrastructure', desc: 'Router, OLT, ODP, ODC, POP, dan infrastruktur lainnya sesuai kebutuhan', threadId: 18),
    TelegramTopicModel(no: 10, key: 'REPORTS_ANALYTICS', name: '📊 Reports & Analytics', desc: 'Laporan operasional dan statistik', threadId: 20),
    TelegramTopicModel(no: 11, key: 'SYSTEM_AUTOMATION', name: '⚙️ System & Automation', desc: 'Status bot, API, database, dan automasi', threadId: 22),
    TelegramTopicModel(no: 12, key: 'AI_ASSISTANT', name: '🤖 AI Assistant', desc: 'Analisis dan bantuan AI', threadId: 24),
    TelegramTopicModel(no: 13, key: 'CHANGE_MANAGEMENT', name: '📝 Change Management', desc: 'Perubahan konfigurasi dan pekerjaan terencana', threadId: 26),
    TelegramTopicModel(no: 14, key: 'FINANCE_SUMMARY', name: '💰 Finance Summary', desc: 'Ringkasan keuangan dengan akses terbatas', threadId: 28),
  ];

  List<TelegramTopicModel> _cachedTopics = [];

  List<TelegramTopicModel> get topics =>
      _cachedTopics.isNotEmpty ? _cachedTopics : defaultTopics;

  /// Fetch topics from Backend NestJS
  Future<List<TelegramTopicModel>> fetchTopics() async {
    try {
      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.telegramTopics));
      final resp = await http.get(url, headers: ApiConfig.defaultHeaders).timeout(const Duration(seconds: 5));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['topics'] is List) {
          _cachedTopics = (data['topics'] as List)
              .map((item) => TelegramTopicModel.fromJson(item))
              .toList();
          return _cachedTopics;
        }
      }
    } catch (e) {
      LoggerService.warning('Failed to fetch topics from backend: $e. Using local defaults.');
    }
    _cachedTopics = defaultTopics;
    return defaultTopics;
  }

  /// Send message to specific topic (via Backend API first, fallback to direct Telegram Bot API)
  Future<bool> sendMessage({
    required int topicNo,
    required String message,
    String? title,
  }) async {
    // 1. Try via backend
    try {
      final backendUrl = Uri.parse(ApiConfig.getUrl(ApiConfig.telegramBroadcast));
      final resp = await http
          .post(
            backendUrl,
            headers: ApiConfig.defaultHeaders,
            body: json.encode({
              'topicNo': topicNo,
              'title': title,
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = json.decode(resp.body);
        if (body['success'] == true) {
          LoggerService.info('Telegram broadcast sent via backend to topic #$topicNo');
          return true;
        }
      }
    } catch (e) {
      LoggerService.warning('Backend broadcast error: $e. Attempting direct Telegram Bot fallback.');
    }

    // 2. Direct Telegram fallback
    try {
      final topic = defaultTopics.firstWhere(
        (t) => t.no == topicNo,
        orElse: () => defaultTopics.first,
      );

      final fullText = title != null && title.isNotEmpty
          ? '📢 *$title*\n━━━━━━━━━━━━━━━━━━━━\n$message'
          : message;

      final directUrl = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
      final resp = await http.post(
        directUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': chatId,
          'message_thread_id': topic.threadId,
          'text': fullText,
          'parse_mode': 'Markdown',
        }),
      );

      return resp.statusCode == 200;
    } catch (e) {
      LoggerService.error('Direct Telegram API failed: $e');
      return false;
    }
  }

  /// Open Supergroup in Telegram app
  Future<bool> openSupergroup() async {
    final uri = Uri.parse(inviteLink);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Open specific topic in Telegram app
  Future<bool> openTopic(int topicNo) async {
    final topic = defaultTopics.firstWhere(
      (t) => t.no == topicNo,
      orElse: () => defaultTopics.first,
    );

    // Deep link format for supergroup topics
    // Web: https://t.me/c/4464075869/${topic.threadId}
    final webUrl = Uri.parse('https://t.me/c/4464075869/${topic.threadId}');
    if (await canLaunchUrl(webUrl)) {
      return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
    return openSupergroup();
  }

  // Quick Dispatch Helpers for Mobile Users

  /// Topic 5: Report Network Incident
  Future<bool> reportIncident({
    required String title,
    required String location,
    required String severity,
    required String details,
    String? reporter,
  }) {
    final text = '🚨 *LAPORAN GANGGUAN JARINGAN (MOBILE)*\n'
        '━━━━━━━━━━━━━━━━━━━━\n'
        '⚠️ Kendala: *$title*\n'
        '📍 Lokasi: $location\n'
        '🔴 Severity: *$severity*\n'
        '📋 Detail:\n$details\n\n'
        '📱 _Dilaporkan oleh: ${reporter ?? 'Petugas Lapangan'} via App_';
    return sendMessage(topicNo: 5, message: text);
  }

  /// Topic 7: Field Operation Check-In
  Future<bool> reportFieldTask({
    required String technician,
    required String spkId,
    required String taskType,
    required String location,
    required String status,
  }) {
    final text = '🛠️ *UPDATE PEKERJAAN LAPANGAN*\n'
        '━━━━━━━━━━━━━━━━━━━━\n'
        'SPK: `$spkId`\n'
        'Teknisi: *$technician*\n'
        'Tugas: *$taskType*\n'
        'Lokasi: $location\n'
        'Status: *$status*\n\n'
        '📍 _Presensi & GPS Terverifikasi_';
    return sendMessage(topicNo: 7, message: text);
  }

  /// Topic 8: FTTH Customer Activation Report
  Future<bool> reportActivation({
    required String customerName,
    required String internetNumber,
    required String ontSn,
    required double rxDbm,
    required String technician,
  }) {
    final text = '🔌 *AKTIVASI FTTH BERHASIL (MOBILE)*\n'
        '━━━━━━━━━━━━━━━━━━━━\n'
        'Pelanggan: *$customerName*\n'
        'No Internet: `$internetNumber`\n'
        'ONT SN: `$ontSn`\n'
        'Redaman: *${rxDbm.toStringAsFixed(2)} dBm*\n'
        'Teknisi: *$technician*\n\n'
        '🎉 _Koneksi pelanggan live & aktif!_';
    return sendMessage(topicNo: 8, message: text);
  }

  /// Topic 6: Support Ticket Escalation
  Future<bool> reportTicket({
    required String ticketId,
    required String customer,
    required String issue,
    required String priority,
  }) {
    final text = '🎫 *ESKALASI TIKET GANGGUAN*\n'
        '━━━━━━━━━━━━━━━━━━━━\n'
        'Tiket ID: `$ticketId`\n'
        'Pelanggan: *$customer*\n'
        'Prioritas: *$priority*\n'
        'Kendala: $issue\n\n'
        '⏱️ _Mohon segera ditindaklanjuti tim NOC._';
    return sendMessage(topicNo: 6, message: text);
  }
}
