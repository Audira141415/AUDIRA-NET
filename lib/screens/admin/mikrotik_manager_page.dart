import 'package:flutter/material.dart';
import '../../services/mikrotik_service.dart';

/// MikroTik Manager - Network Management
/// Manage MikroTik routers via RouterOS API
class MikroTikManagerPage extends StatefulWidget {
  const MikroTikManagerPage({super.key});

  @override
  State<MikroTikManagerPage> createState() => _MikroTikManagerPageState();
}

class _MikroTikManagerPageState extends State<MikroTikManagerPage> {
  bool _isLoading = false;
  final MikroTikServiceManager _serviceManager = MikroTikServiceManager();
  final List<Map<String, dynamic>> _routers = [];
  bool _useMockData = true; // Toggle between mock and real API

  @override
  void initState() {
    super.initState();
    _loadRouters();
  }

  void _loadRouters() async {
    setState(() => _isLoading = true);

    if (_useMockData) {
      // Mock data untuk demonstrasi
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _routers.clear();
        _routers.addAll([
          {
            'id': 'MT-001',
            'name': 'Core Router 1',
            'ipAddress': '192.168.1.1',
            'status': 'online',
            'model': 'RB4011iGS+',
            'uptime': '45d 12h 30m',
            'cpuLoad': 15,
            'memoryUsage': 42,
            'interfaces': 10,
            'activeConnections': 245,
          },
          {
            'id': 'MT-002',
            'name': 'Distribution Router A',
            'ipAddress': '192.168.2.1',
            'status': 'online',
            'model': 'CCR1009-7G-1C-1S+',
            'uptime': '30d 8h 15m',
            'cpuLoad': 28,
            'memoryUsage': 55,
            'interfaces': 8,
            'activeConnections': 182,
          },
          {
            'id': 'MT-003',
            'name': 'Access Point Controller',
            'ipAddress': '192.168.3.1',
            'status': 'warning',
            'model': 'RB2011UiAS-2HnD-IN',
            'uptime': '15d 4h 45m',
            'cpuLoad': 65,
            'memoryUsage': 78,
            'interfaces': 11,
            'activeConnections': 98,
          },
        ]);
        _isLoading = false;
      });
    } else {
      // Load from real API
      for (var routerId in _serviceManager.getAllRouterIds()) {
        await _loadRouterData(routerId);
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRouterData(String routerId) async {
    final service = _serviceManager.getService(routerId);
    if (service == null) return;

    if (!service.isConnected) {
      final connected = await service.connect();
      if (!connected) {
        _showError('Failed to connect to router $routerId');
        return;
      }
    }

    final resources = await service.getSystemResources();
    final interfaces = await service.getInterfaces();
    final connections = await service.getActiveConnections();
    final identity = await service.getRouterIdentity();

    if (resources != null) {
      final memUsage = resources['totalMemory'] > 0
          ? ((resources['totalMemory'] - resources['freeMemory']) /
                    resources['totalMemory'] *
                    100)
                .round()
          : 0;

      setState(() {
        final index = _routers.indexWhere((r) => r['id'] == routerId);
        final routerData = {
          'id': routerId,
          'name': identity ?? routerId,
          'ipAddress': service.host,
          'status': 'online',
          'model': resources['boardName'] ?? 'Unknown',
          'uptime': resources['uptime'] ?? '0',
          'cpuLoad': resources['cpuLoad'] ?? 0,
          'memoryUsage': memUsage,
          'interfaces': interfaces.length,
          'activeConnections': connections,
        };

        if (index >= 0) {
          _routers[index] = routerData;
        } else {
          _routers.add(routerData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MikroTik Manager'),
        actions: [
          // Toggle Mock/Real API
          IconButton(
            icon: Icon(_useMockData ? Icons.cloud_off : Icons.cloud_queue),
            tooltip: _useMockData ? 'Using Mock Data' : 'Using Real API',
            onPressed: () {
              setState(() {
                _useMockData = !_useMockData;
              });
              _loadRouters();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRouters),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add_circle),
                    SizedBox(width: 8),
                    Text('Add Router'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('API Settings'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'add') {
                _showAddRouterDialog();
              } else if (value == 'settings') {
                _showAPISettingsDialog();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade400, Colors.teal.shade600],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.router, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Network Infrastructure',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_routers.where((r) => r['status'] == 'online').length}/${_routers.length} routers online',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // API Status Notice
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Mock data displayed. Configure RouterOS API credentials to connect to real routers.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Router List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _routers.length,
                    itemBuilder: (context, index) {
                      final router = _routers[index];
                      return _buildRouterCard(router);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouterCard(Map<String, dynamic> router) {
    final status = router['status'] as String;
    final cpuLoad = router['cpuLoad'] as int;
    final memoryUsage = router['memoryUsage'] as int;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'online':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'offline':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(Icons.router, color: statusColor),
        ),
        title: Text(
          router['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${router['model']} • ${router['ipAddress']}'),
            Text(
              'Uptime: ${router['uptime']}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            status.toUpperCase(),
            style: TextStyle(fontSize: 10, color: statusColor),
          ),
          backgroundColor: statusColor.withOpacity(0.1),
          avatar: Icon(statusIcon, size: 16, color: statusColor),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Performance Metrics
                const Text(
                  'Performance Metrics',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildMetricBar('CPU Load', cpuLoad, Colors.blue),
                const SizedBox(height: 8),
                _buildMetricBar('Memory Usage', memoryUsage, Colors.purple),
                const SizedBox(height: 16),

                // Statistics
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Interfaces',
                        '${router['interfaces']}',
                        Icons.settings_ethernet,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Connections',
                        '${router['activeConnections']}',
                        Icons.people,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showRouterDetails(router),
                      icon: const Icon(Icons.info, size: 18),
                      label: const Text('Details'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showBandwidthMonitor(router),
                      icon: const Icon(Icons.speed, size: 18),
                      label: const Text('Bandwidth'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showFirewallRules(router),
                      icon: const Icon(Icons.security, size: 18),
                      label: const Text('Firewall'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _rebootRouter(router),
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Reboot'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text(
              '$value%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: value > 70 ? Colors.red : color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(value > 70 ? Colors.red : color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouterDetails(Map<String, dynamic> router) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                router['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mock RouterOS API Integration',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'This is a placeholder. In production, this would show:\n'
                '• Interface statistics\n'
                '• DHCP leases\n'
                '• ARP table\n'
                '• Routing table\n'
                '• Wireless clients\n'
                '• Queue statistics',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBandwidthMonitor(Map<String, dynamic> router) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bandwidth Monitor'),
        content: const Text(
          'Real-time bandwidth monitoring will be available after RouterOS API integration.\n\n'
          'Features:\n'
          '• Live traffic graphs\n'
          '• Per-interface statistics\n'
          '• Top talkers\n'
          '• Traffic shaping rules',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFirewallRules(Map<String, dynamic> router) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firewall Rules'),
        content: const Text(
          'Firewall management will be available after RouterOS API integration.\n\n'
          'Features:\n'
          '• View/Edit firewall rules\n'
          '• NAT configuration\n'
          '• Mangle rules\n'
          '• Address lists',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _rebootRouter(Map<String, dynamic> router) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reboot Router'),
        content: Text(
          'This action will reboot ${router['name']}.\n\n'
          'The router will be offline for approximately 2-3 minutes.\n\n'
          '${_useMockData ? 'Note: This is a mock action. Actual reboot requires real API connection.' : 'Are you sure you want to proceed?'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reboot'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (_useMockData) {
      // Mock action
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mock: Reboot command sent to ${router['name']}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Real API call
      final service = _serviceManager.getService(router['id']);
      if (service != null) {
        final success = await service.rebootRouter();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Reboot command sent to ${router['name']}'
                    : 'Failed to reboot ${router['name']}',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddRouterDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ipController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController portController = TextEditingController(
      text: '8728',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add MikroTik Router'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Router Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portController,
                decoration: const InputDecoration(
                  labelText: 'API Port (default: 8728)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final ip = ipController.text.trim();
              final port = int.tryParse(portController.text) ?? 8728;
              final username = usernameController.text.trim();
              final password = passwordController.text.trim();

              if (name.isEmpty ||
                  ip.isEmpty ||
                  username.isEmpty ||
                  password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Add router to manager
              final routerId = 'MT-${DateTime.now().millisecondsSinceEpoch}';
              _serviceManager.addRouter(
                routerId,
                host: ip,
                port: port,
                username: username,
                password: password,
              );

              // Try to connect
              setState(() => _isLoading = true);
              final connected = await _serviceManager.connectRouter(routerId);

              if (connected) {
                await _loadRouterData(routerId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Router $name connected successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                _serviceManager.removeRouter(routerId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to connect to router $name at $ip'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }

              setState(() => _isLoading = false);
            },
            child: const Text('Add & Connect'),
          ),
        ],
      ),
    );
  }

  void _showAPISettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('RouterOS API Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure RouterOS API connection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Required packages:'),
            Text('• routeros_api (Dart package)'),
            Text('• Enable API service on MikroTik routers'),
            SizedBox(height: 16),
            Text('Documentation:'),
            Text('wiki.mikrotik.com/wiki/Manual:API'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
