import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/chat_model.dart';
import '../../services/live_chat_service.dart';
import '../../services/auth_service.dart';

/// Cyberpunk Neo-Brutalist Live Chat Room for AUDIRA
/// Real-time dialogue between Customer and CS Siaga / Field Technician
class LiveChatRoomPage extends StatefulWidget {
  final ChatRoom room;

  const LiveChatRoomPage({
    super.key,
    required this.room,
  });

  @override
  State<LiveChatRoomPage> createState() => _LiveChatRoomPageState();
}

class _LiveChatRoomPageState extends State<LiveChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  late final String _myId;
  late final String _myName;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUserData;
    _myId = user?['id']?.toString() ?? 'customer_usr';
    _myName = user?['name']?.toString() ?? 'Pelanggan';

    LiveChatService.instance.markRoomAsRead(widget.room.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage({String? presetText}) async {
    final text = presetText ?? _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    if (presetText == null) {
      _messageController.clear();
    }

    HapticFeedback.lightImpact();
    setState(() => _isSending = true);

    try {
      await LiveChatService.instance.sendMessage(
        roomId: widget.room.id,
        senderId: _myId,
        senderName: _myName,
        senderRole: 'customer',
        message: text,
      );
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _launchCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone?text=Halo%20AUDIRA%20Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final isCS = widget.room.isCustomerCs;
    final accentColor = isCS
        ? (isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3))
        : const Color(0xFF00FF9D);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162032) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentColor, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(
                      isCS ? LucideIcons.headphones : LucideIcons.wrench,
                      color: accentColor,
                      size: 18,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00FF9D),
                      border: Border.all(
                        color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.room.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00FF9D),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'E2E ENCRYPTED // LATENSI 12ms',
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.phone, size: 19, color: textPrimary),
            tooltip: 'Hubungi Hotline',
            onPressed: () => _launchCall('1500888'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.messageCircle, size: 19, color: Color(0xFF00FF9D)),
            tooltip: 'WhatsApp Fallback',
            onPressed: () => _launchWhatsApp('6282112001600'),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            height: 1.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Stream of Messages
          Expanded(
            child: StreamBuilder<List<LiveChatMessage>>(
              stream: LiveChatService.instance.getMessagesStream(widget.room.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageItem(
                      msg: msg,
                      isDark: isDark,
                      accentColor: accentColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  },
                );
              },
            ),
          ),

          // Quick Prompt Action Chips
          _buildQuickChipsBar(isDark, accentColor),

          // Brutalist Input Box
          _buildInputBar(isDark, cardBg, borderColor, textPrimary, textSecondary, accentColor),
        ],
      ),
    );
  }

  Widget _buildMessageItem({
    required LiveChatMessage msg,
    required bool isDark,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    // 1. System Notification Message
    if (msg.type == 'system') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF162032) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.shieldAlert, size: 14, color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                msg.message,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    final isMe = msg.senderRole == 'customer' || msg.senderId == _myId;
    final timeStr = '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: isMe
              ? (isDark ? const Color(0xFF0052CC) : const Color(0xFF0F172A))
              : (isDark ? const Color(0xFF0A0E1A) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
          border: Border.all(
            color: isMe
                ? (isDark ? const Color(0xFF00F0FF) : Colors.black)
                : (isDark ? accentColor.withValues(alpha: 0.5) : const Color(0xFFCBD5E1)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isMe
                  ? (isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.15))
                  : (isDark ? accentColor.withValues(alpha: 0.1) : const Color(0xFF0F172A).withValues(alpha: 0.05)),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender tag
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMe ? '// ANDA' : '// ${msg.senderName.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: isMe
                        ? (isDark ? const Color(0xFF00F0FF) : const Color(0xFF93C5FD))
                        : accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Message text
            Text(
              msg.message,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: isMe ? Colors.white : textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Timestamp + status tick
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: isMe ? Colors.white.withValues(alpha: 0.7) : textSecondary,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.checkCheck, size: 12, color: Color(0xFF00F0FF)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChipsBar(bool isDark, Color accentColor) {
    final chips = widget.room.isCustomerCs
        ? [
            'Bagaimana cara konfirmasi bayar?',
            'Koneksi internet lambat',
            'Jadwalkan teknisi lapangan',
            'Reset modem ONT sekarang',
          ]
        : [
            'Kapan teknisi tiba di lokasi?',
            'Cek nilai redaman optik',
            'Estimasi perbaikan berapa lama?',
          ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chipText = chips[index];
          return ActionChip(
            label: Text(
              chipText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              ),
            ),
            backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              width: 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            onPressed: () => _handleSendMessage(presetText: chipText),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        8,
        14,
        MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 24,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162032) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: IconButton(
              icon: Icon(LucideIcons.paperclip, size: 18, color: textSecondary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lampiran foto/log diagnostik siap diunggah.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // Text Field
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(fontSize: 13, color: textPrimary),
                onSubmitted: (_) => _handleSendMessage(),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan Anda ke ${widget.room.isCustomerCs ? "CS Siaga" : "Teknisi"}...',
                  hintStyle: TextStyle(fontSize: 12, color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send Button
          InkWell(
            onTap: _handleSendMessage,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white : Colors.black,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFF00F0FF).withValues(alpha: 0.3)
                        : const Color(0xFF0F172A).withValues(alpha: 0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  LucideIcons.send,
                  size: 18,
                  color: isDark ? const Color(0xFF05070D) : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
