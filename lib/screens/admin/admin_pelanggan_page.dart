import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../widgets/enhanced_ui_components.dart';
import '../../utils/excel_exporter.dart';

class AdminPelangganPageEnhanced extends StatefulWidget {
  const AdminPelangganPageEnhanced({super.key});

  @override
  State<AdminPelangganPageEnhanced> createState() =>
      _AdminPelangganPageEnhancedState();
}

class _AdminPelangganPageEnhancedState
    extends State<AdminPelangganPageEnhanced> {
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, unpaid, tickets

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseService.instance.database;
      final result = await db.rawQuery('''
        SELECT 
          c.*,
          u.name,
          u.email,
          u.phone,
          (SELECT COUNT(*) FROM bills WHERE customerId = c.id AND status = 'unpaid') as unpaidBills,
          (SELECT COUNT(*) FROM tickets WHERE customerId = c.id AND status != 'closed') as openTickets
        FROM customers c
        JOIN users u ON c.userId = u.id
        ORDER BY c.id DESC
      ''');

      setState(() {
        _customers = result;
        _applyFilters();
        _isLoading = false;
      });

      // Successfully loaded ${_customers.length} customers
    } catch (e) {
      // Error loading customers
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    var filtered = _customers;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        final name = (c['name'] as String? ?? '').toLowerCase();
        final phone = (c['phone'] as String? ?? '').toLowerCase();
        final customerId = (c['customerId'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) ||
            phone.contains(query) ||
            customerId.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_filterStatus == 'unpaid') {
      filtered = filtered
          .where((c) => (c['unpaidBills'] as int? ?? 0) > 0)
          .toList();
    } else if (_filterStatus == 'tickets') {
      filtered = filtered
          .where((c) => (c['openTickets'] as int? ?? 0) > 0)
          .toList();
    } else if (_filterStatus == 'active') {
      filtered = filtered
          .where((c) => (c['status'] as String? ?? '') == 'active')
          .toList();
    }

    setState(() {
      _filteredCustomers = filtered;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pelanggan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('all', 'Semua'),
            _buildFilterOption('active', 'Aktif'),
            _buildFilterOption('unpaid', 'Punya Tagihan Belum Bayar'),
            _buildFilterOption('tickets', 'Punya Tiket Terbuka'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String title) {
    final isSelected = _filterStatus == value;
    return InkWell(
      onTap: () {
        setState(() => _filterStatus = value);
        Navigator.pop(context);
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.blue : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari Pelanggan'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama, telepon, atau ID pelanggan...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            _applyFilters();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer['name'] as String? ?? 'Detail Pelanggan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(
                icon: Icons.badge,
                label: 'ID',
                value: customer['customerId'] ?? '-',
              ),
              _DetailRow(
                icon: Icons.wifi_password,
                label: 'No. Internet',
                value: customer['internetNumber'] ?? '-',
              ),
              _DetailRow(
                icon: Icons.phone,
                label: 'Telepon',
                value: customer['phone'] ?? '-',
              ),
              _DetailRow(
                icon: Icons.email,
                label: 'Email',
                value: customer['email'] ?? '-',
              ),
              _DetailRow(
                icon: Icons.location_on,
                label: 'Alamat',
                value: customer['address'] ?? '-',
              ),
              _DetailRow(
                icon: Icons.wifi,
                label: 'Paket',
                value: customer['packageName'] ?? '-',
              ),
              _DetailRow(
                icon: Icons.speed,
                label: 'Kecepatan',
                value: '${customer['speed'] ?? 0} Mbps',
              ),
              _DetailRow(
                icon: Icons.attach_money,
                label: 'Harga',
                value:
                    'Rp ${(customer['price'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
              ),
              _DetailRow(
                icon: Icons.info,
                label: 'Status',
                value: customer['status'] ?? '-',
              ),
              const Divider(height: 24),
              _DetailRow(
                icon: Icons.receipt,
                label: 'Tagihan Belum Bayar',
                value: '${customer['unpaidBills'] ?? 0}',
                color: (customer['unpaidBills'] as int? ?? 0) > 0
                    ? Colors.red
                    : null,
              ),
              _DetailRow(
                icon: Icons.support,
                label: 'Tiket Terbuka',
                value: '${customer['openTickets'] ?? 0}',
                color: (customer['openTickets'] as int? ?? 0) > 0
                    ? Colors.orange
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur edit akan segera hadir')),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerForm() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final internetNumberController = TextEditingController();
    String selectedPackage = '20 Mbps';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.blue),
            SizedBox(width: 8),
            Text('Tambah Pelanggan Baru'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: internetNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Internet (opsional)',
                    prefixIcon: Icon(Icons.wifi_password),
                    border: OutlineInputBorder(),
                    hintText: 'Contoh: 111641129008 (12 digit)',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 12 || int.tryParse(value) == null) {
                        return 'Nomor internet harus 12 digit angka';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Lengkap',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedPackage,
                  decoration: const InputDecoration(
                    labelText: 'Paket Internet',
                    prefixIcon: Icon(Icons.wifi),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '20 Mbps',
                      child: Text('20 Mbps - Rp 150.000'),
                    ),
                    DropdownMenuItem(
                      value: '50 Mbps',
                      child: Text('50 Mbps - Rp 300.000'),
                    ),
                    DropdownMenuItem(
                      value: '100 Mbps',
                      child: Text('100 Mbps - Rp 500.000'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedPackage = value!;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _addCustomer(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                  internetNumber: internetNumberController.text.isEmpty
                      ? null
                      : internetNumberController.text,
                  package: selectedPackage,
                );
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustomer({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? internetNumber,
    required String package,
  }) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menambahkan pelanggan...'),
                ],
              ),
            ),
          ),
        ),
      );

      final db = await DatabaseService.instance.database;

      // Determine package details
      int speed;
      int price;
      switch (package) {
        case '100 Mbps':
          speed = 100;
          price = 500000;
          break;
        case '50 Mbps':
          speed = 50;
          price = 300000;
          break;
        default:
          speed = 20;
          price = 150000;
      }

      // Create user
      final userId = await db.insert('users', {
        'name': name,
        'email': email,
        'phone': phone,
        'password':
            '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', // password123
        'role': 'customer',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Generate customer ID
      final customerId = 'CUST${(1000 + userId).toString()}';

      // Generate internet number if not provided (12 digit: area(4) + year(4) + id(4))
      String finalInternetNumber;
      if (internetNumber != null && internetNumber.isNotEmpty) {
        finalInternetNumber = internetNumber;
      } else {
        final area = '1116'; // Area code (4 digit)
        final year = DateTime.now().year.toString(); // 2025
        final id = userId.toString().padLeft(4, '0'); // 0008
        finalInternetNumber = '$area$year$id'; // 111620250008
      }

      // Create customer
      await db.insert('customers', {
        'userId': userId,
        'customerId': customerId,
        'internetNumber': finalInternetNumber,
        'address': address,
        'packageName': package,
        'speed': speed,
        'price': price,
        'status': 'active',
        'installDate': DateTime.now().toIso8601String(),
      });

      // Reload data
      await _loadCustomers();

      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Pelanggan "$name" berhasil ditambahkan!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Lihat',
            textColor: Colors.white,
            onPressed: () {
              // Find and show customer details
              final customer = _customers.firstWhere(
                (c) => c['customerId'] == customerId,
                orElse: () => {},
              );
              if (customer.isNotEmpty) {
                _showCustomerDetails(customer);
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
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
        title: Text('Daftar Pelanggan (${_filteredCustomers.length})'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export ke Excel',
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Mengexport data...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );

                final filePath = await ExcelExporter.exportCustomers(
                  _filteredCustomers,
                );

                if (mounted) {
                  if (filePath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Export berhasil! ${_filteredCustomers.length} pelanggan',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal export data'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Badge(
              label: Text(_filterStatus == 'all' ? '' : '1'),
              isLabelVisible: _filterStatus != 'all',
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const EnhancedLoadingIndicator(
              type: LoadingType.linear,
              message: 'Memuat Data Pelanggan',
            )
          : _customers.isEmpty
          ? const EnhancedEmptyState(
              icon: Icons.people_outline,
              title: 'Belum Ada Pelanggan',
              description:
                  'Belum ada data pelanggan. Tambahkan pelanggan baru untuk memulai.',
              actionLabel: 'Tambah Pelanggan',
            )
          : _filteredCustomers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada hasil',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _filterStatus = 'all';
                      });
                      _applyFilters();
                    },
                    child: const Text('Reset Filter'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCustomers,
              child: Column(
                children: [
                  // Summary cards
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.people,
                            label: 'Total',
                            value: _customers.length.toString(),
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.warning,
                            label: 'Tagihan',
                            value: _customers
                                .where(
                                  (c) => (c['unpaidBills'] as int? ?? 0) > 0,
                                )
                                .length
                                .toString(),
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.support,
                            label: 'Tiket',
                            value: _customers
                                .where(
                                  (c) => (c['openTickets'] as int? ?? 0) > 0,
                                )
                                .length
                                .toString(),
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        final unpaidBills =
                            customer['unpaidBills'] as int? ?? 0;
                        final openTickets =
                            customer['openTickets'] as int? ?? 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                (customer['name'] as String? ?? 'U')[0]
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              customer['name'] as String? ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('📱 ${customer['phone'] ?? '-'}'),
                                Text('📦 ${customer['packageName'] ?? '-'}'),
                                Text(
                                  '💰 Rp ${(customer['price'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                ),
                                if (unpaidBills > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '⚠️ $unpaidBills tagihan belum bayar',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (openTickets > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '🎫 $openTickets tiket terbuka',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showCustomerDetails(customer),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerForm,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Pelanggan'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black87,
                fontWeight: color != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
