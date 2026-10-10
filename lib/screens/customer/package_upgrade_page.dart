import 'package:flutter/material.dart';
import '../../services/package_upgrade_service.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../models/package_upgrade_request.dart';
import 'package:intl/intl.dart';

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
        setState(() {
          _customerData = customer;
          _currentPackage = {
            'name': customer['packageName'] ?? '',
            'speed': customer['speed'] ?? 0,
            'price': customer['monthlyFee'] ?? 0,
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

    final selectedPackage = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _PackageSelectionDialog(currentSpeed: _currentPackage?['speed'] ?? 0),
    );

    if (selectedPackage != null && mounted) {
      _showConfirmationDialog(selectedPackage);
    }
  }

  Future<void> _showConfirmationDialog(Map<String, dynamic> newPackage) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Perubahan Paket'),
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
                decoration: const InputDecoration(
                  labelText: 'Alasan (opsional)',
                  hintText: 'Mengapa Anda ingin mengubah paket?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Informasi Penting:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Permintaan akan diproses oleh admin\n'
                      '• Proses persetujuan 1-2 hari kerja\n'
                      '• Perubahan berlaku bulan berikutnya\n'
                      '• Tidak ada biaya instalasi ulang',
                      style: TextStyle(fontSize: 13),
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
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajukan Permintaan'),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ubah Paket'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Package Card
                  Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade500],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Paket Saat Ini',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentPackage?['name'] ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
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
                                    'Kecepatan',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${_currentPackage?['speed'] ?? 0} Mbps',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Biaya Bulanan',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${NumberFormat('#,###', 'id_ID').format(_currentPackage?['price'] ?? 0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
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
                  ),

                  const SizedBox(height: 24),

                  // Change Package Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _hasPendingRequest
                          ? null
                          : _showPackageSelection,
                      icon: const Icon(Icons.sync_alt),
                      label: Text(
                        _hasPendingRequest
                            ? 'Menunggu Persetujuan'
                            : 'Ubah Paket',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Request History
                  const Text(
                    'Riwayat Permintaan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _requestHistory.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada riwayat permintaan',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
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
                            return _RequestHistoryCard(request: request);
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
    final packages = PackageUpgradeService.instance.availablePackages;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Text(
                'Pilih Paket Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: packages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
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
    return Card(
      color: isCurrent ? Colors.grey.shade200 : Colors.white,
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Paket Saat Ini',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                package['description'],
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (package['features'] as List<String>)
                    .map(
                      (feature) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '✓ $feature',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
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
    final priceDiff = newPackage['price'] - currentPackage['price'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saat Ini',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      currentPackage['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${currentPackage['speed']} Mbps'),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(currentPackage['price'])}',
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Paket Baru',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      newPackage['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                    Text('${newPackage['speed']} Mbps'),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(newPackage['price'])}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: priceDiff > 0
                  ? Colors.orange.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  priceDiff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: priceDiff > 0 ? Colors.orange : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selisih: ${priceDiff > 0 ? '+' : ''}Rp ${NumberFormat('#,###', 'id_ID').format(priceDiff.abs())}/bulan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: priceDiff > 0
                        ? Colors.orange.shade900
                        : Colors.green.shade900,
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
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: request.isUpgrade ? Colors.green : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      request.isUpgrade ? 'Upgrade' : 'Downgrade',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 14,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
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
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const Icon(Icons.arrow_downward, size: 16),
                      Text(
                        request.requestedPackage,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(request.requestedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (request.processedAt != null)
                      Text(
                        'Diproses: ${DateFormat('dd MMM yyyy').format(request.processedAt!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (request.adminNotes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.adminNotes!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
