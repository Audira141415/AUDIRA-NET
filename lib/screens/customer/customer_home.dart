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
import 'usage_analytics_page.dart';
import 'wifi_management_page.dart';

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
        body: _pages[_selectedIndex],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotPage()),
            );
          },
          backgroundColor: Colors.blue,
          tooltip: 'Tanya Audi AI',
          child: const Icon(Icons.smart_toy, color: Colors.white),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            height: 65,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Tagihan',
              ),
              NavigationDestination(
                icon: Icon(Icons.support_agent_outlined),
                selectedIcon: Icon(Icons.support_agent),
                label: 'Bantuan',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
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
      if (_userData == null) {
        throw Exception('User not logged in');
      }

      // Get customer data from Firestore
      final customer = await FirebaseService.instance.getCustomerByUserId(
        _userData!['id'].toString(),
      );

      if (customer == null) {
        throw Exception('Customer data not found');
      }

      if (mounted) {
        setState(() {
          _customerData = customer;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadCustomerData,
        child: CustomScrollView(
          slivers: [
            // Modern App Bar dengan Gradient
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade500,
                        Colors.cyan.shade400,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
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
                                Colors.white.withValues(alpha: 0.1),
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
                    // Status Layanan Card
                    if (_isLoading)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 18,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 14,
                              width: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 16,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Gagal Memuat Data',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Silakan coba lagi',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _loadCustomerData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Muat Ulang'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_customerData != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _customerData!['status'] == 'active'
                                  ? Colors.green.shade400
                                  : Colors.orange.shade400,
                              _customerData!['status'] == 'active'
                                  ? Colors.green.shade600
                                  : Colors.orange.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_customerData!['status'] == 'active'
                                          ? Colors.green
                                          : Colors.orange)
                                      .withValues(alpha: 0.3),
                              blurRadius: 15,
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
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _customerData!['status'] == 'active'
                                        ? 'Layanan Aktif'
                                        : 'Layanan ${_customerData!['status'] ?? 'Tidak Aktif'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Network Status Indicator (Feature #4)
                                _NetworkStatusBadge(),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ID: ${_customerData!['customerId'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Paket: ${_customerData!['packageName'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatCurrency(
                                      _customerData!['monthlyFee'],
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Quick Pay Button (Feature #3)
                            ElevatedButton.icon(
                              onPressed: () {
                                final customerHomeState = context
                                    .findAncestorStateOfType<
                                      _CustomerHomePageState
                                    >();
                                customerHomeState?.navigateToIndex(1);
                              },
                              icon: const Icon(Icons.payment_rounded, size: 20),
                              label: const Text('Bayar Tagihan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    _customerData!['status'] == 'active'
                                    ? Colors.green.shade600
                                    : Colors.orange.shade600,
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
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

                    // Stats Grid - 2x2
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: const [
                        _StatCard(
                          icon: Icons.speed_rounded,
                          title: 'Kecepatan',
                          value: '45.2 Mbps',
                          color: Colors.blue,
                        ),
                        _StatCard(
                          icon: Icons.data_usage_rounded,
                          title: 'Penggunaan',
                          value: '125.5 GB',
                          color: Colors.orange,
                        ),
                        _StatCard(
                          icon: Icons.signal_wifi_4_bar_rounded,
                          title: 'Uptime',
                          value: '99.8%',
                          color: Colors.green,
                        ),
                        _StatCard(
                          icon: Icons.router_rounded,
                          title: 'Ping',
                          value: '12 ms',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Mini Bandwidth Chart (Feature #6)
                    _MiniBandwidthChart(
                      userId: _userData?['id']?.toString() ?? '',
                    ),
                    const SizedBox(height: 24),

                    // Aksi Cepat Section
                    const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.payment_rounded,
                            label: 'Bayar Tagihan',
                            color: Colors.blue,
                            onTap: () {
                              // Navigate ke halaman Tagihan
                              final customerHomeState = context
                                  .findAncestorStateOfType<
                                    _CustomerHomePageState
                                  >();
                              customerHomeState?.navigateToIndex(1);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.support_agent_rounded,
                            label: 'Buat Tiket',
                            color: Colors.orange,
                            onTap: () {
                              // Navigate ke halaman Bantuan
                              final customerHomeState = context
                                  .findAncestorStateOfType<
                                    _CustomerHomePageState
                                  >();
                              customerHomeState?.navigateToIndex(2);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.speed_rounded,
                            label: 'Speed Test',
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SpeedTestPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.data_usage_rounded,
                            label: 'Data Usage',
                            color: Colors.purple,
                            onTap: () async {
                              // Get current user ID
                              final currentUserData =
                                  AuthService.instance.currentUserData;
                              if (currentUserData == null || !context.mounted) {
                                return;
                              }

                              // Get customer data
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.info_rounded,
                            label: 'Info Layanan',
                            color: Colors.teal,
                            onTap: () {
                              // Show dialog info layanan
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Row(
                                    children: const [
                                      Icon(
                                        Icons.info_rounded,
                                        color: Colors.purple,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Info Layanan'),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Layanan Pelanggan 24/7',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '📞 Call Center: ${AppConstants.csCallCenter}',
                                      ),
                                      Text('📧 Email: ${AppConstants.csEmail}'),
                                      Text(
                                        '💬 WhatsApp: ${AppConstants.csWhatsApp}',
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Jam Operasional:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text('Senin - Jumat: 08:00 - 20:00'),
                                      Text('Sabtu - Minggu: 09:00 - 17:00'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
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
                          child: _QuickActionButton(
                            icon: Icons.upgrade_rounded,
                            label: 'Ubah Paket',
                            color: Colors.deepPurple,
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.analytics_rounded,
                            label: 'Analytics',
                            color: Colors.indigo,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UsageAnalyticsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // PHASE 3 Features
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.card_giftcard,
                            label: 'Loyalty & Rewards',
                            color: Colors.purple,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.loyaltyRewards,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.wifi,
                            label: 'WiFi Management',
                            color: Colors.deepPurple,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Lapor Gangguan Button (Feature #8)
                    _LaporGangguanButton(),
                    const SizedBox(height: 24),

                    // Info Penting Section
                    const Text(
                      'Info Penting',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _InfoCard(
                      icon: Icons.calendar_today_rounded,
                      title: 'Jatuh Tempo Pembayaran',
                      subtitle: '25 November 2025',
                      color: Colors.red,
                    ),
                    const _InfoCard(
                      icon: Icons.announcement_rounded,
                      title: 'Pemeliharaan Jaringan',
                      subtitle: 'Minggu, 15 Nov 2025 | 01:00 - 05:00 WIB',
                      color: Colors.orange,
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

// Widget Lapor Gangguan Button (Feature #8)
class _LaporGangguanButton extends StatelessWidget {
  const _LaporGangguanButton();

  void _showReportIssueDialog(BuildContext context) {
    final TextEditingController descController = TextEditingController();
    String selectedType = 'Internet Mati';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.report_problem_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Lapor Gangguan'),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jenis Gangguan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items:
                      [
                        'Internet Mati',
                        'Internet Lambat',
                        'Tidak Stabil',
                        'Lainnya',
                      ].map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deskripsi Masalah',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Jelaskan gangguan yang Anda alami...',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Validate input
              if (descController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon jelaskan masalah yang Anda alami'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Show loading
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

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

                // Create ticket data
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

                // Save to Firebase
                await firebaseService.createTicket(ticketData);

                // Close loading and show success
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Laporan gangguan berhasil dikirim!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                // Close loading and show error
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Gagal mengirim laporan: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Kirim Laporan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showReportIssueDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.report_problem_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Lapor Gangguan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Quick Action Button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final MaterialColor color;
  final VoidCallback onTap;

  const _QuickActionButton({
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
            gradient: LinearGradient(colors: [color[400]!, color[600]!]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Info Card
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final MaterialColor color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      'subtitle': 'Hanya Rp 450.000/bulan',
      'gradient': [Colors.purple.shade400, Colors.purple.shade600],
      'icon': Icons.rocket_launch_rounded,
      'action': 'upgrade',
      'details': {
        'title': 'Upgrade ke Paket 100 Mbps',
        'description':
            'Nikmati kecepatan internet super cepat untuk gaming, streaming 4K, dan video conference tanpa lag!',
        'benefits': [
          '✅ Kecepatan 100 Mbps',
          '✅ Unlimited Quota',
          '✅ Gratis Instalasi',
          '✅ Priority Support 24/7',
          '✅ Free Router Upgrade',
          '✅ Cocok untuk 5-6 perangkat',
        ],
        'price': 'Rp 500.000/bulan',
        'discount': 'Diskon 10% bulan pertama: Rp 450.000',
      },
    },
    {
      'title': 'Promo Akhir Tahun',
      'subtitle': 'Diskon 20% untuk pelanggan baru',
      'gradient': [Colors.orange.shade400, Colors.orange.shade600],
      'icon': Icons.local_offer_rounded,
      'action': 'promo',
      'details': {
        'title': 'Promo Akhir Tahun 2025',
        'description':
            'Dapatkan diskon spesial untuk pelanggan baru yang berlangganan sebelum 31 Desember 2025!',
        'benefits': [
          '🎉 Diskon 20% untuk 3 bulan pertama',
          '🎁 Gratis biaya instalasi',
          '🎁 Gratis Modem WiFi 6',
          '⚡ Aktivasi dalam 1 hari',
          '📞 Gratis konsultasi teknis',
        ],
        'terms':
            'Syarat & ketentuan berlaku. Promo terbatas untuk 100 pelanggan pertama.',
      },
    },
    {
      'title': 'Refer & Earn',
      'subtitle': 'Ajak teman, dapat cashback',
      'gradient': [Colors.teal.shade400, Colors.teal.shade600],
      'icon': Icons.card_giftcard_rounded,
      'action': 'referral',
      'details': {
        'title': 'Program Referral',
        'description':
            'Ajak teman dan keluarga untuk berlangganan AudiraNet dan dapatkan reward menarik!',
        'benefits': [
          '💰 Cashback Rp 100.000 per referral',
          '🎁 Bonus tambahan untuk 5 referral: Rp 1.000.000',
          '⭐ Unlimited referral, unlimited reward',
          '📱 Kode referral otomatis di profil Anda',
          '💳 Cashback langsung ke saldo akun',
        ],
        'howto': 'Bagikan kode referral Anda → Teman daftar → Dapat cashback!',
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

    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detail promo tidak tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: promo['gradient'] as List<Color>,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      promo['icon'] as IconData,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      details['title'] as String,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details['description'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Keuntungan:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(details['benefits'] as List<String>).map(
                        (benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (details.containsKey('price')) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Harga:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                details['price'] as String,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (details.containsKey('discount')) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    details['discount'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (details.containsKey('terms')) ...[
                        const SizedBox(height: 16),
                        Text(
                          details['terms'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (details.containsKey('howto')) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  details['howto'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade900,
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: (promo['gradient'] as List<Color>)[0],
                          ),
                        ),
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
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
                                content: Text(
                                  'Hubungi CS untuk info lebih lanjut!',
                                ),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              (promo['gradient'] as List<Color>)[0],
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          action == 'upgrade'
                              ? 'Upgrade Sekarang'
                              : action == 'referral'
                              ? 'Lihat Kode Referral'
                              : 'Hubungi CS',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _promos.length,
            itemBuilder: (context, index) {
              final promo = _promos[index];
              return InkWell(
                onTap: () => _showPromoDetails(context, promo),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: promo['gradient'] as List<Color>,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (promo['gradient'] as List<Color>)[0].withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          promo['icon'] as IconData,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              promo['title'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              promo['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promos.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.blue.shade600
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
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

// Widget Mini Bandwidth Chart (Feature #6)
class _MiniBandwidthChart extends StatelessWidget {
  final String userId;

  const _MiniBandwidthChart({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.blue, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Penggunaan Bandwidth',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '7 Hari Terakhir',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simple bar chart visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniChartBar(height: 60, day: 'Sen', value: '12 GB'),
              _MiniChartBar(height: 45, day: 'Sel', value: '9 GB'),
              _MiniChartBar(height: 70, day: 'Rab', value: '15 GB'),
              _MiniChartBar(height: 55, day: 'Kam', value: '11 GB'),
              _MiniChartBar(height: 80, day: 'Jum', value: '18 GB'),
              _MiniChartBar(
                height: 90,
                day: 'Sab',
                value: '22 GB',
                isToday: true,
              ),
              _MiniChartBar(height: 40, day: 'Min', value: '8 GB'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatLabel(
                label: 'Total Minggu Ini',
                value: '95 GB',
                color: Colors.blue,
              ),
              _StatLabel(
                label: 'Rata-rata/Hari',
                value: '13.6 GB',
                color: Colors.orange,
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isToday
                      ? [Colors.blue.shade600, Colors.blue.shade400]
                      : [Colors.blue.shade300, Colors.blue.shade200],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.blue.shade700 : Colors.grey.shade700,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Widget Payment Reminder Section (Feature #2)
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
      // Get customer data first
      final customer = await FirebaseService.instance.getCustomerByUserId(
        widget.userId,
      );
      if (customer == null) return;

      // Get all bills for this customer
      final allBills = await FirebaseService.instance.getBillsByCustomerId(
        customer['customerId'].toString(),
      );

      // Filter unpaid bills
      final unpaid = allBills.where((bill) {
        final status = bill['status']?.toString().toLowerCase() ?? '';
        return status != 'paid' && status != 'lunas';
      }).toList();

      // Sort by due date (earliest first)
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
      return 'Terlambat ${-difference} hari';
    } else if (difference == 0) {
      return 'Jatuh tempo hari ini';
    } else if (difference <= 7) {
      return 'Jatuh tempo $difference hari lagi';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getUrgencyColor(Timestamp? timestamp) {
    if (timestamp == null) return Colors.grey;

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) return Colors.red;
    if (difference <= 3) return Colors.orange;
    if (difference <= 7) return Colors.yellow.shade700;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Memuat tagihan...'),
          ],
        ),
      );
    }

    if (_unpaidBills.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstBill = _unpaidBills.first;
    final hasMultiple = _unpaidBills.length > 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getUrgencyColor(
              firstBill['dueDate'] as Timestamp?,
            ).withValues(alpha: 0.1),
            _getUrgencyColor(
              firstBill['dueDate'] as Timestamp?,
            ).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getUrgencyColor(
            firstBill['dueDate'] as Timestamp?,
          ).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: _getUrgencyColor(firstBill['dueDate'] as Timestamp?),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasMultiple
                          ? '${_unpaidBills.length} Tagihan Belum Dibayar'
                          : 'Tagihan Belum Dibayar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getUrgencyColor(
                          firstBill['dueDate'] as Timestamp?,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDueDate(firstBill['dueDate'] as Timestamp?),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    _formatCurrency(
                      _unpaidBills.fold<num>(
                        0,
                        (total, bill) => total + (bill['amount'] ?? 0),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getUrgencyColor(
                        firstBill['dueDate'] as Timestamp?,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Navigate to payment page
              final customerHomeState = context
                  .findAncestorStateOfType<_CustomerHomePageState>();
              customerHomeState?.navigateToIndex(1); // Go to Tagihan tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getUrgencyColor(
                firstBill['dueDate'] as Timestamp?,
              ),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Bayar Sekarang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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

// Widget Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final MaterialColor color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Tagihan & Pembayaran'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
              tooltip: 'Filter',
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Tagihan Aktif', icon: Icon(Icons.receipt_long)),
              Tab(text: 'Riwayat', icon: Icon(Icons.history)), // Feature #9
            ],
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
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari bulan tagihan...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
        ),

        // Auto-Pay Toggle (Feature #13)
        _AutoPayToggle(),

        // Filter Chips
        if (_statusFilter != 'all')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontSize: 12)),
                Chip(
                  label: Text(
                    _statusFilter == 'paid' ? 'Lunas' : 'Belum Bayar',
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
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
                        icon: Icons.receipt_long_outlined,
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
                        icon: Icons.search_off,
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
                      return SwipeableListItem(
                        key: Key('bill_${bill['id']}'),
                        onEdit: bill['status'] != 'paid'
                            ? () async {
                                // Quick pay
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                      billId: bill['id'],
                                      billMonth: bill['billMonth'],
                                      amount: bill['amount'].toDouble(),
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
                          billId: bill['id']?.toString() ?? '',
                          month: bill['billMonth']?.toString() ?? 'Unknown',
                          amount: bill['amount'] ?? 0,
                          dueDate: bill['dueDate']?.toString() ?? 'Unknown',
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
              Icons.autorenew,
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
          icon: Icons.receipt_outlined,
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
              child: const Icon(Icons.check, color: Colors.white, size: 16),
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
                      Icons.calendar_today,
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
                    Icon(Icons.payment, size: 14, color: Colors.grey.shade600),
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

// Widget Bill Card
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
    // Parse amount dengan aman (bisa int atau String dari Firestore)
    final int amountValue = amount is int
        ? amount
        : int.tryParse(amount.toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPaid
              ? [Colors.green.shade50, Colors.green.shade100]
              : [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
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
              Text(
                month,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Tagihan',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${amountValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (!isPaid)
                ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Bayar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Jatuh Tempo: $dueDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (isPaid)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, size: 20),
                      onPressed: () async {
                        try {
                          // Show loading
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Generating PDF...'),
                              duration: Duration(seconds: 1),
                            ),
                          );

                          // Get customer data
                          final currentUserData =
                              AuthService.instance.currentUserData;
                          if (currentUserData == null) return;

                          final customer = await FirebaseService.instance
                              .getCustomerByUserId(
                                currentUserData['id'].toString(),
                              );
                          if (customer == null) return;

                          // Prepare bill data for PDF
                          final billData = {
                            'customerName': customer['name'],
                            'customerId': customer['customerId'],
                            'billMonth': month,
                            'amount': amount.toDouble(),
                            'dueDate': dueDate,
                            'status': 'paid',
                            'paidDate': dueDate, // Assume paid on due date
                            'packageName': customer['package'],
                            'installAddress': customer['installAddress'],
                          };

                          // Generate PDF
                          final pdfFile = await PdfGeneratorService.instance
                              .generateInvoicePdf(billData);

                          if (!context.mounted) return;

                          // Show success and options
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Invoice PDF Generated'),
                              content: Text('File saved to:\n${pdfFile.path}'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                                FilledButton.icon(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await PdfGeneratorService.instance.sharePdf(
                                      pdfFile,
                                    );
                                  },
                                  icon: const Icon(Icons.share),
                                  label: const Text('Share'),
                                ),
                                FilledButton.icon(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await PdfGeneratorService.instance.printPdf(
                                      pdfFile,
                                    );
                                  },
                                  icon: const Icon(Icons.print),
                                  label: const Text('Print'),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      tooltip: 'Download PDF',
                      color: Colors.red.shade700,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      onPressed: () async {
                        await ShareHelper.shareBillingReport(
                          customerName: 'Budi Santoso',
                          period: month,
                          totalAmount:
                              'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        );
                      },
                      tooltip: 'Bagikan Bukti Pembayaran',
                      color: Colors.green.shade700,
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan Gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade600, Colors.orange.shade400],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Tiket Baru',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Laporkan masalah Anda',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori Masalah
                        const Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 20,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Kategori Masalah',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              _CategoryOption(
                                icon: Icons.wifi_off,
                                title: 'Masalah Teknis',
                                subtitle: 'Internet lambat, tidak bisa connect',
                                value: 'teknis',
                                groupValue: selectedCategory,
                                onChanged: (value) {
                                  setState(() => selectedCategory = value!);
                                },
                              ),
                              Divider(height: 1, color: Colors.grey.shade300),
                              _CategoryOption(
                                icon: Icons.receipt_long,
                                title: 'Tagihan & Pembayaran',
                                subtitle: 'Pertanyaan seputar billing',
                                value: 'billing',
                                groupValue: selectedCategory,
                                onChanged: (value) {
                                  setState(() => selectedCategory = value!);
                                },
                              ),
                              Divider(height: 1, color: Colors.grey.shade300),
                              _CategoryOption(
                                icon: Icons.upgrade,
                                title: 'Upgrade Paket',
                                subtitle: 'Ingin upgrade atau downgrade',
                                value: 'upgrade',
                                groupValue: selectedCategory,
                                onChanged: (value) {
                                  setState(() => selectedCategory = value!);
                                },
                              ),
                              Divider(height: 1, color: Colors.grey.shade300),
                              _CategoryOption(
                                icon: Icons.help_outline,
                                title: 'Lainnya',
                                subtitle: 'Pertanyaan umum',
                                value: 'lainnya',
                                groupValue: selectedCategory,
                                onChanged: (value) {
                                  setState(() => selectedCategory = value!);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Judul Masalah
                        const Row(
                          children: [
                            Icon(Icons.title, size: 20, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Judul Masalah',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: subjectController,
                          decoration: InputDecoration(
                            hintText:
                                'Contoh: Internet putus-putus sejak kemarin',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.edit,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Deskripsi Detail
                        const Row(
                          children: [
                            Icon(
                              Icons.description,
                              size: 20,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Deskripsi Detail',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText:
                                'Jelaskan masalah secara detail...\n\n• Kapan mulai terjadi?\n• Sudah dicoba apa saja?\n• Perangkat yang terpengaruh?',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Zona Lokasi
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Zona Lokasi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedZone,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: const Icon(
                                Icons.location_city,
                                color: AppTheme.primaryCyan,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Batam Center',
                                child: Text('Batam Center'),
                              ),
                              DropdownMenuItem(
                                value: 'Piayu',
                                child: Text('Piayu'),
                              ),
                              DropdownMenuItem(
                                value: 'Baloi',
                                child: Text('Baloi'),
                              ),
                              DropdownMenuItem(
                                value: 'Nagoya',
                                child: Text('Nagoya'),
                              ),
                              DropdownMenuItem(
                                value: 'Batu Aji',
                                child: Text('Batu Aji'),
                              ),
                              DropdownMenuItem(
                                value: 'Sekupang',
                                child: Text('Sekupang'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => selectedZone = value!);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tingkat Prioritas
                        const Row(
                          children: [
                            Icon(
                              Icons.priority_high,
                              size: 20,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tingkat Prioritas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _PriorityChip(
                                label: 'Rendah',
                                icon: Icons.arrow_downward,
                                color: Colors.green,
                                isSelected: selectedPriority == 'low',
                                onTap: () {
                                  setState(() => selectedPriority = 'low');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PriorityChip(
                                label: 'Sedang',
                                icon: Icons.remove,
                                color: Colors.orange,
                                isSelected: selectedPriority == 'medium',
                                onTap: () {
                                  setState(() => selectedPriority = 'medium');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PriorityChip(
                                label: 'Tinggi',
                                icon: Icons.arrow_upward,
                                color: Colors.red,
                                isSelected: selectedPriority == 'high',
                                onTap: () {
                                  setState(() => selectedPriority = 'high');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Info Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tim support kami akan merespons tiket Anda dalam 1x24 jam',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontSize: 12,
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () async {
                            if (subjectController.text.isEmpty ||
                                descriptionController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Mohon lengkapi semua field',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              // Add category to subject
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
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Tiket berhasil dibuat! Tim kami akan segera menghubungi Anda.',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 4),
                                ),
                              );

                              _loadTickets();
                            } catch (e) {
                              // Error creating ticket
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text('Gagal membuat tiket'),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Kirim Tiket',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadTickets,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Buat Tiket Baru Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showCreateTicketDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Buat Tiket Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tiket Saya',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _isLoading
                ? Column(
                    children: List.generate(
                      3,
                      (index) => const SkeletonCard(
                        margin: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  )
                : _tickets.isEmpty
                ? const EnhancedEmptyState(
                    icon: Icons.support_agent_outlined,
                    title: 'Belum Ada Tiket',
                    description:
                        'Anda belum memiliki tiket support. Buat tiket baru jika mengalami masalah.',
                    actionLabel: 'Buat Tiket',
                  )
                : Column(
                    children: _tickets.map((ticket) {
                      return _TicketCard(
                        ticketId: ticket['ticketId'],
                        subject: ticket['subject'],
                        description: ticket['description'],
                        status: ticket['status'],
                        priority: ticket['priority'],
                        createdAt: ticket['createdAt'],
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

// Widget Ticket Card
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
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'open':
        return 'Dalam Proses';
      case 'resolved':
        return 'Selesai';
      default:
        return status;
    }
  }

  String _getPriorityText() {
    switch (priority) {
      case 'low':
        return 'Rendah';
      case 'medium':
        return 'Sedang';
      case 'high':
        return 'Tinggi';
      default:
        return priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final date = DateTime.parse(createdAt);
    final formattedDate =
        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticketId,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getPriorityText(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Profil Saya'),
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final userName = _userData?['name'] ?? 'User';
    final userEmail = _userData?['email'] ?? '';
    final customerId = _customerData?['customerId'] ?? 'N/A';
    final profilePicture = _userData?['profilePicture'] as String?;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Avatar - Using ShimmerAvatar for profile images
                ShimmerAvatar(
                  imageUrl: profilePicture,
                  radius: 40,
                  backgroundColor: Colors.white,
                  errorWidget: Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                CopyableText(
                  text: customerId,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  successMessage: 'Customer ID disalin!',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pelanggan Aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Achievement/Loyalty System (Feature #11)
          _LoyaltySection(),
          const SizedBox(height: 16),

          // Referral Program (Feature #12)
          _ReferralCard(),
          const SizedBox(height: 24),

          // Informasi Akun Section
          const Text(
            'Informasi Akun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _ProfileInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'budi@email.com',
          ),
          const _ProfileInfoTile(
            icon: Icons.phone_outlined,
            title: 'No. Telepon',
            value: AppConstants.csWhatsApp,
          ),
          const _ProfileInfoTile(
            icon: Icons.location_on_outlined,
            title: 'Alamat',
            value: 'Jl. Sudirman No. 123, Jakarta Pusat',
          ),
          const _ProfileInfoTile(
            icon: Icons.wifi_outlined,
            title: 'Paket Internet',
            value: '50 Mbps Unlimited',
          ),
          const SizedBox(height: 24),

          // Dark Mode & Settings
          Card(
            color: Colors.white,
            child: Column(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Colors.purple.shade700,
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        themeProvider.isSystemMode
                            ? 'Mengikuti Sistem'
                            : themeProvider.isDarkMode
                            ? 'Aktif'
                            : 'Non-aktif',
                      ),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        activeThumbColor: Colors.purple.shade700,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Colors.purple.shade700,
                  ),
                  title: const Text('Tentang Aplikasi'),
                  subtitle: const Text('Versi, changelog, dan lainnya'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

          // Test Notification Button (untuk demo)
          OutlinedButton.icon(
            onPressed: () async {
              await NotificationService().showBillReminderNotification(
                month: 'November 2025',
                dueDate: '25 Nov 2025',
                amount: 350000,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifikasi dikirim! Cek notification bar'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('Test Notifikasi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              side: BorderSide(color: Colors.blue.shade700),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Logout Button
          FilledButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.unifiedLogin,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text(
              'Keluar',
              style: TextStyle(
                inherit: false,
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Referral Card (Feature #12)
class _ReferralCard extends StatelessWidget {
  const _ReferralCard();

  void _shareReferralCode(BuildContext context) {
    const referralCode = 'ADN-REF-2025001';
    const message =
        '''
🎁 Gabung Audira Digital Network sekarang!

Pakai kode referral saya: $referralCode
Dapatkan diskon 20% untuk 3 bulan pertama!

Download aplikasi: https://audiranet.id/app
    ''';

    // Implement actual share using ShareHelper
    ShareHelper.shareText(
      text: message,
      subject: 'Kode Referral Audira Digital Network',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 15,
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
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajak Teman',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Dapat cashback hingga Rp 100.000',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kode Referral Anda',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CopyableText(
                        text: 'ADN-REF-2025001',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        successMessage: 'Kode referral berhasil disalin!',
                        iconColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareReferralCode(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Bagikan Kode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '3 teman telah bergabung',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+ Rp 150K',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
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

// Widget Profile Info Tile
// Widget Loyalty Section (Feature #11)
class _LoyaltySection extends StatelessWidget {
  const _LoyaltySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade300, Colors.amber.shade500],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Loyalty Program',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Poin Anda',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '2,450 pts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '550 poin lagi untuk level Gold',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Achievements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AchievementBadge(
                icon: Icons.access_time,
                label: '6 Bulan',
                unlocked: true,
              ),
              _AchievementBadge(
                icon: Icons.payment,
                label: 'On-time',
                unlocked: true,
              ),
              _AchievementBadge(
                icon: Icons.star,
                label: '1 Tahun',
                unlocked: false,
              ),
              _AchievementBadge(
                icon: Icons.people,
                label: 'Referral',
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
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: unlocked
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked
                  ? Colors.amber.shade700
                  : Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked
                ? Colors.amber.shade700
                : Colors.white.withValues(alpha: 0.5),
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: unlocked
                ? Colors.white
                : Colors.white.withValues(alpha: 0.7),
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
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

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.purple.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          CopyIconButton(
            text: value,
            successMessage: '$title disalin!',
            color: Colors.purple.shade700,
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
    final isSelected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.orange.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.orange.shade700
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
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isSelected
                            ? Colors.orange.shade900
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Replace deprecated Radio with custom indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.orange.shade700
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.shade700,
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
                    Icons.warning_amber_rounded,
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
                  Icons.arrow_forward_ios,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                  color: isSelected ? color : Colors.grey.shade700,
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
                  icon: Icons.cloud_download,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnalyticsCard(
                  title: 'Avg Speed',
                  value: '48.5 Mbps',
                  subtitle: '7 hari terakhir',
                  icon: Icons.speed,
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
                  icon: Icons.check_circle,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnalyticsCard(
                  title: 'Latency',
                  value: '12 ms',
                  subtitle: 'Rata-rata',
                  icon: Icons.network_ping,
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
          Icon(Icons.speed, color: Colors.indigo.shade600, size: 28),
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
                      Icons.download,
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
                    Icon(Icons.upload, size: 14, color: Colors.blue.shade600),
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
                      Icons.network_ping,
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
