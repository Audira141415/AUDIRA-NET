import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_theme.dart';

/// Item tiket teknisi bergaya Utilitas Modern (Clean Linear Style)
class TeknisiTicketItem extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onTap;

  const TeknisiTicketItem({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critical':
      case 'high':
      case 'tinggi':
        return const Color(0xFFEF4444);
      case 'medium':
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _getPriorityLabel(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critical':
      case 'high':
      case 'tinggi':
        return 'PRIORITAS TINGGI';
      case 'medium':
      case 'sedang':
        return 'PRIORITAS SEDANG';
      default:
        return 'NORMAL';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
      case 'selesai':
        return const Color(0xFF10B981);
      case 'in_progress':
      case 'diproses':
        return const Color(0xFF0284C7);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'resolved':
      case 'selesai':
        return 'Selesai';
      case 'in_progress':
      case 'diproses':
        return 'Diproses';
      default:
        return 'Terbuka';
    }
  }

  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final bodyColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final metaColor = isDark ? const Color(0xFF64748B) : const Color(0xFF64748B);

    final priority = ticket['priority']?.toString();
    final status = ticket['status']?.toString();
    final priorityColor = _getPriorityColor(priority);
    final statusColor = _getStatusColor(status);
    final phone = ticket['phone']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: ID & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: priorityColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _getPriorityLabel(priority),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: priorityColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ticket['ticketId'] ?? ticket['id'] ?? '#TIKET',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: metaColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusLabel(status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Subject / Issue
                Text(
                  ticket['subject'] ?? 'Gangguan Layanan Pelanggan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Description
                if (ticket['description'] != null)
                  Text(
                    ticket['description'],
                    style: TextStyle(
                      fontSize: 13,
                      color: bodyColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),

                // Bottom row: Customer Info & Quick Call
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: metaColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ticket['customerName'] ?? 'Pelanggan Umum',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: metaColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (phone != null && phone.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _makePhoneCall(phone),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.signalBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: AppTheme.signalBlue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Hubungi',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.signalBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
