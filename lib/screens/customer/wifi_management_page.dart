import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/wifi_model.dart';
import '../../services/wifi_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/cyber_widgets.dart';

class WiFiManagementPage extends StatefulWidget {
  const WiFiManagementPage({super.key});

  @override
  State<WiFiManagementPage> createState() => _WiFiManagementPageState();
}

class _WiFiManagementPageState extends State<WiFiManagementPage>
    with SingleTickerProviderStateMixin {
  final WiFiService _wifiService = WiFiService();
  final AuthService _authService = AuthService.instance;
  late TabController _tabController;

  WiFiConfiguration? _wifiConfig;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWiFiConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWiFiConfig() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      final userId = user?.id ??
          _authService.currentUserData?['id']?.toString() ??
          'usr-customer-01';

      var config = await _wifiService.getWiFiConfig(userId);
      config ??= WiFiConfiguration(
        id: 'cfg-$userId',
        customerId: userId,
        ssid: 'AUDIRA-FIBER-5G',
        password: 'audiraspeed2026',
        securityType: 'WPA2/WPA3-Personal',
        isGuestNetworkEnabled: true,
        isHidden: false,
        channel: 36,
        band: 'Dual-Band (2.4GHz + 5GHz)',
        lastModified: DateTime.now(),
        modifiedBy: userId,
      );

      if (mounted) {
        setState(() {
          _wifiConfig = config;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _wifiConfig = WiFiConfiguration(
            id: 'cfg-default',
            customerId: 'usr-customer-01',
            ssid: 'AUDIRA-FIBER-5G',
            password: 'audiraspeed2026',
            securityType: 'WPA2/WPA3-Personal',
            isGuestNetworkEnabled: true,
            isHidden: false,
            channel: 36,
            band: 'Dual-Band (2.4GHz + 5GHz)',
            lastModified: DateTime.now(),
            modifiedBy: 'customer',
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.cyberOledBg : const Color(0xFFF1F5F9),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'WI-FI // MANAJEMEN ONT',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 2.0,
            color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
          ),
        ),
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                indicatorWeight: 3,
                labelColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                unselectedLabelColor: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                labelStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
                tabs: const [
                  Tab(icon: Icon(LucideIcons.wifi, size: 18), text: 'OVERVIEW'),
                  Tab(icon: Icon(LucideIcons.smartphone, size: 18), text: 'DEVICES'),
                  Tab(icon: Icon(LucideIcons.users, size: 18), text: 'GUEST'),
                  Tab(icon: Icon(LucideIcons.shield, size: 18), text: 'PARENTAL'),
                ],
              ),
              Container(
                color: isDark
                    ? AppTheme.neonCyan.withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
                height: 1,
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.neonCyan),
            )
          : _wifiConfig == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.wifiOff,
                        size: 48,
                        color: isDark ? AppTheme.textMuted : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'GAGAL MEMUAT KONFIGURASI WI-FI',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CyberActionButton(
                        label: 'MUAT ULANG',
                        icon: LucideIcons.refreshCw,
                        fullWidth: false,
                        primaryColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                        onPressed: _loadWiFiConfig,
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isDark),
                    _buildDevicesTab(isDark),
                    _buildGuestNetworkTab(isDark),
                    _buildParentalControlTab(isDark),
                  ],
                ),
    );
  }

  // ============ OVERVIEW TAB ============
  Widget _buildOverviewTab(bool isDark) {
    return RefreshIndicator(
      color: AppTheme.neonCyan,
      backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
      onRefresh: _loadWiFiConfig,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            isDark: isDark,
            title: 'JARINGAN UTAMA (PRIMARY WLAN)',
            icon: LucideIcons.wifi,
            color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
            children: [
              _buildInfoRow(isDark, 'SSID', _wifiConfig!.ssid, LucideIcons.wifi),
              _buildPasswordRow(isDark, 'Password', _wifiConfig!.password),
              _buildInfoRow(isDark, 'Security', _wifiConfig!.securityType, LucideIcons.lock),
              _buildInfoRow(
                isDark,
                'Band',
                _wifiConfig!.band,
                LucideIcons.signal,
              ),
              _buildInfoRow(
                isDark,
                'Channel',
                '${_wifiConfig!.channel}',
                LucideIcons.radio,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CyberActionButton(
                      label: 'UBAH SSID',
                      icon: LucideIcons.fileEdit,
                      primaryColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                      onPressed: _showChangeSSIDDialog,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CyberActionButton(
                      label: 'UBAH SANDI',
                      icon: LucideIcons.key,
                      primaryColor: isDark ? AppTheme.neonAmber : const Color(0xFFD97706),
                      onPressed: _showChangePasswordDialog,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            isDark: isDark,
            title: 'INFORMASI TELEMETRI ONT',
            icon: LucideIcons.info,
            color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
            children: [
              _buildInfoRow(
                isDark,
                'Hidden Network (SSID Broadcast)',
                _wifiConfig!.isHidden ? 'Aktif (Disembunyikan)' : 'Tidak (Broadcasting)',
                LucideIcons.eyeOff,
              ),
              _buildInfoRow(
                isDark,
                'Sinkronisasi Terakhir',
                _formatDate(_wifiConfig!.lastModified),
                LucideIcons.clock,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberObsidian : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? color.withValues(alpha: 0.35) : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
            height: 1,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDark, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppTheme.neonCyan : const Color(0xFF64748B),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRow(bool isDark, String label, String password) {
    bool obscured = true;
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                LucideIcons.key,
                size: 18,
                color: isDark ? AppTheme.neonCyan : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  obscured ? '••••••••' : password,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: obscured ? 2.0 : 0.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(
                  obscured ? LucideIcons.eyeOff : LucideIcons.eye,
                  color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                ),
                onPressed: () => setState(() => obscured = !obscured),
                iconSize: 18,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.copy,
                  color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: password));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password berhasil disalin!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                iconSize: 18,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============ DEVICES TAB ============
  Widget _buildDevicesTab(bool isDark) {
    final user = _authService.currentUser;
    if (user == null) {
      return Center(
        child: Text(
          'SESI PENGGUNA BELUM AKTIF',
          style: TextStyle(
            fontFamily: 'monospace',
            color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberObsidian : const Color(0xFFF8FAFC),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppTheme.neonCyan.withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CyberPulseDot(
                    color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
                    size: 8,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PERANGKAT TERHUBUNG',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              CyberActionButton(
                label: 'TAMBAH DEMO',
                icon: LucideIcons.plus,
                fullWidth: false,
                primaryColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                onPressed: _showAddDeviceDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ConnectedDevice>>(
            stream: _wifiService.getConnectedDevices(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.neonCyan),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.laptop,
                        size: 54,
                        color: isDark ? AppTheme.textMuted : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'TIDAK ADA PERANGKAT TERHUBUNG',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Semua perangkat yang tersambung ke WiFi akan muncul di sini',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CyberActionButton(
                        label: 'TAMBAH PERANGKAT CONTOH',
                        icon: LucideIcons.plus,
                        fullWidth: false,
                        primaryColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                        onPressed: _showAddDeviceDialog,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final device = snapshot.data![index];
                  return _buildDeviceCard(isDark, device);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(bool isDark, ConnectedDevice device) {
    IconData deviceIcon;
    Color deviceColor;

    switch (device.deviceType) {
      case 'phone':
        deviceIcon = LucideIcons.smartphone;
        deviceColor = AppTheme.neonCyan;
        break;
      case 'laptop':
        deviceIcon = LucideIcons.laptop;
        deviceColor = AppTheme.neonGreen;
        break;
      case 'tv':
        deviceIcon = LucideIcons.tv;
        deviceColor = AppTheme.neonPurple;
        break;
      case 'iot':
        deviceIcon = LucideIcons.router;
        deviceColor = AppTheme.neonAmber;
        break;
      default:
        deviceIcon = LucideIcons.helpCircle;
        deviceColor = isDark ? AppTheme.textMuted : const Color(0xFF64748B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberObsidian : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: device.isBlocked
              ? AppTheme.neonCrimson.withValues(alpha: 0.5)
              : (isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
          width: 1.2,
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: deviceColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: deviceColor.withValues(alpha: 0.4)),
          ),
          child: Icon(deviceIcon, color: deviceColor, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.deviceName,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (device.isBlocked)
              const CyberBadge(
                label: 'BLOCKED',
                color: AppTheme.neonCrimson,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'IP: ${device.ipAddress} • MAC: ${device.macAddress}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  LucideIcons.arrowDown,
                  size: 13,
                  color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
                ),
                Text(
                  ' ${device.downloadSpeed.toStringAsFixed(1)} Mbps',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 14),
                Icon(
                  LucideIcons.arrowUp,
                  size: 13,
                  color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                ),
                Text(
                  ' ${device.uploadSpeed.toStringAsFixed(1)} Mbps',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: isDark ? AppTheme.cyberObsidian : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1),
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'rename',
              child: Text(
                'Ganti Nama',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'block',
              child: Text(
                device.isBlocked ? 'Buka Blokir' : 'Blokir Akses',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: device.isBlocked ? AppTheme.neonGreen : AppTheme.neonCrimson,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'parental',
              child: Text(
                'Kontrol Orang Tua',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'block') {
              _toggleDeviceBlock(device);
            } else if (value == 'rename') {
              _showRenameDeviceDialog(device);
            } else if (value == 'parental') {
              _tabController.animateTo(3);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Konfigurasi kontrol orang tua untuk ${device.deviceName}',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // ============ GUEST NETWORK TAB ============
  Widget _buildGuestNetworkTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberObsidian : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: SwitchListTile(
            activeTrackColor: isDark ? AppTheme.neonGreen.withValues(alpha: 0.4) : const Color(0xFF86EFAC),
            activeThumbColor: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
            value: _wifiConfig!.isGuestNetworkEnabled,
            onChanged: (value) async {
              await _wifiService.toggleGuestNetwork(
                customerId: _authService.currentUser!.id,
                enable: value,
              );
              _loadWiFiConfig();
            },
            title: Text(
              'GUEST NETWORK (WLAN ISOLASI TAMU)',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.0,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            subtitle: Text(
              _wifiConfig!.isGuestNetworkEnabled
                  ? 'Aktif — Tamu dapat mengakses internet secara terisolasi'
                  : 'Nonaktif — Hanya jaringan utama yang tersedia',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
              ),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (_wifiConfig!.isGuestNetworkEnabled ? AppTheme.neonGreen : AppTheme.textMuted)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.users,
                color: _wifiConfig!.isGuestNetworkEnabled ? AppTheme.neonGreen : AppTheme.textMuted,
                size: 22,
              ),
            ),
          ),
        ),
        if (_wifiConfig!.isGuestNetworkEnabled) ...[
          const SizedBox(height: 16),
          _buildInfoCard(
            isDark: isDark,
            title: 'KREDENSIAL GUEST NETWORK',
            icon: LucideIcons.rss,
            color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
            children: [
              _buildInfoRow(
                isDark,
                'Guest SSID',
                _wifiConfig!.guestSSID ?? 'N/A',
                LucideIcons.wifi,
              ),
              _buildPasswordRow(
                isDark,
                'Guest Password',
                _wifiConfig!.guestPassword ?? 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.25) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.info, color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'TENTANG JARINGAN TAMU (ISOLASI VAP)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '• Menyediakan akses internet terpisah untuk tamu & pengunjung\n'
                  '• Tamu tidak dapat mengakses perangkat LAN pribadi (Printer, NAS, TV)\n'
                  '• Bandwidth terkelola otomatis agar jaringan utama tetap cepat\n'
                  '• Ideal untuk keamanan berkas dan privasi jaringan keluarga',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    height: 1.5,
                    color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ============ PARENTAL CONTROL TAB ============
  Widget _buildParentalControlTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberObsidian : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppTheme.neonPurple.withValues(alpha: 0.35) : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
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
                      color: AppTheme.neonPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(LucideIcons.shield, color: AppTheme.neonPurple, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'KONTROL ORANG TUA // FILTER KELUARGA',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Kelola akses internet anak dan anggota keluarga:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Blokir situs web dewasa dan konten tidak aman\n'
                '• Jadwalkan jam istirahat internet otomatis\n'
                '• Batasi alokasi waktu online harian per perangkat\n'
                '• Pantau status aktivitas bandwidth perangkat secara real-time',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.6,
                  color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cyberObsidian : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PANDUAN KONFIGURASI CEPAT',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Buka tab "DEVICES" di atas, ketuk tombol opsi (⋮) pada perangkat yang ingin Anda atur, lalu pilih "Kontrol Orang Tua".',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              CyberActionButton(
                label: 'BUKA TAB DAFTAR PERANGKAT',
                icon: LucideIcons.smartphone,
                primaryColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                onPressed: () => _tabController.animateTo(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============ DIALOGS ============

  void _showChangeSSIDDialog() {
    final controller = TextEditingController(text: _wifiConfig!.ssid);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Icon(LucideIcons.fileEdit, color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, size: 22),
            const SizedBox(width: 8),
            Text(
              'UBAH SSID WI-FI',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(
            fontFamily: 'monospace',
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            labelText: 'Nama Jaringan Baru (SSID)',
            labelStyle: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF64748B)),
            filled: true,
            fillColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: AppTheme.textMuted, fontFamily: 'monospace')),
          ),
          CyberActionButton(
            label: 'SIMPAN',
            fullWidth: false,
            primaryColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
            onPressed: () async {
              final success = await _wifiService.updateWiFiSSID(
                customerId: _authService.currentUser!.id,
                newSSID: controller.text,
              );
              if (success) {
                _loadWiFiConfig();
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SSID berhasil diperbarui!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppTheme.neonAmber : const Color(0xFFD97706),
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Icon(LucideIcons.key, color: isDark ? AppTheme.neonAmber : const Color(0xFFD97706), size: 22),
            const SizedBox(width: 8),
            Text(
              'UBAH SANDI WI-FI',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: TextStyle(
            fontFamily: 'monospace',
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            labelText: 'Kata Sandi Baru (Min. 8 Karakter)',
            labelStyle: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF64748B)),
            filled: true,
            fillColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? AppTheme.neonAmber : const Color(0xFFD97706)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: AppTheme.textMuted, fontFamily: 'monospace')),
          ),
          CyberActionButton(
            label: 'SIMPAN',
            fullWidth: false,
            primaryColor: isDark ? AppTheme.neonAmber : const Color(0xFFD97706),
            onPressed: () async {
              if (controller.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sandi harus memiliki minimal 8 karakter!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              final success = await _wifiService.updateWiFiPassword(
                customerId: _authService.currentUser!.id,
                newPassword: controller.text,
              );
              if (success) {
                _loadWiFiConfig();
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sandi Wi-Fi berhasil diperbarui!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog() {
    final nameController = TextEditingController();
    String selectedType = 'phone';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              Icon(LucideIcons.smartphone, color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, size: 22),
              const SizedBox(width: 8),
              Text(
                'TAMBAH PERANGKAT DEMO',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Nama Perangkat',
                  labelStyle: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF64748B)),
                  filled: true,
                  fillColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                dropdownColor: isDark ? AppTheme.cyberObsidian : Colors.white,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Tipe Perangkat',
                  labelStyle: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF64748B)),
                  filled: true,
                  fillColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'phone', child: Text('Smartphone')),
                  DropdownMenuItem(value: 'laptop', child: Text('Laptop / PC')),
                  DropdownMenuItem(value: 'tv', child: Text('Smart TV')),
                  DropdownMenuItem(value: 'iot', child: Text('IoT / CCTV')),
                ],
                onChanged: (value) {
                  setState(() => selectedType = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BATAL', style: TextStyle(color: AppTheme.textMuted, fontFamily: 'monospace')),
            ),
            CyberActionButton(
              label: 'TAMBAH',
              fullWidth: false,
              primaryColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Masukkan nama perangkat terlebih dahulu!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                await _wifiService.addMockDevice(
                  customerId: _authService.currentUser!.id,
                  deviceName: nameController.text,
                  deviceType: selectedType,
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDeviceDialog(ConnectedDevice device) {
    final controller = TextEditingController(text: device.deviceName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Icon(LucideIcons.edit3, color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, size: 22),
            const SizedBox(width: 8),
            Text(
              'GANTI NAMA PERANGKAT',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(
            fontFamily: 'monospace',
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            labelText: 'Nama Perangkat Baru',
            labelStyle: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF64748B)),
            filled: true,
            fillColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: AppTheme.textMuted, fontFamily: 'monospace')),
          ),
          CyberActionButton(
            label: 'SIMPAN',
            fullWidth: false,
            primaryColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
            onPressed: () async {
              await _wifiService.updateDeviceName(
                deviceId: device.id,
                newName: controller.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _toggleDeviceBlock(ConnectedDevice device) async {
    final success = await _wifiService.toggleDeviceBlock(
      deviceId: device.id,
      block: !device.isBlocked,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            device.isBlocked
                ? '${device.deviceName} berhasil dibuka blokir'
                : '${device.deviceName} berhasil diblokir dari jaringan',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
