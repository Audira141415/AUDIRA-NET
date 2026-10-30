import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
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
      final firestore = FirebaseFirestore.instance;

      // 1. Get all customer users
      final userSnap = await firestore
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .get();

      // 2. Get all customer records
      final customerSnap = await firestore.collection('customers').get();
      final customerByUserId = <String, Map<String, dynamic>>{};
      for (var doc in customerSnap.docs) {
        final data = doc.data();
        final uId = data['userId']?.toString();
        if (uId != null) {
          customerByUserId[uId] = {'id': doc.id, ...data};
        }
      }

      // 3. Unpaid bills count
      final unpaidMap = <String, int>{};
      try {
        final billsSnap = await firestore
            .collection('bills')
            .where('status', isEqualTo: 'unpaid')
            .get();
        for (var doc in billsSnap.docs) {
          final cId = doc.data()['customerId']?.toString();
          if (cId != null) {
            unpaidMap[cId] = (unpaidMap[cId] ?? 0) + 1;
          }
        }
      } catch (_) {}

      // 4. Open tickets count
      final ticketMap = <String, int>{};
      try {
        final ticketsSnap = await firestore.collection('tickets').get();
        for (var doc in ticketsSnap.docs) {
          final data = doc.data();
          if ((data['status'] ?? '').toString().toLowerCase() != 'closed') {
            final cId = data['customerId']?.toString();
            if (cId != null) {
              ticketMap[cId] = (ticketMap[cId] ?? 0) + 1;
            }
          }
        }
      } catch (_) {}

      List<Map<String, dynamic>> combined = [];

      for (var uDoc in userSnap.docs) {
        final uData = uDoc.data();
        final uId = uDoc.id;
        final cProfile = customerByUserId[uId] ?? {};
        final cId = cProfile['customerId'] ?? cProfile['id'] ?? uData['customerId'] ?? uId;

        combined.add({
          'id': cProfile['id'] ?? uId,
          'customerId': cId,
          'name': uData['name'] ?? cProfile['name'] ?? 'Pelanggan',
          'email': uData['email'] ?? cProfile['email'] ?? '',
          'phone': uData['phone'] ?? cProfile['phone'] ?? '',
          'address': cProfile['address'] ?? uData['address'] ?? 'Area AUDIRA',
          'package': cProfile['packageName'] ?? cProfile['package'] ?? uData['package'] ?? 'Standard',
          'speed': cProfile['speed'] ?? uData['speed'] ?? 20,
          'price': cProfile['price'] ?? uData['price'] ?? 250000,
          'status': cProfile['status'] ?? uData['status'] ?? 'active',
          'isGracePeriod': cProfile['isGracePeriod'] == true || uData['isGracePeriod'] == true,
          'gracePeriodExpiry': cProfile['gracePeriodExpiry'] ?? uData['gracePeriodExpiry'],
          'unpaidBills': unpaidMap[cId] ?? 0,
          'openTickets': ticketMap[cId] ?? 0,
        });
      }

      // Include customer docs without user docs
      for (var cDoc in customerSnap.docs) {
        final cData = cDoc.data();
        final cId = cData['customerId'] ?? cDoc.id;
        if (!combined.any((item) => item['customerId'] == cId || item['id'] == cDoc.id)) {
          combined.add({
            'id': cDoc.id,
            'customerId': cId,
            'name': cData['name'] ?? 'Pelanggan',
            'email': cData['email'] ?? '',
            'phone': cData['phone'] ?? '',
            'address': cData['address'] ?? 'Area AUDIRA',
            'package': cData['packageName'] ?? cData['package'] ?? 'Standard',
            'speed': cData['speed'] ?? 20,
            'price': cData['price'] ?? 250000,
            'status': cData['status'] ?? 'active',
            'isGracePeriod': cData['isGracePeriod'] == true,
            'gracePeriodExpiry': cData['gracePeriodExpiry'],
            'unpaidBills': unpaidMap[cId] ?? 0,
            'openTickets': ticketMap[cId] ?? 0,
          });
        }
      }

      if (mounted) {
        setState(() {
          _customers = combined;
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

      if (_filter == 'active') return (c['status']?.toString() ?? '') == 'active' && c['isGracePeriod'] != true;
      if (_filter == 'grace') return c['isGracePeriod'] == true;
      if (_filter == 'isolated') return (c['status']?.toString() ?? '') != 'active';
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
                  _buildChip('grace', 'Janji Bayar', isDark),
                  const SizedBox(width: 8),
                  _buildChip('isolated', 'Terisolir', isDark),
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
                          color: (c['isGracePeriod'] == true
                                  ? const Color(0xFFFFB800)
                                  : (c['status'] == 'active' ? const Color(0xFF10B981) : const Color(0xFFEF4444)))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: (c['isGracePeriod'] == true
                                    ? const Color(0xFFFFB800)
                                    : (c['status'] == 'active' ? const Color(0xFF10B981) : const Color(0xFFEF4444)))
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          c['isGracePeriod'] == true
                              ? 'Janji Bayar'
                              : (c['status'] == 'active' ? 'Aktif' : 'Terisolir'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: c['isGracePeriod'] == true
                                ? const Color(0xFFFFB800)
                                : (c['status'] == 'active' ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
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
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final name = c['name']?.toString() ?? 'Pelanggan';
    final custId = c['customerId']?.toString() ?? '-';
    final phone = c['phone']?.toString() ?? '-';
    final isActive = c['status'] == 'active';
    final isGrace = c['isGracePeriod'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                          const SizedBox(height: 2),
                          Text('$custId • $phone', style: TextStyle(fontSize: 12, color: textSecondary, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isGrace
                                ? const Color(0xFFFFB800)
                                : (isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444)))
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isGrace
                              ? const Color(0xFFFFB800)
                              : (isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                        ),
                      ),
                      child: Text(
                        isGrace
                            ? 'JANJI BAYAR'
                            : (isActive ? 'AKTIF' : 'TERISOLIR'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: isGrace
                              ? const Color(0xFFFFB800)
                              : (isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _infoRow('No. Internet', c['internetNumber']?.toString() ?? '-'),
                      _infoRow('Email', c['email']?.toString() ?? '-'),
                      _infoRow('Alamat', c['address']?.toString() ?? '-'),
                      _infoRow('Paket', '${c['package'] ?? c['packageName']} (${c['speed']} Mbps)'),
                      _infoRow('Tagihan Tertunda', '${c['unpaidBills']} Tagihan'),
                      _infoRow('Tiket Terbuka', '${c['openTickets']} Tiket'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'KONTROL OPERASIONAL ISP & NOC',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _toggleCustomerIsolation(c);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          side: BorderSide(
                            color: isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(isActive ? LucideIcons.ban : LucideIcons.checkCircle, size: 16),
                        label: Text(
                          isActive ? 'Isolir 1-Klik' : 'Buka Isolir',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _grantGracePeriodAdmin(c, 24);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFFB800),
                          side: const BorderSide(color: Color(0xFFFFB800), width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(LucideIcons.heartHandshake, size: 16),
                        label: const Text(
                          'Janji Bayar 24h',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(phone, name, custId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(LucideIcons.messageCircle, size: 18),
                    label: const Text(
                      'HUBUNGI PELANGGAN VIA WHATSAPP',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleCustomerIsolation(Map<String, dynamic> c) async {
    final docId = c['id']?.toString() ?? '';
    final currentStatus = c['status']?.toString().toLowerCase() ?? 'active';
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    final actionName = newStatus == 'suspended' ? 'diisolir' : 'diaktifkan kembali';

    try {
      final firestore = FirebaseFirestore.instance;
      if (docId.isNotEmpty) {
        await firestore.collection('customers').doc(docId).set({
          'status': newStatus,
          'isGracePeriod': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Also update users collection if mapped
        final userQuery = await firestore.collection('users').where('id', isEqualTo: docId).get();
        for (var doc in userQuery.docs) {
          await doc.reference.update({'status': newStatus, 'isActive': newStatus == 'active'});
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Pelanggan ${c['name']} berhasil $actionName!'),
            backgroundColor: newStatus == 'active' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadCustomers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengubah status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _grantGracePeriodAdmin(Map<String, dynamic> c, int hours) async {
    final docId = c['id']?.toString() ?? '';
    final custId = c['customerId']?.toString() ?? '';

    try {
      final firestore = FirebaseFirestore.instance;
      final expiryDt = DateTime.now().add(Duration(hours: hours));

      if (docId.isNotEmpty) {
        await firestore.collection('customers').doc(docId).set({
          'status': 'active',
          'isGracePeriod': true,
          'gracePeriodExpiry': Timestamp.fromDate(expiryDt),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Also mark active bill as grace period
      if (custId.isNotEmpty) {
        final billsQuery = await firestore
            .collection('bills')
            .where('customerId', isEqualTo: custId)
            .where('status', isEqualTo: 'unpaid')
            .get();
        for (var doc in billsQuery.docs) {
          await doc.reference.set({
            'isGracePeriod': true,
            'gracePeriodExpiry': Timestamp.fromDate(expiryDt),
          }, SetOptions(merge: true));
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Dispensasi Janji Bayar $hours Jam berhasil diberikan kepada ${c['name']}!'),
            backgroundColor: const Color(0xFFFFB800),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadCustomers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memberikan janji bayar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openWhatsApp(String phone, String name, String custId) async {
    var cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    } else if (!cleanPhone.startsWith('62')) {
      cleanPhone = '62$cleanPhone';
    }

    final msg = Uri.encodeComponent(
      'Halo Bpk/Ibu $name ($custId),\nKami dari Layanan Operasional & Billing AUDIRA Digital Network ingin mengonfirmasi status layanan internet Anda. Ada yang dapat kami bantu?',
    );
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$msg');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka WhatsApp pada perangkat ini')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka WhatsApp: $e')),
        );
      }
    }
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
                final firestore = FirebaseFirestore.instance;
                final userDoc = await firestore.collection('users').add({
                  'name': nameCtrl.text,
                  'email': emailCtrl.text,
                  'phone': phoneCtrl.text,
                  'role': 'customer',
                  'isActive': true,
                  'status': 'active',
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                final custId = 'CUST${1000 + Random().nextInt(9000)}';
                await firestore.collection('customers').doc(userDoc.id).set({
                  'userId': userDoc.id,
                  'customerId': custId,
                  'name': nameCtrl.text,
                  'email': emailCtrl.text,
                  'phone': phoneCtrl.text,
                  'internetNumber': '1116${Random().nextInt(90000000) + 10000000}',
                  'address': addressCtrl.text,
                  'package': pkg,
                  'packageName': pkg,
                  'speed': 20,
                  'price': 150000,
                  'status': 'active',
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
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
