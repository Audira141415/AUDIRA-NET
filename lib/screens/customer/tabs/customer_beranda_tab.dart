import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/firebase_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/theme_provider.dart';
import '../../../utils/app_theme.dart';
import '../../notifications_page.dart';
import '../widgets/customer_hero_service_card.dart';
import '../widgets/customer_quick_actions.dart';
import '../widgets/customer_maintenance_card.dart';

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
                // Clean Enterprise Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Halo, $userName',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ID Pelanggan: $customerId',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: textSecondary,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const ThemeToggleIconButton(),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(LucideIcons.bell, size: 20),
                          color: textSecondary,
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
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Gateway Telemetry Pill
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
                        'EDGE POP-JKT01 • LATENSI 11ms • BACKBONE OPTIMAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark ? AppTheme.neonCyan : const Color(0xFF0369A1),
                        ),
                      ),
                    ],
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
