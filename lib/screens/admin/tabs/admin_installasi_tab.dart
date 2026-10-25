import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/database_service.dart';
import '../../../widgets/map_picker.dart';

/// Clean Apple/Linear Installation Management Tab for AUDIRA Admin
class AdminInstallasiTab extends StatefulWidget {
  const AdminInstallasiTab({super.key});

  @override
  State<AdminInstallasiTab> createState() => _AdminInstallasiTabState();
}

class _AdminInstallasiTabState extends State<AdminInstallasiTab> {
  List<Map<String, dynamic>> _installations = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadInstallations();
  }

  Future<void> _loadInstallations() async {
    setState(() => _isLoading = true);
    try {
      final installations = await DatabaseService.instance.getAllInstallations();
      if (mounted) {
        setState(() {
          if (_filterStatus == 'all') {
            _installations = installations;
          } else {
            _installations = installations
                .where((i) => i['status'] == _filterStatus)
                .toList();
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddInstallationDialog() {
    final formKey = GlobalKey<FormState>();
    String customerName = '';
    String phone = '';
    String address = '';
    String packageName = 'Basic';
    int speed = 30;
    int price = 250000;
    DateTime scheduledDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay scheduledTime = const TimeOfDay(hour: 9, minute: 0);
    double? selectedLat;
    double? selectedLng;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Jadwalkan Instalasi Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan',
                      prefixIcon: Icon(LucideIcons.user, size: 18),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Nama wajib diisi' : null,
                    onSaved: (v) => customerName = v!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nomor WhatsApp / HP',
                      prefixIcon: Icon(LucideIcons.phone, size: 18),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v?.isEmpty ?? true ? 'Nomor telepon wajib diisi' : null,
                    onSaved: (v) => phone = v!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Alamat Pemasangan',
                      prefixIcon: Icon(LucideIcons.mapPin, size: 18),
                    ),
                    maxLines: 2,
                    validator: (v) => v?.isEmpty ?? true ? 'Alamat wajib diisi' : null,
                    onSaved: (v) => address = v!,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.map, size: 20),
                    title: Text(
                      selectedLat != null && selectedLng != null
                          ? 'Koordinat: ${selectedLat!.toStringAsFixed(4)}, ${selectedLng!.toStringAsFixed(4)}'
                          : 'Tentukan Titik di Peta',
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 16),
                    onTap: () async {
                      final result = await Navigator.push<LatLng>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPicker(
                            initialPosition: selectedLat != null && selectedLng != null
                                ? LatLng(selectedLat!, selectedLng!)
                                : null,
                            onLocationPicked: (location) {
                              setDialogState(() {
                                selectedLat = location.latitude;
                                selectedLng = location.longitude;
                              });
                            },
                          ),
                        ),
                      );
                      if (result != null) {
                        setDialogState(() {
                          selectedLat = result.latitude;
                          selectedLng = result.longitude;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: packageName,
                    decoration: const InputDecoration(
                      labelText: 'Paket Layanan',
                      prefixIcon: Icon(LucideIcons.wifi, size: 18),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Basic', child: Text('Basic - 30 Mbps')),
                      DropdownMenuItem(value: 'Standard', child: Text('Standard - 50 Mbps')),
                      DropdownMenuItem(value: 'Premium', child: Text('Premium - 100 Mbps')),
                    ],
                    onChanged: (value) {
                      packageName = value!;
                      if (value == 'Basic') {
                        speed = 30;
                        price = 250000;
                      } else if (value == 'Standard') {
                        speed = 50;
                        price = 350000;
                      } else {
                        speed = 100;
                        price = 500000;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.calendar, size: 20),
                    title: Text(
                      'Tanggal: ${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: const Icon(LucideIcons.edit2, size: 16),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: scheduledDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null) {
                        setDialogState(() => scheduledDate = date);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  try {
                    await DatabaseService.instance.createInstallation({
                      'customer_name': customerName,
                      'phone': phone,
                      'address': address,
                      'package_name': packageName,
                      'speed': speed,
                      'price': price,
                      'scheduled_date':
                          '${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}',
                      'scheduled_time':
                          '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
                      'notes': '',
                      'latitude': selectedLat,
                      'longitude': selectedLng,
                      'status': 'scheduled',
                    });

                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jadwal instalasi berhasil dibuat')),
                      );
                      _loadInstallations();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                }
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              child: const Text('Simpan Jadwal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteInstallation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Instalasi?'),
        content: const Text('Data jadwal instalasi ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseService.instance.deleteInstallation(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Instalasi berhasil dihapus')),
          );
          _loadInstallations();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelola Instalasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jadwal penarikan kabel & aktivasi modem',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      PopupMenuButton<String>(
                        initialValue: _filterStatus,
                        onSelected: (val) {
                          setState(() => _filterStatus = val);
                          _loadInstallations();
                        },
                        icon: Icon(LucideIcons.filter, size: 18, color: textPrimary),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'all', child: Text('Semua Status')),
                          PopupMenuItem(value: 'scheduled', child: Text('Terjadwal')),
                          PopupMenuItem(value: 'in_progress', child: Text('Sedang Proses')),
                          PopupMenuItem(value: 'completed', child: Text('Selesai')),
                        ],
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.refreshCw, size: 18, color: textPrimary),
                        onPressed: _loadInstallations,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Installation List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : RefreshIndicator(
                      onRefresh: _loadInstallations,
                      color: const Color(0xFF0284C7),
                      child: _installations.isEmpty
                          ? Center(
                              child: Container(
                                margin: const EdgeInsets.all(24),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.wrench, size: 44, color: textSecondary),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Belum Ada Jadwal Instalasi',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Gunakan tombol + di bawah untuk menambah jadwal baru',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12, color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: _installations.length,
                              itemBuilder: (context, index) {
                                final item = _installations[index];
                                final status = item['status'] as String? ?? 'scheduled';
                                final isDone = status == 'completed';
                                final isInProgress = status == 'in_progress';

                                final statusColor = isDone
                                    ? const Color(0xFF10B981)
                                    : isInProgress
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF0284C7);

                                final statusLabel = isDone
                                    ? 'SELESAI'
                                    : isInProgress
                                        ? 'PROSES'
                                        : 'TERJADWAL';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item['customerName'] ?? 'Pelanggan',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${item['packageName'] ?? 'Paket'} • ${item['speed'] ?? 30} Mbps',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Alamat: ${item['address'] ?? '-'}',
                                        style: TextStyle(fontSize: 11, color: textSecondary),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Jadwal: ${item['scheduledDate'] ?? '-'} ${item['scheduledTime'] ?? ''}',
                                        style: TextStyle(fontSize: 11, color: textSecondary),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFFEF4444)),
                                            onPressed: () => _deleteInstallation(item['id'] as int),
                                            tooltip: 'Hapus',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddInstallationDialog,
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Tambah Jadwal', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
