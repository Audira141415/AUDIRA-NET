import 'package:flutter/material.dart';
import '../services/telegram_service.dart';

class TelegramTopicsScreen extends StatefulWidget {
  const TelegramTopicsScreen({super.key});

  @override
  State<TelegramTopicsScreen> createState() => _TelegramTopicsScreenState();
}

class _TelegramTopicsScreenState extends State<TelegramTopicsScreen> {
  final TelegramService _telegram = TelegramService.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshTopics();
  }

  Future<void> _refreshTopics() async {
    setState(() => _isLoading = true);
    await _telegram.fetchTopics();
    setState(() => _isLoading = false);
  }

  IconData _getTopicIcon(int no) {
    switch (no) {
      case 1:
        return Icons.campaign_rounded;
      case 2:
        return Icons.credit_card_rounded;
      case 3:
        return Icons.person_add_alt_1_rounded;
      case 4:
        return Icons.wifi_tethering_rounded;
      case 5:
        return Icons.warning_amber_rounded;
      case 6:
        return Icons.support_agent_rounded;
      case 7:
        return Icons.build_circle_rounded;
      case 8:
        return Icons.power_rounded;
      case 9:
        return Icons.router_rounded;
      case 10:
        return Icons.analytics_rounded;
      case 11:
        return Icons.smart_toy_rounded;
      case 12:
        return Icons.auto_awesome_rounded;
      case 13:
        return Icons.edit_calendar_rounded;
      case 14:
        return Icons.lock_clock_rounded;
      default:
        return Icons.forum_rounded;
    }
  }

  Color _getTopicColor(int no) {
    switch (no) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.cyan;
      case 5:
        return Colors.redAccent;
      case 6:
        return Colors.indigoAccent;
      case 7:
        return Colors.orange;
      case 8:
        return Colors.teal;
      case 9:
        return Colors.purpleAccent;
      case 10:
        return Colors.lightBlue;
      case 11:
        return Colors.blueGrey;
      case 12:
        return Colors.pinkAccent;
      case 13:
        return Colors.deepOrange;
      case 14:
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  Future<void> _sendQuickTest(TelegramTopicModel topic) async {
    setState(() => _isLoading = true);
    final success = await _telegram.sendMessage(
      topicNo: topic.no,
      title: 'Tes Notifikasi dari Mobile App',
      message: 'Perangkat mobile staf AUDIRA-NET terhubung live dengan Topik #${topic.no} (${topic.name}).',
    );
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Pesan tes terkirim ke ${topic.name}'
                : '❌ Gagal mengirim pesan ke Telegram',
          ),
          backgroundColor: success ? Colors.green[800] : Colors.red[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = _telegram.topics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Operations Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTopics,
            tooltip: 'Refresh Topics',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _telegram.openSupergroup(),
            tooltip: 'Buka Supergroup Telegram',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Supergroup Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[900]!.withValues(alpha: 0.8),
                          Colors.cyan[900]!.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.send_rounded,
                              color: Colors.lightBlueAccent,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'AUDIRA ISP | Operations Center',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Bot: @AudiraISPBot • 14 Topics Forum',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Pusat notifikasi resmi untuk seluruh operasional ISP, mulai dari tagihan, pemantauan jaringan, tiket gangguan, hingga pekerjaan lapangan.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _telegram.openSupergroup(),
                          icon: const Icon(Icons.telegram, size: 18),
                          label: const Text('Buka Grup Telegram'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'DAFTAR 14 TOPIK FORUM TELEGRAM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                // Topics List
                ...topics.map((topic) {
                  final color = _getTopicColor(topic.no);
                  final icon = _getTopicIcon(topic.no);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      title: Row(
                        children: [
                          Text(
                            '#${topic.no}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              topic.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            topic.desc,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Thread ID: ${topic.threadId}',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.send_outlined, size: 20),
                            onPressed: () => _sendQuickTest(topic),
                            tooltip: 'Kirim Tes Notifikasi',
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 20),
                            onPressed: () => _telegram.openTopic(topic.no),
                            tooltip: 'Buka Topik di Telegram',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
