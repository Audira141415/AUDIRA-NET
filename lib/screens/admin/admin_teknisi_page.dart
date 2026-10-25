import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_provider.dart';

class AdminTeknisiPage extends StatefulWidget {
  const AdminTeknisiPage({super.key});

  @override
  State<AdminTeknisiPage> createState() => _AdminTeknisiPageState();
}

class _AdminTeknisiPageState extends State<AdminTeknisiPage> {
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

      setState(() {
        _teknisiList = teknisi;
        _zones = zonesData.map((z) => z['name'].toString()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  List<Map<String, dynamic>> get _filteredTeknisi {
    if (_filterZone == null) return _teknisiList;
    return _teknisiList.where((t) => t['zone'] == _filterZone).toList();
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
          'Management Teknisi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF080D1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.lightTextPrimary,
        elevation: 0,
        actions: [
          if (_zones.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.filter_list,
                color: isDark ? const Color(0xFF00F0FF) : AppTheme.lightTextPrimary,
              ),
              tooltip: 'Filter Zona',
              onSelected: (zone) {
                setState(() {
                  _filterZone = zone == 'all' ? null : zone;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'all', child: Text('Semua Zona')),
                const PopupMenuDivider(),
                ..._zones.map(
                  (zone) => PopupMenuItem(value: zone, child: Text(zone)),
                ),
              ],
            ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white70 : AppTheme.lightTextPrimary,
            ),
            onPressed: _loadData,
          ),
          const ThemeToggleIconButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
              ),
            )
          : RefreshIndicator(
              color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
              backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
              onRefresh: _loadData,
              child: _filteredTeknisi.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF080D1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF00F0FF).withValues(alpha: 0.2)
                                : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.4)
                                  : Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF00F0FF).withValues(alpha: 0.1)
                                    : Colors.cyan.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.engineering_rounded,
                                size: 48,
                                color: isDark ? const Color(0xFF00F0FF) : AppTheme.primaryCyan,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filterZone == null
                                  ? 'Belum ada teknisi'
                                  : 'Tidak ada teknisi di zona $_filterZone',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Kelola penugasan teknisi lapangan AUDIRA di sini',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTeknisi.length,
                      itemBuilder: (context, index) {
                        final teknisi = _filteredTeknisi[index];
                        return _TeknisiCard(
                          teknisi: teknisi,
                          onEdit: () => _showTeknisiForm(teknisi),
                          onDelete: () => _deleteTeknisi(teknisi),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTeknisiForm(null),
        backgroundColor: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
        foregroundColor: isDark ? const Color(0xFF030712) : Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Teknisi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showTeknisiForm(Map<String, dynamic>? teknisi) {
    final isEdit = teknisi != null;
    final emailCtrl = TextEditingController(text: teknisi?['email']);
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: teknisi?['name']);
    final phoneCtrl = TextEditingController(text: teknisi?['phone']);
    String? selectedZone = teknisi?['zone'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Teknisi' : 'Tambah Teknisi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isEdit,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  decoration: InputDecoration(
                    labelText: isEdit ? 'Password Baru (opsional)' : 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'No. Telepon',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedZone,
                  decoration: const InputDecoration(
                    labelText: 'Zona Penempatan',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                            'Batam Center',
                            'Piayu',
                            'Baloi',
                            'Nagoya',
                            'Batu Aji',
                            'Sekupang',
                          ]
                          .map(
                            (zone) => DropdownMenuItem(
                              value: zone,
                              child: Text(zone),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedZone = value;
                    });
                  },
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
              onPressed: () async {
                if (emailCtrl.text.isEmpty ||
                    nameCtrl.text.isEmpty ||
                    phoneCtrl.text.isEmpty ||
                    selectedZone == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi')),
                  );
                  return;
                }

                if (!isEdit && passwordCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password wajib diisi')),
                  );
                  return;
                }

                try {
                  final data = {
                    'email': emailCtrl.text,
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                    'zone': selectedZone,
                  };

                  if (!isEdit || passwordCtrl.text.isNotEmpty) {
                    data['password'] = passwordCtrl.text;
                  }

                  if (isEdit) {
                    await FirebaseService.instance.updateTeknisi(
                      teknisi['id'],
                      data,
                    );
                  } else {
                    await FirebaseService.instance.addTeknisi(data);
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'Teknisi berhasil diupdate'
                            : 'Teknisi berhasil ditambahkan',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text(isEdit ? 'Update' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTeknisi(Map<String, dynamic> teknisi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Teknisi'),
        content: Text('Yakin ingin menghapus ${teknisi['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await FirebaseService.instance.deleteTeknisi(teknisi['id']);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Teknisi berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _TeknisiCard extends StatelessWidget {
  final Map<String, dynamic> teknisi;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeknisiCard({
    required this.teknisi,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF080D1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                : Colors.cyan.shade50,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? const Color(0xFF00F0FF).withValues(alpha: 0.4)
                  : Colors.cyan.shade200,
            ),
          ),
          child: Center(
            child: Text(
              (teknisi['name'] as String).substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: isDark ? const Color(0xFF00F0FF) : AppTheme.primaryCyan,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          teknisi['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.email,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    teknisi['email'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  teknisi['phone'] ?? '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF00F0FF).withValues(alpha: 0.1)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF00F0FF).withValues(alpha: 0.25)
                      : Colors.blue.shade200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: isDark ? const Color(0xFF00F0FF) : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    teknisi['zone'] ?? 'No Zone',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF00F0FF) : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: isDark ? const Color(0xFF00F0FF) : Colors.blue,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
