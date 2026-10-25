import 'package:flutter/material.dart';
import '../../widgets/dialogs.dart';
import 'tabs/admin_pelanggan_tab.dart';
import 'tabs/admin_teknisi_tab.dart';
import 'admin_tiket_page_new.dart';
import 'tabs/admin_beranda_tab.dart';
import 'tabs/admin_installasi_tab.dart';
import 'tabs/admin_payments_tab.dart';
import 'tabs/admin_profil_tab.dart';
import 'widgets/admin_nav_bar.dart';

/// Clean Apple/Linear Root Orchestrator for AUDIRA Admin
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AdminBerandaTab(),
    AdminPelangganTab(),
    AdminPaymentsTab(),
    AdminTiketPageNew(),
    AdminInstallasiTab(),
    AdminTeknisiTab(),
    AdminProfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          children: _pages,
        ),
        bottomNavigationBar: AdminNavBar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
