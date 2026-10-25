import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Clean Apple/Linear navigation item for AUDIRA Admin
class AdminNavItemData {
  final List<List<dynamic>> icon;
  final String label;

  const AdminNavItemData({required this.icon, required this.label});
}

class AdminNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AdminNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<AdminNavItemData> items = [
    AdminNavItemData(
      icon: HugeIcons.strokeRoundedDashboardSquare02,
      label: 'Dashboard',
    ),
    AdminNavItemData(
      icon: HugeIcons.strokeRoundedUserGroup,
      label: 'Pelanggan',
    ),
    AdminNavItemData(
      icon: HugeIcons.strokeRoundedInvoice02,
      label: 'Transaksi',
    ),
    AdminNavItemData(
      icon: HugeIcons.strokeRoundedCustomerService,
      label: 'Tiket',
    ),
    AdminNavItemData(
      icon: HugeIcons.strokeRoundedWrench01,
      label: 'Instalasi',
    ),
    AdminNavItemData(
      icon: HugeIcons.strokeRoundedCpu,
      label: 'Teknisi',
    ),
    AdminNavItemData(
      icon: HugeIcons.strokeRoundedUser,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF080D1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final selectedBg = isDark ? const Color(0xFF0C2B45) : const Color(0xFFE0F2FE);
    final selectedColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final unselectedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: borderColor, width: 1.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedIndex == index;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Material(
                  color: isSelected ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onItemSelected(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 74,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: item.icon,
                            size: 20,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? selectedColor : unselectedColor,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
