import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Package Upgrade/Downgrade Request
class PackageUpgradeRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String currentPackage;
  final int currentSpeed;
  final int currentPrice;
  final String requestedPackage;
  final int requestedSpeed;
  final int requestedPrice;
  final String requestType; // 'upgrade' or 'downgrade'
  final String status; // 'pending', 'approved', 'rejected'
  final String? reason; // Customer's reason for request
  final String? adminNotes; // Admin's notes/rejection reason
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? processedBy; // Admin user ID who approved/rejected

  PackageUpgradeRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.currentPackage,
    required this.currentSpeed,
    required this.currentPrice,
    required this.requestedPackage,
    required this.requestedSpeed,
    required this.requestedPrice,
    required this.requestType,
    this.status = 'pending',
    this.reason,
    this.adminNotes,
    required this.requestedAt,
    this.processedAt,
    this.processedBy,
  });

  factory PackageUpgradeRequest.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return PackageUpgradeRequest(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      currentPackage: data['currentPackage'] ?? '',
      currentSpeed: data['currentSpeed'] ?? 0,
      currentPrice: data['currentPrice'] ?? 0,
      requestedPackage: data['requestedPackage'] ?? '',
      requestedSpeed: data['requestedSpeed'] ?? 0,
      requestedPrice: data['requestedPrice'] ?? 0,
      requestType: data['requestType'] ?? 'upgrade',
      status: data['status'] ?? 'pending',
      reason: data['reason'],
      adminNotes: data['adminNotes'],
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      processedAt: data['processedAt'] != null
          ? (data['processedAt'] as Timestamp).toDate()
          : null,
      processedBy: data['processedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'currentPackage': currentPackage,
      'currentSpeed': currentSpeed,
      'currentPrice': currentPrice,
      'requestedPackage': requestedPackage,
      'requestedSpeed': requestedSpeed,
      'requestedPrice': requestedPrice,
      'requestType': requestType,
      'status': status,
      'reason': reason,
      'adminNotes': adminNotes,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'processedAt':
          processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'processedBy': processedBy,
    };
  }

  // Calculate price difference
  int get priceDifference => requestedPrice - currentPrice;

  // Check if this is an upgrade or downgrade
  bool get isUpgrade => requestedSpeed > currentSpeed;

  // Get status color
  String get statusColor {
    switch (status) {
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      default:
        return 'orange';
    }
  }
}
