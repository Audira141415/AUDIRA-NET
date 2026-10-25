import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../utils/logger.dart';
import '../../utils/theme_provider.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';
import '../../config/routes.dart';
import '../../widgets/dialogs.dart';
import '../../utils/constants.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/map_picker.dart';
import '../../widgets/enhanced_ui_components.dart';
import 'admin_teknisi_page.dart';
import 'admin_pelanggan_page.dart';
import 'admin_tiket_page_new.dart';
import 'admin_alert_center_page.dart';
import 'admin_broadcast_page.dart';
import 'admin_package_requests_page.dart';
import 'admin_reporting_page.dart';
import 'customer_detail_page.dart';
import '../notifications_page.dart';
import 'audit_logs_page.dart';
import 'backup_status_page.dart';
import 'noc_dashboard_page.dart';
import 'attendance_monitoring_page.dart';
import 'financial_dashboard_page.dart';
import 'employee_management_page.dart';
import 'payroll_page.dart';
import 'mikrotik_manager_page.dart';
import 'modem_manager_page.dart';
import 'modem_monitor_page.dart';

// Dashboard Admin Modern dengan UI Enhancement
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminBerandaPage(),
    const AdminPelangganPageEnhanced(),
    const AdminPaymentsPage(),
    const AdminTiketPageNew(),
    const AdminInstallasiPage(),
    const AdminTeknisiPage(),
    const AdminProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Kembali ke halaman dashboard jika bukan di dashboard
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        } else {
          showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF080D1E) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF00F0FF).withValues(alpha: 0.25)
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -3),
                    ),
                    const BoxShadow(
                      color: Color(0xFF030712),
                      blurRadius: 24,
                      offset: Offset(0, -1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 68,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                children: [
                  _CompactNavItem(
                    icon: HugeIcons.strokeRoundedDashboardSquare02,
                    label: 'Dashboard',
                    isSelected: _selectedIndex == 0,
                    activeColor: const Color(0xFF00F0FF),
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _CompactNavItem(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    label: 'Pelanggan',
                    isSelected: _selectedIndex == 1,
                    activeColor: const Color(0xFF00FF9D),
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  _CompactNavItem(
                    icon: HugeIcons.strokeRoundedInvoice02,
                    label: 'Transaksi',
                    isSelected: _selectedIndex == 2,
                    activeColor: const Color(0xFFFFB800),
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _CompactNavItem(
                    icon: HugeIcons.strokeRoundedCustomerService,
                    label: 'Tiket',
                    isSelected: _selectedIndex == 3,
                    activeColor: const Color(0xFFFF4869),
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                  _CompactNavItem(
                    icon: HugeIcons.strokeRoundedWrench01,
                    label: 'Instalasi',
                    isSelected: _selectedIndex == 4,
                    activeColor: const Color(0xFF38BDF8),
                    onTap: () => setState(() => _selectedIndex = 4),
                  ),
                  _CompactNavItem(
                    icon: HugeIcons.strokeRoundedCpu,
                    label: 'Teknisi',
                    isSelected: _selectedIndex == 5,
                    activeColor: const Color(0xFFA855F7),
                    onTap: () => setState(() => _selectedIndex = 5),
                  ),
                  _CompactNavItem(
                    icon: HugeIcons.strokeRoundedUser,
                    label: 'Profil',
                    isSelected: _selectedIndex == 6,
                    activeColor: const Color(0xFF00F0FF),
                    onTap: () => setState(() => _selectedIndex = 6),
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

// Halaman Beranda Admin dengan Modern UI
class AdminBerandaPage extends StatefulWidget {
  const AdminBerandaPage({super.key});

  @override
  State<AdminBerandaPage> createState() => _AdminBerandaPageState();
}

class _AdminBerandaPageState extends State<AdminBerandaPage> {
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, customer, payment, ticket, overdue

  // Real-time ISP stats
  Map<String, dynamic> _ispStats = {
    'totalCustomers': 0,
    'activeCustomers': 0,
    'openTickets': 0,
    'revenue': 0,
    'pendingPayments': 0,
    'receivedPayments': 0,
    'bandwidthUsage': 0.0,
    'uptime': 99.8,
    'networkStatus': 'online',
  };

  // Network simulation data
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

  // Simulate real-time network monitoring
  void _startNetworkSimulation() {
    _networkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Simulate bandwidth fluctuation (800-950 Mbps)
          _currentBandwidth = 800 + (Random().nextDouble() * 150);
          // Simulate upload (120-150 Mbps)
          _currentUpload = 120 + (Random().nextDouble() * 30);
          // Simulate latency (10-20 ms)
          _currentLatency = 10 + Random().nextInt(11);
        });
      }
    });
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadRecentActivities(), _loadISPStats()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadISPStats() async {
    try {
      final db = await DatabaseService.instance.database;

      // Get total customers
      final totalCustomersResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE role = ?',
        ['customer'],
      );
      final totalCustomers = totalCustomersResult.first['count'] as int? ?? 0;

      // Get active customers (with recent payments)
      final activeCustomersResult = await db.rawQuery('''
        SELECT COUNT(DISTINCT customerId) as count 
        FROM payments 
        WHERE paymentStatus = 'paid'
      ''');
      final activeCustomers = activeCustomersResult.first['count'] as int? ?? 0;

      // Get open tickets
      final openTicketsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tickets WHERE status != ?',
        ['closed'],
      );
      final openTickets = openTicketsResult.first['count'] as int? ?? 0;

      // Get total revenue this month
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(
        now.year,
        now.month,
        1,
      ).toIso8601String();
      final revenueResult = await db.rawQuery(
        '''
        SELECT SUM(amount) as total 
        FROM payments 
        WHERE paymentStatus = 'paid' 
        AND paidAt >= ?
      ''',
        [firstDayOfMonth],
      );
      final revenue = revenueResult.first['total'] as int? ?? 0;

      // Get pending payments count
      final pendingResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM payments WHERE paymentStatus = ?',
        ['pending'],
      );
      final pendingPayments = pendingResult.first['count'] as int? ?? 0;

      // Get received payments count
      final receivedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM payments WHERE paymentStatus = ?',
        ['paid'],
      );
      final receivedPayments = receivedResult.first['count'] as int? ?? 0;

      // Calculate bandwidth usage (simulated based on active customers)
      final bandwidthUsage = activeCustomers > 0
          ? (activeCustomers / totalCustomers * 100).clamp(0, 100)
          : 0.0;

      setState(() {
        _ispStats = {
          'totalCustomers': totalCustomers,
          'activeCustomers': activeCustomers,
          'openTickets': openTickets,
          'revenue': revenue,
          'pendingPayments': pendingPayments,
          'receivedPayments': receivedPayments,
          'bandwidthUsage': bandwidthUsage,
          'uptime': 99.8,
          'networkStatus': 'online',
        };
      });
    } catch (e) {
      // Error loading stats
    }
  }

  Future<void> _loadRecentActivities() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseService.instance.database;

      // Get recent customers (last 24 hours)
      final customers = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['customer'],
        orderBy: 'id DESC',
        limit: 5,
      );

      // Get recent payments
      final payments = await db.query('payments', orderBy: 'id DESC', limit: 5);

      // Get recent tickets
      final tickets = await db.query(
        'tickets',
        orderBy: 'createdAt DESC',
        limit: 5,
      );

      List<Map<String, dynamic>> activities = [];

      // Add customer activities
      for (var customer in customers) {
        activities.add({
          'type': 'customer',
          'icon': Icons.person_add_rounded,
          'title': 'Pelanggan Baru',
          'subtitle': '${customer['name']} - ${customer['email']}',
          'time': _getTimeAgo(customer['id'] as int),
          'color': Colors.green,
          'data': customer,
        });
      }

      // Add payment activities
      for (var payment in payments) {
        activities.add({
          'type': 'payment',
          'icon': Icons.payments_rounded,
          'title': 'Pembayaran Diterima',
          'subtitle': 'Rp ${payment['amount']} - ${payment['paymentMethod']}',
          'time': payment['paidAt'] ?? 'Baru saja',
          'color': Colors.blue,
          'data': payment,
        });
      }

      // Add ticket activities
      for (var ticket in tickets) {
        final priority = ticket['priority'] as String?;
        activities.add({
          'type': 'ticket',
          'icon': Icons.support_agent_rounded,
          'title': 'Tiket Baru',
          'subtitle': '${ticket['subject']}',
          'time': ticket['createdAt'] ?? 'Baru saja',
          'color': priority == 'high' ? Colors.red : Colors.orange,
          'data': ticket,
        });
      }

      // Sort by most recent
      activities.sort((a, b) => 0); // Keep mixed order

      setState(() {
        _recentActivities = activities.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getTimeAgo(int id) {
    // Simple time calculation based on ID
    if (id > 10) return 'Baru saja';
    if (id > 8) return '10 menit lalu';
    if (id > 5) return '1 jam lalu';
    return '2 jam lalu';
  }

  List<Map<String, dynamic>> get _filteredActivities {
    if (_filterType == 'all') return _recentActivities;
    return _recentActivities.where((a) => a['type'] == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: CustomScrollView(
          slivers: [
            // Modern App Bar dengan gradient
            SliverAppBar(
              backgroundColor: isDark ? const Color(0xFF030712) : Colors.white,
              expandedHeight: 180,
              floating: false,
              pinned: true,
              actions: [
                Consumer<ThemeProvider>(
                  builder: (context, tp, _) => ThemeToggleIconButton(themeProvider: tp),
                ),
                IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                  tooltip: 'Notifikasi Saya',
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_active),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminAlertCenterPage(),
                      ),
                    );
                  },
                  tooltip: 'Alert Center',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAllData,
                  tooltip: 'Refresh Data',
                ),
                IconButton(
                  icon: Icon(
                    _ispStats['networkStatus'] == 'online'
                        ? Icons.wifi
                        : Icons.wifi_off,
                    color: _ispStats['networkStatus'] == 'online'
                        ? const Color(0xFF00FF9D)
                        : Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF080D1E),
                        title: const Text('Status Jaringan', style: TextStyle(color: Colors.white)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${_ispStats['networkStatus'] == 'online' ? 'Online ✓' : 'Offline ✗'}',
                              style: const TextStyle(color: Color(0xFF00FF9D)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bandwidth: ${_currentBandwidth.toStringAsFixed(0)} Mbps',
                              style: const TextStyle(color: Color(0xFF94A3B8)),
                            ),
                            Text(
                              'Upload: ${_currentUpload.toStringAsFixed(0)} Mbps',
                              style: const TextStyle(color: Color(0xFF94A3B8)),
                            ),
                            Text(
                              'Latency: $_currentLatency ms',
                              style: const TextStyle(color: Color(0xFF94A3B8)),
                            ),
                            Text(
                              'Uptime: ${_ispStats['uptime']}%',
                              style: const TextStyle(color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK', style: TextStyle(color: Color(0xFF00F0FF))),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AUDIRA NOC',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 16,
                        color: Color(0xFF00F0FF),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '// CORE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0A1128),
                        Color(0xFF060D20),
                        Color(0xFF030712),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated background pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: CustomPaint(painter: _GridPainter()),
                        ),
                      ),
                      // Glassmorphism effect
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00F0FF).withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats dengan Glassmorphism
                    _buildQuickStats(),
                    const SizedBox(height: 24),

                    // Chart Section
                    _buildChartSection(),
                    const SizedBox(height: 24),

                    // Network Health Monitor (ISP Feature)
                    _buildNetworkHealthMonitor(),
                    const SizedBox(height: 24),

                    // ISP Quick Actions
                    _buildISPQuickActions(),
                    const SizedBox(height: 24),

                    // Revenue Analytics (ISP Feature)
                    _buildRevenueAnalytics(),
                    const SizedBox(height: 24),

                    // Alerts & Notifications (ISP Feature)
                    _buildAlertsSection(),
                    const SizedBox(height: 24),

                    // Aktivitas Terkini dengan modern design
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aktivitas Terkini // LOGS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Colors.white,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.filter_list, size: 20),
                          onSelected: (value) {
                            setState(() => _filterType = value);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'all',
                              child: Row(
                                children: [
                                  Icon(Icons.list, size: 18),
                                  SizedBox(width: 8),
                                  Text('Semua'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'customer',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_add,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Pelanggan'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'payment',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Pembayaran'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'ticket',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.support_agent,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Tiket'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Loading or Activities List
                    if (_isLoading)
                      const EnhancedLoadingIndicator(
                        type: LoadingType.pulse,
                        message: 'Memuat Aktivitas Jaringan',
                      )
                    else if (_filteredActivities.isEmpty)
                      const EnhancedEmptyState(
                        icon: Icons.inbox_outlined,
                        title: 'Tidak Ada Aktivitas',
                        description:
                            'Belum ada aktivitas jaringan yang tercatat. Aktivitas akan muncul di sini.',
                        actionLabel: 'Refresh',
                      )
                    else
                      ..._filteredActivities.map((activity) {
                        final color = activity['color'] as Color;
                        return _ModernActivityTile(
                          icon: activity['icon'] as IconData,
                          title: activity['title'] as String,
                          subtitle: activity['subtitle'] as String,
                          time: activity['time'] as String,
                          color: color,
                          gradient: LinearGradient(
                            colors: [color.withValues(alpha: 0.8), color],
                          ),
                          onTap: () => _showActivityDetail(context, activity),
                        );
                      }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ISP Feature: Network Health Monitor
  Widget _buildNetworkHealthMonitor() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF080D1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.3),
                  ),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedRouter01,
                  color: Color(0xFF00F0FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Jaringan // NOC CORE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Real-time ISP telemetry monitoring',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FF9D).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00FF9D),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00FF9D),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ONLINE',
                      style: TextStyle(
                        color: Color(0xFF00FF9D),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _NetworkMetricCard(
                  icon: Icons.speed,
                  label: 'BANDWIDTH',
                  value: '${_currentBandwidth.toStringAsFixed(0)} Mbps',
                  color: _currentBandwidth > 900
                      ? const Color(0xFFFF4869)
                      : const Color(0xFF00F0FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NetworkMetricCard(
                  icon: Icons.cloud_upload,
                  label: 'UPLOAD',
                  value: '${_currentUpload.toStringAsFixed(0)} Mbps',
                  color: const Color(0xFFFFB800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NetworkMetricCard(
                  icon: Icons.wifi_tethering,
                  label: 'LATENCY',
                  value: '$_currentLatency ms',
                  color: _currentLatency < 15
                      ? const Color(0xFF00FF9D)
                      : const Color(0xFFFFB800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NetworkMetricCard(
                  icon: Icons.trending_up,
                  label: 'UPTIME',
                  value: '${_ispStats['uptime'] ?? 99.8}%',
                  color: const Color(0xFFA855F7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ISP Feature: Quick Actions
  Widget _buildISPQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat // NOC TOOLS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.notifications_active,
                label: 'Alert Center',
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminAlertCenterPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.data_object,
                label: 'Mock Data',
                color: Colors.indigo,
                onTap: () {
                  _showMockDataDialog();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.dashboard_customize,
                label: 'NOC Dashboard',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NOCDashboardPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.settings_input_antenna,
                label: 'Troubleshoot',
                color: Colors.blue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Memulai troubleshoot jaringan...'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.router,
                label: 'MikroTik Manager',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MikroTikManagerPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.devices,
                label: 'Modem Manager',
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModemManagerPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.live_tv,
                label: 'Modem Monitor',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModemLiveMonitorPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.analytics,
                label: 'Financial Dashboard',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FinancialDashboardPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.people_alt,
                label: 'Attendance',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceMonitoringPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.analytics,
                label: 'Billing Analytics',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminAlertCenterPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.campaign,
                label: 'Broadcast',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminBroadcastPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.settings_input_antenna,
                label: 'Troubleshoot',
                color: Colors.blue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Memulai troubleshoot jaringan...'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.bar_chart,
                label: 'Advanced Reports',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminReportingPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.sync_alt,
                label: 'Package Requests',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPackageRequestsPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.build_circle,
                label: 'Maintenance',
                color: Colors.red,
                onTap: () {
                  _showMaintenanceDialog();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ISP Feature: Revenue Analytics
  Widget _buildRevenueAnalytics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF080D1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB800).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB800).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pendapatan Bulan Ini // BILLING',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Billing Cycle Realtime',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FF9D).withValues(alpha: 0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 14,
                      color: Color(0xFF00FF9D),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+18.5%',
                      style: TextStyle(
                        color: Color(0xFF00FF9D),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Rp ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Color(0xFFFFB800),
                ),
              ),
              Text(
                (_ispStats['revenue'] ?? 0).toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]}.',
                ),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Color(0xFF00FF9D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _RevenueMetricCard(
                  label: 'DITERIMA',
                  value: (_ispStats['receivedPayments'] ?? 0).toString(),
                  icon: Icons.check_circle,
                  color: const Color(0xFF00FF9D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RevenueMetricCard(
                  label: 'PENDING',
                  value: (_ispStats['pendingPayments'] ?? 0).toString(),
                  icon: Icons.pending,
                  color: const Color(0xFFFFB800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ISP Feature: Alerts & Notifications
  Widget _buildAlertsSection() {
    final pendingPayments = _ispStats['pendingPayments'] ?? 0;
    final bandwidthUsage = _ispStats['bandwidthUsage'] ?? 0.0;
    final openTickets = _ispStats['openTickets'] ?? 0;

    final alerts = [
      if (pendingPayments > 0)
        {
          'icon': Icons.warning_amber_rounded,
          'title': 'Pembayaran Tertunda',
          'subtitle': '$pendingPayments pelanggan belum melakukan pembayaran',
          'color': Colors.orange,
          'count': pendingPayments.toString(),
          'onTap': () {
            // Navigate to payments page with filter
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$pendingPayments pembayaran tertunda')),
            );
          },
        },
      if (openTickets > 5)
        {
          'icon': Icons.support_agent,
          'title': 'Tiket Perlu Perhatian',
          'subtitle': '$openTickets tiket support masih terbuka',
          'color': Colors.red,
          'count': openTickets.toString(),
          'onTap': () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$openTickets tiket terbuka')),
            );
          },
        },
      if (bandwidthUsage > 80)
        {
          'icon': Icons.speed,
          'title': 'Bandwidth Tinggi',
          'subtitle':
              'Penggunaan bandwidth mencapai ${bandwidthUsage.toStringAsFixed(1)}%',
          'color': Colors.blue,
          'count': '!',
          'onTap': () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Monitoring bandwidth aktif')),
            );
          },
        },
      if (_currentBandwidth > 920)
        {
          'icon': Icons.network_check,
          'title': 'Bandwidth Mendekati Limit',
          'subtitle':
              'Current: ${_currentBandwidth.toStringAsFixed(0)} Mbps (Max: 1000 Mbps)',
          'color': Colors.red,
          'count': '!',
          'onTap': () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pertimbangkan upgrade kapasitas'),
                backgroundColor: Colors.red,
              ),
            );
          },
        },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alert & Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (alerts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Semua sistem berjalan normal! 🎉',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...alerts.map(
            (alert) => _AlertCard(
              icon: alert['icon'] as IconData,
              title: alert['title'] as String,
              subtitle: alert['subtitle'] as String,
              color: alert['color'] as Color,
              count: alert['count'] as String,
              onTap: alert['onTap'] as VoidCallback?,
            ),
          ),
      ],
    );
  }

  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.build_circle, color: Colors.red),
            SizedBox(width: 8),
            Text('Mode Maintenance'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aktifkan mode maintenance untuk:'),
            const SizedBox(height: 12),
            const Text('• Notifikasi gangguan ke pelanggan'),
            const Text('• Suspend layanan sementara'),
            const Text('• Update sistem'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Estimasi Waktu (menit)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mode maintenance diaktifkan'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Aktifkan'),
          ),
        ],
      ),
    );
  }

  void _showMockDataDialog() async {
    // Get current data count
    final counts = await DatabaseService.instance.getMockDataCount();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.data_object, color: Colors.purple),
            SizedBox(width: 8),
            Text('Generate Mock Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate data dummy untuk testing dashboard ISP:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Data saat ini:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('👥 Pelanggan:'),
                      Text(
                        '${counts['customers']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('💰 Pembayaran:'),
                      Text(
                        '${counts['payments']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🎫 Tiket:'),
                      Text(
                        '${counts['tickets']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data yang akan di-generate:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('✓ 50 Pelanggan dengan profil lengkap'),
                  Text('✓ 150+ Transaksi pembayaran (3 bulan)'),
                  Text('✓ 20 Tiket support dengan berbagai status'),
                  Text('✓ Data billing dan tagihan otomatis'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Proses ini akan menambahkan data baru ke database',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (counts['customers']! > 0)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                _showClearDataConfirmation();
              },
              child: const Text(
                'Hapus Data',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              _generateMockData();
            },
            icon: const Icon(Icons.add),
            label: const Text('Generate'),
            style: FilledButton.styleFrom(backgroundColor: Colors.purple),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus Data'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus semua data pelanggan dan pembayaran?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Data yang akan dihapus:'),
            Text('• Semua pelanggan'),
            Text('• Semua pembayaran'),
            Text('• Semua tiket'),
            Text('• Semua tagihan'),
            SizedBox(height: 12),
            Text(
              '⚠️ Tindakan ini tidak dapat dibatalkan!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearMockData();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateMockData() async {
    Logger.debug('📋 Starting mock data generation...');

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating mock data...'),
                Text('Mohon tunggu', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      Logger.debug('📝 Generating customers...');
      // Generate customers with payments
      await DatabaseService.instance.generateMockCustomers(count: 50);

      Logger.debug('🎫 Generating tickets...');
      // Generate tickets
      await DatabaseService.instance.generateMockTickets(count: 20);

      Logger.debug('🔄 Reloading data...');
      // Reload all data
      await _loadAllData();

      // Get updated count
      final newCounts = await DatabaseService.instance.getMockDataCount();
      Logger.debug(
        '📊 New counts - Customers: ${newCounts['customers']}, Payments: ${newCounts['payments']}, Tickets: ${newCounts['tickets']}',
      );

      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      Logger.debug('✅ Mock data generation complete!');

      // Show success with details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Mock data berhasil! Pelanggan: ${newCounts['customers']}, '
            'Pembayaran: ${newCounts['payments']}, Tiket: ${newCounts['tickets']}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      Logger.error('❌ Error generating mock data', e);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _clearMockData() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menghapus data...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await DatabaseService.instance.clearMockData();
      await _loadAllData();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Semua data berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showActivityDetail(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                activity['title'] as String,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity['subtitle'] as String,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  activity['time'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (activity['type'] == 'ticket')
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to ticket detail
              },
              child: const Text('Lihat Tiket'),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalCustomers = _ispStats['totalCustomers'] ?? 0;
    final activeCustomers = _ispStats['activeCustomers'] ?? 0;
    final openTickets = _ispStats['openTickets'] ?? 0;
    final revenue = _ispStats['revenue'] ?? 0;

    // Calculate trends (simplified)
    final customerTrend = totalCustomers > 0
        ? ((activeCustomers / totalCustomers) * 100).toStringAsFixed(1)
        : '0';
    final ticketTrend = openTickets > 5
        ? '-${(openTickets - 5)}'
        : '+${5 - openTickets}';
    final revenueTrend = revenue > 45000000
        ? '+${((revenue - 45000000) / 45000000 * 100).toStringAsFixed(1)}%'
        : '0%';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _GlassStatCard(
          icon: Icons.people_rounded,
          title: 'Total Pelanggan',
          value: totalCustomers.toString(),
          trend: '+$customerTrend%',
          trendUp: true,
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
        ),
        _GlassStatCard(
          icon: Icons.signal_wifi_4_bar_rounded,
          title: 'Aktif',
          value: activeCustomers.toString(),
          trend:
              '+${(activeCustomers / (totalCustomers > 0 ? totalCustomers : 1) * 100).toStringAsFixed(0)}%',
          trendUp: true,
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
        ),
        _GlassStatCard(
          icon: Icons.support_agent_rounded,
          title: 'Tiket Terbuka',
          value: openTickets.toString(),
          trend: ticketTrend,
          trendUp: openTickets <= 5,
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
          ),
        ),
        _GlassStatCard(
          icon: Icons.attach_money_rounded,
          title: 'Pendapatan',
          value: revenue > 1000000
              ? '${(revenue / 1000000).toStringAsFixed(1)} Jt'
              : '${(revenue / 1000).toStringAsFixed(0)} Rb',
          trend: revenueTrend,
          trendUp: revenue > 45000000,
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF080D1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktivitas Jaringan // TRAFFIC',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '7 hari terakhir (Gbps)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00FF9D).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Color(0xFF00FF9D),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '99.8% SLA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Color(0xFF00FF9D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildChartBar(0.6, 'Sen'),
                  _buildChartBar(0.8, 'Sel'),
                  _buildChartBar(0.7, 'Rab'),
                  _buildChartBar(0.9, 'Kam'),
                  _buildChartBar(1.0, 'Jum'),
                  _buildChartBar(0.85, 'Sab'),
                  _buildChartBar(0.75, 'Min'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(double height, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: FractionallySizedBox(
              heightFactor: height,
              child: Container(
                width: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF0070F3), Color(0xFF00F0FF)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Cyber Obsidian Stat Card
class _GlassStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String trend;
  final bool trendUp;
  final Gradient gradient;

  const _GlassStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = gradient.colors.first;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080D1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(icon, color: themeColor, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (trendUp ? const Color(0xFF00FF9D) : const Color(0xFFFF4869))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (trendUp ? const Color(0xFF00FF9D) : const Color(0xFFFF4869))
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 9,
                        color: trendUp ? const Color(0xFF00FF9D) : const Color(0xFFFF4869),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: TextStyle(
                          color: trendUp ? const Color(0xFF00FF9D) : const Color(0xFFFF4869),
                          fontSize: 10,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Activity Tile
class _ModernActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _ModernActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF080D1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF64748B)),
                    ),
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

// Custom Painter untuk background pattern
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ISP Widget: Network Metric Card
class _NetworkMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _NetworkMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF050B18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ISP Widget: Quick Action Card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.8), color],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ISP Widget: Revenue Metric Card
class _RevenueMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _RevenueMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF050B18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

// ISP Widget: Alert Card
class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String count;
  final VoidCallback? onTap;

  const _AlertCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF080D1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Stack(
                    children: [
                      Center(child: Icon(icon, color: color, size: 24)),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Halaman Pelanggan, Tiket, Profil (copy dari file lama)
class AdminPelangganPage extends StatefulWidget {
  const AdminPelangganPage({super.key});

  @override
  State<AdminPelangganPage> createState() => _AdminPelangganPageState();
}

class _AdminPelangganPageState extends State<AdminPelangganPage> {
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseService.instance.database;
      final result = await db.rawQuery('''
        SELECT 
          c.*,
          u.name,
          u.email,
          u.phone,
          (SELECT COUNT(*) FROM bills WHERE customerId = c.id AND status = 'unpaid') as unpaidBills,
          (SELECT COUNT(*) FROM tickets WHERE customerId = c.id AND status != 'closed') as openTickets
        FROM customers c
        JOIN users u ON c.userId = u.id
        ORDER BY c.id DESC
      ''');

      setState(() {
        _customers = result;
        _isLoading = false;
      });

      Logger.debug('📋 Loaded ${_customers.length} customers');
    } catch (e) {
      Logger.error('❌ Error loading customers', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const EnhancedLoadingIndicator(
              type: LoadingType.circular,
              message: 'Memuat Data Pelanggan',
            )
          : _customers.isEmpty
          ? const EnhancedEmptyState(
              icon: Icons.people_outline,
              title: 'Belum Ada Pelanggan',
              description:
                  'Belum ada pelanggan yang terdaftar. Tambahkan pelanggan baru untuk memulai.',
              actionLabel: 'Tambah Pelanggan',
            )
          : RefreshIndicator(
              onRefresh: _loadCustomers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  final unpaidBills = customer['unpaidBills'] as int? ?? 0;
                  final openTickets = customer['openTickets'] as int? ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          (customer['name'] as String? ?? 'U')[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        customer['name'] as String? ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('📱 ${customer['phone'] ?? '-'}'),
                          Text('📦 ${customer['packageName'] ?? '-'}'),
                          Text(
                            '💰 Rp ${(customer['price'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          ),
                          if (unpaidBills > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '⚠️ $unpaidBills tagihan belum bayar',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ),
                          if (openTickets > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '🎫 $openTickets tiket terbuka',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CustomerDetailPage(customer: customer),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Pelanggan'),
      ),
    );
  }
}

class AdminTiketPage extends StatelessWidget {
  const AdminTiketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tiket Dukungan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Terbuka'),
              Tab(text: 'Proses'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Tiket Terbuka')),
            Center(child: Text('Tiket Dalam Proses')),
            Center(child: Text('Tiket Selesai')),
          ],
        ),
      ),
    );
  }
}

// Halaman Instalasi Admin
class AdminInstallasiPage extends StatefulWidget {
  const AdminInstallasiPage({super.key});

  @override
  State<AdminInstallasiPage> createState() => _AdminInstallasiPageState();
}

class _AdminInstallasiPageState extends State<AdminInstallasiPage> {
  List<Map<String, dynamic>> _installations = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadInstallations();
  }

  Future<void> _loadInstallations() async {
    setState(() => _isLoading = true);
    try {
      final installations = await DatabaseService.instance
          .getAllInstallations();
      setState(() {
        if (_filterStatus == 'all') {
          _installations = installations;
        } else {
          _installations = installations
              .where((i) => i['status'] == _filterStatus)
              .toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      // Error loading installations
      setState(() => _isLoading = false);
    }
  }

  void _showAddInstallationDialog() {
    final formKey = GlobalKey<FormState>();
    String customerName = '';
    String phone = '';
    String address = '';
    String packageName = 'Basic';
    int speed = 30;
    int price = 250000;
    DateTime scheduledDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay scheduledTime = const TimeOfDay(hour: 9, minute: 0);
    double? selectedLat;
    double? selectedLng;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Instalasi Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Nama harus diisi' : null,
                    onSaved: (v) => customerName = v!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Telepon harus diisi' : null,
                    onSaved: (v) => phone = v!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Alamat Instalasi',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Alamat harus diisi' : null,
                    onSaved: (v) => address = v!,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.map),
                    title: Text(
                      selectedLat != null && selectedLng != null
                          ? 'Lokasi: ${selectedLat!.toStringAsFixed(4)}, ${selectedLng!.toStringAsFixed(4)}'
                          : 'Pilih lokasi di peta',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPicker(
                            initialPosition:
                                selectedLat != null && selectedLng != null
                                ? LatLng(selectedLat!, selectedLng!)
                                : null,
                            onLocationPicked: (location) {
                              setDialogState(() {
                                selectedLat = location.latitude;
                                selectedLng = location.longitude;
                              });
                            },
                          ),
                        ),
                      );
                      if (result != null) {
                        setDialogState(() {
                          selectedLat = result.latitude;
                          selectedLng = result.longitude;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: packageName,
                    decoration: const InputDecoration(
                      labelText: 'Paket Internet',
                      prefixIcon: Icon(Icons.wifi),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Basic',
                        child: Text('Basic - 30 Mbps'),
                      ),
                      DropdownMenuItem(
                        value: 'Standard',
                        child: Text('Standard - 50 Mbps'),
                      ),
                      DropdownMenuItem(
                        value: 'Premium',
                        child: Text('Premium - 100 Mbps'),
                      ),
                    ],
                    onChanged: (value) {
                      packageName = value!;
                      if (value == 'Basic') {
                        speed = 30;
                        price = 250000;
                      } else if (value == 'Standard') {
                        speed = 50;
                        price = 350000;
                      } else {
                        speed = 100;
                        price = 500000;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      'Tanggal: ${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: scheduledDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null) {
                        setDialogState(() => scheduledDate = date);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      'Waktu: ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: scheduledTime,
                      );
                      if (time != null) {
                        setDialogState(() => scheduledTime = time);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  try {
                    await DatabaseService.instance.createInstallation({
                      'customer_name': customerName,
                      'phone': phone,
                      'address': address,
                      'package_name': packageName,
                      'speed': speed,
                      'price': price,
                      'scheduled_date':
                          '${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}',
                      'scheduled_time':
                          '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
                      'notes': '',
                      'latitude': selectedLat,
                      'longitude': selectedLng,
                      'status': 'scheduled',
                    });

                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Instalasi berhasil ditambahkan'),
                        ),
                      );
                      _loadInstallations();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteInstallation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Instalasi?'),
        content: const Text('Data instalasi akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseService.instance.deleteInstallation(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Instalasi berhasil dihapus')),
          );
          _loadInstallations();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
      appBar: AppBar(
        title: Text(
          'Kelola Instalasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF080D1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, tp, _) => ThemeToggleIconButton(themeProvider: tp),
          ),
          PopupMenuButton<String>(
            initialValue: _filterStatus,
            onSelected: (value) {
              setState(() => _filterStatus = value);
              _loadInstallations();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'scheduled', child: Text('Terjadwal')),
              const PopupMenuItem(
                value: 'in_progress',
                child: Text('Sedang Proses'),
              ),
              const PopupMenuItem(value: 'completed', child: Text('Selesai')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInstallations,
              child: _installations.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF080D1E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.build_circle_outlined,
                                size: 64,
                                color: isDark ? const Color(0xFF00F0FF) : Colors.indigo,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum Ada Jadwal Instalasi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap tombol + untuk menjadwalkan instalasi baru',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _installations.length,
                      itemBuilder: (context, index) {
                        final installation = _installations[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF080D1E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor:
                                  installation['status'] == 'completed'
                                  ? Colors.green
                                  : installation['status'] == 'in_progress'
                                  ? Colors.orange
                                  : Colors.blue,
                              child: Icon(
                                installation['status'] == 'completed'
                                    ? Icons.check
                                    : installation['status'] == 'in_progress'
                                    ? Icons.build
                                    : Icons.schedule,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              installation['customerName'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${installation['packageName']} - ${installation['speed']} Mbps',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '${installation['scheduledDate']} ${installation['scheduledTime']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF64748B) : Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  installation['phone'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF64748B) : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'detail',
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline),
                                      SizedBox(width: 8),
                                      Text('Detail'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteInstallation(installation['id']);
                                } else if (value == 'detail') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Detail Instalasi'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _detailRow(
                                            'Nama',
                                            installation['customerName'],
                                          ),
                                          _detailRow(
                                            'Telepon',
                                            installation['phone'],
                                          ),
                                          _detailRow(
                                            'Alamat',
                                            installation['address'],
                                          ),
                                          _detailRow(
                                            'Paket',
                                            '${installation['packageName']} - ${installation['speed']} Mbps',
                                          ),
                                          _detailRow(
                                            'Harga',
                                            'Rp ${installation['price']}',
                                          ),
                                          _detailRow(
                                            'Jadwal',
                                            '${installation['scheduledDate']} ${installation['scheduledTime']}',
                                          ),
                                          _detailRow(
                                            'Status',
                                            installation['status'],
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Tutup'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddInstallationDialog,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Instalasi'),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class AdminProfilPage extends StatefulWidget {
  const AdminProfilPage({super.key});

  @override
  State<AdminProfilPage> createState() => _AdminProfilPageState();
}

class _AdminProfilPageState extends State<AdminProfilPage> {
  Map<String, int> _stats = {'customers': 0, 'payments': 0, 'technicians': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final db = await DatabaseService.instance.database;

      final customerResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE role = ?',
        ['customer'],
      );
      final customerCount = customerResult.first['count'] as int? ?? 0;

      final paymentResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM payments',
      );
      final paymentCount = paymentResult.first['count'] as int? ?? 0;

      final technicianResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE role = ?',
        ['teknisi'],
      );
      final technicianCount = technicianResult.first['count'] as int? ?? 0;

      setState(() {
        _stats = {
          'customers': customerCount,
          'payments': paymentCount,
          'technicians': technicianCount,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: const Text('Fitur edit profil akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ganti Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password berhasil diubah')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
      body: CustomScrollView(
        slivers: [
          // Header dengan gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF080D1E) : AppTheme.primaryCyan,
            actions: [
              Consumer<ThemeProvider>(
                builder: (context, tp, _) => ThemeToggleIconButton(themeProvider: tp),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF080D1E),
                            Color(0xFF0F172A),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryCyan,
                            AppTheme.primaryCyan.withValues(alpha: 0.7),
                          ],
                        ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF00F0FF) : Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? const Color(0xFF00F0FF).withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 44,
                            color: isDark ? const Color(0xFF00F0FF) : AppTheme.primaryCyan,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        AppConstants.adminName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0x3300F0FF)
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: isDark
                              ? Border.all(color: const Color(0x6600F0FF))
                              : null,
                        ),
                        child: Text(
                          'Administrator',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF00F0FF) : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Statistik Admin
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF080D1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistik Sistem',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _StatItemCard(
                              icon: Icons.people,
                              label: 'Pelanggan',
                              value: '${_stats['customers']}',
                              color: Colors.blue,
                            ),
                            _StatItemCard(
                              icon: Icons.payments,
                              label: 'Transaksi',
                              value: '${_stats['payments']}',
                              color: Colors.green,
                            ),
                            _StatItemCard(
                              icon: Icons.engineering,
                              label: 'Teknisi',
                              value: '${_stats['technicians']}',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Tema & Tampilan Section
                _ProfileSection(
                  title: 'Tampilan & Tema',
                  children: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            'Mode Tampilan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                            ),
                          ),
                          subtitle: Text(
                            isDark
                                ? 'Tema Aktif: Dark Cyber Midnight'
                                : 'Tema Aktif: Clean High-Contrast Light',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                            ),
                          ),
                          trailing: Switch(
                            value: isDark,
                            activeThumbColor: const Color(0xFF00F0FF),
                            onChanged: (value) => themeProvider.toggleTheme(context),
                          ),
                          onTap: () => themeProvider.toggleTheme(context),
                        );
                      },
                    ),
                  ],
                ),

                // Info Akun
                _ProfileSection(
                  title: 'Informasi Akun',
                  children: [
                    _InfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: AppConstants.adminEmail,
                    ),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Telepon',
                      subtitle: AppConstants.csCallCenter,
                    ),
                    _InfoTile(
                      icon: Icons.calendar_today_outlined,
                      title: 'Bergabung',
                      subtitle: '1 Januari 2024',
                    ),
                    _InfoTile(
                      icon: Icons.access_time_outlined,
                      title: 'Login Terakhir',
                      subtitle: 'Hari ini, 10:30',
                    ),
                  ],
                ),

                // Quick Actions
                _ProfileSection(
                  title: 'Aksi Cepat',
                  children: [
                    _ActionTile(
                      icon: Icons.badge_outlined,
                      title: 'Employee Management',
                      subtitle: 'Kelola data karyawan (HRM)',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EmployeeManagementPage(),
                          ),
                        );
                      },
                    ),
                    _ActionTile(
                      icon: Icons.payments,
                      title: 'Payroll System',
                      subtitle: 'Proses penggajian karyawan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PayrollPage(),
                          ),
                        );
                      },
                    ),
                    _ActionTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profil',
                      subtitle: 'Ubah informasi profil Anda',
                      onTap: _showEditProfileDialog,
                    ),
                    _ActionTile(
                      icon: Icons.lock_outline,
                      title: 'Ganti Password',
                      subtitle: 'Perbarui password akun',
                      onTap: _showChangePasswordDialog,
                    ),
                    _ActionTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifikasi',
                      subtitle: 'Kelola pengaturan notifikasi',
                      trailing: Switch(value: true, onChanged: (value) {}),
                    ),
                  ],
                ),

                // System Info
                _ProfileSection(
                  title: 'Informasi Sistem',
                  children: [
                    _ActionTile(
                      icon: Icons.history,
                      title: 'Audit Logs',
                      subtitle: 'Lihat riwayat aktivitas sistem',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuditLogsPage(),
                          ),
                        );
                      },
                    ),
                    _ActionTile(
                      icon: Icons.backup,
                      title: 'Status Backup',
                      subtitle: 'Monitor backup database',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BackupStatusPage(),
                          ),
                        );
                      },
                    ),
                    _InfoTile(
                      icon: Icons.info_outline,
                      title: 'Versi Aplikasi',
                      subtitle: '1.0.0',
                    ),
                    _InfoTile(
                      icon: Icons.storage_outlined,
                      title: 'Database',
                      subtitle: 'SQLite - 2.5 MB',
                    ),
                    _InfoTile(
                      icon: Icons.update_outlined,
                      title: 'Update Terakhir',
                      subtitle: '14 November 2024',
                    ),
                  ],
                ),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Keluar dari Akun?'),
                          content: const Text(
                            'Anda akan keluar dari akun administrator.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Routes.unifiedLogin,
                                  (route) => false,
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Keluar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar dari Akun'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk section profil
class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF080D1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

// Widget untuk info tile
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF00F0FF) : AppTheme.primaryCyan)
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDark ? const Color(0xFF00F0FF) : AppTheme.primaryCyan,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
        ),
      ),
    );
  }
}

// Widget untuk action tile
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF00F0FF) : AppTheme.primaryCyan)
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDark ? const Color(0xFF00F0FF) : AppTheme.primaryCyan,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: isDark ? const Color(0xFF64748B) : Colors.grey[400],
          ),
      onTap: onTap,
    );
  }
}

// Widget untuk stat item card
class _StatItemCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItemCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ADMIN PAYMENTS PAGE (with Tabs) ====================
class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _speedTests = [];
  bool _isLoadingPayments = true;
  bool _isLoadingSpeedTests = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPayments();
    _loadSpeedTests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    try {
      final db = await DatabaseService.instance.database;
      final payments = await db.rawQuery('''
        SELECT p.*, b.billMonth, c.customerId, u.name as customerName
        FROM payments p
        JOIN bills b ON p.billId = b.id
        JOIN customers c ON p.customerId = c.id
        JOIN users u ON c.userId = u.id
        ORDER BY p.paidAt DESC
      ''');

      setState(() {
        _payments = payments;
        _isLoadingPayments = false;
      });
    } catch (e) {
      // Error loading payments
      setState(() => _isLoadingPayments = false);
    }
  }

  Future<void> _loadSpeedTests() async {
    try {
      final tests = await DatabaseService.instance.getAllSpeedTests();
      setState(() {
        _speedTests = tests;
        _isLoadingSpeedTests = false;
      });
    } catch (e) {
      // Error loading speed tests
      setState(() => _isLoadingSpeedTests = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
      appBar: AppBar(
        title: Text(
          'Transaksi & Monitoring',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF080D1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
        elevation: 0,
        actions: const [
          ThemeToggleIconButton(),
          SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
          indicatorWeight: 3,
          labelColor: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.grey.shade600,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Pembayaran'),
            Tab(icon: Icon(Icons.network_check), text: 'Speed Test'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Pembayaran
          _isLoadingPayments
              ? Center(
                  child: CircularProgressIndicator(
                    color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                  ),
                )
              : RefreshIndicator(
                  color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                  backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                  onRefresh: _loadPayments,
                  child: _payments.isEmpty
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF080D1E) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF00F0FF).withValues(alpha: 0.2)
                                    : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.4)
                                      : Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF00F0FF).withValues(alpha: 0.1)
                                        : Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    size: 48,
                                    color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada pembayaran',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Riwayat transaksi pelanggan akan dicatat di sini',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _payments.length,
                          itemBuilder: (context, index) {
                            final payment = _payments[index];
                            return _PaymentCard(payment: payment);
                          },
                        ),
                ),
          // Tab Speed Test
          _isLoadingSpeedTests
              ? Center(
                  child: CircularProgressIndicator(
                    color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                  ),
                )
              : RefreshIndicator(
                  color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                  backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                  onRefresh: _loadSpeedTests,
                  child: _speedTests.isEmpty
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF080D1E) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF00F0FF).withValues(alpha: 0.2)
                                    : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.4)
                                      : Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF00F0FF).withValues(alpha: 0.1)
                                        : Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.network_check_rounded,
                                    size: 48,
                                    color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada speed test',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Hasil uji kecepatan jaringan pelanggan akan tampil di sini',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _speedTests.length,
                          itemBuilder: (context, index) {
                            final test = _speedTests[index];
                            return _SpeedTestCard(test: test);
                          },
                        ),
                ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amount = payment['amount'] as int;
    final paidAt = DateTime.parse(payment['paidAt']);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF080D1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDark
                    ? const Color(0xFF00F0FF).withValues(alpha: 0.25)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: isDark ? const Color(0xFF00FF9D) : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detail Pembayaran',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PaymentDetailRow(
                    icon: Icons.confirmation_number,
                    label: 'ID Transaksi',
                    value: payment['transactionId'] ?? '-',
                  ),
                  _PaymentDetailRow(
                    icon: Icons.person,
                    label: 'Pelanggan',
                    value: payment['customerName'] ?? '-',
                  ),
                  _PaymentDetailRow(
                    icon: Icons.badge,
                    label: 'ID Pelanggan',
                    value: payment['customerId'] ?? '-',
                  ),
                  Divider(
                    height: 24,
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                  _PaymentDetailRow(
                    icon: Icons.calendar_month,
                    label: 'Periode Tagihan',
                    value: payment['billMonth'] ?? '-',
                  ),
                  _PaymentDetailRow(
                    icon: Icons.attach_money,
                    label: 'Jumlah',
                    value:
                        'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                    color: isDark ? const Color(0xFF00FF9D) : Colors.green,
                  ),
                  _PaymentDetailRow(
                    icon: Icons.payment,
                    label: 'Metode',
                    value: payment['paymentMethod'] ?? '-',
                  ),
                  _PaymentDetailRow(
                    icon: Icons.info,
                    label: 'Status',
                    value:
                        payment['paymentStatus']?.toString().toUpperCase() ??
                        '-',
                    color: isDark ? const Color(0xFF00FF9D) : Colors.green,
                  ),
                  _PaymentDetailRow(
                    icon: Icons.schedule,
                    label: 'Tanggal Bayar',
                    value:
                        '${paidAt.day}/${paidAt.month}/${paidAt.year} ${paidAt.hour}:${paidAt.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                  foregroundColor: isDark ? const Color(0xFF030712) : Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur cetak akan segera hadir'),
                    ),
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text('Cetak'),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF080D1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment['customerName'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payment['customerId'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF00FF9D).withValues(alpha: 0.15)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF00FF9D).withValues(alpha: 0.3)
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Text(
                    payment['paymentStatus'].toUpperCase(),
                    style: TextStyle(
                      color: isDark ? const Color(0xFF00FF9D) : Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 24,
              color: isDark ? Colors.white12 : Colors.grey.shade200,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tagihan',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment['billMonth'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Jumlah',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF00FF9D) : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 16,
                  color: isDark ? const Color(0xFF00F0FF) : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  payment['paymentMethod'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  '${paidAt.day}/${paidAt.month}/${paidAt.year} ${paidAt.hour}:${paidAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Payment Detail Row Widget
class _PaymentDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _PaymentDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? (isDark ? const Color(0xFF00F0FF) : Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: color ?? (isDark ? Colors.white : Colors.black87),
                fontWeight: color != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SPEED TEST CARD (Reusable Component) ====================
class _SpeedTestCard extends StatelessWidget {
  final Map<String, dynamic> test;

  const _SpeedTestCard({required this.test});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final testDate = DateTime.parse(test['testDate']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF080D1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      test['customerId'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF00F0FF).withValues(alpha: 0.3)
                        : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      test['connectionType'] == 'WiFi'
                          ? Icons.wifi
                          : Icons.signal_cellular_alt,
                      size: 14,
                      color: isDark ? const Color(0xFF00F0FF) : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      test['connectionType'],
                      style: TextStyle(
                        color: isDark ? const Color(0xFF00F0FF) : Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            color: isDark ? Colors.white12 : Colors.grey.shade200,
          ),
          Row(
            children: [
              Expanded(
                child: _SpeedMetric(
                  icon: Icons.download_rounded,
                  label: 'Download',
                  value: test['downloadSpeed'].toStringAsFixed(1),
                  unit: 'Mbps',
                  color: isDark ? const Color(0xFF00FF9D) : Colors.green,
                ),
              ),
              Expanded(
                child: _SpeedMetric(
                  icon: Icons.upload_rounded,
                  label: 'Upload',
                  value: test['uploadSpeed'].toStringAsFixed(1),
                  unit: 'Mbps',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _SpeedMetric(
                  icon: Icons.network_ping,
                  label: 'Ping',
                  value: test['latency'].toStringAsFixed(1),
                  unit: 'ms',
                  color: isDark ? const Color(0xFF00F0FF) : Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: isDark ? Colors.white38 : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                '${testDate.day}/${testDate.month}/${testDate.year} ${testDate.hour}:${testDate.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SpeedMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Compact Tactical Navigation Item for horizontal scrolling
class _CompactNavItem extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _CompactNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor = const Color(0xFF00F0FF),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 78,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.04),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: icon,
                  size: 20,
                  color: isSelected
                      ? activeColor
                      : const Color(0xFF64748B),
                ),
                const SizedBox(height: 3),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        letterSpacing: 0.2,
                        color: isSelected
                            ? activeColor
                            : const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 16,
                    height: 2,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
