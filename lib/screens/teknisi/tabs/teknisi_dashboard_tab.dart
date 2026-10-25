import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/routes.dart';
import '../../../services/firebase_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/theme_provider.dart';
import '../barcode_scanner_page.dart';
import '../installation_map_view.dart';
import '../../notifications_page.dart';
import '../widgets/teknisi_duty_card.dart';
import '../widgets/teknisi_metric_bar.dart';
import '../widgets/teknisi_ticket_item.dart';

/// Dashboard Teknisi berstandar High-Utility & Anti-Slop (Minimalis, Fungsional, Cepat)
class TeknisiDashboardTab extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;
  final Function(Map<String, dynamic> ticket)? onOpenTicket;

  const TeknisiDashboardTab({
    super.key,
    this.onNavigateTab,
    this.onOpenTicket,
  });

  @override
  State<TeknisiDashboardTab> createState() => _TeknisiDashboardTabState();
}

class _TeknisiDashboardTabState extends State<TeknisiDashboardTab> {
  bool _isLoading = true;
  bool _hasCheckedInToday = false;
  Map<String, dynamic>? _rewardData;
  String _teknisiName = 'Teknisi Lapangan';
  String _teknisiZone = 'Semua Zona';

  int _activeTicketCount = 0;
  int _pendingInstallCount = 0;
  int _completedTodayCount = 0;
  List<Map<String, dynamic>> _priorityTickets = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _checkCheckInStatus(),
      _loadMetricsAndTickets(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkCheckInStatus() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return;

      final hasCheckedIn = await FirebaseService.instance.hasCheckedInToday(userId);
      final rewards = await FirebaseService.instance.getRewardsByTeknisiId(userId);

      if (mounted) {
        setState(() {
          _hasCheckedInToday = hasCheckedIn;
          _rewardData = rewards.isNotEmpty ? rewards.first : null;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadMetricsAndTickets() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      final email = currentUser?.email ?? 'teknisi@audiranet.com';
      final user = await FirebaseService.instance.getUserByEmail(email);

      final String? zone = user?['zone'] as String?;
      final String? name = user?['name'] as String? ?? currentUser?.name;

      final allTickets = zone != null
          ? await FirebaseService.instance.getTicketsByZone(zone)
          : await FirebaseService.instance.getAllTickets();

      final installStats = await FirebaseService.instance.getInstallationStats();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final activeTickets = allTickets.where((t) {
        final status = (t['status'] ?? '').toString().toLowerCase();
        return status == 'open' || status == 'in_progress' || status == 'assigned';
      }).toList();

      final completedToday = allTickets.where((t) {
        final status = (t['status'] ?? '').toString().toLowerCase();
        final resolvedAt = t['resolvedAt']?.toString() ?? '';
        return status == 'resolved' && resolvedAt.startsWith(todayStr);
      }).length;

      // Urutkan tiket aktif: Critical/High paling atas
      activeTickets.sort((a, b) {
        final pA = (a['priority'] ?? '').toString().toLowerCase();
        final pB = (b['priority'] ?? '').toString().toLowerCase();
        int score(String p) => (p == 'critical' || p == 'high') ? 2 : (p == 'medium' ? 1 : 0);
        return score(pB).compareTo(score(pA));
      });

      if (mounted) {
        setState(() {
          if (name != null && name.isNotEmpty) _teknisiName = name;
          if (zone != null && zone.isNotEmpty) _teknisiZone = zone;
          _activeTicketCount = activeTickets.length;
          _pendingInstallCount = installStats['scheduled'] ?? 0;
          _completedTodayCount = completedToday;
          _priorityTickets = activeTickets.take(3).toList();
        });
      }
    } catch (_) {}
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[now.weekday % 7];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg;
    final titleColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.signalBlue),
            )
          : RefreshIndicator(
              onRefresh: _loadAllData,
              color: AppTheme.signalBlue,
              child: CustomScrollView(
                slivers: [
                  // App Bar Bersih & Modern
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    elevation: 0,
                    backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    scrolledUnderElevation: 1,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.signalBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.wifi_tethering_rounded,
                            color: AppTheme.signalBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AUDIRA FIELD OPS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: titleColor,
                              ),
                            ),
                            Text(
                              'Zona: $_teknisiZone',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      const ThemeToggleIconButton(),
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        tooltip: 'Notifikasi',
                        color: titleColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),

                  // Isi Konten Dashboard
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sapaan & Tanggal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Halo, $_teknisiName',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: titleColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatCurrentDate(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: subColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Field Ops Telemetry Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0284C7).withValues(alpha: 0.1)
                                  : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF0284C7).withValues(alpha: 0.3)
                                    : const Color(0xFFBAE6FD),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF10B981),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'FIELD DISPATCH ACTIVE • ZONA: $_teknisiZone • SYNC REALTIME',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 1. Status Duty & Presensi
                          TeknisiDutyCard(
                            hasCheckedIn: _hasCheckedInToday,
                            rewardData: _rewardData,
                            onCheckInSuccess: _loadAllData,
                          ),
                          const SizedBox(height: 16),

                          // 2. Bilah Metrik Fungsional (3 Kolom)
                          TeknisiMetricBar(
                            activeTickets: _activeTicketCount,
                            pendingInstallations: _pendingInstallCount,
                            completedToday: _completedTodayCount,
                            onActiveTicketsTap: () {
                              widget.onNavigateTab?.call(1);
                            },
                            onPendingInstallationsTap: () {
                              widget.onNavigateTab?.call(2);
                            },
                          ),
                          const SizedBox(height: 24),

                          // 3. Header Tugas Prioritas Hari Ini
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tugas Prioritas Hari Ini',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  color: titleColor,
                                ),
                              ),
                              if (_activeTicketCount > 0)
                                TextButton(
                                  onPressed: () => widget.onNavigateTab?.call(1),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(60, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Lihat Semua',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.signalBlue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // List Tiket Prioritas
                          if (_priorityTickets.isEmpty)
                            _buildEmptyTaskState(isDark)
                          else
                            ..._priorityTickets.map(
                              (ticket) => TeknisiTicketItem(
                                ticket: ticket,
                                onTap: () {
                                  widget.onOpenTicket?.call(ticket);
                                },
                              ),
                            ),

                          const SizedBox(height: 20),

                          // 4. Alat Kerja Lapangan (Field Utilities)
                          Text(
                            'Alat Kerja Cepat',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _FieldToolCard(
                                  icon: Icons.qr_code_scanner_rounded,
                                  label: 'Scan Modem',
                                  color: const Color(0xFF0284C7),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const BarcodeScannerPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FieldToolCard(
                                  icon: Icons.map_outlined,
                                  label: 'Peta Lokasi',
                                  color: const Color(0xFF059669),
                                  onTap: () async {
                                    final installations = await FirebaseService.instance.getAllInstallations();
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => InstallationMapView(installations: installations),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _FieldToolCard(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Jadwal Dinas',
                                  color: const Color(0xFF6366F1),
                                  onTap: () {
                                    Navigator.pushNamed(context, Routes.jadwalTeknisi);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FieldToolCard(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'Stok Alat & ODP',
                                  color: const Color(0xFFD97706),
                                  onTap: () {
                                    Navigator.pushNamed(context, Routes.inventoryManagement);
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyTaskState(bool isDark) {
    final bg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final border = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF10B981),
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Semua Tiket Bersih!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tidak ada tiket gangguan tertunda di zona Anda.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FieldToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FieldToolCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final border = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textCol = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textCol,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
