class Billing {
  final String id;
  final String customerId;
  final String customerName;
  final int amount;
  final DateTime billingMonth;
  final DateTime dueDate;
  final DateTime? paidDate;
  final BillingStatus status;
  final String? paymentMethod;
  final String? transactionId;

  Billing({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.billingMonth,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.paymentMethod,
    this.transactionId,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      amount: json['amount'] as int,
      billingMonth: DateTime.parse(json['billingMonth'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
      status: BillingStatus.values.firstWhere(
        (e) => e.toString() == 'BillingStatus.${json['status']}',
      ),
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'billingMonth': billingMonth.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }

  bool get isOverdue {
    if (status == BillingStatus.paid) return false;
    return DateTime.now().isAfter(dueDate);
  }
}

enum BillingStatus { unpaid, paid, overdue, cancelled }
