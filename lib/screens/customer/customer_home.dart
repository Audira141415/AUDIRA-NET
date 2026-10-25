import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dialogs.dart';
import 'tabs/customer_beranda_tab.dart';
import 'tabs/customer_tagihan_tab.dart';
import 'tabs/customer_bantuan_tab.dart';
import 'tabs/customer_profil_tab.dart';

/// Floating Cyber-Dock Customer Hub for AUDIRA
/// Berstandar Neo-Brutalism + Cyberpunk Studio dengan Floating Navigation Capsule
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;

  void navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      CustomerBerandaTab(onNavigateToTab: navigateToIndex),
      const CustomerTagihanTab(),
      const CustomerBantuanTab(),
      const CustomerProfilTab(),
    ];

    final navBg = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final activeColor = isDark ? AppTheme.neonCyan : AppTheme.signalBlue;
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    final navItems = [
      _NavItem(icon: LucideIcons.home, label: 'Beranda'),
      _NavItem(icon: LucideIcons.receipt, label: 'Tagihan'),
      _NavItem(icon: LucideIcons.lifeBuoy, label: 'Bantuan'),
      _NavItem(icon: LucideIcons.user, label: 'Profil'),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        } else {
          showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF05070D) : const Color(0xFFF1F5F9),
        body: Stack(
          children: [
            // Active Tab Page
            IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),

            // Floating Cyber-Capsule Navigation Dock
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: Container(
                  height: 66,
                  decoration: BoxDecoration(
                    color: navBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF00F0FF).withValues(alpha: 0.3)
                          : borderColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFF00F0FF).withValues(alpha: 0.12)
                            : const Color(0xFF0F172A).withValues(alpha: 0.08),
                        offset: const Offset(0, 6),
                        blurRadius: 16,
                      ),
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.6)
                            : const Color(0xFF0F172A).withValues(alpha: 0.05),
                        offset: const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(navItems.length, (index) {
                      final item = navItems[index];
                      final isSelected = _selectedIndex == index;

                      return Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedIndex = index),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeColor.withValues(alpha: isDark ? 0.15 : 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: isSelected
                                  ? Border.all(
                                      color: activeColor.withValues(alpha: isDark ? 0.4 : 0.2),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 20,
                                  color: isSelected ? activeColor : inactiveColor,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? activeColor : inactiveColor,
                                    letterSpacing: isSelected ? 0.3 : 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
