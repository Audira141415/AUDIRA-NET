import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/wifi_model.dart';
import '../../services/wifi_service.dart';
import '../../services/auth_service.dart';

class WiFiManagementPage extends StatefulWidget {
  const WiFiManagementPage({super.key});

  @override
  State<WiFiManagementPage> createState() => _WiFiManagementPageState();
}

class _WiFiManagementPageState extends State<WiFiManagementPage>
    with SingleTickerProviderStateMixin {
  final WiFiService _wifiService = WiFiService();
  final AuthService _authService = AuthService.instance;
  late TabController _tabController;

  WiFiConfiguration? _wifiConfig;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWiFiConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWiFiConfig() async {
    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    if (user != null) {
      final config = await _wifiService.getWiFiConfig(user.id);
      setState(() {
        _wifiConfig = config;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.wifi), text: 'Overview'),
            Tab(icon: Icon(Icons.devices), text: 'Devices'),
            Tab(icon: Icon(Icons.people), text: 'Guest'),
            Tab(icon: Icon(Icons.child_care), text: 'Parental'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wifiConfig == null
          ? const Center(child: Text('Failed to load WiFi configuration'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDevicesTab(),
                _buildGuestNetworkTab(),
                _buildParentalControlTab(),
              ],
            ),
    );
  }

  // ============ OVERVIEW TAB ============
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadWiFiConfig,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            title: 'Main Network',
            icon: Icons.wifi,
            color: Colors.deepPurple,
            children: [
              _buildInfoRow('SSID', _wifiConfig!.ssid, Icons.network_wifi),
              _buildPasswordRow('Password', _wifiConfig!.password),
              _buildInfoRow('Security', _wifiConfig!.securityType, Icons.lock),
              _buildInfoRow(
                'Band',
                _wifiConfig!.band,
                Icons.signal_cellular_alt,
              ),
              _buildInfoRow(
                'Channel',
                '${_wifiConfig!.channel}',
                Icons.settings_input_antenna,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showChangeSSIDDialog,
                      icon: const Icon(Icons.edit),
                      label: const Text('Change SSID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showChangePasswordDialog,
                      icon: const Icon(Icons.vpn_key),
                      label: const Text('Change Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Network Information',
            icon: Icons.info_outline,
            color: Colors.blue,
            children: [
              _buildInfoRow(
                'Hidden Network',
                _wifiConfig!.isHidden ? 'Yes' : 'No',
                Icons.visibility_off,
              ),
              _buildInfoRow(
                'Last Modified',
                _formatDate(_wifiConfig!.lastModified),
                Icons.access_time,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRow(String label, String password) {
    bool obscured = true;
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.vpn_key, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                '$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  obscured ? '••••••••' : password,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  textAlign: TextAlign.right,
                ),
              ),
              IconButton(
                icon: Icon(obscured ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => obscured = !obscured),
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: password));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password copied!')),
                  );
                },
                iconSize: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============ DEVICES TAB ============
  Widget _buildDevicesTab() {
    final user = _authService.currentUser;
    if (user == null) return const Center(child: Text('Not logged in'));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.deepPurple[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Connected Devices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddDeviceDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Demo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ConnectedDevice>>(
            stream: _wifiService.getConnectedDevices(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.devices_other,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No devices connected',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showAddDeviceDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Demo Device'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final device = snapshot.data![index];
                  return _buildDeviceCard(device);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(ConnectedDevice device) {
    IconData deviceIcon;
    Color deviceColor;

    switch (device.deviceType) {
      case 'phone':
        deviceIcon = Icons.phone_android;
        deviceColor = Colors.blue;
        break;
      case 'laptop':
        deviceIcon = Icons.laptop;
        deviceColor = Colors.green;
        break;
      case 'tv':
        deviceIcon = Icons.tv;
        deviceColor = Colors.purple;
        break;
      case 'iot':
        deviceIcon = Icons.router;
        deviceColor = Colors.orange;
        break;
      default:
        deviceIcon = Icons.device_unknown;
        deviceColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: deviceColor.withValues(alpha: 0.1),
          child: Icon(deviceIcon, color: deviceColor),
        ),
        title: Text(
          device.deviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('IP: ${device.ipAddress}'),
            Text('MAC: ${device.macAddress}'),
            Row(
              children: [
                Icon(Icons.download, size: 14, color: Colors.green[700]),
                Text(' ${device.downloadSpeed.toStringAsFixed(1)} Mbps'),
                const SizedBox(width: 12),
                Icon(Icons.upload, size: 14, color: Colors.blue[700]),
                Text(' ${device.uploadSpeed.toStringAsFixed(1)} Mbps'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'rename', child: Text('Rename')),
            PopupMenuItem(
              value: 'block',
              child: Text(device.isBlocked ? 'Unblock' : 'Block'),
            ),
            const PopupMenuItem(
              value: 'parental',
              child: Text('Parental Control'),
            ),
          ],
          onSelected: (value) {
            if (value == 'block') {
              _toggleDeviceBlock(device);
            } else if (value == 'rename') {
              _showRenameDeviceDialog(device);
            } else if (value == 'parental') {
              _tabController.animateTo(3);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Set parental control for ${device.deviceName}',
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // ============ GUEST NETWORK TAB ============
  Widget _buildGuestNetworkTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          child: SwitchListTile(
            value: _wifiConfig!.isGuestNetworkEnabled,
            onChanged: (value) async {
              await _wifiService.toggleGuestNetwork(
                customerId: _authService.currentUser!.id,
                enable: value,
              );
              _loadWiFiConfig();
            },
            title: const Text(
              'Guest Network',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              _wifiConfig!.isGuestNetworkEnabled
                  ? 'Enabled - Guests can connect'
                  : 'Disabled - Only main network available',
            ),
            secondary: Icon(
              Icons.people,
              color: _wifiConfig!.isGuestNetworkEnabled
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
        ),
        if (_wifiConfig!.isGuestNetworkEnabled) ...[
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Guest Network Details',
            icon: Icons.wifi_tethering,
            color: Colors.green,
            children: [
              _buildInfoRow(
                'Guest SSID',
                _wifiConfig!.guestSSID ?? 'N/A',
                Icons.network_wifi,
              ),
              _buildPasswordRow(
                'Guest Password',
                _wifiConfig!.guestPassword ?? 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'About Guest Network',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('• Guest network provides internet access for visitors'),
                  Text('• Guests cannot access your main network devices'),
                  Text('• Guest network has limited bandwidth'),
                  Text('• Ideal for temporary visitors'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ============ PARENTAL CONTROL TAB ============
  Widget _buildParentalControlTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.child_care, color: Colors.purple, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Parental Control',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Manage internet access for your children:'),
                SizedBox(height: 8),
                Text('• Block specific websites or categories'),
                Text('• Set time restrictions'),
                Text('• Limit daily screen time'),
                Text('• Monitor device usage'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Setup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Go to "Devices" tab to select a device and configure parental controls.',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.devices),
                  label: const Text('Go to Devices'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============ DIALOGS ============

  void _showChangeSSIDDialog() {
    final controller = TextEditingController(text: _wifiConfig!.ssid);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change SSID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New SSID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _wifiService.updateWiFiSSID(
                customerId: _authService.currentUser!.id,
                newSSID: controller.text,
              );
              if (success) {
                _loadWiFiConfig();
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SSID updated successfully')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change WiFi Password'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 8 characters'),
                  ),
                );
                return;
              }
              final success = await _wifiService.updateWiFiPassword(
                customerId: _authService.currentUser!.id,
                newPassword: controller.text,
              );
              if (success) {
                _loadWiFiConfig();
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog() {
    final nameController = TextEditingController();
    String selectedType = 'phone';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Demo Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Device Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'phone', child: Text('Phone')),
                  DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
                  DropdownMenuItem(value: 'tv', child: Text('TV')),
                  DropdownMenuItem(value: 'iot', child: Text('IoT Device')),
                ],
                onChanged: (value) {
                  setState(() => selectedType = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter device name')),
                  );
                  return;
                }
                await _wifiService.addMockDevice(
                  customerId: _authService.currentUser!.id,
                  deviceName: nameController.text,
                  deviceType: selectedType,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDeviceDialog(ConnectedDevice device) {
    final controller = TextEditingController(text: device.deviceName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Device'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Device Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _wifiService.updateDeviceName(
                deviceId: device.id,
                newName: controller.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleDeviceBlock(ConnectedDevice device) async {
    final success = await _wifiService.toggleDeviceBlock(
      deviceId: device.id,
      block: !device.isBlocked,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            device.isBlocked
                ? '${device.deviceName} unblocked'
                : '${device.deviceName} blocked',
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
