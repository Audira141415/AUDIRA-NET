import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/chat_model.dart';
import '../../services/live_chat_service.dart';
import '../../utils/app_theme.dart';
import 'live_chat_room_page.dart';

/// Cyberpunk Neo-Brutalist Live Chat Center for AUDIRA
/// Real-time chat list connecting Customers with CS Siaga and Field Technicians
class LiveChatListPage extends StatefulWidget {
  const LiveChatListPage({super.key});

  @override
  State<LiveChatListPage> createState() => _LiveChatListPageState();
}

class _LiveChatListPageState extends State<LiveChatListPage> {
  String _selectedFilter = 'all'; // 'all' | 'customer_cs' | 'customer_teknisi'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.15) : const Color(0xFF0070F3).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00FF9D),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PUSAT LIVE CHAT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: textPrimary,
                  ),
                ),
                Text(
                  '// CS & TEKNISI SIAGA 24/7',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: textSecondary,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162032) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.shieldCheck,
                  size: 13,
                  color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF059669),
                ),
                const SizedBox(width: 4),
                Text(
                  'E2E ENCRYPTED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF059669),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
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
          // Filter & Search Controls Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
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
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    style: TextStyle(fontSize: 12.5, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari riwayat percakapan...',
                      hintStyle: TextStyle(fontSize: 12, color: textSecondary),
                      prefixIcon: Icon(LucideIcons.search, size: 16, color: textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 14),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip('Semua', 'all', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Customer Support', 'customer_cs', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Teknisi Lapangan', 'customer_teknisi', isDark),
                  ],
                ),
              ],
            ),
          ),

          // Chat Rooms Stream
          Expanded(
            child: StreamBuilder<List<ChatRoom>>(
              stream: LiveChatService.instance.getRoomsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var rooms = snapshot.data!;

                // Apply filter
                if (_selectedFilter != 'all') {
                  rooms = rooms.where((r) => r.type == _selectedFilter).toList();
                }

                // Apply search
                if (_searchQuery.isNotEmpty) {
                  rooms = rooms.where((r) {
                    return r.title.toLowerCase().contains(_searchQuery) ||
                        r.lastMessage.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (rooms.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.messageSquareDashed, size: 48, color: textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak Ada Percakapan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Belum ada pesan yang cocok dengan filter atau pencarian Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return _buildRoomBentoCard(
                      room: room,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedFilter == value;
    final activeColor = isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3);

    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF00F0FF).withValues(alpha: 0.15) : const Color(0xFF0070F3).withValues(alpha: 0.1))
              : (isDark ? const Color(0xFF162032) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? activeColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomBentoCard({
    required ChatRoom room,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final hasUnread = room.unreadCount > 0;
    final isCS = room.isCustomerCs;
    final accentColor = isCS
        ? (isDark ? const Color(0xFF00F0FF) : const Color(0xFF0070F3))
        : const Color(0xFF00FF9D);

    return InkWell(
      onTap: () {
        LiveChatService.instance.markRoomAsRead(room.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveChatRoomPage(room: room),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasUnread
                ? accentColor
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            width: hasUnread ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? accentColor.withValues(alpha: hasUnread ? 0.18 : 0.04)
                  : const Color(0xFF0F172A).withValues(alpha: 0.06),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Holographic Avatar with status badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162032) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isCS ? LucideIcons.headphones : LucideIcons.wrench,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: room.status == 'online'
                          ? const Color(0xFF00FF9D)
                          : const Color(0xFFFACC15),
                      border: Border.all(
                        color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Role Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 0.8),
                        ),
                        child: Text(
                          isCS ? 'CS SUPPORT SIAGA' : (room.ticketId != null ? 'TEKNISI // ${room.ticketId}' : 'TEKNISI LAPANGAN'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      // Time
                      Text(
                        _formatTime(room.lastMessageTime),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Room Title
                  Text(
                    room.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Last Message Snippet
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessage,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
                            color: hasUnread ? textPrimary : textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${room.unreadCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}j lalu';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
