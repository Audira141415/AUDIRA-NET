import 'package:flutter/material.dart';
import '../../services/broadcast_service.dart';
import '../../services/auth_service.dart';
import '../../models/broadcast_notification.dart';
import 'package:intl/intl.dart';
import 'widgets/odp_incident_broadcast_sheet.dart';

class AdminBroadcastPage extends StatefulWidget {
  const AdminBroadcastPage({super.key});

  @override
  State<AdminBroadcastPage> createState() => _AdminBroadcastPageState();
}

class _AdminBroadcastPageState extends State<AdminBroadcastPage>
    with SingleTickerProviderStateMixin {
  final BroadcastService _broadcastService = BroadcastService.instance;
  late TabController _tabController;

  List<BroadcastNotification> _scheduledBroadcasts = [];
  List<BroadcastNotification> _sentBroadcasts = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

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
      final stats = await _broadcastService.getBroadcastStats();
      final scheduled = await _broadcastService.getBroadcastsByStatus(
        'scheduled',
      );
      final sent = await _broadcastService.getBroadcastsByStatus('sent');

      setState(() {
        _stats = stats;
        _scheduledBroadcasts = scheduled;
        _sentBroadcasts = sent;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _createNewBroadcast() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateBroadcastPage()),
    ).then((_) => _loadData());
  }

  Future<void> _cancelBroadcast(BroadcastNotification broadcast) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Broadcast?'),
        content: Text(
          'Yakin ingin membatalkan broadcast "${broadcast.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _broadcastService.cancelBroadcast(broadcast.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Broadcast dibatalkan'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Notifikasi'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cell_tower),
            tooltip: 'WhatsApp Blast Insiden ODP',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const OdpIncidentBroadcastSheet(),
              ).then((_) => _loadData());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Terjadwal (${_stats['scheduled'] ?? 0})'),
            Tab(text: 'Terkirim (${_stats['sent'] ?? 0})'),
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
                          icon: Icons.campaign,
                          label: 'Total Broadcast',
                          value: _stats['total']?.toString() ?? '0',
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people,
                          label: 'Total Penerima',
                          value: _stats['totalRecipients']?.toString() ?? '0',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.trending_up,
                          label: 'Rata-rata',
                          value: _stats['avgRecipients']?.toString() ?? '0',
                          color: Colors.green,
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
                      _buildBroadcastList(
                        _scheduledBroadcasts,
                        isScheduled: true,
                      ),
                      _buildBroadcastList(_sentBroadcasts),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewBroadcast,
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add),
        label: const Text('Buat Broadcast'),
      ),
    );
  }

  Widget _buildBroadcastList(
    List<BroadcastNotification> broadcasts, {
    bool isScheduled = false,
  }) {
    if (broadcasts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada broadcast',
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
        itemCount: broadcasts.length,
        itemBuilder: (context, index) {
          final broadcast = broadcasts[index];
          return _BroadcastCard(
            broadcast: broadcast,
            isScheduled: isScheduled,
            onCancel: () => _cancelBroadcast(broadcast),
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
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BroadcastCard extends StatelessWidget {
  final BroadcastNotification broadcast;
  final bool isScheduled;
  final VoidCallback? onCancel;

  const _BroadcastCard({
    required this.broadcast,
    this.isScheduled = false,
    this.onCancel,
  });

  Color _getCategoryColor() {
    switch (broadcast.category) {
      case 'maintenance':
        return Colors.orange;
      case 'promo':
        return Colors.green;
      case 'emergency':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _getPriorityColor() {
    switch (broadcast.priority) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

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
              children: [
                Text(
                  broadcast.categoryIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        broadcast.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        broadcast.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getCategoryColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    broadcast.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              broadcast.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),

            const Divider(height: 24),

            // Target Info
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Target: ${broadcast.targetRole}${broadcast.targetZone != null ? ' (${broadcast.targetZone})' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Schedule/Sent Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      isScheduled
                          ? 'Terjadwal: ${DateFormat('dd MMM HH:mm').format(broadcast.scheduledAt)}'
                          : 'Terkirim: ${broadcast.sentAt != null ? DateFormat('dd MMM HH:mm').format(broadcast.sentAt!) : '-'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (broadcast.recipientCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${broadcast.recipientCount} penerima',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            ),

            // Cancel Button (only for scheduled)
            if (isScheduled) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Batalkan'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Create Broadcast Page
class CreateBroadcastPage extends StatefulWidget {
  const CreateBroadcastPage({super.key});

  @override
  State<CreateBroadcastPage> createState() => _CreateBroadcastPageState();
}

class _CreateBroadcastPageState extends State<CreateBroadcastPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _category = 'announcement';
  String _priority = 'medium';
  String _targetRole = 'all';
  String? _targetZone;
  DateTime _scheduledAt = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _zones = [
    'Jakarta Pusat',
    'Jakarta Selatan',
    'Jakarta Utara',
    'Jakarta Barat',
    'Tangerang',
    'Bekasi',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _useTemplate(String templateKey) {
    final template = BroadcastService.instance.messageTemplates[templateKey];
    if (template != null) {
      setState(() {
        _titleController.text = template['title'] ?? '';
        _messageController.text = template['message'] ?? '';
        _category = templateKey;
      });
    }
  }

  Future<void> _selectScheduleTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledAt),
      );

      if (time != null && mounted) {
        setState(() {
          _scheduledAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final adminUserId = AuthService.instance.currentUser?.id ?? '';

      await BroadcastService.instance.createBroadcast(
        title: _titleController.text,
        message: _messageController.text,
        targetRole: _targetRole,
        targetZone: _targetZone,
        category: _category,
        priority: _priority,
        scheduledAt: _scheduledAt,
        createdBy: adminUserId,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Broadcast berhasil dijadwalkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Broadcast'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Templates
            const Text(
              'Template Pesan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TemplateChip(
                  label: '🔧 Maintenance',
                  onTap: () => _useTemplate('maintenance'),
                ),
                _TemplateChip(
                  label: '🎉 Promo',
                  onTap: () => _useTemplate('promo'),
                ),
                _TemplateChip(
                  label: '💰 Reminder',
                  onTap: () => _useTemplate('payment_reminder'),
                ),
                _TemplateChip(
                  label: '🚨 Gangguan',
                  onTap: () => _useTemplate('outage'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Judul harus diisi' : null,
            ),

            const SizedBox(height: 16),

            // Message
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Pesan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 5,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Pesan harus diisi' : null,
            ),

            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'announcement',
                  child: Text('📢 Pengumuman'),
                ),
                DropdownMenuItem(
                  value: 'maintenance',
                  child: Text('🔧 Maintenance'),
                ),
                DropdownMenuItem(value: 'promo', child: Text('🎉 Promo')),
                DropdownMenuItem(
                  value: 'emergency',
                  child: Text('🚨 Emergency'),
                ),
              ],
              onChanged: (value) => setState(() => _category = value!),
            ),

            const SizedBox(height: 16),

            // Priority
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Prioritas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Rendah')),
                DropdownMenuItem(value: 'medium', child: Text('Sedang')),
                DropdownMenuItem(value: 'high', child: Text('Tinggi')),
                DropdownMenuItem(value: 'critical', child: Text('Kritis')),
              ],
              onChanged: (value) => setState(() => _priority = value!),
            ),

            const SizedBox(height: 16),

            // Target Role
            DropdownButtonFormField<String>(
              initialValue: _targetRole,
              decoration: const InputDecoration(
                labelText: 'Target Penerima',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua')),
                DropdownMenuItem(value: 'customer', child: Text('Customer')),
                DropdownMenuItem(value: 'teknisi', child: Text('Teknisi')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) => setState(() => _targetRole = value!),
            ),

            const SizedBox(height: 16),

            // Target Zone
            DropdownButtonFormField<String?>(
              initialValue: _targetZone,
              decoration: const InputDecoration(
                labelText: 'Filter Zona (opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Zona')),
                ..._zones.map(
                  (zone) => DropdownMenuItem(value: zone, child: Text(zone)),
                ),
              ],
              onChanged: (value) => setState(() => _targetZone = value),
            ),

            const SizedBox(height: 16),

            // Schedule Time
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Jadwal Kirim'),
              subtitle: Text(
                DateFormat('EEEE, dd MMMM yyyy HH:mm').format(_scheduledAt),
              ),
              trailing: const Icon(Icons.edit),
              onTap: _selectScheduleTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitBroadcast,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Mengirim...' : 'Jadwalkan Broadcast',
                ),
                style: FilledButton.styleFrom(backgroundColor: Colors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TemplateChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.purple.shade50,
      labelStyle: const TextStyle(fontSize: 12),
    );
  }
}
