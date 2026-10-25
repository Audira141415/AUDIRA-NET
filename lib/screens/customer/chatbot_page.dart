import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/chatbot_service.dart';
import '../../utils/app_theme.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final ChatbotService _chatbot = ChatbotService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              'Halo! 👋 Saya Audi, asisten virtual NOC AudiraNET.\n\n'
              'Saya siap membantu Anda dengan:\n'
              '• Informasi paket internet & kecepatan\n'
              '• Troubleshooting kendala koneksi\n'
              '• Cek tagihan & riwayat tiket NOC\n'
              '• Cara & metode pembayaran digital\n\n'
              'Ada yang bisa saya bantu hari ini?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await _chatbot.sendMessage(text.trim());

      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Maaf, terjadi kendala koneksi telemetri. Silakan coba kembali. 🙏',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSuggestedQuestionTap(String question) {
    _sendMessage(question);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppTheme.neonCyan : AppTheme.signalBlue;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.cyberOledBg : const Color(0xFFF1F5F9),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppTheme.neonCyan, AppTheme.neonPurple]
                      : [AppTheme.signalBlue, const Color(0xFF38BDF8)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.bot, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUDI AI // ASSISTANT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.0,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'NOC TELEMETRY & SUPPORT',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.refreshCw,
              color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
            ),
            tooltip: 'Reset percakapan',
            onPressed: () {
              setState(() {
                _messages.clear();
                _chatbot.resetConversation();
                _addWelcomeMessage();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Suggested questions (selalu tampil)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberObsidian : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 14,
                      color: isDark ? AppTheme.neonAmber : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PERTANYAAN POPULER:',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _chatbot.getSuggestedQuestions().map((q) {
                    return ActionChip(
                      label: Text(q),
                      onPressed: () => _onSuggestedQuestionTap(q),
                      backgroundColor: isDark
                          ? AppTheme.cyberSurfaceCard
                          : const Color(0xFFF8FAFC),
                      side: BorderSide(
                        color: isDark
                            ? AppTheme.neonCyan.withValues(alpha: 0.3)
                            : const Color(0xFFCBD5E1),
                      ),
                      labelStyle: TextStyle(
                        color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator(isDark);
                }
                return _buildMessageBubble(_messages[index], isDark);
              },
            ),
          ),

          // Input field container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberObsidian : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.cyberSurfaceCard
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.cyberBorder
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan Anda...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppTheme.textMuted
                                : const Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        onSubmitted: (text) => _sendMessage(text),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppTheme.neonCyan, AppTheme.neonPurple]
                            : [AppTheme.signalBlue, const Color(0xFF2563EB)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryAccent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isUser = message.isUser;
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppTheme.neonCyan, AppTheme.neonPurple]
                      : [AppTheme.signalBlue, const Color(0xFF38BDF8)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.bot, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark ? AppTheme.signalBlue : const Color(0xFF2563EB))
                        : (isDark ? AppTheme.cyberSurfaceCard : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: isDark
                                ? AppTheme.cyberBorder
                                : const Color(0xFFE2E8F0),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.04,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: isDark ? AppTheme.textMuted : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cyberObsidian : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.user,
                color: isDark ? AppTheme.neonCyan : const Color(0xFF64748B),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppTheme.neonCyan, AppTheme.neonPurple]
                    : [AppTheme.signalBlue, const Color(0xFF38BDF8)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bot, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, isDark),
                const SizedBox(width: 4),
                _buildDot(1, isDark),
                const SizedBox(width: 4),
                _buildDot(2, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    final dotColor = isDark ? AppTheme.neonCyan : AppTheme.signalBlue;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final adjustedValue = (value - delay).clamp(0.0, 1.0);
        final opacity = (adjustedValue * 2).clamp(0.3, 1.0);

        return Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isTyping) {
          setState(() {});
        }
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
