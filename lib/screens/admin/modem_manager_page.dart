import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/genieacs_service.dart';

/// GenieACS/Modem Manager - Device Management via TR-069
/// Manage customer modems/ONTs via GenieACS
class ModemManagerPage extends StatefulWidget {
  const ModemManagerPage({super.key});

  @override
  State<ModemManagerPage> createState() => _ModemManagerPageState();
}

class _ModemManagerPageState extends State<ModemManagerPage> {
  bool _isLoading = false;
  String _filterStatus = 'all';
  final List<Map<String, dynamic>> _devices = [];
  GenieACSService? _genieACSService;
  bool _useMockData = true; // Toggle between mock and real API

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() async {
    setState(() => _isLoading = true);

    if (_useMockData) {
      // Mock data untuk demonstrasi
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _devices.clear();
        _devices.addAll([
          {
            'id': 'DEV-001',
            'serialNumber': 'GPON123456789',
            'model': 'HG8245H5',
            'manufacturer': 'Huawei',
            'customerName': 'John Doe',
            'ipAddress': '192.168.100.10',
            'status': 'online',
            'signalStrength': -15,
            'uptime': '15d 8h',
            'firmware': 'V5R020C00S125',
            'lastSeen': DateTime.now().subtract(const Duration(minutes: 2)),
          },
          {
            'id': 'DEV-002',
            'serialNumber': 'GPON987654321',
            'model': 'HG8245Q2',
            'manufacturer': 'Huawei',
            'customerName': 'Jane Smith',
            'ipAddress': '192.168.100.20',
            'status': 'online',
            'signalStrength': -18,
            'uptime': '8d 4h',
            'firmware': 'V5R020C00S125',
            'lastSeen': DateTime.now().subtract(const Duration(minutes: 5)),
          },
          {
            'id': 'DEV-003',
            'serialNumber': 'GPON456789123',
            'model': 'F670L',
            'manufacturer': 'ZTE',
            'customerName': 'Bob Johnson',
            'ipAddress': '192.168.100.30',
            'status': 'warning',
            'signalStrength': -28,
            'uptime': '3d 12h',
            'firmware': 'V9.0.10P2N2',
            'lastSeen': DateTime.now().subtract(const Duration(hours: 1)),
          },
          {
            'id': 'DEV-004',
            'serialNumber': 'GPON789123456',
            'model': 'Archer VR2800',
            'manufacturer': 'TP-Link',
            'customerName': 'Alice Williams',
            'ipAddress': '192.168.100.40',
            'status': 'offline',
            'signalStrength': 0,
            'uptime': '0h',
            'firmware': '1.0.0 Build 20200629',
            'lastSeen': DateTime.now().subtract(const Duration(days: 2)),
          },
        ]);
        _isLoading = false;
      });
    } else {
      // Load from real GenieACS API
      if (_genieACSService == null) {
        setState(() => _isLoading = false);
        _showError('GenieACS service not configured');
        return;
      }

      final devices = await _genieACSService!.getAllDevices(limit: 100);
      setState(() {
        _devices.clear();
        _devices.addAll(
          devices.map((d) {
            return {
              'id': d['id'],
              'serialNumber': d['serialNumber'],
              'model': d['model'],
              'manufacturer': d['manufacturer'],
              'customerName': 'Customer ${d['serialNumber'].substring(0, 8)}',
              'ipAddress': d['ipAddress'] ?? 'N/A',
              'status': d['online'] ? 'online' : 'offline',
              'signalStrength': -20,
              'uptime': d['uptime'] ?? '0h',
              'firmware': d['firmwareVersion'],
              'lastSeen': d['lastInform'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(d['lastInform'])
                  : DateTime.now(),
            };
          }),
        );
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDevices {
    if (_filterStatus == 'all') return _devices;
    return _devices.where((d) => d['status'] == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modem Manager (GenieACS)'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            initialValue: _filterStatus,
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('All Devices')),
              PopupMenuItem(value: 'online', child: Text('Online')),
              PopupMenuItem(value: 'warning', child: Text('Warning')),
              PopupMenuItem(value: 'offline', child: Text('Offline')),
            ],
          ),
          // Toggle Mock/Real API
          IconButton(
            icon: Icon(_useMockData ? Icons.cloud_off : Icons.cloud_queue),
            tooltip: _useMockData ? 'Using Mock Data' : 'Using GenieACS API',
            onPressed: () {
              setState(() {
                _useMockData = !_useMockData;
              });
              _loadDevices();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDevices),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showGenieACSSettings,
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
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.devices, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CPE Device Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_devices.where((d) => d['status'] == 'online').length} online • ${_devices.where((d) => d['status'] == 'warning').length} warning • ${_devices.where((d) => d['status'] == 'offline').length} offline',
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
                Expanded(
                  child: Text(
                    _useMockData
                        ? 'Mock data displayed. Configure GenieACS connection in settings.'
                        : 'Connected to GenieACS server',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Device List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDevices.isEmpty
                ? const Center(child: Text('No devices found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = _filteredDevices[index];
                      return _buildDeviceCard(device);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final status = device['status'] as String;
    final signalStrength = device['signalStrength'] as int;

    Color statusColor;
    Color signalColor;
    String signalQuality;

    switch (status) {
      case 'online':
        statusColor = Colors.green;
        break;
      case 'warning':
        statusColor = Colors.orange;
        break;
      case 'offline':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    if (signalStrength >= -20) {
      signalColor = Colors.green;
      signalQuality = 'Excellent';
    } else if (signalStrength >= -25) {
      signalColor = Colors.blue;
      signalQuality = 'Good';
    } else if (signalStrength >= -30) {
      signalColor = Colors.orange;
      signalQuality = 'Fair';
    } else {
      signalColor = Colors.red;
      signalQuality = 'Poor';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(Icons.router, color: statusColor),
        ),
        title: Text(
          device['customerName'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${device['manufacturer']} ${device['model']}'),
            Text(
              'SN: ${device['serialNumber']} • IP: ${device['ipAddress']}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                status.toUpperCase(),
                style: TextStyle(fontSize: 9, color: statusColor),
              ),
              backgroundColor: statusColor.withValues(alpha: 0.1),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            if (status != 'offline')
              Text(
                signalQuality,
                style: TextStyle(fontSize: 9, color: signalColor),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Info
                const Text(
                  'Device Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Firmware', device['firmware']),
                _buildInfoRow('Uptime', device['uptime']),
                if (status != 'offline')
                  _buildInfoRow(
                    'Signal Strength',
                    '$signalStrength dBm ($signalQuality)',
                  ),
                _buildInfoRow(
                  'Last Seen',
                  DateFormat(
                    'dd MMM yyyy, HH:mm',
                  ).format(device['lastSeen'] as DateTime),
                ),
                const Divider(height: 24),

                // Actions
                const Text(
                  'Device Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.settings, size: 18),
                      label: const Text('Configure'),
                      onPressed: () => _configureDevice(device),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.system_update, size: 18),
                      label: const Text('Update FW'),
                      onPressed: () => _updateFirmware(device),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.bug_report, size: 18),
                      label: const Text('Diagnostics'),
                      onPressed: () => _runDiagnostics(device),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reboot'),
                      onPressed: () => _rebootDevice(device),
                      backgroundColor: Colors.orange.shade100,
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.restore, size: 18),
                      label: const Text('Factory Reset'),
                      onPressed: () => _factoryReset(device),
                      backgroundColor: Colors.red.shade100,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _configureDevice(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure Device'),
        content: const Text(
          'Device configuration via GenieACS:\n\n'
          '• Wi-Fi settings\n'
          '• Port forwarding\n'
          '• QoS settings\n'
          '• VLANs\n'
          '• VPN\n\n'
          'Requires GenieACS API integration.',
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

  void _updateFirmware(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Firmware'),
        content: Text(
          'Update firmware for ${device['serialNumber']}?\n\n'
          'Current: ${device['firmware']}\n'
          'Available: Check GenieACS\n\n'
          'Note: Requires GenieACS API integration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Firmware update initiated for ${device['serialNumber']}',
                  ),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _runDiagnostics(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Diagnostics'),
        content: const Text(
          'Run diagnostics via GenieACS:\n\n'
          '• Ping test\n'
          '• Traceroute\n'
          '• Speed test\n'
          '• Connection quality\n'
          '• Port status\n\n'
          'Requires GenieACS API integration.',
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

  void _rebootDevice(Map<String, dynamic> device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reboot Device'),
        content: Text(
          'Reboot ${device['customerName']}\'s modem?\n\n'
          'The device will be offline for approximately 2-3 minutes.\n\n'
          '${_useMockData ? 'Note: Mock action. Real reboot requires GenieACS API.' : 'Are you sure you want to proceed?'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
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
            content: Text(
              'Mock: Reboot command sent to ${device['serialNumber']}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Real API call
      if (_genieACSService != null) {
        final success = await _genieACSService!.rebootDevice(device['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Reboot command sent to ${device['serialNumber']}'
                    : 'Failed to reboot ${device['serialNumber']}',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    }
  }

  void _factoryReset(Map<String, dynamic> device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Factory Reset'),
        content: Text(
          'Factory reset ${device['customerName']}\'s modem?\n\n'
          '⚠️ WARNING: This will erase all configurations!\n'
          'The device will need to be reconfigured.\n\n'
          '${_useMockData ? 'Note: Mock action. Real factory reset requires GenieACS API.' : 'Are you absolutely sure you want to proceed?'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Factory Reset'),
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
            content: Text(
              'Mock: Factory reset command sent to ${device['serialNumber']}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Real API call
      if (_genieACSService != null) {
        final success = await _genieACSService!.factoryResetDevice(
          device['id'],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Factory reset command sent to ${device['serialNumber']}'
                    : 'Failed to factory reset ${device['serialNumber']}',
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

  void _showGenieACSSettings() {
    final TextEditingController urlController = TextEditingController(
      text: _genieACSService?.baseUrl ?? 'http://localhost:7557',
    );
    final TextEditingController usernameController = TextEditingController(
      text: _genieACSService?.username ?? 'admin',
    );
    final TextEditingController passwordController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GenieACS Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configure GenieACS Server',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'GenieACS URL',
                  border: OutlineInputBorder(),
                  hintText: 'http://genieacs-server:7557',
                ),
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
              const SizedBox(height: 16),
              const Text(
                'Documentation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('genieacs.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final url = urlController.text.trim();
              final username = usernameController.text.trim();
              final password = passwordController.text.trim();

              if (url.isEmpty || username.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              _connectToGenieACS(url, username, password);
            },
            child: const Text('Test & Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToGenieACS(
    String url,
    String username,
    String password,
  ) async {
    // Create GenieACS service
    _genieACSService = GenieACSService(
      baseUrl: url,
      username: username,
      password: password,
    );

    // Test connection
    setState(() => _isLoading = true);
    final connected = await _genieACSService!.testConnection();

    if (connected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected to GenieACS successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _useMockData = false;
        _loadDevices();
      }
    } else {
      _genieACSService = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect to GenieACS server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }
}
