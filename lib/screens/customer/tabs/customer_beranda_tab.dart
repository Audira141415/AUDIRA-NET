import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/firebase_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/theme_provider.dart';
import '../../notifications_page.dart';
import '../../chat/live_chat_list_page.dart';
import '../widgets/customer_hero_service_card.dart';
import '../widgets/customer_quick_actions.dart';
import '../widgets/customer_maintenance_card.dart';
import '../widgets/customer_network_doctor_dialog.dart';

class CustomerBerandaTab extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const CustomerBerandaTab({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  State<CustomerBerandaTab> createState() => _CustomerBerandaTabState();
}

class _CustomerBerandaTabState extends State<CustomerBerandaTab> {
  Map<String, dynamic>? _customerData;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    setState(() => _isLoading = true);

    try {
      _userData = AuthService.instance.currentUserData;
      _userData ??= {
        'id': 'usr-customer-01',
        'name': 'Budi Pelanggan',
        'email': 'budi@audira.my.id',
        'role': 'customer',
      };

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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = _userData?['name']?.toString() ?? 'Pelanggan';
    final customerId = _customerData?['customerId'] ?? 'ADN-FIBER';
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCustomerData,
          color: const Color(0xFF0284C7),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cyber Command HUD Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF00F0FF).withValues(alpha: 0.35)
                          : const Color(0xFF0F172A),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFF00F0FF).withValues(alpha: 0.12)
                            : const Color(0xFF0F172A).withValues(alpha: 0.08),
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Holographic Avatar with status dot
                      Stack(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00F0FF), Color(0xFF7928CA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00FF9D),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00FF9D).withValues(alpha: 0.8),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // User Identity & ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: textPrimary,
                                      letterSpacing: -0.4,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00FF9D).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF00FF9D), width: 0.8),
                                  ),
                                  child: const Text(
                                    'ONLINE',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF00FF9D),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '// ID: $customerId',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controls: Theme Toggle & Bell
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ThemeToggleIconButton(),
                          const SizedBox(width: 2),
                          // Live Chat Button with Green Online Badge
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.messageSquare, size: 20),
                                color: textPrimary,
                                tooltip: 'Live Chat Siaga 24/7',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LiveChatListPage(),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 9,
                                right: 9,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF00FF9D),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00FF9D).withValues(alpha: 0.8),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 2),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.bell, size: 20),
                                color: textPrimary,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationsPage(),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 9,
                                right: 9,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF00F0FF),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00F0FF).withValues(alpha: 0.8),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Interactive Gateway Telemetry HUD Strip (Tap to launch Network Doctor)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      CustomerNetworkDoctorDialog.show(context);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF00F0FF).withValues(alpha: 0.3)
                              : const Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF00F0FF),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00F0FF).withValues(alpha: 0.8),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'GPON CORE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
                              fontFamily: 'monospace',
                              letterSpacing: 0.6,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ' // -19.4 dBm // LATENSI 11ms // POP: JKT-01',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '[ DETAIL ➔ ]',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Hero Card
                if (_isLoading)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  CustomerHeroServiceCard(
                    customerData: _customerData,
                    onPayPressed: () => widget.onNavigateToTab(1),
                  ),

                const SizedBox(height: 24),

                // Quick Actions
                CustomerQuickActions(
                  customerId: _customerData?['id']?.toString(),
                  onHelpPressed: () => widget.onNavigateToTab(2),
                ),

                const SizedBox(height: 24),

                // Maintenance / Announcements
                const CustomerMaintenanceCard(),

                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
