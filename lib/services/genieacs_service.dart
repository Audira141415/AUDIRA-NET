import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// GenieACS TR-069 API Service
/// Handles communication with GenieACS server for CPE/ONT/Modem management
class GenieACSService {
  final String baseUrl;
  final String username;
  final String password;

  bool _isConnected = false;

  GenieACSService({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  /// Check if service is connected
  bool get isConnected => _isConnected;

  /// Get authorization header
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Authorization':
        'Basic ${base64Encode(utf8.encode('$username:$password'))}',
  };

  /// Test connection to GenieACS server
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/devices');

      final response = await http
          .get(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      _isConnected = response.statusCode == 200;
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      print('GenieACS connection error: $e');
      return false;
    }
  }

  /// Get all devices
  Future<List<Map<String, dynamic>>> getAllDevices({
    String? filter,
    int limit = 100,
    int skip = 0,
  }) async {
    try {
      var url = '$baseUrl/devices?limit=$limit&skip=$skip';
      if (filter != null && filter.isNotEmpty) {
        url += '&query=${Uri.encodeComponent(filter)}';
      }

      final response = await http
          .get(Uri.parse(url), headers: _authHeaders)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => _parseDevice(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching devices: $e');
      return [];
    }
  }

  /// Get single device by ID
  Future<Map<String, dynamic>?> getDevice(String deviceId) async {
    try {
      final url = Uri.parse('$baseUrl/devices/$deviceId');

      final response = await http
          .get(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseDevice(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching device: $e');
      return null;
    }
  }

  /// Parse device data from API response
  Map<String, dynamic> _parseDevice(Map<String, dynamic> data) {
    // Extract common parameters from TR-069 data model
    final params = data['_deviceId'] ?? {};

    return {
      'id': data['_id'] ?? '',
      'deviceId':
          '${params['_Manufacturer']?.toString() ?? ''}${params['_OUI']?.toString() ?? ''}${params['_SerialNumber']?.toString() ?? ''}',
      'serialNumber': params['_SerialNumber']?.toString() ?? data['_id'] ?? '',
      'manufacturer': params['_Manufacturer']?.toString() ?? 'Unknown',
      'model': params['_ProductClass']?.toString() ?? 'Unknown',
      'firmwareVersion': params['_SoftwareVersion']?.toString() ?? 'Unknown',
      'ipAddress':
          data['InternetGatewayDevice.ManagementServer.ConnectionRequestURL']?['_value'] ??
          '',
      'uptime': params['_UpTime']?.toString() ?? '0',
      'lastInform': data['_lastInform'] ?? '',
      'registered': data['_registered'] ?? 0,
      'online': _isDeviceOnline(data),
      'parameters': data,
    };
  }

  /// Check if device is online (informed within last 5 minutes)
  bool _isDeviceOnline(Map<String, dynamic> data) {
    try {
      final lastInform = data['_lastInform'];
      if (lastInform == null) return false;

      final lastInformTime = DateTime.fromMillisecondsSinceEpoch(lastInform);
      final now = DateTime.now();
      final difference = now.difference(lastInformTime);

      return difference.inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  /// Get device parameter value
  Future<dynamic> getDeviceParameter(
    String deviceId,
    String parameterPath,
  ) async {
    try {
      final device = await getDevice(deviceId);
      if (device == null) return null;

      final params = device['parameters'];
      return params[parameterPath]?['_value'];
    } catch (e) {
      print('Error getting parameter: $e');
      return null;
    }
  }

  /// Set device parameter value
  Future<bool> setDeviceParameter(
    String deviceId,
    String parameterPath,
    dynamic value,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/devices/$deviceId/tasks');

      final response = await http
          .post(
            url,
            headers: _authHeaders,
            body: jsonEncode({
              'name': 'setParameterValues',
              'parameterValues': [
                [parameterPath, value],
              ],
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      print('Error setting parameter: $e');
      return false;
    }
  }

  /// Refresh device (trigger inform)
  Future<bool> refreshDevice(String deviceId) async {
    try {
      final url = Uri.parse('$baseUrl/devices/$deviceId/tasks');

      final response = await http
          .post(
            url,
            headers: _authHeaders,
            body: jsonEncode({'name': 'refreshObject', 'objectName': ''}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      print('Error refreshing device: $e');
      return false;
    }
  }

  /// Reboot device
  Future<bool> rebootDevice(String deviceId) async {
    try {
      final url = Uri.parse('$baseUrl/devices/$deviceId/tasks');

      final response = await http
          .post(
            url,
            headers: _authHeaders,
            body: jsonEncode({'name': 'reboot'}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      print('Error rebooting device: $e');
      return false;
    }
  }

  /// Factory reset device
  Future<bool> factoryResetDevice(String deviceId) async {
    try {
      final url = Uri.parse('$baseUrl/devices/$deviceId/tasks');

      final response = await http
          .post(
            url,
            headers: _authHeaders,
            body: jsonEncode({'name': 'factoryReset'}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      print('Error factory resetting device: $e');
      return false;
    }
  }

  /// Download firmware to device
  Future<bool> downloadFirmware(
    String deviceId, {
    required String fileType,
    required String fileName,
    required String targetFileName,
    required String url,
  }) async {
    try {
      final apiUrl = Uri.parse('$baseUrl/devices/$deviceId/tasks');

      final response = await http
          .post(
            apiUrl,
            headers: _authHeaders,
            body: jsonEncode({
              'name': 'download',
              'fileType': fileType,
              'fileName': fileName,
              'targetFileName': targetFileName,
              'url': url,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      print('Error downloading firmware: $e');
      return false;
    }
  }

  /// Get device tasks/jobs
  Future<List<Map<String, dynamic>>> getDeviceTasks(String deviceId) async {
    try {
      final url = Uri.parse('$baseUrl/tasks?device=$deviceId');

      final response = await http
          .get(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (item) => {
                'id': item['_id'] ?? '',
                'device': item['device'] ?? '',
                'name': item['name'] ?? '',
                'timestamp': item['timestamp'] ?? 0,
                'status': item['status'] ?? 'pending',
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  /// Delete device task
  Future<bool> deleteTask(String taskId) async {
    try {
      final url = Uri.parse('$baseUrl/tasks/$taskId');

      final response = await http
          .delete(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  /// Get device faults
  Future<List<Map<String, dynamic>>> getDeviceFaults(String deviceId) async {
    try {
      final url = Uri.parse('$baseUrl/faults?device=$deviceId');

      final response = await http
          .get(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (item) => {
                'id': item['_id'] ?? '',
                'device': item['device'] ?? '',
                'channel': item['channel'] ?? '',
                'code': item['code'] ?? '',
                'message': item['message'] ?? '',
                'timestamp': item['timestamp'] ?? 0,
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching faults: $e');
      return [];
    }
  }

  /// Get presets (configurations)
  Future<List<Map<String, dynamic>>> getPresets() async {
    try {
      final url = Uri.parse('$baseUrl/presets');

      final response = await http
          .get(url, headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (item) => {
                'id': item['_id'] ?? '',
                'name': item['name'] ?? '',
                'channel': item['channel'] ?? '',
                'precondition': item['precondition'] ?? '',
                'weight': item['weight'] ?? 0,
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching presets: $e');
      return [];
    }
  }

  /// Apply preset to device
  Future<bool> applyPreset(String deviceId, String presetName) async {
    try {
      final url = Uri.parse('$baseUrl/devices/$deviceId/tasks');

      final response = await http
          .post(
            url,
            headers: _authHeaders,
            body: jsonEncode({'name': 'preset', 'preset': presetName}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      print('Error applying preset: $e');
      return false;
    }
  }

  /// Get device statistics
  Future<Map<String, dynamic>?> getDeviceStats(String deviceId) async {
    try {
      final device = await getDevice(deviceId);
      if (device == null) return null;

      final params = device['parameters'];

      // Extract common statistics
      return {
        'uptime': params['DeviceInfo.UpTime']?['_value'] ?? 0,
        'cpuUsage': params['DeviceInfo.ProcessStatus.CPUUsage']?['_value'] ?? 0,
        'memoryUsage': params['DeviceInfo.MemoryStatus.Total']?['_value'] ?? 0,
        'memoryFree': params['DeviceInfo.MemoryStatus.Free']?['_value'] ?? 0,
        'temperature':
            params['DeviceInfo.TemperatureStatus.TemperatureSensor']?['_value'] ??
            0,
        // WAN interface stats
        'wanBytesReceived':
            params['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.Stats.EthernetBytesReceived']?['_value'] ??
            0,
        'wanBytesSent':
            params['InternetGatewayDevice.WANDevice.1.WANConnectionDevice.1.WANIPConnection.1.Stats.EthernetBytesSent']?['_value'] ??
            0,
        // LAN interface stats
        'lanBytesReceived':
            params['InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.1.Stats.BytesReceived']?['_value'] ??
            0,
        'lanBytesSent':
            params['InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.1.Stats.BytesSent']?['_value'] ??
            0,
      };
    } catch (e) {
      print('Error fetching device stats: $e');
      return null;
    }
  }

  /// Search devices by criteria
  Future<List<Map<String, dynamic>>> searchDevices({
    String? manufacturer,
    String? model,
    String? firmwareVersion,
    bool? online,
  }) async {
    final filters = <String>[];

    if (manufacturer != null) {
      filters.add('_deviceId._Manufacturer="$manufacturer"');
    }
    if (model != null) {
      filters.add('_deviceId._ProductClass="$model"');
    }
    if (firmwareVersion != null) {
      filters.add('_deviceId._SoftwareVersion="$firmwareVersion"');
    }

    final filter = filters.isEmpty ? null : '{${filters.join(',')}}';
    final devices = await getAllDevices(filter: filter);

    if (online != null) {
      return devices.where((d) => d['online'] == online).toList();
    }

    return devices;
  }
}
