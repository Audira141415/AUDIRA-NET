import 'package:cloud_firestore/cloud_firestore.dart';

/// WiFi Configuration Model
class WiFiConfiguration {
  final String id;
  final String customerId;
  final String ssid;
  final String password;
  final String securityType; // WPA2, WPA3
  final bool isGuestNetworkEnabled;
  final String? guestSSID;
  final String? guestPassword;
  final bool isHidden;
  final int channel;
  final String band; // 2.4GHz, 5GHz, dual
  final DateTime lastModified;
  final String modifiedBy;

  WiFiConfiguration({
    required this.id,
    required this.customerId,
    required this.ssid,
    required this.password,
    this.securityType = 'WPA2',
    this.isGuestNetworkEnabled = false,
    this.guestSSID,
    this.guestPassword,
    this.isHidden = false,
    this.channel = 6,
    this.band = '2.4GHz',
    required this.lastModified,
    required this.modifiedBy,
  });

  factory WiFiConfiguration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WiFiConfiguration(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      ssid: data['ssid'] ?? '',
      password: data['password'] ?? '',
      securityType: data['securityType'] ?? 'WPA2',
      isGuestNetworkEnabled: data['isGuestNetworkEnabled'] ?? false,
      guestSSID: data['guestSSID'],
      guestPassword: data['guestPassword'],
      isHidden: data['isHidden'] ?? false,
      channel: data['channel'] ?? 6,
      band: data['band'] ?? '2.4GHz',
      lastModified: (data['lastModified'] as Timestamp).toDate(),
      modifiedBy: data['modifiedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'ssid': ssid,
      'password': password,
      'securityType': securityType,
      'isGuestNetworkEnabled': isGuestNetworkEnabled,
      'guestSSID': guestSSID,
      'guestPassword': guestPassword,
      'isHidden': isHidden,
      'channel': channel,
      'band': band,
      'lastModified': Timestamp.fromDate(lastModified),
      'modifiedBy': modifiedBy,
    };
  }
}

/// Connected Device Model
class ConnectedDevice {
  final String id;
  final String customerId;
  final String deviceName;
  final String macAddress;
  final String ipAddress;
  final String deviceType; // phone, laptop, tv, iot
  final bool isBlocked;
  final DateTime connectedAt;
  final DateTime? lastSeen;
  final double downloadSpeed; // Mbps
  final double uploadSpeed; // Mbps
  final int signalStrength; // dBm

  ConnectedDevice({
    required this.id,
    required this.customerId,
    required this.deviceName,
    required this.macAddress,
    required this.ipAddress,
    required this.deviceType,
    this.isBlocked = false,
    required this.connectedAt,
    this.lastSeen,
    this.downloadSpeed = 0.0,
    this.uploadSpeed = 0.0,
    this.signalStrength = -50,
  });

  factory ConnectedDevice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConnectedDevice(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      deviceName: data['deviceName'] ?? 'Unknown Device',
      macAddress: data['macAddress'] ?? '',
      ipAddress: data['ipAddress'] ?? '',
      deviceType: data['deviceType'] ?? 'phone',
      isBlocked: data['isBlocked'] ?? false,
      connectedAt: (data['connectedAt'] as Timestamp).toDate(),
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
      downloadSpeed: (data['downloadSpeed'] ?? 0.0).toDouble(),
      uploadSpeed: (data['uploadSpeed'] ?? 0.0).toDouble(),
      signalStrength: data['signalStrength'] ?? -50,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'deviceName': deviceName,
      'macAddress': macAddress,
      'ipAddress': ipAddress,
      'deviceType': deviceType,
      'isBlocked': isBlocked,
      'connectedAt': Timestamp.fromDate(connectedAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
      'signalStrength': signalStrength,
    };
  }
}

/// Parental Control Model
class ParentalControl {
  final String id;
  final String customerId;
  final String deviceMacAddress;
  final bool isEnabled;
  final List<String> blockedWebsites;
  final List<String> blockedCategories; // social_media, gaming, adult
  final Map<String, String> timeRestrictions; // day: "08:00-22:00"
  final int dailyTimeLimit; // minutes
  final DateTime createdAt;
  final DateTime updatedAt;

  ParentalControl({
    required this.id,
    required this.customerId,
    required this.deviceMacAddress,
    this.isEnabled = false,
    this.blockedWebsites = const [],
    this.blockedCategories = const [],
    this.timeRestrictions = const {},
    this.dailyTimeLimit = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParentalControl.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParentalControl(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      deviceMacAddress: data['deviceMacAddress'] ?? '',
      isEnabled: data['isEnabled'] ?? false,
      blockedWebsites: List<String>.from(data['blockedWebsites'] ?? []),
      blockedCategories: List<String>.from(data['blockedCategories'] ?? []),
      timeRestrictions:
          Map<String, String>.from(data['timeRestrictions'] ?? {}),
      dailyTimeLimit: data['dailyTimeLimit'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'deviceMacAddress': deviceMacAddress,
      'isEnabled': isEnabled,
      'blockedWebsites': blockedWebsites,
      'blockedCategories': blockedCategories,
      'timeRestrictions': timeRestrictions,
      'dailyTimeLimit': dailyTimeLimit,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
