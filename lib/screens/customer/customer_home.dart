import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/routes.dart';
import '../../widgets/dialogs.dart';
import '../../utils/constants.dart';
import 'speed_test_page.dart';
import 'chatbot_page.dart';
import 'payment_page.dart';
import '../../services/notification_service.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../services/logger_service.dart';
import '../../widgets/enhanced_ui_components.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/shimmer_avatar.dart';
import '../../utils/app_theme.dart';
import 'package:provider/provider.dart';
import '../../utils/theme_provider.dart';
import '../about_page.dart';
import '../../widgets/swipeable_items.dart';
import '../../widgets/copy_clipboard.dart';
import '../../widgets/share_widget.dart';
import 'bandwidth_usage_page.dart';
import '../../services/pdf_generator_service.dart';
import 'maintenance_alert_page.dart';
import 'package:intl/intl.dart';
import '../notifications_page.dart';
import 'package_upgrade_page.dart';
import 'wifi_management_page.dart';
import '../../widgets/cyber_widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hugeicons/hugeicons.dart';

// Quick Wins Integration Notes:
// - ShimmerImage: Available via '../../widgets/shimmer_image.dart'
//   Ready for network profile pictures & banners when needed
//   Usage: ShimmerImage(imageUrl: url, width: 200, height: 150)
//   Usage: ShimmerAvatar(imageUrl: url, radius: 40)
// - SwipeableListItem: ✅ Implemented for Bill list (swipe = quick pay)
// - CopyableText: ✅ Implemented for Customer ID, Email, Phone, etc.
// - ShareWidget: ✅ Implemented for bill/payment receipt sharing

// Dashboard Pelanggan Modern
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BerandaPage(),
    const TagihanPage(),
    const BantuanPage(),
    const ProfilPage(),
  ];

  void navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Kembali ke halaman beranda jika bukan di beranda
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        } else {
          showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.cyberOledBg : const Color(0xFFF1F5F9),
        body: _pages[_selectedIndex],
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppTheme.neonCyan, AppTheme.neonPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonCyan.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: FloatingActionButton(
            elevation: 0,
            highlightElevation: 0,
            backgroundColor: Colors.transparent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotPage()),
              );
            },
            tooltip: 'Tanya Audi AI // NOC Assistant',
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedBot,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberObsidian : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
              indicatorColor: isDark
                  ? AppTheme.neonCyan.withValues(alpha: 0.16)
                  : AppTheme.signalBlue.withValues(alpha: 0.12),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isDark
                      ? AppTheme.neonCyan.withValues(alpha: 0.6)
                      : AppTheme.signalBlue.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(
                    color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    size: 24,
                  );
                }
                return IconThemeData(
                  color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                  size: 22,
                );
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  );
                }
                return TextStyle(
                  color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              height: 68,
              destinations: [
                NavigationDestination(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedHome01,
                    color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                    size: 20,
                  ),
                  selectedIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedHome01,
                    color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    size: 20,
                  ),
                  label: 'BERANDA',
                ),
                NavigationDestination(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedInvoice01,
                    color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                    size: 20,
                  ),
                  selectedIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedInvoice01,
                    color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    size: 20,
                  ),
                  label: 'TAGIHAN',
                ),
                NavigationDestination(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCustomerService,
                    color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                    size: 20,
                  ),
                  selectedIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCustomerService,
                    color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    size: 20,
                  ),
                  label: 'BANTUAN',
                ),
                NavigationDestination(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedUserCircle,
                    color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                    size: 20,
                  ),
                  selectedIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedUserCircle,
                    color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    size: 20,
                  ),
                  label: 'PROFIL',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Beranda Page dengan UI Modern
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  Map<String, dynamic>? _customerData;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get current user data
      _userData = AuthService.instance.currentUserData;
      _userData ??= {
        'id': 'usr-customer-01',
        'name': 'BUDI SANTOSO',
        'email': 'budi@audira.my.id',
        'role': 'customer',
      };

      // Get customer data from Firestore
      var customer = await FirebaseService.instance.getCustomerByUserId(
        _userData!['id'].toString(),
      );

      customer ??= FirebaseService.getDefaultCustomerData(
        userId: _userData!['id'].toString(),
        email: _userData!['email'].toString(),
        name: _userData!['name'].toString(),
      );

      if (mounted) {
        setState(() {
          _customerData = customer;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _customerData = FirebaseService.getDefaultCustomerData(
            userId: _userData?['id']?.toString(),
            email: _userData?['email']?.toString(),
            name: _userData?['name']?.toString(),
          );
          _error = null;
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';

    final number = value is num ? value : (int.tryParse(value.toString()) ?? 0);
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  void _showCyberServiceInfoDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppTheme.neonCyan : const Color(0xFFCBD5E1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCustomerService,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUDIRA NOC & SUPPORT',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'LAYANAN OPERASIONAL 24/7',
                          style: TextStyle(
                            color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: isDark ? Colors.white70 : const Color(0xFF64748B), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 16),
              _buildCyberContactRow(context, LucideIcons.phone, 'NOC HOTLINE', AppConstants.csCallCenter, AppTheme.neonCyan),
              const SizedBox(height: 10),
              _buildCyberContactRow(context, LucideIcons.messageSquare, 'WHATSAPP CS', AppConstants.csWhatsApp, AppTheme.neonGreen),
              const SizedBox(height: 10),
              _buildCyberContactRow(context, LucideIcons.mail, 'OFFICIAL EMAIL', AppConstants.csEmail, AppTheme.neonPurple),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cyberObsidian : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS OPERASIONAL NOC:',
                      style: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Engineering Shift: 24 Jam Non-Stop\n• Kantor Layanan: Senin - Minggu (08:00 - 20:00 WIB)',
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CyberActionButton(
                label: 'TUTUP',
                primaryColor: AppTheme.neonCyan,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCyberContactRow(BuildContext context, IconData icon, String title, String val, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowColor = !isDark && color == AppTheme.neonAmber ? const Color(0xFFD97706) : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberObsidian : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? color.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: rowColor, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: rowColor, fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
              Text(
                val,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.cyberOledBg : const Color(0xFFF1F5F9),
      body: RefreshIndicator(
        color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
        backgroundColor: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
        onRefresh: _loadCustomerData,
        child: CustomScrollView(
          slivers: [
            // AUDIRA Tactical Network HUD Header
            SliverToBoxAdapter(
              child: TacticalHudHeader(
                title: _userData?['name']?.toString() ?? 'PELANGGAN AUDIRA',
                subtitle: 'ID: ${_customerData?['customerId'] ?? 'ADN-FIBER'} // IP: 103.144.92.14',
                nodeId: 'JKT-01 // FIBER-CORE',
                latencyMs: '4 ms // 0% LOSS',
                onNotificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promo Banner Slider (Feature #7)
                    _PromoBannerSlider(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Layanan Card (Cyberpunk Network Command Card)
                    if (_isLoading)
                      CyberCard(
                        borderColor: AppTheme.cyberBorder,
                        child: Row(
                          children: const [
                            CyberPulseDot(color: AppTheme.neonCyan, size: 12),
                            SizedBox(width: 12),
                            Text(
                              'SINKRONISASI TELEMETRI ONT...',
                              style: TextStyle(
                                color: AppTheme.neonCyan,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_error != null)
                      CyberCard(
                        borderColor: AppTheme.neonCrimson,
                        glow: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(LucideIcons.alertTriangle, color: AppTheme.neonCrimson, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'KONEKSI TELEMETRI GAGAL',
                                  style: TextStyle(
                                    color: AppTheme.neonCrimson,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gagal menghubungi gateway: $_error',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            CyberActionButton(
                              label: 'RETRY CONNECTION',
                              primaryColor: AppTheme.neonCrimson,
                              onPressed: _loadCustomerData,
                            ),
                          ],
                        ),
                      )
                    else if (_customerData != null)
                      CyberCard(
                        glow: true,
                        borderColor: _customerData!['status'] == 'active'
                            ? AppTheme.neonGreen
                            : AppTheme.neonAmber,
                        badgeText: _customerData!['status'] == 'active'
                            ? 'FIBER OPTIC // 100% ONLINE'
                            : 'STATUS: ${_customerData!['status'] ?? 'OFFLINE'}',
                        badgeColor: _customerData!['status'] == 'active'
                            ? AppTheme.neonGreen
                            : AppTheme.neonAmber,
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
                                      const Text(
                                        'PAKET LANGGANAN AKTIF',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 10.5,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_customerData!['packageName'] ?? 'FIBER ULTRA 50 MBPS'}',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonCyan.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(LucideIcons.zap, color: AppTheme.neonCyan, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        '50 MBPS',
                                        style: TextStyle(
                                          color: AppTheme.neonCyan,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.cyberObsidian
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.cyberBorder
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'TAGIHAN BULANAN',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatCurrency(_customerData!['monthlyFee']),
                                        style: const TextStyle(
                                          color: AppTheme.neonGreen,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                  CyberBadge(
                                    text: 'ID: ${_customerData!['customerId'] ?? 'ADN-001'}',
                                    color: AppTheme.neonCyan,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            CyberActionButton(
                              label: 'BAYAR TAGIHAN SEKARANG',
                              icon: LucideIcons.qrCode,
                              onPressed: () {
                                final customerHomeState = context
                                    .findAncestorStateOfType<_CustomerHomePageState>();
                                customerHomeState?.navigateToIndex(1);
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Payment Reminder Section (Feature #2)
                    _PaymentReminderSection(
                      userId: _userData?['id']?.toString() ?? '',
                    ),
                    const SizedBox(height: 16),

                    // Maintenance Alert Banner
                    _MaintenanceAlertBanner(),
                    const SizedBox(height: 16),

                    // Tactical Telemetry Grid - 2x2
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        CyberStatTile(
                          icon: LucideIcons.gauge,
                          title: 'Kecepatan',
                          value: '45.2 Mbps',
                          subtitle: '⚡ Latensi: 4ms',
                          accentColor: AppTheme.neonCyan,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SpeedTestPage(),
                              ),
                            );
                          },
                        ),
                        CyberStatTile(
                          icon: LucideIcons.activity,
                          title: 'Penggunaan',
                          value: '125.5 GB',
                          subtitle: 'FUP: Unlimited',
                          accentColor: AppTheme.neonPurple,
                          onTap: () async {
                            final currentUserData = AuthService.instance.currentUserData;
                            if (currentUserData == null || !context.mounted) return;
                            final customer = await FirebaseService.instance.getCustomerByUserId(
                              currentUserData['id'].toString(),
                            );
                            if (customer == null || !context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BandwidthUsagePage(
                                   customerId: customer['id'],
                                ),
                              ),
                            );
                          },
                        ),
                        const CyberStatTile(
                          icon: LucideIcons.shieldCheck,
                          title: 'Stabilitas',
                          value: '99.8%',
                          subtitle: 'Uptime ONT: 14 Hari',
                          accentColor: AppTheme.neonGreen,
                        ),
                        const CyberStatTile(
                          icon: LucideIcons.radio,
                          title: 'Ping Gateway',
                          value: '8 ms',
                          subtitle: 'Jitter: 0.8ms',
                          accentColor: AppTheme.neonAmber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Mini Bandwidth Chart (Feature #6)
                    _MiniBandwidthChart(
                      userId: _userData?['id']?.toString() ?? '',
                    ),
                    const SizedBox(height: 24),

                    // Aksi Cepat / Tactical Command Matrix
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppTheme.neonCyan,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonCyan.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KONTROL & OPERASIONAL JARINGAN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        const CyberBadge(
                          text: '8 MODUL',
                          color: AppTheme.neonCyan,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                      children: [
                        CyberCommandTile(
                          icon: HugeIcons.strokeRoundedInvoice01,
                          label: 'Tagihan',
                          color: const Color(0xFFF59E0B),
                          gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                          badge: 'BILL',
                          badgeColor: const Color(0xFFD97706),
                          onTap: () {
                            final customerHomeState = context
                                .findAncestorStateOfType<
                                  _CustomerHomePageState
                                >();
                            customerHomeState?.navigateToIndex(1);
                          },
                        ),
                        CyberCommandTile(
                          icon: HugeIcons.strokeRoundedWifi01,
                          label: 'Wi-Fi',
                          color: const Color(0xFF10B981),
                          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                          badge: 'ON',
                          badgeColor: const Color(0xFF059669),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WiFiManagementPage(),
                              ),
                            );
                          },
                        ),
                        CyberCommandTile(
                          icon: HugeIcons.strokeRoundedDashboardSpeed01,
                          label: 'Speedtest',
                          color: const Color(0xFF06B6D4),
                          gradientColors: const [Color(0xFF06B6D4), Color(0xFF0284C7)],
                          badge: 'FAST',
                          badgeColor: const Color(0xFF0284C7),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SpeedTestPage(),
                              ),
                            );
                          },
                        ),
                        CyberCommandTile(
                          icon: HugeIcons.strokeRoundedActivity01,
                          label: 'Trafik',
                          color: const Color(0xFF8B5CF6),
                          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          badge: 'LIVE',
                          badgeColor: const Color(0xFF6D28D9),
                          onTap: () async {
                            final currentUserData =
                                AuthService.instance.currentUserData;
                            if (currentUserData == null || !context.mounted) {
                              return;
                            }
                            final customer = await FirebaseService.instance
                                .getCustomerByUserId(
                                  currentUserData['id'].toString(),
                                );
                            if (customer == null || !context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BandwidthUsagePage(
                                  customerId: customer['id'],
                                ),
                              ),
                            );
                          },
                        ),
                        CyberCommandTile(
                          icon: HugeIcons.strokeRoundedCustomerService,
                          label: 'Bantuan',
                          color: const Color(0xFF3B82F6),
                          gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          badge: 'CARE',
                          badgeColor: const Color(0xFF1D4ED8),
                          onTap: () {
                            final customerHomeState = context
                                .findAncestorStateOfType<
                                  _CustomerHomePageState
                                >();
                            customerHomeState?.navigateToIndex(2);
                          },
                        ),
                        CyberCommandTile(
                          icon: HugeIcons.strokeRoundedLayers01,
                          label: 'Paket',
                          color: const Color(0xFFF43F5E),
                          gradientColors: const [Color(0xFFF43F5E), Color(0xFFBE123C)],
                          badge: 'HOT',
                          badgeColor: const Color(0xFFBE123C),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PackageUpgradePage(),
                              ),
                            );
                          },
                        ),
                        CyberCommandTile(
                          icon: HugeIcons.strokeRoundedSparkles,
                          label: 'Rewards',
                          color: const Color(0xFFA855F7),
                          gradientColors: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
                          badge: 'VIP',
                          badgeColor: const Color(0xFF7C3AED),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.loyaltyRewards);
                          },
                        ),
                        CyberCommandTile(
                          icon: HugeIcons.strokeRoundedBubbleChatQuestion,
                          label: 'Info CS',
                          color: const Color(0xFF14B8A6),
                          gradientColors: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
                          badge: '24/7',
                          badgeColor: const Color(0xFF0F766E),
                          onTap: () => _showCyberServiceInfoDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Lapor Gangguan Button (Feature #8)
                    const _LaporGangguanButton(),
                    const SizedBox(height: 24),

                    // Info Penting Section
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppTheme.neonAmber,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonAmber.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'BULETIN & STATUS JARINGAN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        const CyberBadge(
                          text: '2 INFO BARU',
                          color: AppTheme.neonAmber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _InfoCard(
                      icon: LucideIcons.clock,
                      title: 'Jatuh Tempo Pembayaran',
                      subtitle: '25 November 2025 // Tagihan Periode Berjalan',
                      color: AppTheme.neonCrimson,
                    ),
                    const _InfoCard(
                      icon: LucideIcons.alertTriangle,
                      title: 'Pemeliharaan Backbone Fiber',
                      subtitle: 'Minggu, 15 Nov 2025 | 01:00 - 05:00 WIB (NOC JKT-01)',
                      color: AppTheme.neonAmber,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ), // Close RefreshIndicator (Feature #10)
    );
  }
}

// Widget Lapor Gangguan Button (Feature #8 - Cyber Tactical Dispatch)
class _LaporGangguanButton extends StatelessWidget {
  const _LaporGangguanButton();

  void _showReportIssueDialog(BuildContext context) {
    final TextEditingController descController = TextEditingController();
    String selectedType = 'Internet Mati';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.neonCrimson, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(LucideIcons.alertTriangle, color: AppTheme.neonCrimson, size: 22),
            const SizedBox(width: 10),
            Text(
              'LAPOR GANGGUAN NOC',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KATEGORI GANGGUAN',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  dropdownColor: isDark ? AppTheme.cyberObsidian : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppTheme.cyberObsidian : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.neonCyan),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  items:
                      [
                        'Internet Mati',
                        'Internet Lambat',
                        'Tidak Stabil',
                        'Lainnya',
                      ].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A))),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'DESKRIPSI KENDALA',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppTheme.cyberObsidian : const Color(0xFFF8FAFC),
                    hintText: 'Jelaskan kendala koneksi yang Anda alami...',
                    hintStyle: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF94A3B8), fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: AppTheme.neonCrimson),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (descController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon jelaskan kendala yang Anda alami'),
                    backgroundColor: AppTheme.neonAmber,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator(color: AppTheme.neonCrimson)),
              );

              try {
                final authService = AuthService.instance;
                final currentUser = await authService.getCurrentUser();

                if (currentUser == null) {
                  throw Exception('User tidak ditemukan');
                }

                final firebaseService = FirebaseService.instance;
                final customer = await firebaseService.getCustomerByUserId(
                  currentUser['id'],
                );

                final ticketData = {
                  'customerId': currentUser['id'],
                  'customerName':
                      customer?['name'] ?? currentUser['name'] ?? 'Unknown',
                  'subject': selectedType,
                  'description': descController.text.trim(),
                  'category': 'teknis',
                  'priority': selectedType == 'Internet Mati'
                      ? 'urgent'
                      : 'medium',
                  'status': 'open',
                  'zone': customer?['zone'] ?? 'Unknown',
                  'createdAt': DateTime.now().toIso8601String(),
                };

                await firebaseService.createTicket(ticketData);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Laporan gangguan berhasil dikirim ke NOC!'),
                      backgroundColor: AppTheme.neonGreen,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Gagal mengirim laporan: $e'),
                      backgroundColor: AppTheme.neonCrimson,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            icon: const Icon(LucideIcons.send, size: 16),
            label: const Text('DISPATCH LAPORAN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonCrimson,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showReportIssueDialog(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.neonCrimson,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonCrimson.withValues(alpha: isDark ? 0.25 : 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonCrimson.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.30),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.65],
                          ),
                        ),
                      ),
                    ),
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedAlert02,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        CyberPulseDot(color: AppTheme.neonCrimson, size: 8),
                        SizedBox(width: 6),
                        Text(
                          'EMERGENCY NOC DISPATCH',
                          style: TextStyle(
                            color: AppTheme.neonCrimson,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LAPOR GANGGUAN JARINGAN',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.neonCrimson,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LAPOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Widget Info Card (Cyber Buletin Card)
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? color.withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? color.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.12 : 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppTheme.textSecondary : const Color(0xFF64748B),
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

// Widget Promo Banner Slider (Feature #7)
class _PromoBannerSlider extends StatefulWidget {
  const _PromoBannerSlider();

  @override
  State<_PromoBannerSlider> createState() => _PromoBannerSliderState();
}

class _PromoBannerSliderState extends State<_PromoBannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _promos = [
    {
      'title': 'Upgrade ke 100 Mbps',
      'subtitle': 'TURBO SPEED // RP 450.000/BLN',
      'accent': AppTheme.neonPurple,
      'gradient': [AppTheme.cyberObsidian, const Color(0xFF1F1235)],
      'lightGradient': [const Color(0xFFFFFFFF), const Color(0xFFF5F3FF)],
      'icon': LucideIcons.rocket,
      'action': 'upgrade',
      'details': {
        'title': 'UPGRADE // 100 MBPS HYPERLINK',
        'description':
            'Bandwidth tanpa batas untuk gaming ultra-low latency, streaming 4K HDR tanpa buffer, dan performa multi-device kelas NOC.',
        'benefits': [
          '⚡ Dedicated 100 Mbps Simetris 1:1',
          '🛡️ Unlimited Quota & Fair Usage Policy Maksimal',
          '🔧 Gratis Pemasangan & Kalibrasi ONT Fiber',
          '🛰️ 24/7 Priority NOC Dispatch & Direct Support',
          '📡 Free Dual-Band Gigabit Wi-Fi 6 Router',
          '🎮 Latency Ring-1 Gaming Ping Optimizer',
        ],
        'price': 'Rp 500.000 / Bulan',
        'discount': 'PROMO BULAN PERTAMA: RP 450.000',
      },
    },
    {
      'title': 'Promo Spesial Fiber Net',
      'subtitle': 'DISKON 20% PELANGGAN BARU',
      'accent': AppTheme.neonAmber,
      'gradient': [AppTheme.cyberObsidian, const Color(0xFF281C08)],
      'lightGradient': [const Color(0xFFFFFFFF), const Color(0xFFFFFBEB)],
      'icon': LucideIcons.zap,
      'action': 'promo',
      'details': {
        'title': 'PROMO SPECIAL FIBER // Q4',
        'description':
            'Dapatkan diskon eksklusif dan modem Wi-Fi 6 berkecepatan tinggi untuk registrasi baru sebelum periode promo berakhir!',
        'benefits': [
          '⚡ Diskon 20% Billing untuk 3 Bulan Pertama',
          '🎁 Bebas Biaya Instalasi Lapangan Teknisi',
          '📡 Gratis Router High-Power Wi-Fi 6',
          '🟢 Fast Activation & Provisioning dalam 24 Jam',
          '📞 SLA Monitoring & Dukungan CS Prioritas',
        ],
        'terms':
            'Syarat & ketentuan berlaku. Kuota terbatas 100 subscriber pertama di zona aktif.',
      },
    },
    {
      'title': 'Refer & Earn Cashback',
      'subtitle': 'REWARD CASHBACK HINGGA RP 100K',
      'accent': AppTheme.neonCyan,
      'gradient': [AppTheme.cyberObsidian, const Color(0xFF04252B)],
      'lightGradient': [const Color(0xFFFFFFFF), const Color(0xFFF0FDF4)],
      'icon': LucideIcons.gift,
      'action': 'referral',
      'details': {
        'title': 'REFERRAL PROGRAM // REWARD MATRIX',
        'description':
            'Ajak rekan, keluarga, atau tetangga berlangganan jaringan fiber AudiraNet dan klaim saldo cashback instan ke akun Anda!',
        'benefits': [
          '💎 Cashback Rp 100.000 per referral aktif',
          '🚀 Milestone Bonus 5 Referral: +Rp 1.000.000',
          '♾️ Tanpa batas kuota referral per akun',
          '📲 Kode referral unik otomatis aktif di profil',
          '💳 Kredit saldo otomatis memotong tagihan berikutnya',
        ],
        'howto': 'Bagikan kode referral → Teman registrasi → Bonus langsung cair!',
      },
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showPromoDetails(BuildContext context, Map<String, dynamic> promo) {
    final details = promo['details'] as Map<String, dynamic>?;
    final action = promo['action'] as String?;
    final accent = promo['accent'] as Color? ?? AppTheme.neonCyan;

    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detail promo tidak tersedia'),
          backgroundColor: AppTheme.neonAmber,
        ),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accent.withValues(alpha: isDark ? 0.6 : 0.4), width: 1.5),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 620),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberObsidian : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Tactical
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? accent.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.15 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accent.withValues(alpha: isDark ? 0.5 : 0.4)),
                      ),
                      child: Icon(promo['icon'] as IconData, color: !isDark && accent == AppTheme.neonAmber ? const Color(0xFFD97706) : accent, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CyberBadge(text: 'SPECIAL CAMPAIGN', color: !isDark && accent == AppTheme.neonAmber ? const Color(0xFFD97706) : accent),
                          const SizedBox(height: 4),
                          Text(
                            details['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details['description'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'KEUNGGULAN FITUR // SLA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: !isDark && accent == AppTheme.neonAmber ? const Color(0xFFD97706) : accent,
                          letterSpacing: 1,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...(details['benefits'] as List<String>).map(
                        (benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (details.containsKey('price')) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? accent.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BIAYA PAKET / TARIF:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                details['price'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: !isDark && accent == AppTheme.neonAmber ? const Color(0xFFD97706) : accent,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              if (details.containsKey('discount')) ...[
                                const SizedBox(height: 8),
                                CyberBadge(
                                  text: details['discount'] as String,
                                  color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (details.containsKey('terms')) ...[
                        const SizedBox(height: 14),
                        Text(
                          details['terms'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (details.containsKey('howto')) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.info,
                                color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  details['howto'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CyberActionButton(
                        text: action == 'upgrade'
                            ? 'UPGRADE SEKARANG'
                            : action == 'referral'
                            ? 'KODE REFERRAL'
                            : 'HUBUNGI NOC CS',
                        icon: LucideIcons.arrowRight,
                        color: accent,
                        isFullWidth: true,
                        onPressed: () {
                          Navigator.pop(context);
                          if (action == 'upgrade') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PackageUpgradePage(),
                              ),
                            );
                          } else if (action == 'referral') {
                            Navigator.pushNamed(context, Routes.loyaltyRewards);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hubungi CS Hotline untuk aktivasi'),
                                backgroundColor: AppTheme.neonCyan,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
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

    return Column(
      children: [
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _promos.length,
            itemBuilder: (context, index) {
              final promo = _promos[index];
              final accent = promo['accent'] as Color? ?? AppTheme.neonCyan;
              final gradient = isDark
                  ? (promo['gradient'] as List<Color>)
                  : (promo['lightGradient'] as List<Color>? ?? [Colors.white, accent.withValues(alpha: 0.12)]);
              final activeColor = !isDark && accent == AppTheme.neonAmber ? const Color(0xFFD97706) : accent;

              return InkWell(
                onTap: () => _showPromoDetails(context, promo),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cyberObsidian : Colors.white,
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? accent.withValues(alpha: 0.5) : accent.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? accent.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.15 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accent.withValues(alpha: isDark ? 0.4 : 0.3),
                          ),
                        ),
                        child: Icon(
                          promo['icon'] as IconData,
                          color: activeColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              promo['title'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              promo['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: activeColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        color: activeColor,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promos.length,
            (index) {
              final isCurrent = _currentPage == index;
              final accent = _promos[index]['accent'] as Color? ?? AppTheme.neonCyan;
              final activeColor = !isDark && accent == AppTheme.neonAmber ? const Color(0xFFD97706) : accent;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 24 : 8,
                height: 5,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? activeColor
                      : (isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isCurrent && isDark
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                          )
                        ]
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Widget Network Status Badge (Feature #4)
class _NetworkStatusBadge extends StatefulWidget {
  const _NetworkStatusBadge();

  @override
  State<_NetworkStatusBadge> createState() => _NetworkStatusBadgeState();
}

class _NetworkStatusBadgeState extends State<_NetworkStatusBadge> {
  bool _isOnline = true;
  String _latency = 'Checking...';

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
  }

  Future<void> _checkNetworkStatus() async {
    // Simulate network check - in real app, ping to server
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isOnline = true;
        _latency = '12 ms';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isOnline ? Colors.greenAccent : Colors.redAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isOnline ? Colors.greenAccent : Colors.redAccent)
                      .withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _latency,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Mini Bandwidth Chart (Feature #6 - Cyber Telemetri Trafik)
class _MiniBandwidthChart extends StatelessWidget {
  final String userId;

  const _MiniBandwidthChart({required this.userId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppTheme.neonCyan : AppTheme.signalBlue;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryAccent.withValues(alpha: isDark ? 0.12 : 0.10),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: primaryAccent.withValues(alpha: 0.4)),
                    ),
                    child: Icon(LucideIcons.barChart2, color: primaryAccent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'TELEMETRI TRAFIK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              CyberBadge(
                text: '7 HARI TERAKHIR',
                color: primaryAccent,
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Bar chart visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _MiniChartBar(height: 55, day: 'SEN', value: '12 GB'),
              _MiniChartBar(height: 42, day: 'SEL', value: '9 GB'),
              _MiniChartBar(height: 68, day: 'RAB', value: '15 GB'),
              _MiniChartBar(height: 50, day: 'KAM', value: '11 GB'),
              _MiniChartBar(height: 78, day: 'JUM', value: '18 GB'),
              _MiniChartBar(
                height: 92,
                day: 'SAB',
                value: '22 GB',
                isToday: true,
              ),
              _MiniChartBar(height: 38, day: 'MIN', value: '8 GB'),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatLabel(
                label: 'TOTAL MINGGU INI',
                value: '95 GB',
                color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
              ),
              _StatLabel(
                label: 'RATA-RATA HARIAN',
                value: '13.6 GB/HARI',
                color: isDark ? AppTheme.neonAmber : const Color(0xFFD97706),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChartBar extends StatelessWidget {
  final double height;
  final String day;
  final String value;
  final bool isToday;

  const _MiniChartBar({
    required this.height,
    required this.day,
    required this.value,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppTheme.neonCyan : AppTheme.signalBlue;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 8.5,
                color: isToday ? primaryAccent : (isDark ? AppTheme.textMuted : const Color(0xFF64748B)),
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isToday
                      ? [primaryAccent, isDark ? AppTheme.neonPurple : const Color(0xFF7C3AED)]
                      : (isDark
                          ? [AppTheme.cyberObsidian, AppTheme.neonCyan.withValues(alpha: 0.35)]
                          : [const Color(0xFFE2E8F0), AppTheme.signalBlue.withValues(alpha: 0.35)]),
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isToday
                      ? primaryAccent
                      : (isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
                  width: isToday ? 1.2 : 0.8,
                ),
                boxShadow: isToday && isDark
                    ? [
                        BoxShadow(
                          color: AppTheme.neonCyan.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              day,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                color: isToday ? primaryAccent : (isDark ? AppTheme.textMuted : const Color(0xFF64748B)),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatLabel({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
            fontFamily: 'monospace',
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// Widget Payment Reminder Section (Feature #2 - Cyber Billing Alert)
class _PaymentReminderSection extends StatefulWidget {
  final String userId;

  const _PaymentReminderSection({required this.userId});

  @override
  State<_PaymentReminderSection> createState() =>
      _PaymentReminderSectionState();
}

class _PaymentReminderSectionState extends State<_PaymentReminderSection> {
  List<Map<String, dynamic>> _unpaidBills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnpaidBills();
  }

  Future<void> _loadUnpaidBills() async {
    setState(() => _isLoading = true);

    try {
      var customer = await FirebaseService.instance.getCustomerByUserId(
        widget.userId,
      );
      customer ??= FirebaseService.getDefaultCustomerData(userId: widget.userId);

      final allBills = await FirebaseService.instance.getBillsByCustomerId(
        customer['customerId'].toString(),
      );

      final unpaid = allBills.where((bill) {
        final status = bill['status']?.toString().toLowerCase() ?? '';
        return status != 'paid' && status != 'lunas';
      }).toList();

      unpaid.sort((a, b) {
        final dateA = a['dueDate'] as Timestamp?;
        final dateB = b['dueDate'] as Timestamp?;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

      if (mounted) {
        setState(() {
          _unpaidBills = unpaid;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _unpaidBills = [];
          _isLoading = false;
        });
      }
    }
  }

  String _formatDueDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'TERLAMBAT ${-difference} HARI';
    } else if (difference == 0) {
      return 'JATUH TEMPO HARI INI';
    } else if (difference <= 7) {
      return 'JATUH TEMPO $difference HARI LAGI';
    } else {
      return 'TEMPO: ${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getUrgencyColor(Timestamp? timestamp) {
    if (timestamp == null) return AppTheme.textMuted;

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) return AppTheme.neonCrimson;
    if (difference <= 3) return AppTheme.neonCrimson;
    if (difference <= 7) return AppTheme.neonAmber;
    return AppTheme.neonCyan;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return CyberCard(
        borderColor: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1),
        child: Row(
          children: [
            CyberPulseDot(color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, size: 8),
            const SizedBox(width: 12),
            Text(
              'MEMERIKSA TELEMETRI BILLING...',
              style: TextStyle(
                color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
    }

    if (_unpaidBills.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstBill = _unpaidBills.first;
    final hasMultiple = _unpaidBills.length > 1;
    final urgencyColor = _getUrgencyColor(firstBill['dueDate'] as Timestamp?);

    return CyberCard(
      glow: true,
      borderColor: urgencyColor,
      badgeText: hasMultiple
          ? '${_unpaidBills.length} INVOICE TERUTANG'
          : 'INVOICE AKTIF',
      badgeColor: urgencyColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: isDark ? 0.15 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: urgencyColor.withValues(alpha: isDark ? 0.5 : 0.4)),
                ),
                child: Icon(
                  LucideIcons.receipt,
                  color: urgencyColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasMultiple
                          ? '${_unpaidBills.length} Tagihan Belum Dibayar'
                          : 'Tagihan Berjalan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDueDate(firstBill['dueDate'] as Timestamp?),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: urgencyColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL TAGIHAN',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(
                      _unpaidBills.fold<num>(
                        0,
                        (total, bill) => total + (bill['amount'] ?? 0),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: urgencyColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          CyberActionButton(
            label: 'BAYAR SEKARANG',
            primaryColor: urgencyColor,
            onPressed: () {
              final customerHomeState = context
                  .findAncestorStateOfType<_CustomerHomePageState>();
              customerHomeState?.navigateToIndex(1);
            },
          ),
        ],
      ),
    );
  }

  String _formatCurrency(num value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}


// Tagihan Page dengan UI Modern
class TagihanPage extends StatefulWidget {
  const TagihanPage({super.key});

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _filteredBills = [];
  bool _isLoading = true;

  // Filter states
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'paid', 'unpaid'

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    try {
      setState(() => _isLoading = true);

      // Get current user data from AuthService
      final currentUserData = AuthService.instance.currentUserData;
      if (currentUserData == null) {
        LoggerService.uiError('❌ No current user data found');
        setState(() => _isLoading = false);
        return;
      }

      LoggerService.uiInfo('👤 Current user ID: ${currentUserData['id']}');

      // Get customer data using user ID
      final customerData = await FirebaseService.instance.getCustomerByUserId(
        currentUserData['id'].toString(),
      );

      if (customerData == null) {
        LoggerService.uiInfo('❌ No customer data found for user');
        setState(() {
          _bills = [];
          _isLoading = false;
        });
        return;
      }

      LoggerService.uiInfo('UI operation completed');

      // Get bills for this customer
      final bills = await FirebaseService.instance.getBillsByCustomerId(
        customerData['id'].toString(),
      );

      LoggerService.uiInfo('🧾 Found ${bills.length} bills');

      setState(() {
        _bills = bills;
        _filteredBills = bills;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      LoggerService.uiInfo('❌ Error loading bills: $e');
      setState(() {
        _bills = [];
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredBills = _bills.where((bill) {
        // Status filter
        if (_statusFilter == 'paid' && bill['status'] != 'paid') return false;
        if (_statusFilter == 'unpaid' && bill['status'] == 'paid') return false;

        // Search query filter (search in month name)
        if (_searchQuery.isNotEmpty &&
            !bill['billMonth'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            )) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  String _formatBillDueDate(dynamic rawDate) {
    if (rawDate == null) return 'Unknown';
    if (rawDate is Timestamp) {
      return DateFormat('d MMM yyyy').format(rawDate.toDate());
    }
    if (rawDate is DateTime) {
      return DateFormat('d MMM yyyy').format(rawDate);
    }
    if (rawDate is String) {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return DateFormat('d MMM yyyy').format(parsed);
      }
      return rawDate;
    }
    return rawDate.toString();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tagihan'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Pembayaran:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _statusFilter == 'all',
                    onSelected: (selected) {
                      setDialogState(() => _statusFilter = 'all');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Lunas'),
                    selected: _statusFilter == 'paid',
                    onSelected: (selected) {
                      setDialogState(() => _statusFilter = 'paid');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Belum Bayar'),
                    selected: _statusFilter == 'unpaid',
                    onSelected: (selected) {
                      setDialogState(() => _statusFilter = 'unpaid');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _statusFilter = 'all';
              });
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          FilledButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.cyberOledBg : const Color(0xFFF1F5F9),
        appBar: AppBar(
          title: Text(
            'TAGIHAN & PEMBAYARAN',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 1.0,
              fontFamily: 'monospace',
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(LucideIcons.filter, color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue),
              onPressed: _showFilterDialog,
              tooltip: 'Filter',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cyberObsidian : Colors.white,
                border: Border(
                  bottom: BorderSide(color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0), width: 1.2),
                ),
              ),
              child: TabBar(
                labelColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                unselectedLabelColor: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                indicatorColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'TAGIHAN AKTIF', icon: Icon(LucideIcons.receipt, size: 20)),
                  Tab(text: 'RIWAYAT PEMBAYARAN', icon: Icon(LucideIcons.history, size: 20)),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Tagihan Aktif Tab
            _buildBillsTab(),
            // Riwayat Pembayaran Tab (Feature #9)
            _PaymentHistoryTimeline(
              bills: _bills.where((b) => b['status'] == 'paid').toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? AppTheme.cyberObsidian : Colors.white,
          child: TextField(
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari invoice atau bulan tagihan...',
              hintStyle: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: Icon(LucideIcons.search, color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue),
              ),
              filled: true,
              fillColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
        ),

        // Auto-Pay Toggle (Feature #13)
        const _AutoPayToggle(),

        // Filter Chips
        if (_statusFilter != 'all')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppTheme.cyberObsidian : Colors.white,
            child: Row(
              children: [
                Text('Filter: ', style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondary : const Color(0xFF64748B))),
                Chip(
                  backgroundColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF1F5F9),
                  side: BorderSide(color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, width: 1),
                  label: Text(
                    _statusFilter == 'paid' ? 'LUNAS' : 'BELUM BAYAR',
                    style: TextStyle(color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  deleteIcon: Icon(LucideIcons.x, size: 16, color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue),
                  onDeleted: () {
                    setState(() => _statusFilter = 'all');
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),

        // Bills List
        Expanded(
          child: _isLoading
              ? const SkeletonList(itemCount: 5)
              : _bills.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadBills,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const EnhancedEmptyState(
                        icon: LucideIcons.receipt,
                        title: 'Belum Ada Tagihan',
                        description:
                            'Tagihan Anda akan muncul di sini setelah data customer dibuat.',
                        actionLabel: 'Refresh',
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadBills,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : _filteredBills.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadBills,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const EnhancedEmptyState(
                        icon: LucideIcons.searchX,
                        title: 'Tidak Ada Hasil',
                        description:
                            'Coba ubah filter atau kata kunci pencarian.',
                        actionLabel: 'Reset',
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _statusFilter = 'all';
                          });
                          _applyFilters();
                        },
                        child: const Text('Reset Filter'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBills,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBills.length,
                    itemBuilder: (context, index) {
                      final bill = _filteredBills[index];
                      final safeBillId = bill['id']?.toString() ?? 'INV-${index + 1}';
                      final safeBillMonth = (bill['billMonth'] ?? bill['month'] ?? bill['periode'] ?? 'Tagihan Aktif').toString();
                      final safeAmount = bill['amount'] ?? 0;

                      return SwipeableListItem(
                        key: Key('bill_$safeBillId'),
                        onTap: bill['status'] != 'paid'
                            ? () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                      billId: safeBillId,
                                      billMonth: safeBillMonth,
                                      amount: safeAmount,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadBills();
                                }
                              }
                            : null,
                        onEdit: bill['status'] != 'paid'
                            ? () async {
                                // Quick pay
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                      billId: safeBillId,
                                      billMonth: safeBillMonth,
                                      amount: safeAmount,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadBills();
                                }
                              }
                            : null,
                        enableEdit: bill['status'] != 'paid',
                        enableDelete: false,
                        child: _BillCard(
                          billId: safeBillId,
                          month: safeBillMonth,
                          amount: safeAmount,
                          dueDate: _formatBillDueDate(bill['dueDate']),
                          status: bill['status'] == 'paid'
                              ? 'Lunas'
                              : 'Belum Dibayar',
                          isPaid: bill['status'] == 'paid',
                          onPaymentComplete: _loadBills,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// Widget Auto-Pay Toggle (Feature #13)
class _AutoPayToggle extends StatefulWidget {
  const _AutoPayToggle();

  @override
  State<_AutoPayToggle> createState() => _AutoPayToggleState();
}

class _AutoPayToggleState extends State<_AutoPayToggle> {
  bool _autoPayEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAutoPaySetting();
  }

  Future<void> _loadAutoPaySetting() async {
    try {
      final authService = AuthService.instance;
      final currentUser = await authService.getCurrentUser();

      if (currentUser != null) {
        final firebaseService = FirebaseService.instance;
        final customer = await firebaseService.getCustomerByUserId(
          currentUser['id'],
        );

        if (customer != null && mounted) {
          setState(() {
            _autoPayEnabled = customer['autoPayEnabled'] ?? false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleAutoPay(bool value) async {
    setState(() => _autoPayEnabled = value);

    try {
      // Get current user
      final authService = AuthService.instance;
      final currentUser = await authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      // Get customer data
      final firebaseService = FirebaseService.instance;
      final customer = await firebaseService.getCustomerByUserId(
        currentUser['id'],
      );

      if (customer == null) {
        throw Exception('Data customer tidak ditemukan');
      }

      // Save to Firestore
      await firebaseService.updateCustomer(customer['id'], {
        'autoPayEnabled': value,
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? '✅ Auto-pay diaktifkan. Tagihan akan dibayar otomatis setiap bulan.'
                  : '✅ Auto-pay dinonaktifkan.',
            ),
            backgroundColor: value ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Revert state on error
      setState(() => _autoPayEnabled = !value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyimpan pengaturan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _autoPayEnabled ? Colors.green.shade200 : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (_autoPayEnabled ? Colors.green : Colors.grey).shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.refreshCw,
              color: _autoPayEnabled
                  ? Colors.green.shade600
                  : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran Otomatis',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _autoPayEnabled
                      ? 'Tagihan dibayar otomatis setiap bulan'
                      : 'Aktifkan untuk pembayaran otomatis',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: _autoPayEnabled,
            onChanged: _isLoading ? null : _toggleAutoPay,
            activeThumbColor: Colors.green.shade600,
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget Payment History Timeline (Feature #9)
class _PaymentHistoryTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> bills;

  const _PaymentHistoryTimeline({required this.bills});

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return const Center(
        child: EnhancedEmptyState(
          icon: LucideIcons.receipt,
          title: 'Belum Ada Riwayat',
          description: 'Riwayat pembayaran Anda akan muncul di sini',
        ),
      );
    }

    // Sort bills by paid date (newest first)
    final sortedBills = List<Map<String, dynamic>>.from(bills);
    sortedBills.sort((a, b) {
      final dateA = a['paidDate'] as Timestamp?;
      final dateB = b['paidDate'] as Timestamp?;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedBills.length,
      itemBuilder: (context, index) {
        final bill = sortedBills[index];
        final isLast = index == sortedBills.length - 1;

        return _TimelineItem(
          month: bill['billMonth']?.toString() ?? 'Unknown',
          amount: bill['amount'] ?? 0,
          paidDate: bill['paidDate'] as Timestamp?,
          paymentMethod: bill['paymentMethod']?.toString() ?? 'Unknown',
          isLast: isLast,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String month;
  final dynamic amount;
  final Timestamp? paidDate;
  final String paymentMethod;
  final bool isLast;

  const _TimelineItem({
    required this.month,
    required this.amount,
    required this.paidDate,
    required this.paymentMethod,
    required this.isLast,
  });

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    final number = value is num ? value : (int.tryParse(value.toString()) ?? 0);
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(LucideIcons.check, color: Colors.white, size: 16),
            ),
            if (!isLast)
              Container(width: 2, height: 100, color: Colors.green.shade200),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      month,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Lunas',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(paidDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.creditCard, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      paymentMethod,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatCurrency(amount),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Widget Bill Card (Cyber Invoice Card)
class _BillCard extends StatelessWidget {
  final String billId;
  final String month;
  final dynamic amount;
  final String dueDate;
  final String status;
  final bool isPaid;
  final VoidCallback? onPaymentComplete;

  const _BillCard({
    required this.billId,
    required this.month,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.isPaid,
    this.onPaymentComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int amountValue = amount is int
        ? amount
        : int.tryParse(amount.toString()) ?? 0;
    final formattedAmount = amountValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    final statusColor = isPaid
        ? (isDark ? AppTheme.neonGreen : const Color(0xFF16A34A))
        : (isDark ? AppTheme.neonAmber : const Color(0xFFD97706));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? (isDark ? AppTheme.neonGreen.withValues(alpha: 0.4) : const Color(0xFF86EFAC))
              : (isDark ? AppTheme.neonAmber : const Color(0xFFFDE68A)),
          width: isPaid ? 1.2 : 1.5,
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: statusColor.withValues(alpha: isPaid ? 0.08 : 0.22),
              blurRadius: 14,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Icon(
                      isPaid ? LucideIcons.checkCircle2 : LucideIcons.receipt,
                      color: statusColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    month.toUpperCase(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              CyberBadge(
                text: isPaid ? 'LUNAS // VERIFIED' : 'BELUM DIBAYAR',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL TAGIHAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp $formattedAmount',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isPaid
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : (isDark ? AppTheme.neonAmber : const Color(0xFFD97706)),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              if (!isPaid)
                CyberActionButton(
                  label: 'BAYAR SEKARANG',
                  primaryColor: isDark ? AppTheme.neonAmber : const Color(0xFFD97706),
                  fullWidth: false,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          billId: billId,
                          billMonth: month,
                          amount: amountValue.toDouble(),
                        ),
                      ),
                    );

                    if (!context.mounted) return;
                    if (result == true && onPaymentComplete != null) {
                      onPaymentComplete!();
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 14,
                      color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jatuh Tempo: $dueDate',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppTheme.textSecondary : const Color(0xFF64748B),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isPaid)
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.neonCyan.withValues(alpha: 0.12)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.neonCyan.withValues(alpha: 0.3)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          LucideIcons.fileText,
                          size: 18,
                          color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                        ),
                        onPressed: () async {
                          try {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Generating Invoice PDF...'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: isDark
                                    ? AppTheme.cyberObsidian
                                    : const Color(0xFF1E293B),
                              ),
                            );

                            final currentUserData =
                                AuthService.instance.currentUserData;
                            if (currentUserData == null) return;

                            final customer = await FirebaseService.instance
                                .getCustomerByUserId(
                                  currentUserData['id'].toString(),
                                );
                            if (customer == null) return;

                            final billData = {
                              'customerName': customer['name'],
                              'customerId': customer['customerId'],
                              'billMonth': month,
                              'amount': amount.toDouble(),
                              'dueDate': dueDate,
                              'status': 'paid',
                              'paidDate': dueDate,
                              'packageName': customer['package'],
                              'installAddress': customer['installAddress'],
                            };

                            final pdfFile = await PdfGeneratorService.instance
                                .generateInvoicePdf(billData);

                            if (!context.mounted) return;

                            showDialog(
                              context: context,
                              builder: (dialogCtx) {
                                final isDialogDark =
                                    Theme.of(dialogCtx).brightness == Brightness.dark;
                                return AlertDialog(
                                  backgroundColor: isDialogDark
                                      ? AppTheme.cyberSurfaceCard
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: isDialogDark
                                          ? AppTheme.neonCyan
                                          : AppTheme.signalBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                  title: Text(
                                    'INVOICE PDF SIAP',
                                    style: TextStyle(
                                      color: isDialogDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  content: Text(
                                    'File tersimpan:\n${pdfFile.path}',
                                    style: TextStyle(
                                      color: isDialogDark
                                          ? AppTheme.textSecondary
                                          : const Color(0xFF475569),
                                      fontSize: 12,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx),
                                      child: Text(
                                        'TUTUP',
                                        style: TextStyle(
                                          color: isDialogDark
                                              ? AppTheme.textMuted
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: isDialogDark
                                            ? AppTheme.neonCyan
                                            : AppTheme.signalBlue,
                                        foregroundColor: Colors.white,
                                      ),
                                    onPressed: () async {
                                      Navigator.pop(dialogCtx);
                                      await PdfGeneratorService.instance.sharePdf(pdfFile);
                                    },
                                    icon: const Icon(LucideIcons.share2, size: 16),
                                    label: const Text('SHARE', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: isDialogDark
                                          ? AppTheme.neonGreen
                                          : const Color(0xFF16A34A),
                                      foregroundColor: isDialogDark ? Colors.black : Colors.white,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(dialogCtx);
                                      await PdfGeneratorService.instance.printPdf(pdfFile);
                                    },
                                    icon: const Icon(LucideIcons.printer, size: 16),
                                    label: const Text('PRINT', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              );
                            },
                          );
                        } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: AppTheme.neonCrimson,
                              ),
                            );
                          }
                        },
                        tooltip: 'Download PDF',
                        color: AppTheme.neonCyan,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
                      ),
                      child: IconButton(
                        icon: const Icon(LucideIcons.share2, size: 18),
                        onPressed: () async {
                          await ShareHelper.shareBillingReport(
                            customerName: 'Budi Santoso',
                            period: month,
                            totalAmount:
                                'Rp $formattedAmount',
                          );
                        },
                        tooltip: 'Bagikan Bukti Pembayaran',
                        color: AppTheme.neonGreen,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Bantuan Page dengan UI Modern
class BantuanPage extends StatefulWidget {
  const BantuanPage({super.key});

  @override
  State<BantuanPage> createState() => _BantuanPageState();
}

class _BantuanPageState extends State<BantuanPage> {
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      // Customer ID 1 untuk demo (Budi Santoso)
      final tickets = await FirebaseService.instance.getTicketsByCustomerId(
        '1',
      );
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      // Error loading tickets
      setState(() => _isLoading = false);
    }
  }

  void _showCreateTicketDialog() {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'medium';
    String selectedCategory = 'teknis';
    String selectedZone = 'Batam Center';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark
                    ? AppTheme.neonAmber.withValues(alpha: 0.6)
                    : const Color(0xFFF59E0B),
                width: 1.5,
              ),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cyberObsidian : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Tactical HUD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? AppTheme.neonAmber.withValues(alpha: 0.3)
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.neonAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.neonAmber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.headphones,
                          color: AppTheme.neonAmber,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CyberBadge(
                              text: 'NOC DISPATCH // TIKET BARU',
                              color: AppTheme.neonAmber,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'BUAT TIKET GANGGUAN',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Laporkan anomali jaringan atau pertanyaan billing',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        icon: Icon(LucideIcons.x, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori Masalah
                        Row(
                          children: [
                            const CyberPulseDot(color: AppTheme.neonAmber, size: 8),
                            const SizedBox(width: 8),
                            const Text(
                              'KATEGORI MASALAH // CATEGORY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: AppTheme.neonAmber,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Column(
                            children: [
                              _CategoryOption(
                                icon: LucideIcons.wifiOff,
                                title: 'Masalah Teknis & Koneksi',
                                subtitle: 'Internet drop, LOS merah, redaman tinggi',
                                value: 'teknis',
                                groupValue: selectedCategory,
                                onChanged: (value) {
                                  setState(() => selectedCategory = value!);
                                },
                              ),
                              Divider(
                                height: 1,
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                              ),
                              _CategoryOption(
                                icon: LucideIcons.receipt,
                                title: 'Tagihan & Billing Pembayaran',
                                subtitle: 'Konfirmasi bayar, mutasi invoice',
                                value: 'billing',
                                groupValue: selectedCategory,
                                onChanged: (value) {
                                  setState(() => selectedCategory = value!);
                                },
                              ),
                              Divider(
                                height: 1,
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                              ),
                              _CategoryOption(
                                icon: LucideIcons.gauge,
                                title: 'Upgrade Speed & Bandwidth',
                                subtitle: 'Modifikasi profil langganan internet',
                                value: 'upgrade',
                                groupValue: selectedCategory,
                                onChanged: (value) {
                                  setState(() => selectedCategory = value!);
                                },
                              ),
                              Divider(
                                height: 1,
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                              ),
                              _CategoryOption(
                                icon: LucideIcons.helpCircle,
                                title: 'Pertanyaan Umum Lainnya',
                                subtitle: 'Relokasi ONT, konsultasi teknis Wi-Fi',
                                value: 'lainnya',
                                groupValue: selectedCategory,
                                onChanged: (value) {
                                  setState(() => selectedCategory = value!);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Judul Masalah
                        Row(
                          children: [
                            const CyberPulseDot(color: AppTheme.neonAmber, size: 8),
                            const SizedBox(width: 8),
                            const Text(
                              'SUBJEK KENDALA // SUBJECT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: AppTheme.neonAmber,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: subjectController,
                          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Contoh: Internet terputus sejak pukul 08:00',
                            hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF94A3B8), fontSize: 13),
                            filled: true,
                            fillColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.neonAmber,
                                width: 1.5,
                              ),
                            ),
                            prefixIcon: const Icon(
                              LucideIcons.fileEdit,
                              color: AppTheme.neonAmber,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Deskripsi Detail
                        Row(
                          children: [
                            const CyberPulseDot(color: AppTheme.neonAmber, size: 8),
                            const SizedBox(width: 8),
                            const Text(
                              'DETAIL KENDALA // LOG DESCRIPTION',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: AppTheme.neonAmber,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: descriptionController,
                          maxLines: 4,
                          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13, height: 1.4),
                          decoration: InputDecoration(
                            hintText:
                                'Jelaskan kronologi kendala...\n• Kapan pertama kali terjadi?\n• Status lampu indikator PON/LOS pada ONT modem?\n• Apakah sudah dicoba restart perangkat?',
                            hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF94A3B8), fontSize: 12),
                            filled: true,
                            fillColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.neonAmber,
                                width: 1.5,
                              ),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Zona Lokasi
                        Row(
                          children: [
                            const CyberPulseDot(color: AppTheme.neonAmber, size: 8),
                            const SizedBox(width: 8),
                            const Text(
                              'ZONA LOKASI // POP REGION',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: AppTheme.neonAmber,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedZone,
                            dropdownColor: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
                            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                LucideIcons.mapPin,
                                color: AppTheme.neonCyan,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Batam Center',
                                child: Text('Batam Center (POP-01)'),
                              ),
                              DropdownMenuItem(
                                value: 'Piayu',
                                child: Text('Piayu (POP-02)'),
                              ),
                              DropdownMenuItem(
                                value: 'Baloi',
                                child: Text('Baloi (POP-03)'),
                              ),
                              DropdownMenuItem(
                                value: 'Nagoya',
                                child: Text('Nagoya (POP-04)'),
                              ),
                              DropdownMenuItem(
                                value: 'Batu Aji',
                                child: Text('Batu Aji (POP-05)'),
                              ),
                              DropdownMenuItem(
                                value: 'Sekupang',
                                child: Text('Sekupang (POP-06)'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => selectedZone = value!);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tingkat Prioritas
                        Row(
                          children: [
                            const CyberPulseDot(color: AppTheme.neonAmber, size: 8),
                            const SizedBox(width: 8),
                            const Text(
                              'TINGKAT PRIORITAS // SEVERITY LEVEL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: AppTheme.neonAmber,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _PriorityChip(
                                label: 'Rendah',
                                icon: LucideIcons.arrowDown,
                                color: AppTheme.neonGreen,
                                isSelected: selectedPriority == 'low',
                                onTap: () {
                                  setState(() => selectedPriority = 'low');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PriorityChip(
                                label: 'Sedang',
                                icon: LucideIcons.minus,
                                color: AppTheme.neonAmber,
                                isSelected: selectedPriority == 'medium',
                                onTap: () {
                                  setState(() => selectedPriority = 'medium');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PriorityChip(
                                label: 'Tinggi',
                                icon: LucideIcons.alertTriangle,
                                color: AppTheme.neonCrimson,
                                isSelected: selectedPriority == 'high',
                                onTap: () {
                                  setState(() => selectedPriority = 'high');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Info Box SLA
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.neonCyan.withValues(alpha: 0.35)
                                  : const Color(0xFF86EFAC),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.shieldCheck,
                                color: isDark ? AppTheme.neonCyan : const Color(0xFF16A34A),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'NOC AUDIRA standby 24/7. Tiket prioritas ditanggapi segera sesuai SLA ring-1.',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(
                              color: isDark ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Text(
                            'BATAL',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: CyberActionButton(
                          text: 'TRANSMIT TIKET NOC',
                          icon: LucideIcons.send,
                          color: AppTheme.neonAmber,
                          isFullWidth: true,
                          onPressed: () async {
                            if (subjectController.text.isEmpty ||
                                descriptionController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        LucideIcons.alertCircle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Mohon lengkapi seluruh kolom tiket',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppTheme.neonCrimson,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              final categoryPrefix = {
                                'teknis': '[TEKNIS]',
                                'billing': '[BILLING]',
                                'upgrade': '[UPGRADE]',
                                'lainnya': '[UMUM]',
                              }[selectedCategory];

                              await FirebaseService.instance.createTicket({
                                'customerId': '1',
                                'subject':
                                    '$categoryPrefix ${subjectController.text}',
                                'description': descriptionController.text,
                                'priority': selectedPriority,
                                'zone': selectedZone,
                                'status': 'open',
                                'category': selectedCategory,
                              });

                              if (!context.mounted) return;
                              Navigator.pop(dialogCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        LucideIcons.checkCircle2,
                                        color: AppTheme.neonGreen,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Tiket berhasil di-transmit! NOC akan segera menindaklanjuti.',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: isDark ? AppTheme.cyberObsidian : const Color(0xFF0F172A),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                      color: AppTheme.neonGreen,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 4),
                                ),
                              );

                              _loadTickets();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        LucideIcons.alertCircle,
                                        color: AppTheme.neonCrimson,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text('Gagal mengirimkan tiket'),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: isDark ? AppTheme.cyberObsidian : const Color(0xFF0F172A),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                      color: AppTheme.neonCrimson,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.cyberOledBg : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Row(
          children: [
            const CyberPulseDot(color: AppTheme.neonAmber, size: 9),
            const SizedBox(width: 10),
            Text(
              'PUSAT BANTUAN // NOC SUPPORT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                fontFamily: 'monospace',
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: CyberBadge(
                text: '24/7 ONLINE',
                color: AppTheme.neonGreen,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.neonAmber,
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        onRefresh: _loadTickets,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Buat Tiket Baru Tactical Hero Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cyberObsidian : Colors.white,
                gradient: isDark
                    ? const LinearGradient(
                        colors: [AppTheme.cyberObsidian, Color(0xFF261906)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFFBEB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppTheme.neonAmber.withValues(alpha: 0.6) : const Color(0xFFF59E0B),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonAmber.withValues(alpha: isDark ? 0.15 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showCreateTicketDialog,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.neonAmber.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.neonAmber.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.checkSquare,
                            color: AppTheme.neonAmber,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CyberBadge(
                                text: 'NOC DISPATCH ENGINE',
                                color: AppTheme.neonAmber,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'BUAT TIKET GANGGUAN BARU',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Laporkan masalah untuk penanganan cepat',
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          LucideIcons.chevronRight,
                          color: AppTheme.neonAmber,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const TacticalHudHeader(
              title: 'TIKET AKTIF // STATUS DISPATCH',
              subtitle: 'DAFTAR LAPORAN LAYANAN & RIWAYAT NOC',
              accentColor: AppTheme.neonAmber,
            ),
            const SizedBox(height: 12),
            _isLoading
                ? Column(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        height: 90,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                  )
                : _tickets.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFCBD5E1),
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          LucideIcons.shieldCheck,
                          color: AppTheme.neonGreen,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SEMUA LAYANAN NORMAL',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tidak ada tiket kendala aktif saat ini. Jaringan fiber Anda beroperasi optimal.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: _tickets.map((ticket) {
                      return _TicketCard(
                        ticketId: ticket['ticketId'] ?? 'TK-000',
                        subject: ticket['subject'] ?? 'Laporan Jaringan',
                        description: ticket['description'] ?? '',
                        status: ticket['status'] ?? 'open',
                        priority: ticket['priority'] ?? 'medium',
                        createdAt: ticket['createdAt'] ?? DateTime.now().toIso8601String(),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

// Widget Ticket Card Cyberpunk
class _TicketCard extends StatelessWidget {
  final String ticketId;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final String createdAt;

  const _TicketCard({
    required this.ticketId,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'open':
        return AppTheme.neonAmber;
      case 'resolved':
        return AppTheme.neonGreen;
      default:
        return AppTheme.neonCyan;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'open':
        return 'DALAM PROSES';
      case 'resolved':
        return 'SELESAI // CLOSED';
      default:
        return status.toUpperCase();
    }
  }

  String _getPriorityText() {
    switch (priority) {
      case 'low':
        return 'RENDAH';
      case 'medium':
        return 'SEDANG';
      case 'high':
        return 'TINGGI // URGENT';
      default:
        return priority.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getStatusColor();
    DateTime date;
    try {
      date = DateTime.parse(createdAt);
    } catch (_) {
      date = DateTime.now();
    }
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final priorityColor = priority == 'high'
        ? AppTheme.neonCrimson
        : priority == 'medium'
        ? AppTheme.neonAmber
        : AppTheme.neonGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.45 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  LucideIcons.ticket,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CyberBadge(
                      text: ticketId,
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CyberBadge(
                text: _getStatusText(),
                color: color,
              ),
              const SizedBox(width: 8),
              CyberBadge(
                text: _getPriorityText(),
                color: priorityColor,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 12,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Profil Page dengan UI Modern
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _customerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = AuthService.instance;
      final user = await authService.getCurrentUser();

      if (user != null) {
        final firebaseService = FirebaseService.instance;
        final customer = await firebaseService.getCustomerByUserId(user['id']);

        if (mounted) {
          setState(() {
            _userData = user;
            _customerData = customer;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.cyberOledBg : const Color(0xFFF1F5F9),
        appBar: AppBar(
          title: Text(
            'PROFIL // IDENTITY',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.neonCyan),
        ),
      );
    }

    final userName = _userData?['name'] ?? 'Pelanggan Audira';
    final userEmail = _userData?['email'] ?? '';
    final customerId = _customerData?['customerId'] ?? 'ADN-ID-001';
    final profilePicture = _userData?['profilePicture'] as String?;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.cyberOledBg : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Row(
          children: [
            const CyberPulseDot(color: AppTheme.neonPurple, size: 9),
            const SizedBox(width: 10),
            Text(
              'PROFIL PELANGGAN // IDENTITY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                fontFamily: 'monospace',
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: CyberBadge(
                text: 'SECURE // KYC',
                color: AppTheme.neonGreen,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cyberpunk Profile Header Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberObsidian : Colors.white,
              gradient: isDark
                  ? const LinearGradient(
                      colors: [AppTheme.cyberObsidian, Color(0xFF1D1236)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Colors.white, Color(0xFFF5F3FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.neonPurple.withValues(alpha: 0.6) : const Color(0xFFC084FC),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonPurple.withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar with Neon Ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.neonCyan,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonCyan.withValues(alpha: 0.35),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ShimmerAvatar(
                    imageUrl: profilePicture,
                    radius: 38,
                    backgroundColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF1F5F9),
                    errorWidget: const Icon(
                      LucideIcons.user,
                      size: 40,
                      color: AppTheme.neonCyan,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                // Customer ID Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.neonCyan.withValues(alpha: 0.4)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ID: ',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CopyableText(
                        text: customerId,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.neonCyan,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                        successMessage: 'Customer ID disalin!',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const CyberBadge(
                  text: 'PELANGGAN AKTIF // VERIFIED',
                  color: AppTheme.neonGreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Achievement/Loyalty System (Feature #11)
          const _LoyaltySection(),
          const SizedBox(height: 16),

          // Referral Program (Feature #12)
          const _ReferralCard(),
          const SizedBox(height: 24),

          // Informasi Akun Section
          const TacticalHudHeader(
            title: 'DATA AKUN // TELEMETRI PELANGGAN',
            subtitle: 'INFORMASI IDENTITAS DAN LAYANAN BERLANGGANAN',
            accentColor: AppTheme.neonCyan,
          ),
          const SizedBox(height: 12),
          _ProfileInfoTile(
            icon: LucideIcons.mail,
            title: 'Email Terdaftar',
            value: userEmail.isNotEmpty ? userEmail : 'budi@audira.my.id',
            accentColor: AppTheme.neonCyan,
          ),
          const _ProfileInfoTile(
            icon: LucideIcons.phone,
            title: 'No. Hotline / WhatsApp',
            value: AppConstants.csWhatsApp,
            accentColor: AppTheme.neonGreen,
          ),
          const _ProfileInfoTile(
            icon: LucideIcons.mapPin,
            title: 'Alamat Instalasi ONT',
            value: 'Batam Center, Kepulauan Riau',
            accentColor: AppTheme.neonAmber,
          ),
          const _ProfileInfoTile(
            icon: LucideIcons.wifi,
            title: 'Paket Fiber Aktif',
            value: '50 Mbps Simetris Unlimited',
            accentColor: AppTheme.neonPurple,
          ),
          const SizedBox(height: 20),

          // Dark Mode & Settings Tactical Card
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFCBD5E1),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.neonPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          themeProvider.isDarkMode
                              ? LucideIcons.moon
                              : LucideIcons.sun,
                          color: AppTheme.neonPurple,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Cyber Dark HUD Mode',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        themeProvider.isSystemMode
                            ? 'Sinkron Sistem OS'
                            : themeProvider.isDarkMode
                            ? 'Mode Gelap Aktif'
                            : 'Mode Terang',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        activeThumbColor: AppTheme.neonPurple,
                        activeTrackColor: AppTheme.neonPurple.withValues(alpha: 0.4),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.neonCyan : AppTheme.signalBlue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.info,
                      color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Tentang AUDIRA-NET',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Build v2.4 // Cyberpunk Architecture & Lisensi',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Test Notification Button
          OutlinedButton.icon(
            onPressed: () async {
              await NotificationService().showBillReminderNotification(
                month: 'November 2026',
                dueDate: '25 Nov 2026',
                amount: 350000,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Notifikasi reminder ditransmisikan ke sistem'),
                    backgroundColor: isDark ? AppTheme.cyberObsidian : const Color(0xFF1E293B),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(LucideIcons.bellRing, size: 18),
            label: const Text(
              'TEST NOTIFIKASI REMINDER',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.neonCyan,
              side: BorderSide(color: AppTheme.neonCyan.withValues(alpha: 0.5)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Logout Button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.unifiedLogin,
                (route) => false,
              );
            },
            icon: const Icon(LucideIcons.logOut, size: 18),
            label: const Text(
              'LOGOUT // TERMINATE SESSION',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.neonCrimson,
              side: BorderSide(color: AppTheme.neonCrimson.withValues(alpha: 0.6)),
              backgroundColor: AppTheme.neonCrimson.withValues(alpha: 0.08),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Widget Referral Card Cyberpunk (Feature #12)
class _ReferralCard extends StatelessWidget {
  const _ReferralCard();

  void _shareReferralCode(BuildContext context) {
    const referralCode = 'ADN-REF-2026';
    const message = '''
🎁 Bergabung dengan Jaringan Fiber AUDIRA-NET!

Gunakan kode referral saya: $referralCode
Nikmati koneksi fiber simetris ultra-cepat & cashback saldo tagihan!

Portal: https://audira.my.id
    ''';

    ShareHelper.shareText(
      text: message,
      subject: 'Kode Referral AUDIRA-NET Fiber',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberObsidian : Colors.white,
        gradient: isDark
            ? const LinearGradient(
                colors: [AppTheme.cyberObsidian, Color(0xFF042426)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Colors.white, Color(0xFFF0FDF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppTheme.neonCyan.withValues(alpha: 0.6)
              : const Color(0xFF38BDF8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.neonCyan : AppTheme.signalBlue)
                .withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: (isDark ? AppTheme.neonCyan : AppTheme.signalBlue)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (isDark ? AppTheme.neonCyan : AppTheme.signalBlue)
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  LucideIcons.gift,
                  color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CyberBadge(
                      text: 'PROGRAM AFILIASI',
                      color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AJAK TEMAN & DAPAT REWARD',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Dapatkan cashback saldo hingga Rp 100.000 per subscriber',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? AppTheme.neonCyan.withValues(alpha: 0.35)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KODE REFERRAL UNIK ANDA:',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CopyableText(
                        text: 'ADN-REF-2026',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                        successMessage: 'Kode referral disalin!',
                        iconColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CyberActionButton(
            text: 'BAGIKAN KODE REFERRAL',
            icon: LucideIcons.share2,
            color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
            isFullWidth: true,
            onPressed: () => _shareReferralCode(context),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.users,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '3 rekan telah teraktivasi',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                const CyberBadge(
                  text: '+RP 150K REWARD',
                  color: AppTheme.neonGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Loyalty Section Cyberpunk (Feature #11)
class _LoyaltySection extends StatelessWidget {
  const _LoyaltySection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberObsidian : Colors.white,
        gradient: isDark
            ? const LinearGradient(
                colors: [AppTheme.cyberObsidian, Color(0xFF281C06)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Colors.white, Color(0xFFFFFBEB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppTheme.neonAmber.withValues(alpha: 0.6)
              : const Color(0xFFF59E0B),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonAmber.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              CyberPulseDot(color: AppTheme.neonAmber, size: 8),
              SizedBox(width: 8),
              Text(
                'LOYALTY MATRIX // REWARDS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.neonAmber,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? AppTheme.neonAmber.withValues(alpha: 0.3)
                    : const Color(0xFFFDE68A),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL REWARD POIN:',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const CyberBadge(
                      text: '2,450 PTS',
                      color: AppTheme.neonAmber,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.neonAmber,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '550 poin lagi menuju tier ELITE GOLD',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'HOLOGRAPHIC BADGES // MILESTONE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
              fontFamily: 'monospace',
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _AchievementBadge(
                icon: LucideIcons.clock,
                label: '6 BULAN',
                unlocked: true,
              ),
              _AchievementBadge(
                icon: LucideIcons.checkCircle2,
                label: 'ON-TIME',
                unlocked: true,
              ),
              _AchievementBadge(
                icon: LucideIcons.trophy,
                label: '1 TAHUN',
                unlocked: false,
              ),
              _AchievementBadge(
                icon: LucideIcons.share2,
                label: 'REFERRAL',
                unlocked: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool unlocked;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: unlocked
                ? (isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFFEF3C7))
                : (isDark ? AppTheme.cyberSurfaceCard.withValues(alpha: 0.4) : const Color(0xFFF1F5F9)),
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked
                  ? (isDark ? AppTheme.neonAmber : const Color(0xFFD97706))
                  : (isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCBD5E1)),
              width: 1.5,
            ),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: AppTheme.neonAmber.withValues(alpha: isDark ? 0.3 : 0.15),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: unlocked
                ? (isDark ? AppTheme.neonAmber : const Color(0xFFD97706))
                : (isDark ? Colors.white24 : const Color(0xFF94A3B8)),
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: unlocked
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// Profile Info Tile Widget
class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? accentColor;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? (isDark ? AppTheme.neonCyan : AppTheme.signalBlue);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accent.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          CopyIconButton(
            text: value,
            successMessage: '$title disalin!',
            color: accent,
          ),
        ],
      ),
    );
  }
}

// ==================== CATEGORY OPTION WIDGET ====================
class _CategoryOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _CategoryOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.neonAmber.withValues(alpha: isDark ? 0.12 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.neonAmber.withValues(alpha: 0.2)
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.neonAmber.withValues(alpha: 0.6)
                        : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? (isDark ? AppTheme.neonAmber : const Color(0xFFD97706))
                      : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF0F172A))
                            : (isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF334155)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              // Custom neon radio indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.neonAmber
                        : Colors.white24,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.neonAmber,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonAmber,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== MAINTENANCE ALERT BANNER ====================
class _MaintenanceAlertBanner extends StatefulWidget {
  @override
  State<_MaintenanceAlertBanner> createState() =>
      _MaintenanceAlertBannerState();
}

class _MaintenanceAlertBannerState extends State<_MaintenanceAlertBanner> {
  List<Map<String, dynamic>> _upcomingMaintenance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingMaintenance();
  }

  Future<void> _loadUpcomingMaintenance() async {
    try {
      final schedules = await FirebaseService.instance.getUpcomingMaintenance();
      if (mounted) {
        setState(() {
          _upcomingMaintenance = schedules
              .take(1)
              .toList(); // Show only first one
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _upcomingMaintenance.isEmpty) {
      return const SizedBox.shrink();
    }

    final maintenance = _upcomingMaintenance.first;
    final scheduledDate = DateTime.parse(maintenance['scheduledDate']);
    final now = DateTime.now();
    final daysUntil = scheduledDate.difference(now).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.deepOrange.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MaintenanceAlertPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.alertTriangle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pemeliharaan Terjadwal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        daysUntil == 0
                            ? 'Hari ini • ${maintenance['startTime']} - ${maintenance['endTime']}'
                            : '$daysUntil hari lagi • ${DateFormat('d MMM').format(scheduledDate)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== PRIORITY CHIP WIDGET ====================
class _PriorityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.18)
                : (isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFCBD5E1)),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontFamily: 'monospace',
                  color: isSelected ? color : (isDark ? Colors.white70 : const Color(0xFF334155)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Advanced Analytics Dashboard (Feature #14)
// Reserved for future implementation
// Uncomment when ready to use
/*
class _AdvancedAnalyticsDashboard extends StatelessWidget {
  const _AdvancedAnalyticsDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview Cards
          Row(
            children: [
              Expanded(
                child: _AnalyticsCard(
                  title: 'Total Pemakaian',
                  value: '456 GB',
                  subtitle: 'Bulan ini',
                  icon: LucideIcons.hardDrive,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnalyticsCard(
                  title: 'Avg Speed',
                  value: '48.5 Mbps',
                  subtitle: '7 hari terakhir',
                  icon: LucideIcons.gauge,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AnalyticsCard(
                  title: 'Uptime',
                  value: '99.2%',
                  subtitle: 'Bulan ini',
                  icon: LucideIcons.checkCircle2,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnalyticsCard(
                  title: 'Latency',
                  value: '12 ms',
                  subtitle: 'Rata-rata',
                  icon: LucideIcons.activity,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Monthly Usage Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penggunaan Bulanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _MonthlyBar(month: 'Jun', gb: 380, maxGb: 500),
                      _MonthlyBar(month: 'Jul', gb: 420, maxGb: 500),
                      _MonthlyBar(month: 'Aug', gb: 390, maxGb: 500),
                      _MonthlyBar(month: 'Sep', gb: 450, maxGb: 500),
                      _MonthlyBar(month: 'Okt', gb: 410, maxGb: 500),
                      _MonthlyBar(
                        month: 'Nov',
                        gb: 456,
                        maxGb: 500,
                        isCurrentMonth: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Speed Test History
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                    const Text(
                      'Riwayat Speed Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpeedTestPage(),
                          ),
                        );
                      },
                      child: const Text('Tes Sekarang'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SpeedTestHistoryItem(
                  date: '26 Nov 2025, 14:30',
                  download: 48.2,
                  upload: 42.1,
                  ping: 12,
                ),
                _SpeedTestHistoryItem(
                  date: '25 Nov 2025, 09:15',
                  download: 49.8,
                  upload: 43.5,
                  ping: 11,
                ),
                _SpeedTestHistoryItem(
                  date: '24 Nov 2025, 20:45',
                  download: 47.1,
                  upload: 41.2,
                  ping: 13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

// Supporting classes for Advanced Analytics Dashboard
// Reserved for future implementation
/*
class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final MaterialColor color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.shade400, color.shade600]),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyBar extends StatelessWidget {
  final String month;
  final int gb;
  final int maxGb;
  final bool isCurrentMonth;

  const _MonthlyBar({
    required this.month,
    required this.gb,
    required this.maxGb,
    required this.isCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final heightPercent = gb / maxGb;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${gb}GB',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrentMonth
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isCurrentMonth
                    ? Colors.indigo.shade700
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 150 * heightPercent,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isCurrentMonth
                      ? [Colors.indigo.shade600, Colors.indigo.shade400]
                      : [Colors.indigo.shade300, Colors.indigo.shade200],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              month,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrentMonth
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isCurrentMonth
                    ? Colors.indigo.shade700
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedTestHistoryItem extends StatelessWidget {
  final String date;
  final double download;
  final double upload;
  final int ping;

  const _SpeedTestHistoryItem({
    required this.date,
    required this.download,
    required this.upload,
    required this.ping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.gauge, color: Colors.indigo.shade600, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.download,
                      size: 14,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$download Mbps',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(LucideIcons.upload, size: 14, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '$upload Mbps',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      LucideIcons.activity,
                      size: 14,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ping}ms',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
