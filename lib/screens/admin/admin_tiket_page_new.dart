import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../utils/excel_exporter.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_provider.dart';
import '../teknisi/teknisi_home.dart'; // Import untuk TicketDetailPage

class AdminTiketPageNew extends StatefulWidget {
  const AdminTiketPageNew({super.key});

  @override
  State<AdminTiketPageNew> createState() => _AdminTiketPageNewState();
}

class _AdminTiketPageNewState extends State<AdminTiketPageNew>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadTickets();
      }
    });
    _loadTickets();
    _loadCustomers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final allTickets = await FirebaseService.instance.getAllTickets();
      setState(() {
        _tickets = allTickets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat tiket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await FirebaseService.instance.getAllCustomers();
      setState(() {
        _customers = customers;
      });
    } catch (e) {
      // Error loading customers
    }
  }

  List<Map<String, dynamic>> get _filteredTickets {
    final status = ['open', 'in_progress', 'resolved'][_tabController.index];
    return _tickets.where((t) => t['status'] == status).toList();
  }

  void _showCreateTicketDialog() {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'medium';
    String selectedCategory = 'teknis';
    String selectedZone = 'Batam Center';
    int? selectedCustomerId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Tiket Baru',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tiket atas nama pelanggan',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pilih Pelanggan
                        const Row(
                          children: [
                            Icon(Icons.person, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Pilih Pelanggan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedCustomerId,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.blue,
                              ),
                              hintText: 'Pilih pelanggan...',
                            ),
                            items: _customers.map((customer) {
                              return DropdownMenuItem<int>(
                                value: customer['id'],
                                child: Text(customer['name'] ?? 'Unknown'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedCustomerId = value);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Kategori
                        const Row(
                          children: [
                            Icon(Icons.category, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Kategori Masalah',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCategory,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.label_outline,
                                color: Colors.blue,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'teknis',
                                child: Text('Masalah Teknis'),
                              ),
                              DropdownMenuItem(
                                value: 'billing',
                                child: Text('Tagihan & Pembayaran'),
                              ),
                              DropdownMenuItem(
                                value: 'upgrade',
                                child: Text('Upgrade Paket'),
                              ),
                              DropdownMenuItem(
                                value: 'lainnya',
                                child: Text('Lainnya'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => selectedCategory = value!);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Judul
                        const Row(
                          children: [
                            Icon(Icons.title, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Judul Masalah',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: subjectController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: Internet lambat di area Piayu',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Deskripsi
                        const Row(
                          children: [
                            Icon(
                              Icons.description,
                              size: 20,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Deskripsi Detail',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Jelaskan masalah secara detail...',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Zona
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Zona Lokasi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedZone,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.location_city,
                                color: Colors.blue,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Batam Center',
                                child: Text('Batam Center'),
                              ),
                              DropdownMenuItem(
                                value: 'Piayu',
                                child: Text('Piayu'),
                              ),
                              DropdownMenuItem(
                                value: 'Baloi',
                                child: Text('Baloi'),
                              ),
                              DropdownMenuItem(
                                value: 'Nagoya',
                                child: Text('Nagoya'),
                              ),
                              DropdownMenuItem(
                                value: 'Batu Aji',
                                child: Text('Batu Aji'),
                              ),
                              DropdownMenuItem(
                                value: 'Sekupang',
                                child: Text('Sekupang'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => selectedZone = value!);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Prioritas
                        const Row(
                          children: [
                            Icon(
                              Icons.priority_high,
                              size: 20,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tingkat Prioritas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedPriority,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(Icons.flag, color: Colors.blue),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'low',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Rendah'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'medium',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.remove,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Sedang'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'high',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Tinggi'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => selectedPriority = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () async {
                            if (selectedCustomerId == null ||
                                subjectController.text.isEmpty ||
                                descriptionController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Mohon lengkapi semua field',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              final categoryPrefix = {
                                'teknis': '[TEKNIS]',
                                'billing': '[BILLING]',
                                'upgrade': '[UPGRADE]',
                                'lainnya': '[UMUM]',
                              }[selectedCategory];

                              await FirebaseService.instance.createTicket({
                                'customerId': selectedCustomerId!,
                                'subject':
                                    '$categoryPrefix ${subjectController.text}',
                                'description': descriptionController.text,
                                'priority': selectedPriority,
                                'zone': selectedZone,
                                'status': 'open',
                                'category': selectedCategory,
                              });

                              if (!context.mounted) return;
                              Navigator.pop(context);
                              _loadTickets();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Tiket berhasil dibuat untuk pelanggan!',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Buat Tiket',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : AppTheme.lightScaffoldBg,
      appBar: AppBar(
        title: Text(
          'Manajemen Tiket',
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
          IconButton(
            icon: Icon(
              Icons.download,
              color: isDark ? const Color(0xFF00F0FF) : AppTheme.lightTextPrimary,
            ),
            tooltip: 'Export ke Excel',
            onPressed: () async {
              try {
                final currentTab = _tabController.index;
                final status = currentTab == 0
                    ? 'open'
                    : currentTab == 1
                    ? 'in_progress'
                    : 'resolved';

                final ticketsToExport = _tickets
                    .where((t) => t['status']?.toLowerCase() == status)
                    .toList();

                if (ticketsToExport.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tidak ada tiket untuk diexport'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

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
                        Text('Mengexport tiket...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );

                final filePath = await ExcelExporter.exportTickets(
                  ticketsToExport,
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
                                'Export berhasil! ${ticketsToExport.length} tiket',
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
                        content: Text('Gagal export tiket'),
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
          const ThemeToggleIconButton(),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
          indicatorWeight: 3,
          labelColor: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.grey.shade600,
          tabs: const [
            Tab(icon: Icon(Icons.inbox), text: 'Terbuka'),
            Tab(icon: Icon(Icons.hourglass_empty), text: 'Proses'),
            Tab(icon: Icon(Icons.check_circle), text: 'Selesai'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTicketList('open'),
                _buildTicketList('in_progress'),
                _buildTicketList('resolved'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTicketDialog,
        icon: const Icon(Icons.add),
        label: const Text('Buat Tiket', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
        foregroundColor: isDark ? const Color(0xFF030712) : Colors.white,
      ),
    );
  }

  Widget _buildTicketList(String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets = _filteredTickets;

    if (tickets.isEmpty) {
      return Center(
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
                      : Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == 'open'
                      ? Icons.inbox_outlined
                      : status == 'in_progress'
                      ? Icons.hourglass_empty_outlined
                      : Icons.check_circle_outline,
                  size: 48,
                  color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                status == 'open'
                    ? 'Tidak ada tiket terbuka'
                    : status == 'in_progress'
                    ? 'Tidak ada tiket dalam proses'
                    : 'Tidak ada tiket selesai',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tiket keluhan dan laporan gangguan jaringan akan tampil di sini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: isDark ? const Color(0xFF00F0FF) : AppTheme.signalBlue,
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return _TicketCard(ticket: ticket, onRefresh: _loadTickets);
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onRefresh;

  const _TicketCard({required this.ticket, required this.onRefresh});

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
        return 'Rendah';
      default:
        return priority;
    }
  }

  Future<void> _showAssignTeknisiDialog(BuildContext context) async {
    final zone = ticket['zone'] as String?;
    if (zone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiket tidak memiliki zona'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Load teknisi by zone
    final teknisiList = await FirebaseService.instance.getTeknisiByZone(zone);

    if (teknisiList.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak ada teknisi di zona $zone'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.engineering, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Assign Teknisi', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih teknisi untuk zona: $zone',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: teknisiList.map((teknisi) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            teknisi['name']?.toString()[0] ?? 'T',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          teknisi['name'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(teknisi['email'] ?? ''),
                            if (teknisi['phone'] != null)
                              Text(
                                teknisi['phone'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.blue.shade700,
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          try {
                            await FirebaseService.instance
                                .assignTicketToTeknisi(
                                  ticket['id'],
                                  teknisi['id'],
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Tiket berhasil di-assign ke ${teknisi['name']}',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              onRefresh();
                            }
                          } catch (e) {
                            if (context.mounted) {
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
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Show loading
                if (context.mounted) {
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
                          Text('Mencari teknisi terbaik...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                final assignedTeknisiId = await FirebaseService.instance
                    .autoAssignTicket(ticket['id'], zone);

                if (context.mounted) {
                  if (assignedTeknisiId != null) {
                    // Get teknisi name
                    final teknisi = teknisiList.firstWhere(
                      (t) => t['id'] == assignedTeknisiId,
                      orElse: () => {'name': 'Unknown'},
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Auto-assigned ke ${teknisi['name']} (teknisi paling tersedia)',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    onRefresh();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal auto-assign tiket'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Auto-Assign'),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zone = ticket['zone'] as String?;
    final teknisiId = ticket['teknisiId'] as int?;

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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TicketDetailPage(ticket: ticket, onTicketResolved: onRefresh),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID + Priority
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF00F0FF).withValues(alpha: 0.12)
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF00F0FF).withValues(alpha: 0.3)
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Text(
                      ticket['ticketId'] ?? '',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF00F0FF) : Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                        ticket['priority'] ?? '',
                      ).withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getPriorityColor(ticket['priority'] ?? ''),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 14,
                          color: _getPriorityColor(ticket['priority'] ?? ''),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPriorityLabel(ticket['priority'] ?? ''),
                          style: TextStyle(
                            color: _getPriorityColor(ticket['priority'] ?? ''),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (zone != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.purple.shade900.withValues(alpha: 0.3)
                            : Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.purple.shade400.withValues(alpha: 0.4)
                              : Colors.purple.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: isDark ? Colors.purple.shade200 : Colors.purple.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            zone,
                            style: TextStyle(
                              color: isDark ? Colors.purple.shade200 : Colors.purple.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Subject
              Text(
                ticket['subject'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                ticket['description'] ?? '',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer: Customer + Assigned Teknisi
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket['customerName'] ?? 'Unknown',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (teknisiId == null)
                    FilledButton.icon(
                      onPressed: () => _showAssignTeknisiDialog(context),
                      icon: const Icon(Icons.engineering, size: 16),
                      label: const Text(
                        'Assign',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF00F0FF) : Colors.blue,
                        foregroundColor: isDark ? const Color(0xFF030712) : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF00FF9D).withValues(alpha: 0.15)
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF00FF9D).withValues(alpha: 0.3)
                              : Colors.green.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.engineering,
                            size: 12,
                            color: isDark ? const Color(0xFF00FF9D) : Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Assigned',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF00FF9D) : Colors.green.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Auto-assign button for unassigned tickets
                  if (teknisiId == null && zone != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        try {
                          // Show loading
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
                                  Text('Auto-assigning...'),
                                ],
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          final assignedTeknisiId = await FirebaseService
                              .instance
                              .autoAssignTicket(ticket['id'], zone);

                          if (context.mounted) {
                            if (assignedTeknisiId != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Tiket berhasil di-assign otomatis!',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              onRefresh();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tidak ada teknisi tersedia di zona ini',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.auto_awesome, size: 20),
                      tooltip: 'Auto-Assign ke teknisi paling tersedia',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.all(8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
