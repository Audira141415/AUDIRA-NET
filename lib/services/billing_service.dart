import 'dart:async';
import '../utils/logger.dart';
import 'database_service.dart';

class BillingService {
  static final BillingService _instance = BillingService._internal();
  factory BillingService() => _instance;
  BillingService._internal();

  // Auto billing timer
  Timer? _autoBillingTimer;

  void startAutoBilling() {
    // Check every hour for billing generation
    _autoBillingTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkAndGenerateBills();
    });
  }

  void stopAutoBilling() {
    _autoBillingTimer?.cancel();
  }

  Future<void> _checkAndGenerateBills() async {
    try {
      final now = DateTime.now();

      // Generate bills on the 1st of each month
      if (now.day == 1 && now.hour == 0) {
        await generateMonthlyBills();
      }

      // Send reminders 7 days before due date
      await sendPaymentReminders();
    } catch (e) {
      // Auto billing error occurred
    }
  }

  Future<void> generateMonthlyBills() async {
    try {
      final db = await DatabaseService.instance.database;

      // Get all active customers
      final customers = await db.rawQuery('''
        SELECT c.*, u.name, u.email 
        FROM customers c 
        JOIN users u ON c.userId = u.id 
        WHERE c.status = 'active'
      ''');

      final now = DateTime.now();
      final billMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final dueDate = DateTime(now.year, now.month, 25); // Due on 25th

      for (final customer in customers) {
        // Check if bill already exists for this month
        final existingBill = await db.rawQuery(
          '''
          SELECT id FROM bills 
          WHERE customerId = ? AND billMonth = ?
        ''',
          [customer['id'], billMonth],
        );

        if (existingBill.isEmpty) {
          // Generate new bill
          await db.insert('bills', {
            'customerId': customer['id'],
            'billMonth': billMonth,
            'amount': customer['price'],
            'dueDate': dueDate.toIso8601String().split('T')[0],
            'status': 'unpaid',
            'createdAt': now.toIso8601String(),
          });
        }
      }

      // Bills generated successfully for ${customers.length} customers
    } catch (e) {
      // Generate bills error occurred
    }
  }

  Future<void> sendPaymentReminders() async {
    try {
      final db = await DatabaseService.instance.database;

      // Get bills due in 7 days
      final dueBills = await db.rawQuery('''
        SELECT b.*, c.*, u.name, u.email 
        FROM bills b
        JOIN customers c ON b.customerId = c.id
        JOIN users u ON c.userId = u.id
        WHERE b.dueDate = date('now', '+7 days')
        AND b.status = 'unpaid'
      ''');

      for (final bill in dueBills) {
        await _sendEmailReminder(bill);
        await _sendSMSReminder(bill);
      }

      Logger.debug('Payment reminders sent to ${dueBills.length} customers');
    } catch (e) {
      Logger.error('Send reminders error: $e');
    }
  }

  Future<void> _sendEmailReminder(Map<String, dynamic> bill) async {
    // Simulate email sending
    Logger.debug(
      '📧 Email reminder sent to ${bill['email']} for bill ${bill['billMonth']}',
    );
  }

  Future<void> _sendSMSReminder(Map<String, dynamic> bill) async {
    // Simulate SMS sending
    Logger.debug(
      '📱 SMS reminder sent for bill ${bill['billMonth']} amount: Rp ${_formatCurrency(bill['amount'])}',
    );
  }

  Future<Map<String, dynamic>> getPaymentAnalytics() async {
    try {
      final db = await DatabaseService.instance.database;

      // Total revenue this month
      final revenueResult = await db.rawQuery('''
        SELECT SUM(amount) as total FROM payments 
        WHERE strftime('%Y-%m', paidAt) = strftime('%Y-%m', 'now')
        AND paymentStatus = 'paid'
      ''');
      final monthlyRevenue = revenueResult.first['total'] as int? ?? 0;

      // Payment success rate
      final totalBillsResult = await db.rawQuery('''
        SELECT COUNT(*) as count FROM bills 
        WHERE strftime('%Y-%m', createdAt) = strftime('%Y-%m', 'now')
      ''');
      final totalBills = totalBillsResult.first['count'] as int? ?? 0;

      final paidBillsResult = await db.rawQuery('''
        SELECT COUNT(*) as count FROM bills 
        WHERE strftime('%Y-%m', createdAt) = strftime('%Y-%m', 'now')
        AND status = 'paid'
      ''');
      final paidBills = paidBillsResult.first['count'] as int? ?? 0;

      final successRate = totalBills > 0 ? (paidBills / totalBills * 100) : 0.0;

      // Outstanding amount
      final outstandingResult = await db.rawQuery('''
        SELECT SUM(amount) as total FROM bills 
        WHERE status = 'unpaid' AND dueDate < date('now')
      ''');
      final outstandingAmount = outstandingResult.first['total'] as int? ?? 0;

      // Payment methods distribution
      final paymentMethodsResult = await db.rawQuery('''
        SELECT paymentMethod, COUNT(*) as count FROM payments 
        WHERE strftime('%Y-%m', paidAt) = strftime('%Y-%m', 'now')
        GROUP BY paymentMethod
      ''');

      return {
        'monthlyRevenue': monthlyRevenue,
        'successRate': successRate,
        'outstandingAmount': outstandingAmount,
        'totalBills': totalBills,
        'paidBills': paidBills,
        'pendingBills': totalBills - paidBills,
        'paymentMethods': paymentMethodsResult,
      };
    } catch (e) {
      Logger.error('Payment analytics error: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getOutstandingReport() async {
    try {
      final db = await DatabaseService.instance.database;

      final outstanding = await db.rawQuery('''
        SELECT 
          b.*,
          c.customerId,
          c.internetNumber,
          u.name,
          u.email,
          u.phone,
          julianday('now') - julianday(b.dueDate) as daysPastDue
        FROM bills b
        JOIN customers c ON b.customerId = c.id
        JOIN users u ON c.userId = u.id
        WHERE b.status = 'unpaid' 
        AND b.dueDate < date('now')
        ORDER BY daysPastDue DESC
      ''');

      return outstanding;
    } catch (e) {
      Logger.error('Outstanding report error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getRevenueChart() async {
    try {
      final db = await DatabaseService.instance.database;

      // Last 12 months revenue
      final chartData = <String, int>{};

      for (int i = 11; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i * 30));
        final monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';

        final result = await db.rawQuery(
          '''
          SELECT SUM(amount) as total FROM payments 
          WHERE strftime('%Y-%m', paidAt) = ?
          AND paymentStatus = 'paid'
        ''',
          [monthKey],
        );

        final revenue = result.first['total'] as int? ?? 0;
        chartData[monthKey] = revenue;
      }

      return {
        'chartData': chartData,
        'maxValue': chartData.values.isEmpty
            ? 0
            : chartData.values.reduce((a, b) => a > b ? a : b),
      };
    } catch (e) {
      Logger.error('Revenue chart error: $e');
      return {'chartData': <String, int>{}, 'maxValue': 0};
    }
  }

  Future<void> applyPromotion({
    required String customerId,
    required String promoType,
    required double discountPercent,
    required DateTime validUntil,
  }) async {
    try {
      final db = await DatabaseService.instance.database;

      await db.insert('promotions', {
        'customerId': customerId,
        'promoType': promoType,
        'discountPercent': discountPercent,
        'validUntil': validUntil.toIso8601String(),
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
      });

      Logger.debug('Promotion applied: $promoType for customer $customerId');
    } catch (e) {
      Logger.error('Apply promotion error: $e');
    }
  }

  Future<void> createPaymentPlan({
    required String customerId,
    required String planName,
    required int monthlyAmount,
    required int durationMonths,
  }) async {
    try {
      final db = await DatabaseService.instance.database;

      await db.insert('payment_plans', {
        'customerId': customerId,
        'planName': planName,
        'monthlyAmount': monthlyAmount,
        'durationMonths': durationMonths,
        'remainingMonths': durationMonths,
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
      });

      Logger.debug('Payment plan created: $planName for customer $customerId');
    } catch (e) {
      Logger.error('Create payment plan error: $e');
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void dispose() {
    stopAutoBilling();
  }
}
