import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/package_upgrade_request.dart';
import 'firebase_service.dart';
import 'logger_service.dart';

/// Service for handling Package Upgrade/Downgrade Requests
class PackageUpgradeService {
  static final PackageUpgradeService instance = PackageUpgradeService._internal();
  factory PackageUpgradeService() => instance;
  PackageUpgradeService._internal();

  final CollectionReference _upgradeRequestsCollection =
      FirebaseFirestore.instance.collection('package_upgrade_requests');

  // ==================== AVAILABLE PACKAGES ====================

  final List<Map<String, dynamic>> availablePackages = [
    {
      'id': 'pkg_home_20',
      'name': 'Home 20 Mbps',
      'speed': 20,
      'price': 250000,
      'description': 'Cocok untuk browsing & streaming (1-2 perangkat)',
      'features': ['20 Mbps', 'Unlimited', 'Gratis Instalasi'],
    },
    {
      'id': 'pkg_home_50',
      'name': 'Home 50 Mbps',
      'speed': 50,
      'price': 350000,
      'description': 'Ideal untuk keluarga (3-4 perangkat)',
      'features': ['50 Mbps', 'Unlimited', 'Gratis Instalasi', 'Priority Support'],
    },
    {
      'id': 'pkg_home_100',
      'name': 'Home 100 Mbps',
      'speed': 100,
      'price': 500000,
      'description': 'Super cepat untuk gaming & 4K streaming (5-6 perangkat)',
      'features': [
        '100 Mbps',
        'Unlimited',
        'Gratis Instalasi',
        'Priority Support',
        'Free Router Upgrade',
      ],
    },
    {
      'id': 'pkg_business_200',
      'name': 'Business 200 Mbps',
      'speed': 200,
      'price': 1500000,
      'description': 'Untuk kantor & bisnis (10+ perangkat)',
      'features': [
        '200 Mbps',
        'Unlimited',
        'Dedicated Support',
        'SLA 99.9%',
        'Free Router & Backup',
      ],
    },
  ];

  // ==================== CUSTOMER REQUESTS ====================

  /// Submit a package upgrade/downgrade request
  Future<String> submitUpgradeRequest({
    required String customerId,
    required String customerName,
    required String currentPackage,
    required int currentSpeed,
    required int currentPrice,
    required String requestedPackage,
    required int requestedSpeed,
    required int requestedPrice,
    String? reason,
  }) async {
    try {
      final requestType = requestedSpeed > currentSpeed ? 'upgrade' : 'downgrade';

      final requestData = {
        'customerId': customerId,
        'customerName': customerName,
        'currentPackage': currentPackage,
        'currentSpeed': currentSpeed,
        'currentPrice': currentPrice,
        'requestedPackage': requestedPackage,
        'requestedSpeed': requestedSpeed,
        'requestedPrice': requestedPrice,
        'requestType': requestType,
        'status': 'pending',
        'reason': reason,
        'requestedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _upgradeRequestsCollection.add(requestData);

      LoggerService.info(
        'Package $requestType request submitted: ${docRef.id} for customer $customerId',
      );

      return docRef.id;
    } catch (e) {
      LoggerService.error('Error submitting upgrade request: $e');
      rethrow;
    }
  }

  /// Get all upgrade requests for a specific customer
  Future<List<PackageUpgradeRequest>> getCustomerRequests(
    String customerId,
  ) async {
    try {
      final querySnapshot = await _upgradeRequestsCollection
          .where('customerId', isEqualTo: customerId)
          .orderBy('requestedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PackageUpgradeRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting customer requests: $e');
      return [];
    }
  }

  /// Check if customer has pending upgrade request
  Future<bool> hasPendingRequest(String customerId) async {
    try {
      final querySnapshot = await _upgradeRequestsCollection
          .where('customerId', isEqualTo: customerId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      LoggerService.error('Error checking pending request: $e');
      return false;
    }
  }

  // ==================== ADMIN OPERATIONS ====================

  /// Get all pending upgrade requests (for admin)
  Future<List<PackageUpgradeRequest>> getPendingRequests() async {
    try {
      final querySnapshot = await _upgradeRequestsCollection
          .where('status', isEqualTo: 'pending')
          .orderBy('requestedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PackageUpgradeRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting pending requests: $e');
      return [];
    }
  }

  /// Get all upgrade requests with optional status filter
  Future<List<PackageUpgradeRequest>> getAllRequests({String? status}) async {
    try {
      Query query = _upgradeRequestsCollection.orderBy('requestedAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => PackageUpgradeRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting all requests: $e');
      return [];
    }
  }

  /// Approve an upgrade request
  Future<void> approveRequest(
    String requestId,
    String adminUserId, {
    String? notes,
  }) async {
    try {
      final requestDoc = await _upgradeRequestsCollection.doc(requestId).get();
      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      final request = PackageUpgradeRequest.fromFirestore(requestDoc);

      // Update request status
      await _upgradeRequestsCollection.doc(requestId).update({
        'status': 'approved',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminUserId,
        'adminNotes': notes,
      });

      // Update customer package in Firestore
      final customerSnapshot = await FirebaseService
          .instance.customersCollection
          .where('id', isEqualTo: request.customerId)
          .limit(1)
          .get();

      if (customerSnapshot.docs.isNotEmpty) {
        final customerDoc = customerSnapshot.docs.first;
        await customerDoc.reference.update({
          'packageName': request.requestedPackage,
          'speed': request.requestedSpeed,
          'monthlyFee': request.requestedPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      LoggerService.info('Package upgrade request approved: $requestId');
    } catch (e) {
      LoggerService.error('Error approving request: $e');
      rethrow;
    }
  }

  /// Reject an upgrade request
  Future<void> rejectRequest(
    String requestId,
    String adminUserId, {
    required String reason,
  }) async {
    try {
      await _upgradeRequestsCollection.doc(requestId).update({
        'status': 'rejected',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminUserId,
        'adminNotes': reason,
      });

      LoggerService.info('Package upgrade request rejected: $requestId');
    } catch (e) {
      LoggerService.error('Error rejecting request: $e');
      rethrow;
    }
  }

  /// Get request statistics
  Future<Map<String, int>> getRequestStats() async {
    try {
      final allRequests = await getAllRequests();

      return {
        'total': allRequests.length,
        'pending': allRequests.where((r) => r.status == 'pending').length,
        'approved': allRequests.where((r) => r.status == 'approved').length,
        'rejected': allRequests.where((r) => r.status == 'rejected').length,
        'upgrades':
            allRequests.where((r) => r.requestType == 'upgrade').length,
        'downgrades':
            allRequests.where((r) => r.requestType == 'downgrade').length,
      };
    } catch (e) {
      LoggerService.error('Error getting request stats: $e');
      return {};
    }
  }
}
