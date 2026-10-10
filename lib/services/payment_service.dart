import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import 'logger_service.dart';

/// Service for Payment Gateway operations
class PaymentService {
  static final PaymentService instance = PaymentService._internal();
  factory PaymentService() => instance;
  PaymentService._internal();

  final CollectionReference _paymentsCollection = FirebaseFirestore.instance
      .collection('payments');

  // ==================== PAYMENT METHODS ====================

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'gopay',
      'name': 'GoPay',
      'type': 'e-wallet',
      'icon': 'assets/payment/gopay.png',
      'minAmount': 10000,
    },
    {
      'id': 'ovo',
      'name': 'OVO',
      'type': 'e-wallet',
      'icon': 'assets/payment/ovo.png',
      'minAmount': 10000,
    },
    {
      'id': 'dana',
      'name': 'DANA',
      'type': 'e-wallet',
      'icon': 'assets/payment/dana.png',
      'minAmount': 10000,
    },
    {
      'id': 'shopeepay',
      'name': 'ShopeePay',
      'type': 'e-wallet',
      'icon': 'assets/payment/shopeepay.png',
      'minAmount': 10000,
    },
    {
      'id': 'bca_va',
      'name': 'BCA Virtual Account',
      'type': 'bank_transfer',
      'icon': 'assets/payment/bca.png',
      'minAmount': 10000,
    },
    {
      'id': 'mandiri_va',
      'name': 'Mandiri Virtual Account',
      'type': 'bank_transfer',
      'icon': 'assets/payment/mandiri.png',
      'minAmount': 10000,
    },
    {
      'id': 'bri_va',
      'name': 'BRI Virtual Account',
      'type': 'bank_transfer',
      'icon': 'assets/payment/bri.png',
      'minAmount': 10000,
    },
    {
      'id': 'qris',
      'name': 'QRIS (Semua e-wallet & m-banking)',
      'type': 'qris',
      'icon': 'assets/payment/qris.png',
      'minAmount': 1,
    },
  ];

  // ==================== CREATE PAYMENT ====================

  /// Create new payment transaction
  Future<Payment> createPayment({
    required String customerId,
    required String customerName,
    required int amount,
    required String method,
    required String provider,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final paymentData = {
        'customerId': customerId,
        'customerName': customerName,
        'amount': amount,
        'method': method,
        'provider': provider,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'referenceNumber': _generateReferenceNumber(),
        'metadata': metadata,
      };

      final docRef = await _paymentsCollection.add(paymentData);

      // Simulate payment gateway response (in production, call real API)
      final payment = Payment(
        id: docRef.id,
        customerId: customerId,
        customerName: customerName,
        amount: amount,
        method: method,
        provider: provider,
        status: 'pending',
        createdAt: DateTime.now(),
        referenceNumber: paymentData['referenceNumber'] as String,
      );

      LoggerService.info(
        'Payment created: ${docRef.id} - Rp $amount via $provider',
      );

      return payment;
    } catch (e) {
      LoggerService.error('Error creating payment: $e');
      rethrow;
    }
  }

  /// Generate unique reference number
  String _generateReferenceNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5);
    return 'ADN$timestamp';
  }

  // ==================== PAYMENT STATUS ====================

  /// Update payment status (called by webhook in production)
  Future<void> updatePaymentStatus(
    String paymentId,
    String status, {
    String? transactionId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == 'success') {
        updateData['paidAt'] = FieldValue.serverTimestamp();
        updateData['transactionId'] = transactionId;
      }

      await _paymentsCollection.doc(paymentId).update(updateData);

      LoggerService.info('Payment $paymentId status updated to: $status');
    } catch (e) {
      LoggerService.error('Error updating payment status: $e');
      rethrow;
    }
  }

  /// Simulate successful payment (for testing)
  Future<void> simulatePaymentSuccess(String paymentId) async {
    await Future.delayed(const Duration(seconds: 2));
    await updatePaymentStatus(
      paymentId,
      'success',
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // ==================== QUERY PAYMENTS ====================

  /// Get payment by ID
  Future<Payment?> getPaymentById(String paymentId) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (doc.exists) {
        return Payment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting payment: $e');
      return null;
    }
  }

  /// Get customer payment history
  Future<List<Payment>> getCustomerPayments(String customerId) async {
    try {
      final querySnapshot = await _paymentsCollection
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting customer payments: $e');
      return [];
    }
  }

  /// Get pending payments
  Future<List<Payment>> getPendingPayments(String customerId) async {
    try {
      final querySnapshot = await _paymentsCollection
          .where('customerId', isEqualTo: customerId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting pending payments: $e');
      return [];
    }
  }

  // ==================== INVOICE GENERATION ====================

  /// Generate invoice URL (mock - in production, generate PDF)
  Future<String> generateInvoice(String paymentId) async {
    try {
      final payment = await getPaymentById(paymentId);
      if (payment == null) throw Exception('Payment not found');

      // Mock invoice URL (in production, upload PDF to Firebase Storage)
      final invoiceUrl = 'https://audiranet.id/invoices/$paymentId.pdf';

      await _paymentsCollection.doc(paymentId).update({
        'invoiceUrl': invoiceUrl,
      });

      return invoiceUrl;
    } catch (e) {
      LoggerService.error('Error generating invoice: $e');
      rethrow;
    }
  }

  // ==================== STATISTICS ====================

  /// Get payment statistics
  Future<Map<String, dynamic>> getPaymentStats({
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _paymentsCollection;

      if (customerId != null) {
        query = query.where('customerId', isEqualTo: customerId);
      }

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final querySnapshot = await query.get();
      final payments = querySnapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();

      int totalAmount = 0;
      int successCount = 0;
      int pendingCount = 0;
      int failedCount = 0;

      for (var payment in payments) {
        if (payment.status == 'success') {
          totalAmount += payment.amount;
          successCount++;
        } else if (payment.status == 'pending') {
          pendingCount++;
        } else if (payment.status == 'failed') {
          failedCount++;
        }
      }

      return {
        'totalTransactions': payments.length,
        'totalAmount': totalAmount,
        'successCount': successCount,
        'pendingCount': pendingCount,
        'failedCount': failedCount,
        'successRate': payments.isEmpty
            ? 0.0
            : (successCount / payments.length) * 100,
      };
    } catch (e) {
      LoggerService.error('Error getting payment stats: $e');
      return {};
    }
  }
}
