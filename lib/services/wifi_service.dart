import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wifi_model.dart';

class WiFiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ WiFi Configuration ============

  /// Get WiFi configuration for customer
  Future<WiFiConfiguration?> getWiFiConfig(String customerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('wifi_configurations')
          .where('customerId', isEqualTo: customerId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Create default config if not exists
        return await _createDefaultConfig(customerId);
      }

      return WiFiConfiguration.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      developer.log('Error getting WiFi config: $e', name: 'WiFiService');
      return null;
    }
  }

  /// Create default WiFi configuration
  Future<WiFiConfiguration> _createDefaultConfig(String customerId) async {
    final config = WiFiConfiguration(
      id: '',
      customerId: customerId,
      ssid: 'AudiraNet-${customerId.substring(0, 6)}',
      password: _generateRandomPassword(),
      securityType: 'WPA2',
      isGuestNetworkEnabled: false,
      isHidden: false,
      channel: 6,
      band: '2.4GHz',
      lastModified: DateTime.now(),
      modifiedBy: customerId,
    );

    final docRef = await _firestore
        .collection('wifi_configurations')
        .add(config.toMap());

    return WiFiConfiguration.fromFirestore(await docRef.get());
  }

  /// Update WiFi password
  Future<bool> updateWiFiPassword({
    required String customerId,
    required String newPassword,
  }) async {
    try {
      final config = await getWiFiConfig(customerId);
      if (config == null) return false;

      await _firestore.collection('wifi_configurations').doc(config.id).update({
        'password': newPassword,
        'lastModified': Timestamp.now(),
        'modifiedBy': customerId,
      });

      return true;
    } catch (e) {
      developer.log('Error updating WiFi password: $e', name: 'WiFiService');
      return false;
    }
  }

  /// Update WiFi SSID
  Future<bool> updateWiFiSSID({
    required String customerId,
    required String newSSID,
  }) async {
    try {
      final config = await getWiFiConfig(customerId);
      if (config == null) return false;

      await _firestore.collection('wifi_configurations').doc(config.id).update({
        'ssid': newSSID,
        'lastModified': Timestamp.now(),
        'modifiedBy': customerId,
      });

      return true;
    } catch (e) {
      developer.log('Error updating WiFi SSID: $e', name: 'WiFiService');
      return false;
    }
  }

  /// Enable/Disable Guest Network
  Future<bool> toggleGuestNetwork({
    required String customerId,
    required bool enable,
    String? guestSSID,
    String? guestPassword,
  }) async {
    try {
      final config = await getWiFiConfig(customerId);
      if (config == null) return false;

      final updateData = <String, dynamic>{
        'isGuestNetworkEnabled': enable,
        'lastModified': Timestamp.now(),
        'modifiedBy': customerId,
      };

      if (enable) {
        updateData['guestSSID'] =
            guestSSID ?? 'AudiraNet-Guest-${customerId.substring(0, 6)}';
        updateData['guestPassword'] =
            guestPassword ?? _generateRandomPassword();
      } else {
        updateData['guestSSID'] = null;
        updateData['guestPassword'] = null;
      }

      await _firestore
          .collection('wifi_configurations')
          .doc(config.id)
          .update(updateData);

      return true;
    } catch (e) {
      developer.log('Error toggling guest network: $e', name: 'WiFiService');
      return false;
    }
  }

  // ============ Connected Devices ============

  /// Get all connected devices for customer
  Stream<List<ConnectedDevice>> getConnectedDevices(String customerId) {
    return _firestore
        .collection('connected_devices')
        .where('customerId', isEqualTo: customerId)
        .orderBy('connectedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ConnectedDevice.fromFirestore(doc))
              .toList(),
        );
  }

  /// Add mock connected device (for demo)
  Future<void> addMockDevice({
    required String customerId,
    required String deviceName,
    required String deviceType,
  }) async {
    final device = ConnectedDevice(
      id: '',
      customerId: customerId,
      deviceName: deviceName,
      macAddress: _generateMacAddress(),
      ipAddress: '192.168.1.${100 + DateTime.now().millisecond % 50}',
      deviceType: deviceType,
      isBlocked: false,
      connectedAt: DateTime.now(),
      lastSeen: DateTime.now(),
      downloadSpeed: (20 + DateTime.now().millisecond % 80).toDouble(),
      uploadSpeed: (10 + DateTime.now().millisecond % 40).toDouble(),
      signalStrength: -30 - (DateTime.now().millisecond % 40),
    );

    await _firestore.collection('connected_devices').add(device.toMap());
  }

  /// Block/Unblock device
  Future<bool> toggleDeviceBlock({
    required String deviceId,
    required bool block,
  }) async {
    try {
      await _firestore.collection('connected_devices').doc(deviceId).update({
        'isBlocked': block,
      });
      return true;
    } catch (e) {
      developer.log('Error toggling device block: $e', name: 'WiFiService');
      return false;
    }
  }

  /// Update device name
  Future<bool> updateDeviceName({
    required String deviceId,
    required String newName,
  }) async {
    try {
      await _firestore.collection('connected_devices').doc(deviceId).update({
        'deviceName': newName,
      });
      return true;
    } catch (e) {
      developer.log('Error updating device name: $e', name: 'WiFiService');
      return false;
    }
  }

  // ============ Parental Control ============

  /// Get parental control for device
  Future<ParentalControl?> getParentalControl(
    String customerId,
    String macAddress,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('parental_controls')
          .where('customerId', isEqualTo: customerId)
          .where('deviceMacAddress', isEqualTo: macAddress)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ParentalControl.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      developer.log('Error getting parental control: $e', name: 'WiFiService');
      return null;
    }
  }

  /// Create or update parental control
  Future<bool> setParentalControl({
    required String customerId,
    required String deviceMacAddress,
    required bool isEnabled,
    List<String>? blockedWebsites,
    List<String>? blockedCategories,
    Map<String, String>? timeRestrictions,
    int? dailyTimeLimit,
  }) async {
    try {
      final existing = await getParentalControl(customerId, deviceMacAddress);

      final controlData = {
        'customerId': customerId,
        'deviceMacAddress': deviceMacAddress,
        'isEnabled': isEnabled,
        'blockedWebsites': blockedWebsites ?? [],
        'blockedCategories': blockedCategories ?? [],
        'timeRestrictions': timeRestrictions ?? {},
        'dailyTimeLimit': dailyTimeLimit ?? 0,
        'updatedAt': Timestamp.now(),
      };

      if (existing == null) {
        controlData['createdAt'] = Timestamp.now();
        await _firestore.collection('parental_controls').add(controlData);
      } else {
        await _firestore
            .collection('parental_controls')
            .doc(existing.id)
            .update(controlData);
      }

      return true;
    } catch (e) {
      developer.log('Error setting parental control: $e', name: 'WiFiService');
      return false;
    }
  }

  // ============ Helper Methods ============

  String _generateRandomPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      12,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }

  String _generateMacAddress() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      6,
      (i) =>
          (random + i * 13).toRadixString(16).padLeft(2, '0').substring(0, 2),
    ).join(':').toUpperCase();
  }
}
