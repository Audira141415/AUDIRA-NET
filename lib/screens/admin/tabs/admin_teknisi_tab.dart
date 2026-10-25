import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/firebase_service.dart';

/// Clean Apple/Linear Fleet Management Tab for AUDIRA Admin
class AdminTeknisiTab extends StatefulWidget {
  const AdminTeknisiTab({super.key});

  @override
  State<AdminTeknisiTab> createState() => _AdminTeknisiTabState();
}

class _AdminTeknisiTabState extends State<AdminTeknisiTab> {
  List<Map<String, dynamic>> _teknisiList = [];
  List<String> _zones = [];
  bool _isLoading = true;
  String? _filterZone;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final teknisi = await FirebaseService.instance.getAllTeknisi();
      final zonesData = await FirebaseService.instance.getAllZones();
      if (mounted) {
        setState(() {
          _teknisiList = teknisi;
          _zones = zonesData.map((z) => z['name']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filterZone == null || _filterZone!.isEmpty) return _teknisiList;
    return _teknisiList.where((t) => (t['zone']?.toString() ?? '') == _filterZone).toList();
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
                        'Armada Teknisi',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.4),
                      ),
                      const SizedBox(height: 2),
                      Text('${_teknisiList.length} teknisi lapangan terdaftar', style: TextStyle(fontSize: 12, color: textSecondary)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.refreshCw, size: 18, color: textPrimary),
                    tooltip: 'Refresh',
                    onPressed: _loadData,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildMetric(isDark, 'Total Armada', '${_teknisiList.length}', const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  _buildMetric(isDark, 'Zona Tercover', '${_zones.length}', const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  _buildMetric(isDark, 'Tersedia', '${_teknisiList.length}', const Color(0xFFF59E0B)),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildChip(null, 'Semua Zona (${_teknisiList.length})', isDark),
                  ..._zones.map((z) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildChip(z, z, isDark),
                  )),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7)))
                  : filtered.isEmpty
                      ? Center(child: Text('Tidak ada teknisi untuk zona ini', style: TextStyle(color: textSecondary)))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => _buildTeknisiCard(filtered[i], isDark, cardBg, borderColor, textPrimary, textSecondary),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTeknisiForm(null),
        backgroundColor: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0284C7),
        foregroundColor: isDark ? const Color(0xFF030712) : Colors.white,
        icon: const Icon(LucideIcons.userPlus, size: 18),
        label: const Text('Tambah Teknisi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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

  Widget _buildChip(String? zone, String label, bool isDark) {
    final sel = _filterZone == zone;
    return GestureDetector(
      onTap: () => setState(() => _filterZone = zone),
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

  Widget _buildTeknisiCard(Map<String, dynamic> t, bool isDark, Color bg, Color border, Color pColor, Color sColor) {
    final name = t['name']?.toString() ?? 'Teknisi';
    final email = t['email']?.toString() ?? '-';
    final phone = t['phone']?.toString() ?? '-';
    final zone = t['zone']?.toString() ?? 'Zona Standar';
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'T';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            child: Text(initial, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: pColor)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(zone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.mail, size: 12, color: sColor),
                    const SizedBox(width: 6),
                    Expanded(child: Text(email, style: TextStyle(fontSize: 12, color: sColor))),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(LucideIcons.phone, size: 12, color: sColor),
                    const SizedBox(width: 6),
                    Text(phone, style: TextStyle(fontSize: 12, color: sColor)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.moreVertical, size: 16, color: sColor),
            onSelected: (action) {
              if (action == 'edit') _showTeknisiForm(t);
              if (action == 'delete') _deleteTeknisi(t);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Data')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  void _showTeknisiForm(Map<String, dynamic>? teknisi) {
    final isEdit = teknisi != null;
    final emailCtrl = TextEditingController(text: teknisi?['email']?.toString() ?? '');
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: teknisi?['name']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: teknisi?['phone']?.toString() ?? '');
    String selectedZone = (teknisi?['zone']?.toString()) ?? (_zones.isNotEmpty ? _zones.first : 'Batam Center');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Teknisi' : 'Tambah Teknisi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: emailCtrl, enabled: !isEdit, decoration: const InputDecoration(labelText: 'Email')),
                if (!isEdit) TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'No. Telepon')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedZone,
                  decoration: const InputDecoration(labelText: 'Zona Penempatan'),
                  items: ['Batam Center', 'Piayu', 'Baloi', 'Nagoya', 'Batu Aji', 'Sekupang']
                      .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedZone = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                final data = {
                  'email': emailCtrl.text,
                  'name': nameCtrl.text,
                  'phone': phoneCtrl.text,
                  'zone': selectedZone,
                  'role': 'teknisi',
                };
                if (!isEdit && passCtrl.text.isNotEmpty) data['password'] = passCtrl.text;
                if (isEdit) {
                  await FirebaseService.instance.updateTeknisi(teknisi['id'], data);
                } else {
                  await FirebaseService.instance.addTeknisi(data);
                }
                _loadData();
              },
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTeknisi(Map<String, dynamic> teknisi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Teknisi'),
        content: Text('Yakin ingin menghapus ${teknisi['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseService.instance.deleteTeknisi(teknisi['id']);
              _loadData();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
