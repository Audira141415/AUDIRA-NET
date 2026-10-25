import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/dialogs.dart';
import 'tabs/customer_beranda_tab.dart';
import 'tabs/customer_tagihan_tab.dart';
import 'tabs/customer_bantuan_tab.dart';
import 'tabs/customer_profil_tab.dart';

/// Clean, Human-Crafted Customer Home Hub for AUDIRA
/// Eliminates AI-slop bloat, adopts Apple/Linear utility aesthetics
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
        backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
        body: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          backgroundColor: isDark ? const Color(0xFF0B1120) : Colors.white,
          indicatorColor: isDark
              ? const Color(0xFF0284C7).withValues(alpha: 0.25)
              : const Color(0xFF0284C7).withValues(alpha: 0.12),
          elevation: 2,
          height: 65,
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.home, size: 20),
              selectedIcon: Icon(LucideIcons.home, size: 20, color: Color(0xFF0284C7)),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.receipt, size: 20),
              selectedIcon: Icon(LucideIcons.receipt, size: 20, color: Color(0xFF0284C7)),
              label: 'Tagihan',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.lifeBuoy, size: 20),
              selectedIcon: Icon(LucideIcons.lifeBuoy, size: 20, color: Color(0xFF0284C7)),
              label: 'Bantuan',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.user, size: 20),
              selectedIcon: Icon(LucideIcons.user, size: 20, color: Color(0xFF0284C7)),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
