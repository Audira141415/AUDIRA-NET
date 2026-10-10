import 'package:flutter/material.dart';
import '../../services/package_upgrade_service.dart';
import '../../services/auth_service.dart';
import '../../models/package_upgrade_request.dart';
import 'package:intl/intl.dart';

class AdminPackageRequestsPage extends StatefulWidget {
  const AdminPackageRequestsPage({super.key});

  @override
  State<AdminPackageRequestsPage> createState() =>
      _AdminPackageRequestsPageState();
}

class _AdminPackageRequestsPageState extends State<AdminPackageRequestsPage>
    with SingleTickerProviderStateMixin {
  final PackageUpgradeService _upgradeService = PackageUpgradeService.instance;
  late TabController _tabController;

  List<PackageUpgradeRequest> _pendingRequests = [];
  List<PackageUpgradeRequest> _approvedRequests = [];
  List<PackageUpgradeRequest> _rejectedRequests = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _upgradeService.getRequestStats();
      final pending = await _upgradeService.getPendingRequests();
      final approved = await _upgradeService.getAllRequests(status: 'approved');
      final rejected = await _upgradeService.getAllRequests(status: 'rejected');

      setState(() {
        _stats = stats;
        _pendingRequests = pending;
        _approvedRequests = approved;
        _rejectedRequests = rejected;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveRequest(PackageUpgradeRequest request) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request.customerName}\n'
              '${request.currentPackage} → ${request.requestedPackage}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
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
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final adminUserId = AuthService.instance.currentUser?.id ?? '';
        await _upgradeService.approveRequest(
          request.id,
          adminUserId,
          notes: notesController.text.isNotEmpty ? notesController.text : null,
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permintaan disetujui'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _rejectRequest(PackageUpgradeRequest request) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request.customerName}\n'
              '${request.currentPackage} → ${request.requestedPackage}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alasan Penolakan *',
                hintText: 'Jelaskan alasan penolakan...',
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
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan harus diisi'),
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final adminUserId = AuthService.instance.currentUser?.id ?? '';
        await _upgradeService.rejectRequest(
          request.id,
          adminUserId,
          reason: reasonController.text,
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permintaan ditolak'),
              backgroundColor: Colors.red,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permintaan Perubahan Paket'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'Pending (${_stats['pending'] ?? 0})',
            ),
            Tab(
              text: 'Disetujui (${_stats['approved'] ?? 0})',
            ),
            Tab(
              text: 'Ditolak (${_stats['rejected'] ?? 0})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.arrow_upward,
                          label: 'Upgrade',
                          value: _stats['upgrades']?.toString() ?? '0',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.arrow_downward,
                          label: 'Downgrade',
                          value: _stats['downgrades']?.toString() ?? '0',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.pending_actions,
                          label: 'Total',
                          value: _stats['total']?.toString() ?? '0',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRequestList(_pendingRequests, isPending: true),
                      _buildRequestList(_approvedRequests),
                      _buildRequestList(_rejectedRequests),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRequestList(
    List<PackageUpgradeRequest> requests, {
    bool isPending = false,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada permintaan',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _RequestCard(
            request: request,
            isPending: isPending,
            onApprove: () => _approveRequest(request),
            onReject: () => _rejectRequest(request),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final PackageUpgradeRequest request;
  final bool isPending;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _RequestCard({
    required this.request,
    this.isPending = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.customerId,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      request.isUpgrade
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: request.isUpgrade ? Colors.green : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.isUpgrade ? 'Upgrade' : 'Downgrade',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: request.isUpgrade ? Colors.green : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 24),

            // Package Comparison
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paket Saat Ini',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        request.currentPackage,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${request.currentSpeed} Mbps',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(request.currentPrice)}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Paket Baru',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        request.requestedPackage,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        '${request.requestedSpeed} Mbps',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(request.requestedPrice)}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Price Difference
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: request.priceDifference > 0
                    ? Colors.orange.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    request.priceDifference > 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 16,
                    color: request.priceDifference > 0
                        ? Colors.orange
                        : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Selisih: ${request.priceDifference > 0 ? '+' : ''}Rp ${NumberFormat('#,###', 'id_ID').format(request.priceDifference.abs())}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: request.priceDifference > 0
                          ? Colors.orange.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),

            if (request.reason != null) ...[
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
                    const Icon(Icons.comment, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.reason!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (request.adminNotes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Catatan Admin: ${request.adminNotes!}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Timestamp
            Text(
              'Diajukan: ${DateFormat('dd MMM yyyy HH:mm').format(request.requestedAt)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),

            // Action Buttons (only for pending)
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check),
                      label: const Text('Setujui'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
