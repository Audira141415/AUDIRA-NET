import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/inventory_service.dart';
import '../../services/auth_service.dart';
import '../../models/inventory_model.dart';

class InventoryManagementPage extends StatefulWidget {
  const InventoryManagementPage({super.key});

  @override
  State<InventoryManagementPage> createState() =>
      _InventoryManagementPageState();
}

class _InventoryManagementPageState extends State<InventoryManagementPage>
    with SingleTickerProviderStateMixin {
  final InventoryService _inventoryService = InventoryService.instance;
  List<InventoryItem> _myItems = [];
  List<StockRequest> _myRequests = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      final userData = AuthService.instance.currentUserData;
      if (userData == null) return;

      final items = await _inventoryService.getTeknisiItems(userData['id']);
      final requests = await _inventoryService.getStockRequests(
        teknisiId: userData['id'],
      );

      setState(() {
        _myItems = items;
        _myRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createStockRequest() async {
    final result = await showDialog<List<RequestItem>>(
      context: context,
      builder: (context) => const _StockRequestDialog(),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final userData = AuthService.instance.currentUserData!;

      await _inventoryService.createStockRequest(
        teknisiId: userData['id'],
        teknisiName: userData['name'],
        items: result,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan stok berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
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
        title: const Text('📦 Inventory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Barang Saya'),
            Tab(text: 'Permintaan'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildMyItemsTab(), _buildRequestsTab()],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createStockRequest,
        icon: const Icon(Icons.add),
        label: const Text('Minta Stok'),
      ),
    );
  }

  Widget _buildMyItemsTab() {
    if (_myItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada barang yang dipegang',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final groupedItems = <String, List<InventoryItem>>{};
    for (var item in _myItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedItems.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.category),
            title: Text(entry.key.toUpperCase()),
            subtitle: Text('${entry.value.length} item'),
            children: entry.value.map((item) {
              return ListTile(
                title: Text(item.name),
                subtitle: Text('SN: ${item.serialNumber}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRequestsTab() {
    if (_myRequests.isEmpty) {
      return const Center(child: Text('Belum ada permintaan stok'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myRequests.length,
      itemBuilder: (context, index) {
        final request = _myRequests[index];
        final statusColor = request.status == 'approved'
            ? Colors.green
            : request.status == 'pending'
            ? Colors.orange
            : Colors.red;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.2),
              child: Icon(
                request.status == 'approved'
                    ? Icons.check_circle
                    : Icons.pending,
                color: statusColor,
              ),
            ),
            title: Text('${request.items.length} item diminta'),
            subtitle: Text(DateFormat('dd MMM yyyy').format(request.createdAt)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                request.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            children: request.items.map((item) {
              return ListTile(
                title: Text(item.itemName),
                subtitle: Text(item.category),
                trailing: Text('x${item.quantity}'),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _StockRequestDialog extends StatefulWidget {
  const _StockRequestDialog();

  @override
  State<_StockRequestDialog> createState() => _StockRequestDialogState();
}

class _StockRequestDialogState extends State<_StockRequestDialog> {
  final List<RequestItem> _items = [];

  void _addItem() {
    setState(() {
      _items.add(
        RequestItem(category: 'modem', itemName: 'Modem Fiber', quantity: 1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Permintaan Stok'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_items.isEmpty)
              const Text('Tambahkan item yang dibutuhkan')
            else
              ..._items.asMap().entries.map((entry) {
                return ListTile(
                  title: Text(entry.value.itemName),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => setState(() => _items.removeAt(entry.key)),
                  ),
                );
              }),
            TextButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Item'),
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
          onPressed: _items.isEmpty
              ? null
              : () => Navigator.pop(context, _items),
          child: const Text('Kirim Permintaan'),
        ),
      ],
    );
  }
}
