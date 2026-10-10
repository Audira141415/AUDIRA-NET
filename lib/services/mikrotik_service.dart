import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// MikroTik RouterOS API Service
/// Handles communication with MikroTik routers via RouterOS API
class MikroTikService {
  final String host;
  final int port;
  final String username;
  final String password;
  final bool useSSL;

  String? _sessionToken;
  bool _isConnected = false;

  MikroTikService({
    required this.host,
    this.port = 8728,
    required this.username,
    required this.password,
    this.useSSL = false,
  });

  /// Check if service is connected
  bool get isConnected => _isConnected;

  /// Connect to MikroTik router
  Future<bool> connect() async {
    try {
      final url = Uri.parse(
        '${useSSL ? 'https' : 'http'}://$host:$port/rest/login',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _isConnected = true;
        return true;
      }

      _isConnected = false;
      return false;
    } catch (e) {
      _isConnected = false;
      print('MikroTik connection error: $e');
      return false;
    }
  }

  /// Disconnect from router
  Future<void> disconnect() async {
    _sessionToken = null;
    _isConnected = false;
  }

  /// Get system resources (CPU, Memory, Uptime)
  Future<Map<String, dynamic>?> getSystemResources() async {
    if (!_isConnected) return null;

    try {
      final url = Uri.parse(
        '${useSSL ? 'https' : 'http'}://$host:$port/rest/system/resource',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'cpuLoad': data['cpu-load'] ?? 0,
          'totalMemory': data['total-memory'] ?? 0,
          'freeMemory': data['free-memory'] ?? 0,
          'uptime': data['uptime'] ?? '',
          'version': data['version'] ?? '',
          'boardName': data['board-name'] ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Error fetching system resources: $e');
      return null;
    }
  }

  /// Get list of interfaces
  Future<List<Map<String, dynamic>>> getInterfaces() async {
    if (!_isConnected) return [];

    try {
      final url = Uri.parse(
        '${useSSL ? 'https' : 'http'}://$host:$port/rest/interface',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          return {
            'id': item['.id'] ?? '',
            'name': item['name'] ?? '',
            'type': item['type'] ?? '',
            'running': item['running'] ?? false,
            'disabled': item['disabled'] ?? false,
            'rxByte': item['rx-byte'] ?? 0,
            'txByte': item['tx-byte'] ?? 0,
            'lastLinkUpTime': item['last-link-up-time'] ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching interfaces: $e');
      return [];
    }
  }

  /// Get interface traffic stats
  Future<Map<String, dynamic>?> getInterfaceTraffic(String interfaceId) async {
    if (!_isConnected) return null;

    try {
      final url = Uri.parse(
        '${useSSL ? 'https' : 'http'}://$host:$port/rest/interface/monitor-traffic',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
            body: jsonEncode({'.id': interfaceId, 'once': true}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'rxBitsPerSecond': data['rx-bits-per-second'] ?? 0,
          'txBitsPerSecond': data['tx-bits-per-second'] ?? 0,
          'rxPacketsPerSecond': data['rx-packets-per-second'] ?? 0,
          'txPacketsPerSecond': data['tx-packets-per-second'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      print('Error fetching interface traffic: $e');
      return null;
    }
  }

  /// Get active connections count
  Future<int> getActiveConnections() async {
    if (!_isConnected) return 0;

    try {
      final url = Uri.parse(
        '${useSSL ? 'https' : 'http'}://$host:$port/rest/ip/firewall/connection',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Error fetching active connections: $e');
      return 0;
    }
  }

  /// Reboot router
  Future<bool> rebootRouter() async {
    if (!_isConnected) return false;

    try {
      final url = Uri.parse(
        '${useSSL ? 'https' : 'http'}://$host:$port/rest/system/reboot',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error rebooting router: $e');
      return false;
    }
  }

  /// Enable/Disable interface
  Future<bool> setInterfaceStatus(String interfaceId, bool disabled) async {
    if (!_isConnected) return false;

    try {
      final url = Uri.parse(
        '${useSSL ? 'https' : 'http'}://$host:$port/rest/interface/set',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
            body: jsonEncode({'.id': interfaceId, 'disabled': disabled}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error setting interface status: $e');
      return false;
    }
  }

  /// Get DHCP leases
  Future<List<Map<String, dynamic>>> getDHCPLeases() async {
    if (!_isConnected) return [];

    try {
      final url = Uri.parse(
        '${useSSL ? 'https' : 'http'}://$host:$port/rest/ip/dhcp-server/lease',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          return {
            'id': item['.id'] ?? '',
            'address': item['address'] ?? '',
            'macAddress': item['mac-address'] ?? '',
            'hostname': item['host-name'] ?? '',
            'activeAddress': item['active-address'] ?? '',
            'status': item['status'] ?? '',
            'lastSeen': item['last-seen'] ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching DHCP leases: $e');
      return [];
    }
  }

  /// Get router identity
  Future<String?> getRouterIdentity() async {
    if (!_isConnected) return null;

    try {
      final url = Uri.parse(
        '${useSSL ? 'https' : 'http'}://$host:$port/rest/system/identity',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['name'] ?? 'Unknown';
      }
      return null;
    } catch (e) {
      print('Error fetching router identity: $e');
      return null;
    }
  }

  /// Get bandwidth usage statistics
  Future<Map<String, dynamic>?> getBandwidthStats() async {
    if (!_isConnected) return null;

    try {
      // Get all interfaces traffic
      final interfaces = await getInterfaces();
      int totalRx = 0;
      int totalTx = 0;

      for (var interface in interfaces) {
        totalRx += (interface['rxByte'] as int?) ?? 0;
        totalTx += (interface['txByte'] as int?) ?? 0;
      }

      return {
        'totalDownload': totalRx,
        'totalUpload': totalTx,
        'total': totalRx + totalTx,
        'interfaceCount': interfaces.length,
      };
    } catch (e) {
      print('Error fetching bandwidth stats: $e');
      return null;
    }
  }
}

/// MikroTik Service Manager - Manages multiple routers
class MikroTikServiceManager {
  final Map<String, MikroTikService> _services = {};

  /// Add router to manager
  void addRouter(
    String routerId, {
    required String host,
    int port = 8728,
    required String username,
    required String password,
    bool useSSL = false,
  }) {
    _services[routerId] = MikroTikService(
      host: host,
      port: port,
      username: username,
      password: password,
      useSSL: useSSL,
    );
  }

  /// Get service for specific router
  MikroTikService? getService(String routerId) {
    return _services[routerId];
  }

  /// Connect to router
  Future<bool> connectRouter(String routerId) async {
    final service = _services[routerId];
    if (service == null) return false;
    return await service.connect();
  }

  /// Disconnect router
  Future<void> disconnectRouter(String routerId) async {
    final service = _services[routerId];
    if (service == null) return;
    await service.disconnect();
  }

  /// Disconnect all routers
  Future<void> disconnectAll() async {
    for (var service in _services.values) {
      await service.disconnect();
    }
  }

  /// Check if router is connected
  bool isConnected(String routerId) {
    final service = _services[routerId];
    return service?.isConnected ?? false;
  }

  /// Remove router from manager
  void removeRouter(String routerId) {
    _services[routerId]?.disconnect();
    _services.remove(routerId);
  }

  /// Get all router IDs
  List<String> getAllRouterIds() {
    return _services.keys.toList();
  }

  /// Get connection status for all routers
  Map<String, bool> getAllConnectionStatus() {
    return _services.map((key, service) => MapEntry(key, service.isConnected));
  }
}
