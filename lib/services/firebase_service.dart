import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Firebase Firestore Service
/// Replaces SQLite DatabaseService with cloud-based Firestore
class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  factory FirebaseService() => instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Collections ====================
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get customersCollection =>
      _firestore.collection('customers');
  CollectionReference get billsCollection => _firestore.collection('bills');
  CollectionReference get paymentsCollection =>
      _firestore.collection('payments');
  CollectionReference get ticketsCollection => _firestore.collection('tickets');
  CollectionReference get installationsCollection =>
      _firestore.collection('installations');
  CollectionReference get checkinsCollection =>
      _firestore.collection('checkins');
  CollectionReference get rewardsCollection => _firestore.collection('rewards');
  CollectionReference get maintenanceSchedulesCollection =>
      _firestore.collection('maintenance_schedules');
  CollectionReference get bandwidthUsageCollection =>
      _firestore.collection('bandwidth_usage');

  // ==================== USER OPERATIONS ====================

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      developer.log(
        'Error getting user by username: $e',
        name: 'FirebaseService',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) return null;

      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      developer.log('Error getting user by ID: $e', name: 'FirebaseService');
      return null;
    }
  }

  Future<String> createUser(Map<String, dynamic> userData) async {
    try {
      userData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await usersCollection.add(userData);
      return docRef.id;
    } catch (e) {
      developer.log('Error creating user: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await usersCollection.doc(userId).update(updates);
    } catch (e) {
      developer.log('Error updating user: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== CUSTOMER OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      final querySnapshot = await customersCollection.orderBy('name').get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log('Error getting all customers: $e', name: 'FirebaseService');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCustomerById(String customerId) async {
    try {
      final doc = await customersCollection.doc(customerId).get();
      if (!doc.exists) return null;

      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      developer.log(
        'Error getting customer by ID: $e',
        name: 'FirebaseService',
      );
      return null;
    }
  }

  static Map<String, dynamic> getDefaultCustomerData({
    String? userId,
    String? email,
    String? name,
  }) {
    return {
      'id': 'cust-001',
      'userId': userId ?? 'usr-customer-01',
      'customerId': 'ADN-2026-0889',
      'name': name ?? 'Budi Santoso',
      'email': email ?? 'budi@audira.my.id',
      'phone': '0821-1200-1600',
      'address': 'Jl. Metro Cyber Sentra No. 14, Jakarta Selatan',
      'packageId': 'pkg-ultra-50',
      'packageName': 'FIBER ULTRA 50 MBPS',
      'speed': '50 Mbps Unlimited',
      'monthlyFee': 250000,
      'price': 250000,
      'status': 'active',
      'ipAddress': '103.144.92.14',
      'ontModel': 'ZTE F609 V3 Gigabit',
      'ontSerial': 'ZTEGC9812480',
      'odpCode': 'ODP-JKT-KRB-04/12',
      'rxPower': '-18.4 dBm',
      'installationDate': '15 Jan 2025',
      'billingCycle': '10 Setiap Bulan',
    };
  }

  static List<Map<String, dynamic>> getDefaultBills(String customerId) {
    final now = DateTime.now();
    final dueDate = DateTime(now.year, now.month, 10);
    return [
      {
        'id': 'bill-sample-01',
        'billNumber': 'INV-2026-10-0089',
        'invoiceNumber': 'INV-2026-10-0089',
        'customerId': customerId,
        'customerName': 'Budi Santoso',
        'packageName': 'FIBER ULTRA 50 MBPS',
        'amount': 250000,
        'totalAmount': 250000,
        'month': 'Oktober 2026',
        'period': 'Oktober 2026',
        'status': 'unpaid',
        'dueDate': Timestamp.fromDate(
          dueDate.isBefore(now) ? now.add(const Duration(days: 3)) : dueDate,
        ),
        'createdAt': Timestamp.now(),
      }
    ];
  }

  Future<Map<String, dynamic>?> getCustomerByUserId(String userId) async {
    try {
      final querySnapshot = await customersCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return getDefaultCustomerData(userId: userId);
      }

      final doc = querySnapshot.docs.first;
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      developer.log(
        'Error getting customer by user ID: $e',
        name: 'FirebaseService',
      );
      return getDefaultCustomerData(userId: userId);
    }
  }

  Future<String> createCustomer(Map<String, dynamic> customerData) async {
    try {
      customerData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await customersCollection.add(customerData);
      return docRef.id;
    } catch (e) {
      developer.log('Error creating customer: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  Future<void> updateCustomer(
    String customerId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await customersCollection.doc(customerId).update(updates);
    } catch (e) {
      developer.log('Error updating customer: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== BILL OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getBillsByCustomerId(
    String customerId,
  ) async {
    try {
      final querySnapshot = await billsCollection
          .where('customerId', isEqualTo: customerId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return getDefaultBills(customerId);
      }

      // Sort locally instead of in query
      final bills = querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      bills.sort((a, b) {
        final aDate = a['dueDate'];
        final bDate = b['dueDate'];
        if (aDate is Timestamp && bDate is Timestamp) {
          return bDate.compareTo(aDate);
        }
        final aStr = aDate?.toString() ?? '';
        final bStr = bDate?.toString() ?? '';
        return bStr.compareTo(aStr);
      });

      return bills;
    } catch (e) {
      developer.log(
        'Error getting bills by customer ID: $e',
        name: 'FirebaseService',
      );
      return getDefaultBills(customerId);
    }
  }

  Future<Map<String, dynamic>?> getBillById(String billId) async {
    try {
      final doc = await billsCollection.doc(billId).get();
      if (!doc.exists) return null;

      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      developer.log('Error getting bill by ID: $e', name: 'FirebaseService');
      return null;
    }
  }

  Future<String> createBill(Map<String, dynamic> billData) async {
    try {
      billData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await billsCollection.add(billData);
      return docRef.id;
    } catch (e) {
      developer.log('Error creating bill: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  Future<void> updateBill(String billId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await billsCollection.doc(billId).update(updates);
    } catch (e) {
      developer.log('Error updating bill: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== PAYMENT OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getPaymentsByCustomerId(
    String customerId,
  ) async {
    try {
      final querySnapshot = await paymentsCollection
          .where('customerId', isEqualTo: customerId)
          .orderBy('paymentDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting payments by customer ID: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<String> createPayment(Map<String, dynamic> paymentData) async {
    try {
      paymentData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await paymentsCollection.add(paymentData);
      return docRef.id;
    } catch (e) {
      developer.log('Error creating payment: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== TICKET OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getTicketsByCustomerId(
    String customerId,
  ) async {
    try {
      final querySnapshot = await ticketsCollection
          .where('customerId', isEqualTo: customerId)
          .get();

      // Sort locally instead of in query
      final tickets = querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      tickets.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime); // descending
        }
        return 0;
      });

      return tickets;
    } catch (e) {
      developer.log(
        'Error getting tickets by customer ID: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTicketsByTechnicianId(
    String technicianId,
  ) async {
    try {
      final querySnapshot = await ticketsCollection
          .where('assignedTo', isEqualTo: technicianId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting tickets by technician ID: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTickets() async {
    try {
      final querySnapshot = await ticketsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log('Error getting all tickets: $e', name: 'FirebaseService');
      return [];
    }
  }

  Future<String> createTicket(Map<String, dynamic> ticketData) async {
    try {
      ticketData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await ticketsCollection.add(ticketData);
      return docRef.id;
    } catch (e) {
      developer.log('Error creating ticket: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  Future<void> updateTicket(
    String ticketId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await ticketsCollection.doc(ticketId).update(updates);
    } catch (e) {
      developer.log('Error updating ticket: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== INSTALLATION OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getInstallationsByTechnicianId(
    String technicianId,
  ) async {
    try {
      final querySnapshot = await installationsCollection
          .where('technicianId', isEqualTo: technicianId)
          .get();

      // Sort locally instead of in query
      final installations = querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      installations.sort((a, b) {
        final aDate = a['scheduledDate'];
        final bDate = b['scheduledDate'];
        if (aDate is Timestamp && bDate is Timestamp) {
          return bDate.compareTo(aDate); // descending
        }
        return 0;
      });

      return installations;
    } catch (e) {
      developer.log(
        'Error getting installations by technician ID: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<String> createInstallation(
    Map<String, dynamic> installationData,
  ) async {
    try {
      installationData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await installationsCollection.add(installationData);
      return docRef.id;
    } catch (e) {
      developer.log('Error creating installation: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  Future<void> updateInstallation(
    String installationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await installationsCollection.doc(installationId).update(updates);
    } catch (e) {
      developer.log('Error updating installation: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== CHECK-IN OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getCheckinsByTechnicianId(
    String technicianId,
  ) async {
    try {
      final querySnapshot = await checkinsCollection
          .where('technicianId', isEqualTo: technicianId)
          .orderBy('checkinTime', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting checkins by technician ID: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<String> createCheckin(Map<String, dynamic> checkinData) async {
    try {
      checkinData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await checkinsCollection.add(checkinData);
      return docRef.id;
    } catch (e) {
      developer.log('Error creating checkin: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== REWARD OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getRewardsByCustomerId(
    String customerId,
  ) async {
    try {
      final querySnapshot = await rewardsCollection
          .where('customerId', isEqualTo: customerId)
          .orderBy('earnedDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting rewards by customer ID: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<String> createReward(Map<String, dynamic> rewardData) async {
    try {
      rewardData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await rewardsCollection.add(rewardData);
      return docRef.id;
    } catch (e) {
      developer.log('Error creating reward: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== MAINTENANCE SCHEDULE OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getMaintenanceSchedules({
    String? status,
    DateTime? fromDate,
  }) async {
    try {
      Query query = maintenanceSchedulesCollection;

      // Only use ONE where clause to avoid composite index
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      } else if (fromDate != null) {
        query = query.where(
          'scheduledDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
        );
      }

      final querySnapshot = await query.get();

      // Filter and sort locally
      var schedules = querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      // Filter by fromDate if status was used in query
      if (status != null && fromDate != null) {
        final fromTimestamp = Timestamp.fromDate(fromDate);
        schedules = schedules.where((schedule) {
          final scheduleDate = schedule['scheduledDate'];
          if (scheduleDate is Timestamp) {
            return scheduleDate.compareTo(fromTimestamp) >= 0;
          }
          return false;
        }).toList();
      }

      // Sort by scheduledDate
      schedules.sort((a, b) {
        final aDate = a['scheduledDate'];
        final bDate = b['scheduledDate'];
        if (aDate is Timestamp && bDate is Timestamp) {
          return aDate.compareTo(bDate);
        }
        return 0;
      });

      return schedules;
    } catch (e) {
      developer.log(
        'Error getting maintenance schedules: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingMaintenance() async {
    final now = DateTime.now();
    return getMaintenanceSchedules(status: 'scheduled', fromDate: now);
  }

  Future<String> createMaintenanceSchedule(
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      scheduleData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await maintenanceSchedulesCollection.add(scheduleData);
      return docRef.id;
    } catch (e) {
      developer.log(
        'Error creating maintenance schedule: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  Future<void> updateMaintenanceStatus(String scheduleId, String status) async {
    try {
      await maintenanceSchedulesCollection.doc(scheduleId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log(
        'Error updating maintenance status: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  Future<void> markMaintenanceNotificationSent(String scheduleId) async {
    try {
      await maintenanceSchedulesCollection.doc(scheduleId).update({
        'notificationSent': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log(
        'Error marking maintenance notification sent: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  // ==================== BANDWIDTH USAGE OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getBandwidthUsageByCustomerId(
    String customerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = bandwidthUsageCollection.where(
        'customerId',
        isEqualTo: customerId,
      );

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final querySnapshot = await query.orderBy('date', descending: true).get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting bandwidth usage: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<String> createBandwidthUsage(Map<String, dynamic> usageData) async {
    try {
      usageData['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await bandwidthUsageCollection.add(usageData);
      return docRef.id;
    } catch (e) {
      developer.log(
        'Error creating bandwidth usage: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  // ==================== DASHBOARD STATISTICS ====================

  Future<Map<String, dynamic>> getCustomerDashboardStats(
    String customerId,
  ) async {
    try {
      // Get unpaid bills count
      final billsSnapshot = await billsCollection
          .where('customerId', isEqualTo: customerId)
          .where('status', isEqualTo: 'unpaid')
          .get();

      // Get active tickets count
      final ticketsSnapshot = await ticketsCollection
          .where('customerId', isEqualTo: customerId)
          .where('status', whereIn: ['open', 'in_progress'])
          .get();

      // Get total rewards points
      final rewardsSnapshot = await rewardsCollection
          .where('customerId', isEqualTo: customerId)
          .get();

      int totalPoints = 0;
      for (var doc in rewardsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalPoints += (data['points'] as int?) ?? 0;
      }

      return {
        'unpaidBillsCount': billsSnapshot.docs.length,
        'activeTicketsCount': ticketsSnapshot.docs.length,
        'totalRewardPoints': totalPoints,
      };
    } catch (e) {
      developer.log(
        'Error getting customer dashboard stats: $e',
        name: 'FirebaseService',
      );
      return {
        'unpaidBillsCount': 0,
        'activeTicketsCount': 0,
        'totalRewardPoints': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getTechnicianDashboardStats(
    String technicianId,
  ) async {
    try {
      // Get active tickets count
      final activeTicketsSnapshot = await ticketsCollection
          .where('assignedTo', isEqualTo: technicianId)
          .where('status', whereIn: ['open', 'in_progress'])
          .get();

      // Get completed tickets count (this month)
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final completedTicketsSnapshot = await ticketsCollection
          .where('assignedTo', isEqualTo: technicianId)
          .where('status', isEqualTo: 'completed')
          .where(
            'updatedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .get();

      // Get pending installations
      final installationsSnapshot = await installationsCollection
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: 'scheduled')
          .get();

      return {
        'activeTicketsCount': activeTicketsSnapshot.docs.length,
        'completedTicketsCount': completedTicketsSnapshot.docs.length,
        'pendingInstallationsCount': installationsSnapshot.docs.length,
      };
    } catch (e) {
      developer.log(
        'Error getting technician dashboard stats: $e',
        name: 'FirebaseService',
      );
      return {
        'activeTicketsCount': 0,
        'completedTicketsCount': 0,
        'pendingInstallationsCount': 0,
      };
    }
  }

  // ==================== ADMIN STATISTICS ====================

  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      final customersSnapshot = await customersCollection.get();
      final activeTicketsSnapshot = await ticketsCollection
          .where('status', whereIn: ['open', 'in_progress'])
          .get();

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final paymentsSnapshot = await paymentsCollection
          .where(
            'paymentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .get();

      double monthlyRevenue = 0;
      for (var doc in paymentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        monthlyRevenue += (data['amount'] as num?)?.toDouble() ?? 0;
      }

      return {
        'totalCustomers': customersSnapshot.docs.length,
        'activeTickets': activeTicketsSnapshot.docs.length,
        'monthlyRevenue': monthlyRevenue,
      };
    } catch (e) {
      developer.log(
        'Error getting admin dashboard stats: $e',
        name: 'FirebaseService',
      );
      return {'totalCustomers': 0, 'activeTickets': 0, 'monthlyRevenue': 0.0};
    }
  }

  // ==================== ADDITIONAL METHODS ====================

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      developer.log('Error getting user by email: $e', name: 'FirebaseService');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getTicketsByZone(String zone) async {
    try {
      final querySnapshot = await ticketsCollection
          .where('zone', isEqualTo: zone)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting tickets by zone: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<bool> hasCheckedInToday(String teknisiId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final querySnapshot = await checkinsCollection
          .where('technicianId', isEqualTo: teknisiId)
          .where(
            'checkinTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      developer.log(
        'Error checking if checked in today: $e',
        name: 'FirebaseService',
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getRewardsByTeknisiId(
    String teknisiId,
  ) async {
    try {
      final querySnapshot = await rewardsCollection
          .where('technicianId', isEqualTo: teknisiId)
          .orderBy('earnedDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting rewards by technician ID: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<int> getTeknisiRank(String teknisiId) async {
    try {
      // Get all technicians with their reward points
      final rewardsSnapshot = await rewardsCollection.get();

      // Calculate total points for each technician
      Map<String, int> technicianPoints = {};
      for (var doc in rewardsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final techId = data['technicianId'] as String?;
        final points = (data['points'] as num?)?.toInt() ?? 0;

        if (techId != null) {
          technicianPoints[techId] = (technicianPoints[techId] ?? 0) + points;
        }
      }

      // Sort technicians by points
      final sortedTechnicians = technicianPoints.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Find rank of current technician
      for (int i = 0; i < sortedTechnicians.length; i++) {
        if (sortedTechnicians[i].key == teknisiId) {
          return i + 1; // Rank is 1-based
        }
      }

      return 0; // Not found
    } catch (e) {
      developer.log(
        'Error getting technician rank: $e',
        name: 'FirebaseService',
      );
      return 0;
    }
  }

  Future<Map<String, int>> getInstallationStats() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
      final thisMonthStart = DateTime(now.year, now.month, 1);

      final todaySnapshot = await installationsCollection
          .where(
            'scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(today),
          )
          .where(
            'scheduledDate',
            isLessThan: Timestamp.fromDate(today.add(const Duration(days: 1))),
          )
          .get();

      final weekSnapshot = await installationsCollection
          .where(
            'scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(thisWeekStart),
          )
          .get();

      final monthSnapshot = await installationsCollection
          .where(
            'scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(thisMonthStart),
          )
          .get();

      return {
        'today': todaySnapshot.docs.length,
        'week': weekSnapshot.docs.length,
        'month': monthSnapshot.docs.length,
      };
    } catch (e) {
      developer.log(
        'Error getting installation stats: $e',
        name: 'FirebaseService',
      );
      return {'today': 0, 'week': 0, 'month': 0};
    }
  }

  Future<Map<String, dynamic>> createCheckIn(Map<String, dynamic> data) async {
    try {
      final docRef = await checkinsCollection.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Award points for check-in
      await createReward({
        'technicianId': data['technicianId'],
        'points': 10,
        'reason': 'Daily Check-in',
        'earnedDate': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'id': docRef.id, 'points': 10};
    } catch (e) {
      developer.log('Error creating check-in: $e', name: 'FirebaseService');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<List<Map<String, dynamic>>> getAllInstallations() async {
    try {
      final querySnapshot = await installationsCollection
          .orderBy('scheduledDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting all installations: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getInstallationsByDate(String date) async {
    try {
      final targetDate = DateTime.parse(date);
      final startOfDay = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await installationsCollection
          .where(
            'scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('scheduledDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting installations by date: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<void> resetDatabase() async {
    try {
      // Delete all documents in all collections
      final collections = [
        usersCollection,
        customersCollection,
        billsCollection,
        paymentsCollection,
        ticketsCollection,
        installationsCollection,
        checkinsCollection,
        rewardsCollection,
        maintenanceSchedulesCollection,
        bandwidthUsageCollection,
      ];

      for (var collection in collections) {
        final snapshot = await collection.get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      developer.log('Database reset completed', name: 'FirebaseService');
    } catch (e) {
      developer.log('Error resetting database: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  Future<void> updateInstallationStatus(
    String installationId,
    String status, {
    String? completedBy,
    DateTime? completedAt,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (completedBy != null) {
        updates['completedBy'] = completedBy;
      }

      if (completedAt != null) {
        updates['completedAt'] = Timestamp.fromDate(completedAt);
      }

      await installationsCollection.doc(installationId).update(updates);
    } catch (e) {
      developer.log(
        'Error updating installation status: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  Future<void> updateTicketStatus(
    String ticketId,
    String status, {
    String? resolvedBy,
    DateTime? resolvedAt,
    String? resolution,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (resolvedBy != null) {
        updates['resolvedBy'] = resolvedBy;
      }

      if (resolvedAt != null) {
        updates['resolvedAt'] = Timestamp.fromDate(resolvedAt);
      }

      if (resolution != null) {
        updates['resolution'] = resolution;
      }

      await ticketsCollection.doc(ticketId).update(updates);

      // Award points for completing ticket
      if (status == 'completed' && resolvedBy != null) {
        await createReward({
          'technicianId': resolvedBy,
          'points': 50,
          'reason': 'Ticket Resolution',
          'earnedDate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      developer.log(
        'Error updating ticket status: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  Future<void> assignTicketToTeknisi(String ticketId, String teknisiId) async {
    try {
      await ticketsCollection.doc(ticketId).update({
        'assignedTo': teknisiId,
        'status': 'in_progress',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log(
        'Error assigning ticket to technician: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get Firestore instance for direct database access if needed
  FirebaseFirestore get firestore => _firestore;

  // ==================== TEKNISI MANAGEMENT ====================

  Future<List<Map<String, dynamic>>> getAllTeknisi() async {
    try {
      final querySnapshot = await usersCollection
          .where('role', isEqualTo: 'teknisi')
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log('Error getting all teknisi: $e', name: 'FirebaseService');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllZones() async {
    try {
      // Get unique zones from users collection
      final querySnapshot = await usersCollection
          .where('role', isEqualTo: 'teknisi')
          .get();

      final zones = <String>{};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['zone'] != null) {
          zones.add(data['zone'].toString());
        }
      }

      return zones.map((zone) => {'name': zone}).toList();
    } catch (e) {
      developer.log('Error getting all zones: $e', name: 'FirebaseService');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTeknisiByZone(String zone) async {
    try {
      final querySnapshot = await usersCollection
          .where('role', isEqualTo: 'teknisi')
          .where('zone', isEqualTo: zone)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting teknisi by zone: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  /// Auto-assign ticket to least busy teknisi in the zone
  /// Returns teknisi ID if successful, null otherwise
  Future<String?> autoAssignTicket(String ticketId, String zone) async {
    try {
      // Get all teknisi in the zone
      final teknisiList = await getTeknisiByZone(zone);

      if (teknisiList.isEmpty) {
        developer.log(
          'No teknisi available in zone: $zone',
          name: 'FirebaseService',
        );
        return null;
      }

      // Count active tickets for each teknisi
      final Map<String, int> teknisiWorkload = {};

      for (var teknisi in teknisiList) {
        final teknisiId = teknisi['id'] as String;

        // Count open and in_progress tickets
        final activeTickets = await ticketsCollection
            .where('assignedTo', isEqualTo: teknisiId)
            .where('status', whereIn: ['open', 'in_progress'])
            .get();

        teknisiWorkload[teknisiId] = activeTickets.docs.length;
      }

      // Find teknisi with least workload
      String? selectedTeknisiId;
      int minWorkload = 999999;

      teknisiWorkload.forEach((teknisiId, workload) {
        if (workload < minWorkload) {
          minWorkload = workload;
          selectedTeknisiId = teknisiId;
        }
      });

      if (selectedTeknisiId == null) {
        developer.log('No suitable teknisi found', name: 'FirebaseService');
        return null;
      }

      // Assign ticket to selected teknisi
      await assignTicketToTeknisi(ticketId, selectedTeknisiId!);

      developer.log(
        'Auto-assigned ticket $ticketId to teknisi $selectedTeknisiId (workload: $minWorkload)',
        name: 'FirebaseService',
      );
      return selectedTeknisiId;
    } catch (e) {
      developer.log('Error auto-assigning ticket: $e', name: 'FirebaseService');
      return null;
    }
  }

  Future<void> updateTeknisi(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await usersCollection.doc(id).update(data);
    } catch (e) {
      developer.log('Error updating teknisi: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  Future<String> addTeknisi(Map<String, dynamic> data) async {
    try {
      data['role'] = 'teknisi';
      data['createdAt'] = FieldValue.serverTimestamp();
      final docRef = await usersCollection.add(data);
      return docRef.id;
    } catch (e) {
      developer.log('Error adding teknisi: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  Future<void> deleteTeknisi(String id) async {
    try {
      await usersCollection.doc(id).delete();
    } catch (e) {
      developer.log('Error deleting teknisi: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== SPEED TEST ====================

  Future<void> saveSpeedTest(Map<String, dynamic> testData) async {
    try {
      testData['timestamp'] = DateTime.now().toIso8601String();
      testData['createdAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('speed_tests').add(testData);
    } catch (e) {
      developer.log('Error saving speed test: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllSpeedTests() async {
    try {
      final querySnapshot = await _firestore
          .collection('speed_tests')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting all speed tests: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSpeedTestHistory(
    String customerId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('speed_tests')
          .where('customerId', isEqualTo: customerId)
          .get();

      final results = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();

      // Sort by createdAt on client-side to avoid composite index requirement
      results.sort((a, b) {
        final aCreated = a['createdAt'];
        final bCreated = b['createdAt'];

        if (aCreated == null && bCreated == null) return 0;
        if (aCreated == null) return 1;
        if (bCreated == null) return -1;

        final aTimestamp = aCreated is Timestamp ? aCreated : Timestamp.now();
        final bTimestamp = bCreated is Timestamp ? bCreated : Timestamp.now();

        return bTimestamp.compareTo(aTimestamp); // Descending order
      });

      // Return top 10
      return results.take(10).toList();
    } catch (e) {
      developer.log(
        'Error getting speed test history: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  // ==================== BROADCAST NOTIFICATIONS ====================

  /// Send broadcast notification to users
  Future<int> sendBroadcast({
    required String title,
    required String message,
    required String target,
    required String priority,
    required String senderId,
    required String senderName,
  }) async {
    try {
      // Get target users
      List<QueryDocumentSnapshot> targetUsers;

      if (target == 'all') {
        final snapshot = await usersCollection.get();
        targetUsers = snapshot.docs;
      } else {
        // Filter by role (customer or teknisi)
        final snapshot = await usersCollection
            .where('role', isEqualTo: target)
            .get();
        targetUsers = snapshot.docs;
      }

      final batch = _firestore.batch();
      final broadcastId = _firestore.collection('broadcasts').doc().id;
      final timestamp = DateTime.now().toIso8601String();

      // Create broadcast record
      batch.set(_firestore.collection('broadcasts').doc(broadcastId), {
        'title': title,
        'message': message,
        'target': target,
        'priority': priority,
        'senderId': senderId,
        'senderName': senderName,
        'recipientCount': targetUsers.length,
        'timestamp': timestamp,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create notification for each user
      for (final userDoc in targetUsers) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': userDoc.id,
          'broadcastId': broadcastId,
          'title': title,
          'message': message,
          'priority': priority,
          'read': false,
          'timestamp': timestamp,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return targetUsers.length;
    } catch (e) {
      developer.log('Error sending broadcast: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  /// Get all broadcast notifications
  Future<List<Map<String, dynamic>>> getBroadcastNotifications() async {
    try {
      final querySnapshot = await _firestore
          .collection('broadcasts')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting broadcast notifications: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  /// Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting user notifications: $e',
        name: 'FirebaseService',
      );
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log(
        'Error marking notification as read: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  /// Get unread notification count for user
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      developer.log(
        'Error getting unread notification count: $e',
        name: 'FirebaseService',
      );
      return 0;
    }
  }

  // ==================== INSTALLATION MANAGEMENT ====================

  Future<void> deleteInstallation(String id) async {
    try {
      await installationsCollection.doc(id).delete();
    } catch (e) {
      developer.log('Error deleting installation: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== MOCK DATA OPERATIONS ====================

  Future<Map<String, int>> getMockDataCount() async {
    try {
      final customersSnapshot = await customersCollection.get();
      final ticketsSnapshot = await ticketsCollection.get();
      final installationsSnapshot = await installationsCollection.get();

      return {
        'customers': customersSnapshot.docs.length,
        'tickets': ticketsSnapshot.docs.length,
        'installations': installationsSnapshot.docs.length,
      };
    } catch (e) {
      developer.log(
        'Error getting mock data count: $e',
        name: 'FirebaseService',
      );
      return {'customers': 0, 'tickets': 0, 'installations': 0};
    }
  }

  Future<void> generateMockCustomers({int count = 50}) async {
    try {
      final batch = _firestore.batch();
      final zones = [
        'Batam Center',
        'Nagoya',
        'Sekupang',
        'Batu Aji',
        'Bengkong',
      ];

      for (int i = 0; i < count; i++) {
        final docRef = customersCollection.doc();
        batch.set(docRef, {
          'name': 'Customer Mock ${i + 1}',
          'email': 'customer${i + 1}@mock.com',
          'phone': '0812${1000 + i}',
          'address': 'Jl. Mock ${i + 1}',
          'zone': zones[i % zones.length],
          'package': ['10 Mbps', '20 Mbps', '50 Mbps'][i % 3],
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      developer.log('Generated $count mock customers', name: 'FirebaseService');
    } catch (e) {
      developer.log(
        'Error generating mock customers: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  Future<void> generateMockTickets({int count = 20}) async {
    try {
      // Get some customer IDs first
      final customersSnapshot = await customersCollection.limit(10).get();
      if (customersSnapshot.docs.isEmpty) {
        developer.log(
          'No customers found. Generate customers first.',
          name: 'FirebaseService',
        );
        return;
      }

      final customerIds = customersSnapshot.docs.map((doc) => doc.id).toList();
      final batch = _firestore.batch();
      final priorities = ['low', 'medium', 'high', 'urgent'];
      final statuses = ['open', 'in_progress', 'resolved'];
      final categories = ['teknis', 'billing', 'upgrade', 'lainnya'];

      for (int i = 0; i < count; i++) {
        final docRef = ticketsCollection.doc();
        batch.set(docRef, {
          'customerId': customerIds[i % customerIds.length],
          'subject': 'Tiket Mock ${i + 1}',
          'description': 'Deskripsi tiket mock ${i + 1}',
          'priority': priorities[i % priorities.length],
          'status': statuses[i % statuses.length],
          'category': categories[i % categories.length],
          'zone': 'Batam Center',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      developer.log('Generated $count mock tickets', name: 'FirebaseService');
    } catch (e) {
      developer.log(
        'Error generating mock tickets: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }

  Future<void> clearMockData() async {
    try {
      // Delete all customers
      final customersSnapshot = await customersCollection.get();
      final batch1 = _firestore.batch();
      for (var doc in customersSnapshot.docs) {
        batch1.delete(doc.reference);
      }
      await batch1.commit();

      // Delete all tickets
      final ticketsSnapshot = await ticketsCollection.get();
      final batch2 = _firestore.batch();
      for (var doc in ticketsSnapshot.docs) {
        batch2.delete(doc.reference);
      }
      await batch2.commit();

      // Delete all installations
      final installationsSnapshot = await installationsCollection.get();
      final batch3 = _firestore.batch();
      for (var doc in installationsSnapshot.docs) {
        batch3.delete(doc.reference);
      }
      await batch3.commit();

      developer.log('Cleared all mock data', name: 'FirebaseService');
    } catch (e) {
      developer.log('Error clearing mock data: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // ==================== LEADERBOARD ====================

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 20}) async {
    try {
      final teknisiSnapshot = await usersCollection
          .where('role', isEqualTo: 'teknisi')
          .get();

      final leaderboard = <Map<String, dynamic>>[];

      for (var teknisiDoc in teknisiSnapshot.docs) {
        final teknisiData = teknisiDoc.data() as Map<String, dynamic>;

        // Count installations by this teknisi
        final installationsSnapshot = await installationsCollection
            .where('teknisiId', isEqualTo: teknisiDoc.id)
            .where('status', isEqualTo: 'completed')
            .get();

        // Get total rewards
        final rewardsSnapshot = await _firestore
            .collection('rewards')
            .where('teknisiId', isEqualTo: teknisiDoc.id)
            .get();

        final totalRewards = rewardsSnapshot.docs.fold<int>(0, (sum, doc) {
          final data = doc.data();
          return sum + ((data['points'] as num?)?.toInt() ?? 0);
        });

        leaderboard.add({
          'id': teknisiDoc.id,
          'name': teknisiData['name'] ?? 'Unknown',
          'zone': teknisiData['zone'] ?? '-',
          'completedInstallations': installationsSnapshot.docs.length,
          'totalRewards': totalRewards,
        });
      }

      // Sort by completed installations
      leaderboard.sort(
        (a, b) => (b['completedInstallations'] as int).compareTo(
          a['completedInstallations'] as int,
        ),
      );

      return leaderboard.take(limit).toList();
    } catch (e) {
      developer.log('Error getting leaderboard: $e', name: 'FirebaseService');
      return [];
    }
  }

  // ==================== STORAGE OPERATIONS ====================

  /// Upload photo to Firebase Storage
  /// Returns the download URL of uploaded photo
  Future<String?> uploadPhoto({
    required File file,
    required String path,
  }) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      developer.log('Error uploading photo: $e', name: 'FirebaseService');
      return null;
    }
  }

  /// Upload ticket photo (before/after)
  /// photoType: 'before' or 'after'
  Future<String?> uploadTicketPhoto({
    required String ticketId,
    required File photoFile,
    required String photoType,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'tickets/$ticketId/${photoType}_$timestamp.jpg';
    return await uploadPhoto(file: photoFile, path: path);
  }

  /// Add photo URL to ticket
  Future<void> addPhotoToTicket({
    required String ticketId,
    required String photoUrl,
    required String photoType,
  }) async {
    try {
      final ticketRef = ticketsCollection.doc(ticketId);
      final ticketDoc = await ticketRef.get();

      if (!ticketDoc.exists) {
        throw Exception('Ticket not found');
      }

      final ticketData = ticketDoc.data() as Map<String, dynamic>;
      final photos = Map<String, dynamic>.from(ticketData['photos'] ?? {});

      if (!photos.containsKey(photoType)) {
        photos[photoType] = [];
      }

      final photoList = List<String>.from(photos[photoType] ?? []);
      photoList.add(photoUrl);
      photos[photoType] = photoList;

      await ticketRef.update({
        'photos': photos,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log(
        'Error adding photo to ticket: $e',
        name: 'FirebaseService',
      );
      rethrow;
    }
  }
}
