import 'package:cloud_firestore/cloud_firestore.dart';

/// Payment transaction model
class Payment {
  final String id;
  final String customerId;
  final String customerName;
  final int amount;
  final String method; // e-wallet, va, qris, cash
  final String provider; // gopay, ovo, dana, bca, mandiri, etc
  final String status; // pending, success, failed, expired
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? referenceNumber;
  final String? invoiceUrl;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.method,
    required this.provider,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.referenceNumber,
    this.invoiceUrl,
    this.metadata,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      amount: data['amount'] ?? 0,
      method: data['method'] ?? '',
      provider: data['provider'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paidAt: data['paidAt'] != null
          ? (data['paidAt'] as Timestamp).toDate()
          : null,
      referenceNumber: data['referenceNumber'],
      invoiceUrl: data['invoiceUrl'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'method': method,
      'provider': provider,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'referenceNumber': referenceNumber,
      'invoiceUrl': invoiceUrl,
      'metadata': metadata,
    };
  }
}

/// Payment method configuration
class PaymentMethod {
  final String id;
  final String name;
  final String type; // e-wallet, bank_transfer, qris
  final String iconUrl;
  final bool isActive;
  final Map<String, dynamic>? config;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.iconUrl,
    this.isActive = true,
    this.config,
  });

  factory PaymentMethod.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentMethod(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      isActive: data['isActive'] ?? true,
      config: data['config'],
    );
  }
}
