import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../config/routes.dart';
import '../../widgets/dialogs.dart';
import '../../utils/constants.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'barcode_scanner_page.dart';
import 'package:provider/provider.dart';
import '../../utils/theme_provider.dart';
import 'tabs/teknisi_dashboard_tab.dart';
import '../about_page.dart';
import '../../widgets/swipeable_items.dart';
import '../../widgets/copy_clipboard.dart';
import '../../widgets/share_widget.dart';
import '../../utils/map_utils.dart';
import '../notifications_page.dart';
import 'widgets/optical_diagnostics_sheet.dart';
import 'widgets/digital_proof_of_work_dialog.dart';

// Quick Wins Integration Notes:
// - ShimmerImage: Available via '../../widgets/shimmer_image.dart'
//   Ready for network profile pictures & announcements when needed
//   Usage: ShimmerImage(imageUrl: url, width: 100, height: 100)
//   Usage: ShimmerAvatar(imageUrl: url, radius: 40)
// - SwipeableListItem: ✅ Implemented for Ticket list (swipe = call customer)
// - CopyableText: ✅ Implemented for customer phone in ticket detail
// - ShareWidget: ✅ Implemented for performance report sharing

// Dashboard Teknisi
class TeknisiHomePage extends StatefulWidget {
  const TeknisiHomePage({super.key});

  @override
  State<TeknisiHomePage> createState() => _TeknisiHomePageState();
}

class _TeknisiHomePageState extends State<TeknisiHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TeknisiDashboardPage(),
    const TeknisiTiketPage(),
    const TeknisiInstallasiPage(),
    const TeknisiProfilPage(),
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
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        } else {
          showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
        body: Stack(
          children: [
            _pages[_selectedIndex],
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
                    color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF00FF9D).withValues(alpha: 0.35)
                          : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFF00FF9D).withValues(alpha: 0.12)
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
                    children: [
                      _buildTeknisiNavItem(0, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard, isDark),
                      _buildTeknisiNavItem(1, 'Tiket', Icons.assignment_outlined, Icons.assignment, isDark),
                      _buildTeknisiNavItem(2, 'Instalasi', Icons.build_outlined, Icons.build, isDark),
                      _buildTeknisiNavItem(3, 'Profil', Icons.person_outline, Icons.person, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeknisiNavItem(int index, String label, IconData icon, IconData activeIcon, bool isDark) {
    final isSelected = _selectedIndex == index;
    const activeColor = Color(0xFF00FF9D);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: isDark ? 0.15 : 0.1) : Colors.transparent,
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
                isSelected ? activeIcon : icon,
                size: 20,
                color: isSelected ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
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
  }
}

// Dashboard Page - Modularized Clean Utility Implementation
class TeknisiDashboardPage extends StatelessWidget {
  const TeknisiDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TeknisiDashboardTab(
      onNavigateTab: (index) {
        final homeState = context.findAncestorStateOfType<_TeknisiHomePageState>();
        homeState?.navigateToIndex(index);
      },
      onOpenTicket: (ticket) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailPage(
              ticket: ticket,
              onTicketResolved: () {},
            ),
          ),
        );
      },
    );
  }
}
// Tiket Page
class TeknisiTiketPage extends StatefulWidget {
  const TeknisiTiketPage({super.key});

  @override
  State<TeknisiTiketPage> createState() => _TeknisiTiketPageState();
}

class _TeknisiTiketPageState extends State<TeknisiTiketPage> {
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      // Get current teknisi's zone
      final user = await FirebaseService.instance.getUserByEmail(
        'teknisi@audiranet.com',
      );
      final String? teknisiZone = user?['zone'] as String?;

      // Get tickets filtered by zone if teknisi has zone assigned
      final tickets = teknisiZone != null
          ? await FirebaseService.instance.getTicketsByZone(teknisiZone)
          : await FirebaseService.instance.getAllTickets();

      setState(() {
        _tickets = tickets
            .where((t) => t['status'] == 'open' || t['status'] == 'in_progress')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      // Error loading tickets
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
      appBar: AppBar(
        title: Text(
          'Tiket Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF080D1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
        elevation: 0,
        actions: const [ThemeToggleIconButton()],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? const Color(0xFF00F0FF) : AppTheme.primaryCyan,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTickets,
              child: _tickets.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada tiket aktif',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return SwipeableListItem(
                          key: Key(ticket['ticketId']),
                          onEdit: () async {
                            // Call customer
                            final phone = ticket['phone'];
                            if (phone != null) {
                              final uri = Uri(scheme: 'tel', path: phone);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            }
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketDetailPage(
                                  ticket: ticket,
                                  onTicketResolved: _loadTickets,
                                ),
                              ),
                            );
                          },
                          enableDelete: false,
                          child: _TicketCard(
                            ticket: ticket,
                            onRefresh: _loadTickets,
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

// Installasi Page
class TeknisiInstallasiPage extends StatefulWidget {
  const TeknisiInstallasiPage({super.key});

  @override
  State<TeknisiInstallasiPage> createState() => _TeknisiInstallasiPageState();
}

class _TeknisiInstallasiPageState extends State<TeknisiInstallasiPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _installations = [];

  @override
  void initState() {
    super.initState();
    _loadInstallations();
  }

  Future<void> _loadInstallations() async {
    setState(() => _isLoading = true);
    try {
      final installations = await FirebaseService.instance
          .getAllInstallations();
      setState(() {
        _installations = installations
            .where((i) => i['status'] == 'scheduled')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      // Error loading installations
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
      appBar: AppBar(
        title: Text(
          'Jadwal Instalasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF080D1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
        elevation: 0,
        actions: [
          const ThemeToggleIconButton(),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2025, 1, 1),
                lastDate: DateTime(2026, 12, 31),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppTheme.primaryCyan,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (selectedDate != null) {
                final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                final installations = await FirebaseService.instance
                    .getInstallationsByDate(dateStr);

                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Instalasi ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                      ),
                      content: installations.isEmpty
                          ? const Text('Tidak ada jadwal instalasi')
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: installations.length,
                                itemBuilder: (context, index) {
                                  final inst = installations[index];
                                  return ListTile(
                                    leading: Icon(
                                      Icons.build_circle,
                                      color: AppTheme.primaryCyan,
                                    ),
                                    title: Text(inst['customerName']),
                                    subtitle: Text(
                                      '${inst['scheduledTime']} - ${inst['packageName']}',
                                    ),
                                    trailing: Chip(
                                      label: Text(
                                        inst['status'],
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor: AppTheme.signalBlue
                                          .withValues(alpha: 0.1),
                                    ),
                                  );
                                },
                              ),
                            ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            tooltip: 'Kalender',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerPage(),
                ),
              );

              if (result != null && context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Data Modem'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Model: ${result['model']}'),
                        Text('SN: ${result['serialNumber']}'),
                        Text('MAC: ${result['macAddress']}'),
                        Text('Status: ${result['status']}'),
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
              }
            },
            tooltip: 'Scan Modem',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInstallations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInstallations,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF080D1E) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF00F0FF).withValues(alpha: 0.25)
                            : const Color(0xFFBFDBFE),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.build_circle,
                            color: isDark ? const Color(0xFF00F0FF) : Colors.blue.shade700,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Instalasi',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFF94A3B8) : Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_installations.length} Jadwal',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Jadwal Mendatang',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_installations.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: isDark ? const Color(0xFF475569) : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada jadwal instalasi',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._installations.map(
                      (installation) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _InstallationCard(
                          installation: installation,
                          onRefresh: _loadInstallations,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

// Profil Page
class TeknisiProfilPage extends StatefulWidget {
  const TeknisiProfilPage({super.key});

  @override
  State<TeknisiProfilPage> createState() => _TeknisiProfilPageState();
}

class _TeknisiProfilPageState extends State<TeknisiProfilPage> {
  String? _profileImagePath;

  Future<void> _changeProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Ambil Foto'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(() => _profileImagePath = image.path);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Foto profil diperbarui')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() => _profileImagePath = image.path);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Foto profil diperbarui')),
                    );
                  }
                }
              },
            ),
            if (_profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _profileImagePath = null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto profil dihapus')),
                  );
                },
              ),
          ],
        ),
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
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: const [
              ThemeToggleIconButton(),
              SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Profil Teknisi'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.brightCyan,
                      AppTheme.primaryCyan,
                      AppTheme.deepCyan,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _changeProfilePhoto,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: _profileImagePath != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(_profileImagePath!),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.engineering,
                                        size: 48,
                                        color: AppTheme.primaryCyan,
                                      ),
                                    ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.deepCyan,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Profile Info Card
                Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(0x3300F0FF) : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Profil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ProfileItem(
                          icon: Icons.person,
                          label: 'Nama',
                          value: 'Teknisi Support',
                        ),
                        Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        _ProfileItem(
                          icon: Icons.email,
                          label: 'Email',
                          value: 'teknisi@audiranet.com',
                        ),
                        Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        _ProfileItem(
                          icon: Icons.phone,
                          label: 'Telepon',
                          value: '081234567899',
                        ),
                        Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        _ProfileItem(
                          icon: Icons.badge,
                          label: 'Role',
                          value: 'Teknisi',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Performance Card
                Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(0x3300F0FF) : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performa Bulan Ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _PerformanceItem(
                                icon: Icons.check_circle,
                                label: 'Tiket Selesai',
                                value: '45',
                                color: isDark ? const Color(0xFF00FF9D) : Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PerformanceItem(
                                icon: Icons.build,
                                label: 'Instalasi',
                                value: '12',
                                color: isDark ? const Color(0xFF00F0FF) : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _PerformanceItem(
                                icon: Icons.star,
                                label: 'Rating',
                                value: '4.8',
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PerformanceItem(
                                icon: Icons.trending_up,
                                label: 'Response Time',
                                value: '15m',
                                color: isDark ? const Color(0xFFA855F7) : Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Share Performance Button
                Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(0x3300F0FF) : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.share,
                      color: AppTheme.primaryCyan,
                    ),
                    title: Text(
                      'Bagikan Laporan Performa',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Bagikan performa bulan ini',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : AppTheme.lightTextSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios, 
                      size: 16,
                      color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                    ),
                    onTap: () async {
                      await ShareHelper.shareText(
                        text:
                            '''
📊 Laporan Performa - Teknisi Support

📅 Periode: ${DateFormat('MMMM yyyy').format(DateTime.now())}

✅ Tiket Selesai: 45
🔧 Instalasi: 12
⭐ Rating: 4.8/5.0
⚡ Response Time: 15 menit

Terima kasih atas kerja kerasnya!

#AudiraNet #Teknisi
''',
                        subject: 'Laporan Performa Teknisi',
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Settings Options
                Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(0x3300F0FF) : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: isDark ? const Color(0xFF38BDF8) : Colors.blueGrey,
                        ),
                        title: Text(
                          'Notifikasi',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Lihat pengumuman & pesan',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : AppTheme.lightTextSecondary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios, 
                          size: 16,
                          color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: isDark ? const Color(0xFF38BDF8) : Colors.blueGrey,
                        ),
                        title: Text(
                          'Lokasi',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Aktifkan untuk tracking',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : AppTheme.lightTextSecondary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios, 
                          size: 16,
                          color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Izin Lokasi'),
                              content: const Text(
                                'Fitur tracking lokasi memerlukan izin akses lokasi untuk menampilkan posisi real-time teknisi.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Izin lokasi diaktifkan'),
                                      ),
                                    );
                                  },
                                  child: const Text('Aktifkan'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      ListTile(
                        leading: Icon(
                          Icons.help,
                          color: isDark ? const Color(0xFF38BDF8) : Colors.blueGrey,
                        ),
                        title: Text(
                          'Bantuan',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios, 
                          size: 16,
                          color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bantuan & Dukungan',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ListTile(
                                    leading: const Icon(Icons.phone),
                                    title: const Text('Hubungi Admin'),
                                    subtitle: const Text('021-12345678'),
                                    onTap: () async {
                                      final uri = Uri(
                                        scheme: 'tel',
                                        path: '02112345678',
                                      );
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.email),
                                    title: const Text('Email Support'),
                                    subtitle: Text(
                                      AppConstants.techSupportEmail,
                                    ),
                                    onTap: () async {
                                      final uri = Uri(
                                        scheme: 'mailto',
                                        path: AppConstants.techSupportEmail,
                                        query: 'subject=Bantuan Teknisi',
                                      );
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.book),
                                    title: const Text('Panduan Teknisi'),
                                    subtitle: const Text('Lihat dokumentasi'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Panduan akan segera tersedia',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      ListTile(
                        leading: Icon(
                          Icons.refresh,
                          color: Colors.orange.shade700,
                        ),
                        title: Text(
                          'Reset Database (Testing)',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Reload semua data demo',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : AppTheme.lightTextSecondary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios, 
                          size: 16,
                          color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                        ),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Reset Database?'),
                              content: const Text(
                                'Semua data akan direset ke kondisi awal demo. Fitur ini untuk testing saja.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text('Reset'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              ),
                            );

                            try {
                              await FirebaseService.instance.resetDatabase();
                              if (context.mounted) {
                                Navigator.pop(context); // Close loading
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Database berhasil direset! Silakan restart aplikasi.',
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context); // Close loading
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                      Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return ListTile(
                            leading: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: themeProvider.isDarkMode
                                  ? const Color(0xFF00F0FF)
                                  : const Color(0xFF0070F3),
                            ),
                            title: Text(
                              'Tema Tampilan',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              themeProvider.isDarkMode
                                  ? 'Mode Gelap (OLED Midnight)'
                                  : 'Mode Terang (Slate Canvas)',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : AppTheme.lightTextSecondary,
                              ),
                            ),
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              activeThumbColor: const Color(0xFF00F0FF),
                              activeTrackColor: const Color(0x4400F0FF),
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: isDark ? const Color(0xFF38BDF8) : Colors.blueGrey,
                        ),
                        title: Text(
                          'Tentang Aplikasi',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Versi, changelog, dan lainnya',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : AppTheme.lightTextSecondary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios, 
                          size: 16,
                          color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
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

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text(
                            'Apakah Anda yakin ingin keluar?',
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
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Installation Card Widget
class _InstallationCard extends StatelessWidget {
  final Map<String, dynamic> installation;
  final VoidCallback? onRefresh;

  const _InstallationCard({required this.installation, this.onRefresh});

  Future<void> _markAsCompleted(BuildContext context) async {
    try {
      await FirebaseService.instance.updateInstallationStatus(
        installation['id'],
        'completed',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instalasi selesai ditandai')),
        );
        onRefresh?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _callCustomer(BuildContext context) async {
    final phone = installation['phone'];
    final uri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat menghubungi $phone')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF080D1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0x3300F0FF) : const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstallationDetailPage(
                installation: installation,
                onInstallationCompleted: onRefresh ?? () {},
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          installation['customerName'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${installation['packageName']} - ${installation['speed']} Mbps',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
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
                      color: isDark ? const Color(0x2200F0FF) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0x5500F0FF) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      installation['status'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF00F0FF) : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isDark ? const Color(0xFF38BDF8) : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(DateTime.parse(installation['scheduledDate'])),
                    style: TextStyle(
                      fontSize: 14, 
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isDark ? const Color(0xFF38BDF8) : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    installation['scheduledTime'],
                    style: TextStyle(
                      fontSize: 14, 
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: isDark ? const Color(0xFF38BDF8) : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      installation['address'],
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.phone, 
                    size: 16, 
                    color: isDark ? const Color(0xFF38BDF8) : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    installation['phone'],
                    style: TextStyle(
                      fontSize: 13, 
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callCustomer(context),
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Hubungi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFF38BDF8) : Colors.blue,
                        side: BorderSide(
                          color: isDark ? const Color(0x5500F0FF) : Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _markAsCompleted(context),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Selesai'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Item Widget
class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: isDark ? const Color(0xFF38BDF8) : Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12, 
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
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

// Performance Item Widget
class _PerformanceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PerformanceItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Ticket Card Widget
class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onRefresh;

  const _TicketCard({required this.ticket, required this.onRefresh});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'OPEN';
      case 'in_progress':
        return 'PROGRESS';
      case 'resolved':
        return 'SELESAI';
      default:
        return 'UNKNOWN';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'TINGGI';
      case 'medium':
        return 'SEDANG';
      case 'low':
        return 'RENDAH';
      default:
        return 'NORMAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF080D1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF00F0FF).withValues(alpha: 0.2)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF00F0FF).withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TicketDetailPage(ticket: ticket, onTicketResolved: onRefresh),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket['ticketId'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF64748B) : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(ticket['status']),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket['subject'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ticket['description'],
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Customer: ${ticket['customerName'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF64748B) : Colors.grey[600],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(ticket['priority']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPriorityText(ticket['priority']),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? const Color(0xFF64748B) : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Stat Card Widget
// Modern Stat Card Widget with Flat Design
class _ModernStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _ModernStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.35)
              : color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.08 : 0.04),
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
                  color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : AppTheme.lightTextSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Action Button Widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: isDark ? 0 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFF8FAFC) : AppTheme.lightTextPrimary,
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

// Ticket Detail Page
class TicketDetailPage extends StatefulWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onTicketResolved;

  const TicketDetailPage({
    super.key,
    required this.ticket,
    required this.onTicketResolved,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final TextEditingController _notesController = TextEditingController();
  bool _isResolving = false;
  bool _isAssigning = false;
  Map<String, dynamic>? _customerData;
  bool _isLoadingCustomer = false;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingPhoto = false;
  List<String> _beforePhotos = [];
  List<String> _afterPhotos = [];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'OPEN';
      case 'in_progress':
        return 'DALAM PROSES';
      case 'resolved':
        return 'SELESAI';
      default:
        return 'TIDAK DIKETAHUI';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'TINGGI';
      case 'medium':
        return 'SEDANG';
      case 'low':
        return 'RENDAH';
      default:
        return 'NORMAL';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    // Load photos from ticket data if exists
    final photos = widget.ticket['photos'] as Map<String, dynamic>?;
    if (photos != null) {
      setState(() {
        _beforePhotos = List<String>.from(photos['before'] ?? []);
        _afterPhotos = List<String>.from(photos['after'] ?? []);
      });
    }
  }

  Future<void> _loadCustomerData() async {
    if (widget.ticket['customerId'] == null) return;

    setState(() {
      _isLoadingCustomer = true;
    });

    try {
      final customer = await FirebaseService.instance.getCustomerById(
        widget.ticket['customerId'],
      );
      if (mounted) {
        setState(() {
          _customerData = customer;
          _isLoadingCustomer = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCustomer = false;
        });
      }
    }
  }

  Future<void> _navigateToCustomer() async {
    if (_customerData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data customer tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final latitude = _customerData!['latitude'];
    final longitude = _customerData!['longitude'];
    final address = _customerData!['address'];

    bool success = false;

    // Try with coordinates first if available
    if (latitude != null && longitude != null) {
      try {
        final lat = double.parse(latitude.toString());
        final lng = double.parse(longitude.toString());
        success = await MapUtils.navigateToCoordinates(lat, lng);
      } catch (e) {
        developer.log('Error parsing coordinates: $e', name: 'TeknisiHome');
      }
    }

    // Fallback to address if coordinates failed or not available
    if (!success && address != null && address.isNotEmpty) {
      success = await MapUtils.navigateToAddress(address);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membuka navigasi...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal membuka maps. Pastikan Google Maps terinstall.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadPhoto(String photoType) async {
    if (_isUploadingPhoto) return;

    try {
      // Show source selection dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pilih Sumber Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mengupload foto...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Upload to Firebase Storage
      final photoFile = File(pickedFile.path);
      final photoUrl = await FirebaseService.instance.uploadTicketPhoto(
        ticketId: widget.ticket['id'],
        photoFile: photoFile,
        photoType: photoType,
      );

      if (photoUrl == null) {
        throw Exception('Gagal mengupload foto');
      }

      // Add photo URL to ticket
      await FirebaseService.instance.addPhotoToTicket(
        ticketId: widget.ticket['id'],
        photoUrl: photoUrl,
        photoType: photoType,
      );

      // Update local state
      setState(() {
        if (photoType == 'before') {
          _beforePhotos.add(photoUrl);
        } else {
          _afterPhotos.add(photoUrl);
        }
        _isUploadingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Foto ${photoType == "before" ? "sebelum" : "sesudah"} berhasil diupload!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupload foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickupTicket() async {
    if (_isAssigning) return;

    // Get teknisi ID from shared preferences or auth service
    final user = await FirebaseService.instance.getUserByEmail(
      'teknisi@audiranet.com',
    );
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Teknisi tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isAssigning = true;
    });

    try {
      await FirebaseService.instance.assignTicketToTeknisi(
        widget.ticket['id'],
        user['id'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil diambil! Status: Dalam Proses'),
            backgroundColor: Colors.blue,
          ),
        );

        widget.onTicketResolved();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil tiket: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }

  Future<void> _resolveTicket() async {
    if (_isResolving) return;

    // Show confirmation dialog with progress notes
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final notesController = TextEditingController();
        return AlertDialog(
          title: const Text('Selesaikan Tiket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin sudah menyelesaikan tiket ini?',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan Penyelesaian (opsional)',
                  hintText: 'Masalah sudah diperbaiki, kabel diganti, dll...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Ya, Selesaikan'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    setState(() {
      _isResolving = true;
    });

    try {
      await FirebaseService.instance.updateTicketStatus(
        widget.ticket['ticketId'],
        'resolved',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil diselesaikan'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onTicketResolved();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan tiket: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResolving = false;
        });
      }
    }
  }

  void _openOpticalDiagnostics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OpticalDiagnosticsSheet(
        customerName: widget.ticket['customerName'],
        ontSerial: widget.ticket['ontSerial'] ?? 'HWTC-892401',
        odpReference: widget.ticket['zone'] != null ? 'ODP-${widget.ticket["zone"]}' : 'ODP-AUDIRA-MDK-04/08',
      ),
    );
  }

  Future<void> _openBarcodeScannerForBinding() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerPage(
          ticketId: widget.ticket['ticketId'] ?? widget.ticket['id'],
          customerName: widget.ticket['customerName'],
        ),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Perangkat ${result["model"]} (SN: ${result["serialNumber"]}) berhasil diikat ke tiket ini!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openDigitalProofOfWork() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DigitalProofOfWorkDialog(
        ticket: widget.ticket,
        onCompleted: () {
          widget.onTicketResolved();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = widget.ticket['status']?.toLowerCase() == 'resolved';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Detail Tiket ${widget.ticket['ticketId']}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Priority Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.ticket['status'] ?? ''),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Status: ${_getStatusText(widget.ticket['status'] ?? '')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(widget.ticket['priority'] ?? ''),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Prioritas: ${_getPriorityText(widget.ticket['priority'] ?? '')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Zone Badge
            if (widget.ticket['zone'] != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Zona: ${widget.ticket['zone']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Main Content Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  // Ticket ID
                  Text(
                    'ID Tiket',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.ticket['ticketId'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subject
                  Text(
                    'Judul Masalah',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.ticket['subject'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Deskripsi Masalah',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.ticket['description'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer Info
                  Text(
                    'Informasi Customer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.ticket['customerName'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.ticket['phone'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CopyableText(
                            text: widget.ticket['phone'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            successMessage: 'Nomor telepon disalin!',
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Customer Address & Navigation
                  if (_customerData != null &&
                      _customerData!['address'] != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _customerData!['address'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _navigateToCustomer,
                        icon: const Icon(Icons.navigation, size: 18),
                        label: const Text('Navigasi ke Lokasi Customer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                          side: BorderSide(color: Colors.blue.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else if (_isLoadingCustomer) ...[
                    const SizedBox(height: 12),
                    const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Timestamps
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dibuat',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              _formatDate(widget.ticket['createdAt'] ?? ''),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.ticket['updatedAt'] != null) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Terakhir',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _formatDate(widget.ticket['updatedAt']),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (widget.ticket['resolvedAt'] != null) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Diselesaikan',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _formatDate(widget.ticket['resolvedAt']),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Photo Documentation Section
            if (!isResolved) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                        Icon(Icons.photo_camera, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        const Text(
                          'Dokumentasi Foto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Before Photos
                    Text(
                      'Foto Sebelum Perbaikan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._beforePhotos.map(
                          (url) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (!_isUploadingPhoto)
                          InkWell(
                            onTap: () => _uploadPhoto('before'),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tambah',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // After Photos
                    Text(
                      'Foto Sesudah Perbaikan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._afterPhotos.map(
                          (url) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (!_isUploadingPhoto)
                          InkWell(
                            onTap: () => _uploadPhoto('after'),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tambah',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (_isUploadingPhoto) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Assignment Info (if assigned)
            if (widget.ticket['teknisiId'] != null &&
                widget.ticket['assignedAt'] != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
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
                        Icon(Icons.person_pin, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tiket sudah diambil',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Diambil pada: ${_formatDate(widget.ticket['assignedAt'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Progress Flow Indicator
            if (!isResolved) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alur Pengerjaan:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Step 1: Pickup
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: widget.ticket['teknisiId'] != null
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.ticket['teknisiId'] != null
                                      ? Icons.check
                                      : Icons.assignment_ind,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ambil Tiket',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: widget.ticket['teknisiId'] != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: widget.ticket['teknisiId'] != null
                                      ? Colors.green
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Expanded(
                          child: Container(
                            height: 2,
                            color: widget.ticket['teknisiId'] != null
                                ? Colors.green
                                : Colors.grey.shade300,
                          ),
                        ),
                        // Step 2: In Progress
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      widget.ticket['status'] == 'in_progress'
                                      ? Colors.orange
                                      : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.engineering,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Dalam Proses',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      widget.ticket['status'] == 'in_progress'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      widget.ticket['status'] == 'in_progress'
                                      ? Colors.orange
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        // Step 3: Complete
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Selesai',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action Button
            if (!isResolved) ...[
              // If not assigned yet, show pickup button
              if (widget.ticket['teknisiId'] == null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAssigning ? null : _pickupTicket,
                    icon: _isAssigning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.assignment_ind),
                    label: Text(
                      _isAssigning ? 'Mengambil...' : 'Ambil Tiket Ini',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Toolkit Teknisi Lapangan (Diagnostik & Barcode Binding)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openOpticalDiagnostics,
                        icon: const Icon(Icons.speed_rounded, size: 18),
                        label: const Text('Ukur Redaman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0284C7),
                          side: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openBarcodeScannerForBinding,
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                        label: const Text('Scan ONT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF59E0B),
                          side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Primary Resolve Button with Digital Proof of Work (Berita Acara Digital)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openDigitalProofOfWork,
                    icon: const Icon(Icons.verified_rounded, size: 20),
                    label: const Text(
                      'Sahkan Berita Acara & Selesaikan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tiket ini sudah diselesaikan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

// Installation Detail Page
class InstallationDetailPage extends StatefulWidget {
  final Map<String, dynamic> installation;
  final VoidCallback onInstallationCompleted;

  const InstallationDetailPage({
    super.key,
    required this.installation,
    required this.onInstallationCompleted,
  });

  @override
  State<InstallationDetailPage> createState() => _InstallationDetailPageState();
}

class _InstallationDetailPageState extends State<InstallationDetailPage> {
  bool _isCompleting = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'TERJADWAL';
      case 'in_progress':
        return 'DALAM PROSES';
      case 'completed':
        return 'SELESAI';
      case 'cancelled':
        return 'DIBATALKAN';
      default:
        return 'TIDAK DIKETAHUI';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _completeInstallation() async {
    if (_isCompleting) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Apakah Anda yakin ingin menyelesaikan instalasi ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Ya, Selesaikan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      await FirebaseService.instance.updateInstallationStatus(
        widget.installation['id'],
        'completed',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Instalasi berhasil diselesaikan'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onInstallationCompleted();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan instalasi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  Future<void> _callCustomer() async {
    final phone = widget.installation['phone'];
    final uri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat menghubungi $phone')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _openMap() async {
    final lat = widget.installation['latitude'];
    final lng = widget.installation['longitude'];

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koordinat lokasi tidak tersedia')),
      );
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        widget.installation['status']?.toLowerCase() == 'completed';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Detail Instalasi'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.installation['status'] ?? ''),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Status: ${_getStatusText(widget.installation['status'] ?? '')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Customer Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                      Icon(Icons.person, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      const Text(
                        'Informasi Customer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.account_circle,
                    label: 'Nama',
                    value: widget.installation['customerName'] ?? '-',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.phone,
                    label: 'Telepon',
                    value: widget.installation['phone'] ?? '-',
                    onTap: _callCustomer,
                    isClickable: true,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Alamat',
                    value: widget.installation['address'] ?? '-',
                    onTap: _openMap,
                    isClickable: true,
                  ),
                  if (widget.installation['latitude'] != null &&
                      widget.installation['longitude'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Koordinat: ${widget.installation['latitude']}, ${widget.installation['longitude']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Package Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                      Icon(Icons.wifi, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      const Text(
                        'Detail Paket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.shopping_bag,
                    label: 'Paket',
                    value: widget.installation['packageName'] ?? '-',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.speed,
                    label: 'Kecepatan',
                    value: '${widget.installation['speed'] ?? 0} Mbps',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.attach_money,
                    label: 'Harga',
                    value:
                        'Rp ${NumberFormat('#,###', 'id_ID').format(widget.installation['price'] ?? 0)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Schedule Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                      Icon(Icons.calendar_today, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      const Text(
                        'Jadwal Instalasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.event,
                    label: 'Tanggal',
                    value: _formatDate(
                      widget.installation['scheduledDate'] ?? '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Waktu',
                    value: widget.installation['scheduledTime'] ?? '-',
                  ),
                  if (widget.installation['notes'] != null &&
                      widget.installation['notes'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.note,
                      label: 'Catatan',
                      value: widget.installation['notes'],
                    ),
                  ],
                  if (widget.installation['createdAt'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Dibuat: ${_formatDateTime(widget.installation['createdAt'])}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (widget.installation['completedAt'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Diselesaikan: ${_formatDateTime(widget.installation['completedAt'])}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            if (!isCompleted) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _callCustomer,
                      icon: const Icon(Icons.phone),
                      label: const Text('Hubungi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openMap,
                      icon: const Icon(Icons.map),
                      label: const Text('Buka Map'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCompleting ? null : _completeInstallation,
                  icon: _isCompleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    _isCompleting ? 'Memproses...' : 'Selesaikan Instalasi',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Instalasi ini sudah diselesaikan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _callCustomer,
                      icon: const Icon(Icons.phone),
                      label: const Text('Hubungi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openMap,
                      icon: const Icon(Icons.map),
                      label: const Text('Buka Map'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Detail Row Widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isClickable;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isClickable ? Colors.blue.shade700 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (isClickable) ...[
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ],
    );

    if (isClickable && onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }

    return content;
  }
}

// Complete Ticket Dialog with Photos
class _CompleteTicketDialog extends StatefulWidget {
  @override
  _CompleteTicketDialogState createState() => _CompleteTicketDialogState();
}

class _CompleteTicketDialogState extends State<_CompleteTicketDialog> {
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  String? _photoBeforePath;
  String? _photoAfterPath;

  Future<XFile?> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      // Error will be handled by caller using BuildContext
      rethrow;
    }
  }

  void _setPickedImage(bool isBefore, XFile image) {
    if (!mounted) return;
    setState(() {
      if (isBefore) {
        _photoBeforePath = image.path;
      } else {
        _photoAfterPath = image.path;
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.assignment_turned_in, color: Colors.green.shade700),
          const SizedBox(width: 8),
          const Text('Selesaikan Tiket'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notes Section
            const Text(
              'Catatan Progres Pekerjaan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Contoh:\n- Sudah cek kabel, ada yang putus\n- Ganti kabel baru\n- Internet normal kembali',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),

            // Photo Before Section
            const Text(
              'Foto Sebelum Perbaikan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildPhotoButton(
              label: 'Ambil Foto Sebelum',
              icon: Icons.camera_alt,
              hasPhoto: _photoBeforePath != null,
              onTap: () async {
                try {
                  final image = await _pickImageFromCamera();
                  if (image != null) {
                    _setPickedImage(true, image);
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Photo After Section
            const Text(
              'Foto Sesudah Perbaikan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildPhotoButton(
              label: 'Ambil Foto Sesudah',
              icon: Icons.camera_alt,
              hasPhoto: _photoAfterPath != null,
              onTap: () async {
                try {
                  final image = await _pickImageFromCamera();
                  if (image != null) {
                    _setPickedImage(false, image);
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Catatan dan foto akan tersimpan sebagai dokumentasi pekerjaan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (_notesController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mohon isi catatan progres pekerjaan'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            Navigator.pop(context, {
              'confirmed': true,
              'notes': _notesController.text.trim(),
              'photoBefore': _photoBeforePath,
              'photoAfter': _photoAfterPath,
            });
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Selesaikan'),
        ),
      ],
    );
  }

  Widget _buildPhotoButton({
    required String label,
    required IconData icon,
    required bool hasPhoto,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasPhoto ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasPhoto ? Colors.green : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasPhoto ? Icons.check_circle : icon,
              color: hasPhoto ? Colors.green : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasPhoto ? 'Foto sudah diambil' : label,
                style: TextStyle(
                  color: hasPhoto
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                  fontWeight: hasPhoto ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (hasPhoto)
              TextButton(onPressed: onTap, child: const Text('Ubah')),
          ],
        ),
      ),
    );
  }
}

// Resolved Tickets Page
class _ResolvedTicketsPage extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;

  const _ResolvedTicketsPage({required this.tickets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Tiket Selesai'),
        backgroundColor: Colors.green,
      ),
      body: tickets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada tiket yang diselesaikan',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return _ResolvedTicketCard(ticket: ticket);
              },
            ),
    );
  }
}

// Resolved Ticket Card
class _ResolvedTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _ResolvedTicketCard({required this.ticket});

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhotoBefore = ticket['photoBeforePath'] != null;
    final hasPhotoAfter = ticket['photoAfterPath'] != null;
    final hasNotes =
        ticket['progressNotes'] != null &&
        ticket['progressNotes'].toString().isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _TicketDetailDialog(ticket: ticket),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SELESAI',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ticket['ticketId'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subject
              Text(
                ticket['subject'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Resolved Date
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Selesai: ${_formatDateTime(ticket['resolvedAt'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Feature Indicators
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasNotes)
                    _FeatureChip(
                      icon: Icons.note_alt,
                      label: 'Ada Catatan',
                      color: Colors.blue,
                    ),
                  if (hasPhotoBefore)
                    _FeatureChip(
                      icon: Icons.camera_alt,
                      label: 'Foto Sebelum',
                      color: Colors.orange,
                    ),
                  if (hasPhotoAfter)
                    _FeatureChip(
                      icon: Icons.camera_alt,
                      label: 'Foto Sesudah',
                      color: Colors.green,
                    ),
                ],
              ),

              // Tap hint
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap untuk detail',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Feature Chip
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Ticket Detail Dialog
class _TicketDetailDialog extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _TicketDetailDialog({required this.ticket});

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_turned_in,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket['ticketId'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Detail Pekerjaan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject
                  const Text(
                    'Masalah:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket['subject'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Deskripsi:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket['description'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Progress Notes
                  if (ticket['progressNotes'] != null &&
                      ticket['progressNotes'].toString().isNotEmpty) ...[
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
                              Icon(
                                Icons.note_alt,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Catatan Progres Pekerjaan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket['progressNotes'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.signalBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Photos
                  if (ticket['photoBeforePath'] != null ||
                      ticket['photoAfterPath'] != null) ...[
                    const Text(
                      'Dokumentasi Foto:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (ticket['photoBeforePath'] != null)
                          Expanded(
                            child: _PhotoPreview(
                              label: 'Sebelum',
                              icon: Icons.image,
                              color: Colors.orange,
                            ),
                          ),
                        if (ticket['photoBeforePath'] != null &&
                            ticket['photoAfterPath'] != null)
                          const SizedBox(width: 12),
                        if (ticket['photoAfterPath'] != null)
                          Expanded(
                            child: _PhotoPreview(
                              label: 'Sesudah',
                              icon: Icons.image,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Timeline
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _TimelineItem(
                          icon: Icons.create,
                          label: 'Dibuat',
                          time: _formatDateTime(ticket['createdAt']),
                        ),
                        if (ticket['assignedAt'] != null)
                          _TimelineItem(
                            icon: Icons.person_add,
                            label: 'Diambil',
                            time: _formatDateTime(ticket['assignedAt']),
                          ),
                        _TimelineItem(
                          icon: Icons.check_circle,
                          label: 'Selesai',
                          time: _formatDateTime(ticket['resolvedAt']),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Photo Preview Widget
class _PhotoPreview extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _PhotoPreview({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Timeline Item Widget
class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final bool isLast;

  const _TimelineItem({
    required this.icon,
    required this.label,
    required this.time,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Icon(icon, size: 20, color: Colors.green),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: Colors.green.shade200,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
