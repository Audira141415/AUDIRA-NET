import 'package:cloud_firestore/cloud_firestore.dart';
import 'backend_api_service.dart';
import 'logger_service.dart';

/// Hybrid Billing Service
/// Uses Backend API when available, falls back to Firebase when offline
class HybridBillingService {
  static final HybridBillingService instance = HybridBillingService._init();
  HybridBillingService._init();

  final BackendApiService _backendApi = BackendApiService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _useBackend = true; // Try backend first
  bool _backendAvailable = false;

  /// Check backend availability
  Future<bool> checkBackendAvailability() async {
    _backendAvailable = await _backendApi.checkHealth();
    LoggerService.info('🔌 Backend available: $_backendAvailable');
    return _backendAvailable;
  }

  /// Get customers with automatic fallback
  Future<List<Map<String, dynamic>>> getCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) async {
    if (_useBackend && await checkBackendAvailability()) {
      try {
        LoggerService.info('📡 Fetching customers from Backend API...');
        final response = await _backendApi.getCustomers(
          page: page,
          limit: limit,
          search: search,
          status: status,
        );

        if (response['success'] == true) {
          final data = response['data'];
          if (data is Map && data.containsKey('customers')) {
            return List<Map<String, dynamic>>.from(data['customers']);
          }
        }
      } catch (e) {
        LoggerService.warning(
          '⚠️ Backend API failed, falling back to Firebase: $e',
        );
      }
    }

    // Fallback to Firebase
    LoggerService.info('🔥 Fetching customers from Firebase...');
    return await _getCustomersFromFirebase(search: search, status: status);
  }

  Future<List<Map<String, dynamic>>> _getCustomersFromFirebase({
    String? search,
    String? status,
  }) async {
    try {
      Query query = _firestore.collection('customers');

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      LoggerService.error('❌ Firebase query error: $e');
      return [];
    }
  }

  /// Get customer by ID with automatic fallback
  Future<Map<String, dynamic>?> getCustomerById(String id) async {
    if (_useBackend && await checkBackendAvailability()) {
      try {
        LoggerService.info('📡 Fetching customer $id from Backend API...');
        final response = await _backendApi.getCustomerById(id);

        if (response['success'] == true) {
          return response['data'] as Map<String, dynamic>?;
        }
      } catch (e) {
        LoggerService.warning(
          '⚠️ Backend API failed, falling back to Firebase: $e',
        );
      }
    }

    // Fallback to Firebase
    LoggerService.info('🔥 Fetching customer $id from Firebase...');
    try {
      final doc = await _firestore.collection('customers').doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
    } catch (e) {
      LoggerService.error('❌ Firebase query error: $e');
    }

    return null;
  }

  /// Get invoices with automatic fallback
  Future<List<Map<String, dynamic>>> getInvoices({
    int page = 1,
    int limit = 10,
    String? status,
    String? customerId,
  }) async {
    if (_useBackend && await checkBackendAvailability()) {
      try {
        LoggerService.info('📡 Fetching invoices from Backend API...');
        final response = await _backendApi.getInvoices(
          page: page,
          limit: limit,
          status: status,
          customerId: customerId,
        );

        if (response['success'] == true) {
          final data = response['data'];
          if (data is Map && data.containsKey('invoices')) {
            return List<Map<String, dynamic>>.from(data['invoices']);
          } else if (data is List) {
            return List<Map<String, dynamic>>.from(data);
          }
        }
      } catch (e) {
        LoggerService.warning(
          '⚠️ Backend API failed, falling back to Firebase: $e',
        );
      }
    }

    // Fallback to Firebase
    LoggerService.info('🔥 Fetching invoices from Firebase...');
    return await _getInvoicesFromFirebase(
      status: status,
      customerId: customerId,
    );
  }

  Future<List<Map<String, dynamic>>> _getInvoicesFromFirebase({
    String? status,
    String? customerId,
  }) async {
    try {
      Query query = _firestore.collection('invoices');

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      if (customerId != null && customerId.isNotEmpty) {
        query = query.where('customerId', isEqualTo: customerId);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      LoggerService.error('❌ Firebase query error: $e');
      return [];
    }
  }

  /// Create payment with automatic fallback
  Future<Map<String, dynamic>> createPayment({
    required String invoiceId,
    required double amount,
    String? paymentMethod,
  }) async {
    if (_useBackend && await checkBackendAvailability()) {
      try {
        LoggerService.info('📡 Creating payment via Backend API...');
        final response = await _backendApi.createPayment(
          invoiceId: invoiceId,
          amount: amount,
          paymentMethod: paymentMethod,
        );

        if (response['success'] == true) {
          return response;
        }
      } catch (e) {
        LoggerService.warning(
          '⚠️ Backend API failed, falling back to Firebase: $e',
        );
      }
    }

    // Fallback to Firebase
    LoggerService.info('🔥 Creating payment in Firebase...');
    return await _createPaymentInFirebase(
      invoiceId: invoiceId,
      amount: amount,
      paymentMethod: paymentMethod,
    );
  }

  Future<Map<String, dynamic>> _createPaymentInFirebase({
    required String invoiceId,
    required double amount,
    String? paymentMethod,
  }) async {
    try {
      final paymentData = {
        'invoiceId': invoiceId,
        'amount': amount,
        'paymentMethod': paymentMethod ?? 'manual',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('payments').add(paymentData);

      return {
        'success': true,
        'data': {'id': docRef.id, ...paymentData},
      };
    } catch (e) {
      LoggerService.error('❌ Firebase payment creation error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get dashboard stats with automatic fallback
  Future<Map<String, dynamic>> getDashboardStats() async {
    if (_useBackend && await checkBackendAvailability()) {
      try {
        LoggerService.info('📡 Fetching dashboard stats from Backend API...');
        final response = await _backendApi.getDashboardStats();

        if (response['success'] == true) {
          return response['data'] as Map<String, dynamic>;
        }
      } catch (e) {
        LoggerService.warning(
          '⚠️ Backend API failed, falling back to Firebase: $e',
        );
      }
    }

    // Fallback to Firebase
    LoggerService.info('🔥 Calculating stats from Firebase...');
    return await _getDashboardStatsFromFirebase();
  }

  Future<Map<String, dynamic>> _getDashboardStatsFromFirebase() async {
    try {
      // Get counts from Firebase collections
      final customersSnapshot = await _firestore.collection('customers').get();
      final invoicesSnapshot = await _firestore.collection('invoices').get();
      final paymentsSnapshot = await _firestore
          .collection('payments')
          .where('status', isEqualTo: 'paid')
          .get();

      double totalRevenue = 0;
      for (final doc in paymentsSnapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['amount'] as num?)?.toDouble() ?? 0;
      }

      final pendingInvoices = invoicesSnapshot.docs
          .where((doc) => (doc.data()['status'] as String?) == 'pending')
          .length;

      return {
        'totalRevenue': totalRevenue,
        'activeCustomers': customersSnapshot.size,
        'pendingPayments': pendingInvoices,
        'todayRevenue': 0, // Would need time-based query
      };
    } catch (e) {
      LoggerService.error('❌ Firebase stats calculation error: $e');
      return {
        'totalRevenue': 0,
        'activeCustomers': 0,
        'pendingPayments': 0,
        'todayRevenue': 0,
      };
    }
  }

  /// Toggle between backend and Firebase mode
  void setUseBackend(bool useBackend) {
    _useBackend = useBackend;
    LoggerService.info(
      '🔄 Switched to ${useBackend ? "Backend API" : "Firebase"} mode',
    );
  }

  /// Get current data source
  String get dataSource =>
      _backendAvailable && _useBackend ? 'Backend API' : 'Firebase';
}
