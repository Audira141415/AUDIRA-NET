import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../widgets/enhanced_ui_components.dart';
import '../../utils/excel_exporter.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_provider.dart';

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
              _showEditCustomerForm(customer);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerForm(Map<String, dynamic> customer) {
    final formKey = GlobalKey<FormState>();
    final nameController =
        TextEditingController(text: customer['name']?.toString() ?? '');
    final emailController =
        TextEditingController(text: customer['email']?.toString() ?? '');
    final phoneController =
        TextEditingController(text: customer['phone']?.toString() ?? '');
    final addressController =
        TextEditingController(text: customer['address']?.toString() ?? '');
    String selectedPackage = customer['packageName']?.toString() ??
        customer['package']?.toString() ??
        '20 Mbps';
    if (!['20 Mbps', '50 Mbps', '100 Mbps'].contains(selectedPackage)) {
      selectedPackage = '20 Mbps';
    }
    String selectedStatus =
        (customer['status']?.toString() ?? 'active').toLowerCase();
    if (!['active', 'suspended', 'inactive'].contains(selectedStatus)) {
      selectedStatus = 'active';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Edit: ${customer['name'] ?? 'Pelanggan'}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nama harus diisi' : null,
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
                    validator: (v) =>
                        v == null || !v.contains('@') ? 'Email tidak valid' : null,
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
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nomor telepon harus diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Pemasangan',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Alamat harus diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPackage,
                    decoration: const InputDecoration(
                      labelText: 'Paket Layanan',
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
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedPackage = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status Layanan',
                      prefixIcon: Icon(Icons.toggle_on),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Aktif')),
                      DropdownMenuItem(
                          value: 'suspended', child: Text('Terisolir (Suspended)')),
                      DropdownMenuItem(
                          value: 'inactive', child: Text('Non-Aktif')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedStatus = val);
                      }
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
                  await _updateCustomer(
                    customer: customer,
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    address: addressController.text.trim(),
                    package: selectedPackage,
                    status: selectedStatus,
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Perbarui'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateCustomer({
    required Map<String, dynamic> customer,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String package,
    required String status,
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
                  Text('Memperbarui data pelanggan...'),
                ],
              ),
            ),
          ),
        ),
      );

      final db = await DatabaseService.instance.database;

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

      final userId = customer['userId'];
      final customerId = customer['customerId'] ?? customer['id'];

      // 1. Update SQLite users & customers table
      if (userId != null) {
        await db.update(
          'users',
          {
            'name': name,
            'email': email,
            'phone': phone,
            'updatedAt': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [userId],
        );

        await db.update(
          'customers',
          {
            'address': address,
            'packageName': package,
            'speed': speed,
            'price': price,
            'status': status,
          },
          where: 'userId = ?',
          whereArgs: [userId],
        );
      }

      // 2. Sync to Firestore if online
      try {
        final firestore = FirebaseFirestore.instance;
        if (customerId != null) {
          final custDocs = await firestore
              .collection('customers')
              .where('customerId', isEqualTo: customerId.toString())
              .get();

          for (var doc in custDocs.docs) {
            await doc.reference.update({
              'name': name,
              'email': email,
              'phone': phone,
              'address': address,
              'packageName': package,
              'speed': speed,
              'price': price,
              'status': status,
              'updatedAt': Timestamp.now(),
            });
          }
        }
      } catch (_) {}

      await _loadCustomers();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Data pelanggan "$name" berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Daftar Pelanggan (${_filteredCustomers.length})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF080D1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, tp, _) => ThemeToggleIconButton(themeProvider: tp),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export ke Excel',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                messenger.showSnackBar(
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

                if (filePath != null) {
                  messenger.showSnackBar(
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
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Gagal export data'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
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
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF060913)
                          : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.people,
                            label: 'Total',
                            value: _customers.length.toString(),
                            color: isDark ? const Color(0xFF00F0FF) : Colors.blue,
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
                            color: const Color(0xFFFF2A5F),
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
                            color: const Color(0xFFFFB800),
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

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF080D1E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isDark
                                  ? const Color(0xFF0F2B48)
                                  : Colors.blue.shade100,
                              child: Text(
                                (customer['name'] as String? ?? 'U')[0]
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF00F0FF)
                                      : Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              customer['name'] as String? ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.lightTextPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '📱 ${customer['phone'] ?? '-'}',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '📦 ${customer['packageName'] ?? '-'}',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '💰 Rp ${(customer['price'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF00FF9D)
                                        : Colors.green.shade700,
                                  ),
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
                                        color: isDark
                                            ? const Color(0x33FF2A5F)
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0x66FF2A5F)
                                              : Colors.red.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        '⚠️ $unpaidBills tagihan belum bayar',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? const Color(0xFFFF2A5F)
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (openTickets > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0x33FFB800)
                                            : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0x66FFB800)
                                              : Colors.orange.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        '🎫 $openTickets tiket terbuka',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? const Color(0xFFFFB800)
                                              : Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: isDark
                                  ? const Color(0xFF00F0FF)
                                  : Colors.grey.shade400,
                            ),
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
        backgroundColor: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
        foregroundColor: isDark ? const Color(0xFF05070D) : Colors.white,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.35)
              : color.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ??
                (isDark ? const Color(0xFF00F0FF) : Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: color ?? (isDark ? Colors.white : Colors.black87),
                fontWeight: color != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
