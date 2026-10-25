import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/database_service.dart';
import '../../../utils/excel_exporter.dart';

/// Clean Apple/Linear Customer Management Tab for AUDIRA Admin
class AdminPelangganTab extends StatefulWidget {
  const AdminPelangganTab({super.key});

  @override
  State<AdminPelangganTab> createState() => _AdminPelangganTabState();
}

class _AdminPelangganTabState extends State<AdminPelangganTab> {
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filter = 'all'; // all, active, unpaid, tickets

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
      if (mounted) {
        setState(() {
          _customers = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _customers.where((c) {
      final name = (c['name']?.toString() ?? '').toLowerCase();
      final phone = (c['phone']?.toString() ?? '').toLowerCase();
      final id = (c['customerId']?.toString() ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty || name.contains(q) || phone.contains(q) || id.contains(q);
      if (!matchesSearch) return false;

      if (_filter == 'active') return (c['status']?.toString() ?? '') == 'active';
      if (_filter == 'unpaid') return ((c['unpaidBills'] as num?)?.toInt() ?? 0) > 0;
      if (_filter == 'tickets') return ((c['openTickets'] as num?)?.toInt() ?? 0) > 0;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pelanggan Aktif',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.4),
                      ),
                      const SizedBox(height: 2),
                      Text('${_customers.length} total pelanggan terdata', style: TextStyle(fontSize: 12, color: textSecondary)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.fileSpreadsheet, size: 18, color: textPrimary),
                        tooltip: 'Export Excel',
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final path = await ExcelExporter.exportCustomers(filtered);
                          if (!mounted) return;
                          if (path != null) {
                            messenger.showSnackBar(const SnackBar(content: Text('Excel berhasil diexport!')));
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.refreshCw, size: 18, color: textPrimary),
                        tooltip: 'Refresh',
                        onPressed: _loadCustomers,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildMetric(isDark, 'Total', '${_customers.length}', const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  _buildMetric(
                    isDark,
                    'Menunggak',
                    '${_customers.where((c) => ((c['unpaidBills'] as num?)?.toInt() ?? 0) > 0).length}',
                    const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  _buildMetric(
                    isDark,
                    'Tiket',
                    '${_customers.where((c) => ((c['openTickets'] as num?)?.toInt() ?? 0) > 0).length}',
                    const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(LucideIcons.search, size: 16, color: textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 13, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Cari nama, ID, atau no telepon...',
                          hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  _buildChip('all', 'Semua (${_customers.length})', isDark),
                  const SizedBox(width: 8),
                  _buildChip('active', 'Aktif', isDark),
                  const SizedBox(width: 8),
                  _buildChip('unpaid', 'Menunggak', isDark),
                  const SizedBox(width: 8),
                  _buildChip('tickets', 'Ada Tiket', isDark),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7)))
                  : filtered.isEmpty
                      ? Center(child: Text('Tidak ada pelanggan sesuai filter', style: TextStyle(color: textSecondary)))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => _buildCard(filtered[i], isDark, cardBg, borderColor, textPrimary, textSecondary),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        backgroundColor: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
        foregroundColor: isDark ? const Color(0xFF030712) : Colors.white,
        icon: const Icon(LucideIcons.userPlus, size: 18),
        label: const Text('Pelanggan Baru', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildMetric(bool isDark, String label, String val, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(width: 3, height: 24, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c)),
                Text(label, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String key, String label, bool isDark) {
    final sel = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A)) : (isDark ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? Colors.transparent : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1))),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
            color: sel ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> c, bool isDark, Color bg, Color border, Color pColor, Color sColor) {
    final name = c['name']?.toString() ?? 'Pelanggan';
    final custId = c['customerId']?.toString() ?? 'ID-${c['id']}';
    final phone = c['phone']?.toString() ?? '-';
    final pkg = c['packageName']?.toString() ?? 'Paket';
    final speed = (c['speed'] as num?)?.toInt() ?? 0;
    final price = (c['price'] as num?)?.toInt() ?? 0;
    final unpaid = (c['unpaidBills'] as num?)?.toInt() ?? 0;
    final tickets = (c['openTickets'] as num?)?.toInt() ?? 0;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'P';

    return GestureDetector(
      onTap: () => _showCustomerSheet(c),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              child: Text(initial, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: pColor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: pColor)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (c['status'] == 'active' ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          c['status'] == 'active' ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: c['status'] == 'active' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('$custId • $phone', style: TextStyle(fontSize: 12, color: sColor)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('$pkg (${speed}M)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: sColor)),
                      const Spacer(),
                      Text('Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: pColor)),
                    ],
                  ),
                  if (unpaid > 0 || tickets > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (unpaid > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text('$unpaid Tagihan', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                          ),
                        if (unpaid > 0 && tickets > 0) const SizedBox(width: 6),
                        if (tickets > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text('$tickets Tiket', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B))),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerSheet(Map<String, dynamic> c) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c['name']?.toString() ?? 'Detail Pelanggan', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _infoRow('ID Pelanggan', c['customerId']?.toString() ?? '-'),
            _infoRow('No. Internet', c['internetNumber']?.toString() ?? '-'),
            _infoRow('Telepon', c['phone']?.toString() ?? '-'),
            _infoRow('Email', c['email']?.toString() ?? '-'),
            _infoRow('Alamat', c['address']?.toString() ?? '-'),
            _infoRow('Paket', '${c['packageName']} (${c['speed']} Mbps)'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showAddCustomerDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String pkg = '20 Mbps';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Pelanggan'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap'), validator: (v) => v!.isEmpty ? 'Wajib' : null),
                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Wajib' : null),
                TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telepon'), validator: (v) => v!.isEmpty ? 'Wajib' : null),
                TextFormField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Alamat'), validator: (v) => v!.isEmpty ? 'Wajib' : null),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                final db = await DatabaseService.instance.database;
                final userId = await db.insert('users', {
                  'name': nameCtrl.text,
                  'email': emailCtrl.text,
                  'phone': phoneCtrl.text,
                  'password': 'password123',
                  'role': 'customer',
                  'isActive': 1,
                  'createdAt': DateTime.now().toIso8601String(),
                  'updatedAt': DateTime.now().toIso8601String(),
                });
                await db.insert('customers', {
                  'userId': userId,
                  'customerId': 'CUST${1000 + userId}',
                  'internetNumber': '11162025${userId.toString().padLeft(4, '0')}',
                  'address': addressCtrl.text,
                  'packageName': pkg,
                  'speed': 20,
                  'price': 150000,
                  'status': 'active',
                  'installDate': DateTime.now().toIso8601String(),
                });
                _loadCustomers();
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
