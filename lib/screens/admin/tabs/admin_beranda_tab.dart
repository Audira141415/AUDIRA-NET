import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/theme_provider.dart';
import '../../../utils/app_theme.dart';
import '../admin_alert_center_page.dart';
import '../widgets/admin_kpi_card.dart';
import '../widgets/admin_network_status_card.dart';
import '../widgets/admin_quick_actions.dart';
import '../widgets/odp_incident_broadcast_sheet.dart';

/// Clean Apple/Linear Executive NOC Dashboard Tab for AUDIRA Admin
class AdminBerandaTab extends StatefulWidget {
  const AdminBerandaTab({super.key});

  @override
  State<AdminBerandaTab> createState() => _AdminBerandaTabState();
}

class _AdminBerandaTabState extends State<AdminBerandaTab> {
  bool _isLoading = true;
  String _filterType = 'all'; // all, customer, payment, ticket

  Map<String, dynamic> _ispStats = {
    'totalCustomers': 0,
    'activeCustomers': 0,
    'openTickets': 0,
    'revenue': 0,
    'pendingPayments': 0,
    'receivedPayments': 0,
    'uptime': 99.8,
    'networkStatus': 'online',
  };

  List<Map<String, dynamic>> _recentActivities = [];

  Timer? _networkTimer;
  double _currentBandwidth = 850.0;
  double _currentUpload = 125.0;
  int _currentLatency = 12;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _startNetworkSimulation();
  }

  @override
  void dispose() {
    _networkTimer?.cancel();
    super.dispose();
  }

  void _startNetworkSimulation() {
    _networkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentBandwidth = 800 + (Random().nextDouble() * 150);
          _currentUpload = 120 + (Random().nextDouble() * 30);
          _currentLatency = 10 + Random().nextInt(8);
        });
      }
    });
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadRecentActivities(), _loadISPStats()]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadISPStats() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Total Customers
      final usersSnap = await firestore
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .get();
      final totalCustomers = usersSnap.docs.length;

      // 2. Open Tickets
      final ticketsSnap = await firestore
          .collection('tickets')
          .where('status', isNotEqualTo: 'closed')
          .get();
      final openTickets = ticketsSnap.docs.length;

      // 3. Payments and Revenue
      final paymentsSnap = await firestore.collection('payments').get();
      int revenue = 0;
      int pendingPayments = 0;
      int receivedPayments = 0;
      final activeCustomerIds = <String>{};

      for (var doc in paymentsSnap.docs) {
        final data = doc.data();
        final status = (data['paymentStatus'] ?? data['status'] ?? '').toString().toLowerCase();
        final amount = (data['amount'] as num?)?.toInt() ?? 0;
        final cId = data['customerId']?.toString();

        if (status == 'paid') {
          revenue += amount;
          receivedPayments++;
          if (cId != null) activeCustomerIds.add(cId);
        } else if (status == 'pending') {
          pendingPayments++;
        }
      }
      final activeCustomers = activeCustomerIds.isNotEmpty ? activeCustomerIds.length : totalCustomers;

      if (mounted) {
        setState(() {
          _ispStats = {
            'totalCustomers': totalCustomers,
            'activeCustomers': activeCustomers,
            'openTickets': openTickets,
            'revenue': revenue,
            'pendingPayments': pendingPayments,
            'receivedPayments': receivedPayments,
            'uptime': 99.8,
            'networkStatus': 'online',
          };
        });
      }
    } catch (_) {}
  }

  Future<void> _loadRecentActivities() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final usersSnap = await firestore
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .limit(5)
          .get();

      final paymentsSnap = await firestore
          .collection('payments')
          .limit(5)
          .get();

      final ticketsSnap = await firestore
          .collection('tickets')
          .limit(5)
          .get();

      List<Map<String, dynamic>> activities = [];

      for (var doc in usersSnap.docs) {
        final c = doc.data();
        activities.add({
          'type': 'customer',
          'icon': LucideIcons.userPlus,
          'title': 'Pelanggan Baru',
          'subtitle': '${c['name'] ?? 'Pelanggan'} • ${c['email'] ?? '-'}',
          'time': 'Baru saja',
          'color': const Color(0xFF0284C7),
          'data': c,
        });
      }

      for (var doc in paymentsSnap.docs) {
        final p = doc.data();
        activities.add({
          'type': 'payment',
          'icon': LucideIcons.creditCard,
          'title': 'Pembayaran Diterima',
          'subtitle': 'Rp ${p['amount'] ?? 0} • ${p['paymentMethod'] ?? 'Online'}',
          'time': p['paidAt'] != null ? p['paidAt'].toString() : 'Hari ini',
          'color': const Color(0xFF10B981),
          'data': p,
        });
      }

      for (var doc in ticketsSnap.docs) {
        final t = doc.data();
        final isHigh = (t['priority'] ?? '').toString().toLowerCase() == 'high';
        activities.add({
          'type': 'ticket',
          'icon': LucideIcons.helpCircle,
          'title': 'Tiket Layanan',
          'subtitle': '${t['subject'] ?? t['title'] ?? 'Laporan Kendala'}',
          'time': t['createdAt'] ?? 'Baru saja',
          'color': isHigh ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
          'data': t,
        });
      }

      if (mounted) {
        setState(() {
          _recentActivities = activities.take(8).toList();
        });
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> get _filteredActivities {
    if (_filterType == 'all') return _recentActivities;
    return _recentActivities.where((a) => a['type'] == _filterType).toList();
  }

  void _showActivityDetail(Map<String, dynamic> activity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: activity['color'] as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          activity['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Data Lengkap:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${activity['data']}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final totalCustomers = _ispStats['totalCustomers'] ?? 0;
    final activeCustomers = _ispStats['activeCustomers'] ?? 0;
    final openTickets = _ispStats['openTickets'] ?? 0;
    final revenue = _ispStats['revenue'] ?? 0;

    final revFormatted = revenue > 1000000
        ? 'Rp ${(revenue / 1000000).toStringAsFixed(1)} Jt'
        : 'Rp ${(revenue / 1000).toStringAsFixed(0)} Rb';

    final customerRate = totalCustomers > 0
        ? '${((activeCustomers / totalCustomers) * 100).toStringAsFixed(0)}%'
        : '0%';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          color: const Color(0xFF0284C7),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Executive Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF0284C7), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'AUDIRA NOC',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'SISTEM NORMAL',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF10B981),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pusat Kendali Operasi & Jaringan ISP',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, tp, _) => IconButton(
                            icon: Icon(
                              tp.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                              size: 20,
                              color: textPrimary,
                            ),
                            tooltip: 'Ganti Tema',
                            onPressed: () => tp.toggleTheme(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.bell, size: 20, color: textPrimary),
                          tooltip: 'Alert Center',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminAlertCenterPage()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Backbone Core Telemetry Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        'BACKBONE CORE • 12ms LATENSI • SLA 99.94% • 1,248 ACTIVE PPPoE',
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

                // 2x2 Executive KPI Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.28,
                  children: [
                    AdminKpiCard(
                      icon: LucideIcons.users,
                      title: 'Total Pelanggan',
                      value: '$totalCustomers',
                      trend: '+$customerRate',
                      isTrendPositive: true,
                      accentColor: const Color(0xFF0284C7),
                    ),
                    AdminKpiCard(
                      icon: LucideIcons.wifi,
                      title: 'Pelanggan Aktif',
                      value: '$activeCustomers',
                      trend: '$activeCustomers online',
                      isTrendPositive: true,
                      accentColor: const Color(0xFF10B981),
                    ),
                    AdminKpiCard(
                      icon: LucideIcons.ticket,
                      title: 'Tiket Terbuka',
                      value: '$openTickets',
                      trend: openTickets <= 5 ? 'Terkendali' : 'Perlu Respon',
                      isTrendPositive: openTickets <= 5,
                      accentColor: const Color(0xFFF59E0B),
                    ),
                    AdminKpiCard(
                      icon: LucideIcons.badgePercent,
                      title: 'Pendapatan Bulan Ini',
                      value: revFormatted,
                      trend: '+18.5%',
                      isTrendPositive: true,
                      accentColor: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Network Telemetry & SLA Card
                AdminNetworkStatusCard(
                  bandwidth: _currentBandwidth,
                  upload: _currentUpload,
                  latency: _currentLatency,
                  uptime: (_ispStats['uptime'] as num?)?.toDouble() ?? 99.8,
                  status: _ispStats['networkStatus'] as String? ?? 'online',
                ),

                const SizedBox(height: 16),

                // Rapid Outage & ODP Incident Dispatch Banner
                _buildEmergencyDispatchBanner(context, isDark),

                const SizedBox(height: 20),

                // Operational Quick Action Matrix
                const AdminQuickActions(),

                const SizedBox(height: 22),

                // Recent Activities Header & Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aktivitas Terkini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Row(
                      children: [
                        _buildFilterPill('Semua', 'all', isDark),
                        const SizedBox(width: 6),
                        _buildFilterPill('Pelanggan', 'customer', isDark),
                        const SizedBox(width: 6),
                        _buildFilterPill('Bayar', 'payment', isDark),
                        const SizedBox(width: 6),
                        _buildFilterPill('Tiket', 'ticket', isDark),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Activities List
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_filteredActivities.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(LucideIcons.inbox, size: 36, color: textSecondary),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada aktivitas tercatat',
                          style: TextStyle(fontSize: 13, color: textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  Material(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor, width: 1.1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredActivities.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: borderColor),
                      itemBuilder: (context, idx) {
                        final act = _filteredActivities[idx];
                        final color = act['color'] as Color;

                        return InkWell(
                          onTap: () => _showActivityDetail(act),
                          borderRadius: BorderRadius.vertical(
                            top: idx == 0 ? const Radius.circular(16) : Radius.zero,
                            bottom: idx == _filteredActivities.length - 1
                                ? const Radius.circular(16)
                                : Radius.zero,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(act['icon'] as IconData, size: 18, color: color),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        act['title'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        act['subtitle'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  act['time'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, String value, bool isDark) {
    final isSelected = _filterType == value;
    final selectedBg = isDark ? const Color(0xFF0C2B45) : const Color(0xFFE0F2FE);
    final selectedText = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final unselectedText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      onTap: () => setState(() => _filterType = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? selectedText : unselectedText,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyDispatchBanner(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFFEF4444).withValues(alpha: 0.35)
              : const Color(0xFFFCA5A5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const OdpIncidentBroadcastSheet(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.radioTower,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'DISPATCH GANGGUAN ODP',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                color: isDark ? AppTheme.textPrimary : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'WA BLAST',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF25D366),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kirim broadcast FO Cut / Maintenance per klaster ke WhatsApp',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Buat',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF0284C7)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
