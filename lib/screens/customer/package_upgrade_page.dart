import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import '../../services/package_upgrade_service.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../models/package_upgrade_request.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../widgets/cyber_widgets.dart';

class PackageUpgradePage extends StatefulWidget {
  const PackageUpgradePage({super.key});

  @override
  State<PackageUpgradePage> createState() => _PackageUpgradePageState();
}

class _PackageUpgradePageState extends State<PackageUpgradePage> {
  final PackageUpgradeService _upgradeService = PackageUpgradeService.instance;
  Map<String, dynamic>? _currentPackage;
  Map<String, dynamic>? _customerData;
  List<PackageUpgradeRequest> _requestHistory = [];
  bool _isLoading = true;
  bool _hasPendingRequest = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int _parseSpeed(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) {
      final match = RegExp(r'\d+').firstMatch(val);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? 0;
      }
    }
    return 0;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userData = AuthService.instance.currentUserData;
      if (userData == null) return;

      // Get customer data
      final customer = await FirebaseService.instance.getCustomerByUserId(
        userData['id'].toString(),
      );

      if (customer != null) {
        final parsedSpeed = _parseSpeed(customer['speed']);
        final fee = (customer['monthlyFee'] is num)
            ? (customer['monthlyFee'] as num).toInt()
            : int.tryParse(customer['monthlyFee']?.toString() ?? '0') ?? 0;

        setState(() {
          _customerData = customer;
          _currentPackage = {
            'name': customer['packageName'] ?? '',
            'speed': parsedSpeed,
            'speedRaw': customer['speed']?.toString() ?? '$parsedSpeed Mbps',
            'price': fee,
          };
        });

        // Get request history
        final requests = await _upgradeService.getCustomerRequests(
          customer['id'],
        );
        final hasPending = await _upgradeService.hasPendingRequest(
          customer['id'],
        );

        setState(() {
          _requestHistory = requests;
          _hasPendingRequest = hasPending;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showPackageSelection() async {
    if (_hasPendingRequest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda masih memiliki permintaan yang belum diproses'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final int currentSpeed = (_currentPackage?['speed'] is int)
        ? _currentPackage!['speed'] as int
        : _parseSpeed(_currentPackage?['speed']);

    final selectedPackage = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _PackageSelectionDialog(currentSpeed: currentSpeed),
    );

    if (selectedPackage != null && mounted) {
      _showConfirmationDialog(selectedPackage);
    }
  }

  Future<void> _showConfirmationDialog(Map<String, dynamic> newPackage) async {
    final reasonController = TextEditingController();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, width: 1.5),
        ),
        title: Row(
          children: [
            Icon(LucideIcons.arrowLeftRight, color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, size: 22),
            const SizedBox(width: 8),
            Text(
              'KONFIRMASI BANDWIDTH',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ComparisonCard(
                currentPackage: _currentPackage!,
                newPackage: newPackage,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  labelText: 'Alasan Perubahan (Opsional)',
                  labelStyle: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF64748B)),
                  hintText: 'Contoh: Kebutuhan bandwidth streaming / WFH',
                  hintStyle: TextStyle(color: isDark ? AppTheme.textMuted : const Color(0xFF94A3B8), fontSize: 12),
                  filled: true,
                  fillColor: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CyberCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'INFORMASI KETENTUAN LAYANAN:',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppTheme.neonAmber,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Verifikasi profil bandwidth diproses oleh NOC AUDIRA\n'
                      '• Estimasi aktivasi 1 - 2 jam kerja\n'
                      '• Billing disesuaikan pro-rata pada siklus berikutnya\n'
                      '• Tanpa biaya konfigurasi ulang ONT',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        height: 1.5,
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL', style: TextStyle(color: AppTheme.textMuted, fontFamily: 'monospace')),
          ),
          CyberActionButton(
            label: 'AJUKAN TIKET PERUBAHAN',
            fullWidth: false,
            primaryColor: AppTheme.neonCyan,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _submitRequest(newPackage, reasonController.text);
    }
  }

  Future<void> _submitRequest(
    Map<String, dynamic> newPackage,
    String reason,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _upgradeService.submitUpgradeRequest(
        customerId: _customerData!['id'],
        customerName: _customerData!['name'],
        currentPackage: _currentPackage!['name'],
        currentSpeed: _currentPackage!['speed'],
        currentPrice: _currentPackage!['price'],
        requestedPackage: newPackage['name'],
        requestedSpeed: newPackage['speed'],
        requestedPrice: newPackage['price'],
        reason: reason.isNotEmpty ? reason : null,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close page

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan berhasil diajukan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          icon: Icon(LucideIcons.arrowLeft, size: 18, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'BANDWIDTH // UBAH PAKET',
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
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Package Card
                  CyberCard(
                    accentColor: AppTheme.neonCyan,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'PAKET AKTIF SAAT INI',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.textMuted,
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                            CyberBadge(
                              label: 'SUBSCRIPTION ACTIVE',
                              color: AppTheme.neonGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentPackage?['name'] ?? 'N/A',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'BANDWIDTH SPEED',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_currentPackage?['speed'] ?? 0} Mbps',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: AppTheme.neonCyan,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'BIAYA BERLANGGANAN',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${NumberFormat('#,###', 'id_ID').format(_currentPackage?['price'] ?? 0)}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: AppTheme.neonGreen,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Change Package Button
                  CyberActionButton(
                    label: _hasPendingRequest
                        ? 'MENUNGGU VERIFIKASI NOC'
                        : 'UBAH PROFIL BANDWIDTH',
                    icon: _hasPendingRequest ? LucideIcons.hourglass : LucideIcons.arrowLeftRight,
                    color: _hasPendingRequest ? AppTheme.muted : AppTheme.neonCyan,
                    onPressed: _hasPendingRequest ? null : () => _showPackageSelection(),
                    fullWidth: true,
                  ),

                  const SizedBox(height: 28),

                  // Request History Header
                  Row(
                    children: [
                      const CyberPulseDot(color: AppTheme.neonAmber, size: 8),
                      const SizedBox(width: 8),
                      Text(
                        'LOG RIWAYAT PERUBAHAN PAKET',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _requestHistory.isEmpty
                      ? CyberCard(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Center(
                              child: Column(
                                children: const [
                                  Icon(
                                    LucideIcons.history,
                                    size: 40,
                                    color: AppTheme.textMuted,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'BELUM ADA RIWAYAT PERUBAHAN',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _requestHistory.length,
                          itemBuilder: (context, index) {
                            final request = _requestHistory[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RequestHistoryCard(request: request),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}

// Package Selection Dialog
class _PackageSelectionDialog extends StatelessWidget {
  final int currentSpeed;

  const _PackageSelectionDialog({required this.currentSpeed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packages = PackageUpgradeService.instance.availablePackages;

    return Dialog(
      backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, width: 1.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.layers, color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'KATALOG BANDWIDTH AUDIRA',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: packages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final package = packages[index];
                  final isCurrent = package['speed'] == currentSpeed;

                  return _PackageCard(
                    package: package,
                    isCurrent: isCurrent,
                    onTap: isCurrent
                        ? null
                        : () => Navigator.pop(context, package),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BATAL', style: TextStyle(color: AppTheme.textMuted, fontFamily: 'monospace')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Package Card Widget
class _PackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _PackageCard({
    required this.package,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isCurrent
            ? (isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF1F5F9))
            : (isDark ? AppTheme.cyberObsidian : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? (isDark ? AppTheme.textMuted : const Color(0xFFCBD5E1))
              : (isDark ? AppTheme.neonCyan.withValues(alpha: 0.4) : const Color(0xFFCBD5E1)),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        package['name'],
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (isCurrent)
                      const CyberBadge(
                        label: 'AKTIF',
                        color: AppTheme.textMuted,
                      )
                    else
                      CyberBadge(
                        label: '${package['speed']} MBPS',
                        color: AppTheme.neonCyan,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  package['description'],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (package['features'] as List<String>)
                      .map(
                        (feature) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.neonCyan.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            '✓ $feature',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: AppTheme.neonCyan,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(package['price'])}/bulan',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Comparison Card
class _ComparisonCard extends StatelessWidget {
  final Map<String, dynamic> currentPackage;
  final Map<String, dynamic> newPackage;

  const _ComparisonCard({
    required this.currentPackage,
    required this.newPackage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPrice = (currentPackage['price'] is num)
        ? (currentPackage['price'] as num).toInt()
        : int.tryParse(currentPackage['price']?.toString() ?? '0') ?? 0;
    final newPrice = (newPackage['price'] is num)
        ? (newPackage['price'] as num).toInt()
        : int.tryParse(newPackage['price']?.toString() ?? '0') ?? 0;
    final priceDiff = newPrice - currentPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAAT INI',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentPackage['name'],
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${currentPackage['speed']} Mbps',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.neonCyan,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(currentPrice)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.neonGreen,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.arrowRight, color: AppTheme.neonCyan, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PAKET BARU',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      newPackage['name'],
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      '${newPackage['speed']} Mbps',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.neonCyan,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(newPrice)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.neonGreen,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFCBD5E1), height: 1),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (priceDiff > 0 ? AppTheme.neonAmber : AppTheme.neonGreen).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (priceDiff > 0 ? AppTheme.neonAmber : AppTheme.neonGreen).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  priceDiff > 0 ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                  color: priceDiff > 0 ? AppTheme.neonAmber : AppTheme.neonGreen,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'SELISIH: ${priceDiff > 0 ? '+' : ''}Rp ${NumberFormat('#,###', 'id_ID').format(priceDiff.abs())}/BULAN',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: priceDiff > 0 ? AppTheme.neonAmber : AppTheme.neonGreen,
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

// Request History Card
class _RequestHistoryCard extends StatelessWidget {
  final PackageUpgradeRequest request;

  const _RequestHistoryCard({required this.request});

  Color _getStatusColor() {
    switch (request.status) {
      case 'approved':
        return AppTheme.neonGreen;
      case 'rejected':
        return AppTheme.neonCrimson;
      default:
        return AppTheme.neonAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    request.isUpgrade
                        ? LucideIcons.arrowUp
                        : LucideIcons.arrowDown,
                    color: request.isUpgrade ? AppTheme.neonGreen : AppTheme.neonCyan,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    request.isUpgrade ? 'UPGRADE REQUEST' : 'DOWNGRADE REQUEST',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              CyberBadge(
                label: request.status.toUpperCase(),
                color: _getStatusColor(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.currentPackage,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const Icon(LucideIcons.arrowDown, size: 14, color: AppTheme.neonCyan),
                    Text(
                      request.requestedPackage,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(request.requestedAt),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  if (request.processedAt != null)
                    Text(
                      'PROSES: ${DateFormat('dd MMM yyyy').format(request.processedAt!)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: AppTheme.neonCyan,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (request.adminNotes != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppTheme.cyberSurfaceCard : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.info, size: 14, color: AppTheme.neonAmber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.adminNotes!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
