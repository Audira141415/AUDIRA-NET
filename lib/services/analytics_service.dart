import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'firebase_service.dart';
import 'logger_service.dart';

/// Service for Analytics & Reporting
class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._internal();
  factory AnalyticsService() => instance;
  AnalyticsService._internal();

  // ==================== CUSTOMER USAGE ANALYTICS ====================

  /// Get customer's bandwidth usage statistics
  Future<Map<String, dynamic>> getCustomerUsageStats(
    String customerId, {
    int days = 30,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final usageSnapshot = await FirebaseService
          .instance
          .bandwidthUsageCollection
          .where('customerId', isEqualTo: customerId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: false)
          .get();

      final usageData = usageSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Calculate totals
      double totalDownload = 0;
      double totalUpload = 0;
      double avgSpeed = 0;
      int count = usageData.length;

      for (var usage in usageData) {
        totalDownload += (usage['downloadMB'] ?? 0.0) as double;
        totalUpload += (usage['uploadMB'] ?? 0.0) as double;
        avgSpeed += (usage['speedMbps'] ?? 0.0) as double;
      }

      avgSpeed = count > 0 ? avgSpeed / count : 0;

      // Daily breakdown
      final dailyUsage = <String, Map<String, double>>{};
      for (var usage in usageData) {
        final timestamp = (usage['timestamp'] as Timestamp).toDate();
        final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);

        if (!dailyUsage.containsKey(dateKey)) {
          dailyUsage[dateKey] = {'download': 0, 'upload': 0, 'count': 0};
        }

        dailyUsage[dateKey]!['download'] =
            (dailyUsage[dateKey]!['download']! + (usage['downloadMB'] ?? 0.0));
        dailyUsage[dateKey]!['upload'] =
            (dailyUsage[dateKey]!['upload']! + (usage['uploadMB'] ?? 0.0));
        dailyUsage[dateKey]!['count'] = dailyUsage[dateKey]!['count']! + 1;
      }

      // Peak hours analysis
      final hourlyUsage = <int, double>{};
      for (var usage in usageData) {
        final timestamp = (usage['timestamp'] as Timestamp).toDate();
        final hour = timestamp.hour;

        hourlyUsage[hour] =
            (hourlyUsage[hour] ?? 0) + (usage['downloadMB'] ?? 0.0);
      }

      final peakHour = hourlyUsage.entries.isEmpty
          ? 0
          : hourlyUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      return {
        'totalDownloadGB': totalDownload / 1024,
        'totalUploadGB': totalUpload / 1024,
        'totalUsageGB': (totalDownload + totalUpload) / 1024,
        'avgSpeedMbps': avgSpeed,
        'dataPointsCount': count,
        'dailyUsage': dailyUsage,
        'peakHour': peakHour,
        'hourlyDistribution': hourlyUsage,
      };
    } catch (e) {
      LoggerService.error('Error getting customer usage stats: $e');
      return {};
    }
  }

  /// Get package recommendation based on usage pattern
  Future<Map<String, dynamic>> getPackageRecommendation(
    String customerId,
  ) async {
    try {
      // Get customer's current package
      final customerSnapshot = await FirebaseService
          .instance
          .customersCollection
          .where('id', isEqualTo: customerId)
          .limit(1)
          .get();

      if (customerSnapshot.docs.isEmpty) return {};

      final customerData =
          customerSnapshot.docs.first.data() as Map<String, dynamic>;
      final currentSpeed = customerData['speed'] ?? 50;
      final currentPrice = customerData['monthlyFee'] ?? 350000;

      // Get usage stats for last 30 days
      final stats = await getCustomerUsageStats(customerId, days: 30);
      final avgSpeed = (stats['avgSpeedMbps'] ?? 0.0) as double;
      final totalUsageGB = (stats['totalUsageGB'] ?? 0.0) as double;

      // Calculate usage intensity
      final usagePerDay = totalUsageGB / 30;
      final speedUtilization = (avgSpeed / currentSpeed) * 100;

      String recommendation = 'current';
      String reason = '';
      int recommendedSpeed = currentSpeed;
      int recommendedPrice = currentPrice;

      // Recommendation logic
      if (speedUtilization > 80 && usagePerDay > 15) {
        // Heavy user - recommend upgrade
        if (currentSpeed < 100) {
          recommendation = 'upgrade';
          recommendedSpeed = currentSpeed == 20 ? 50 : 100;
          recommendedPrice = recommendedSpeed == 50 ? 350000 : 500000;
          reason =
              'Pemakaian Anda tinggi (${usagePerDay.toStringAsFixed(1)} GB/hari). Upgrade untuk performa lebih baik.';
        } else {
          recommendation = 'current';
          reason = 'Paket Anda sudah optimal untuk pemakaian saat ini.';
        }
      } else if (speedUtilization < 30 && usagePerDay < 5) {
        // Light user - recommend downgrade
        if (currentSpeed > 20) {
          recommendation = 'downgrade';
          recommendedSpeed = currentSpeed == 100 ? 50 : 20;
          recommendedPrice = recommendedSpeed == 50 ? 350000 : 250000;
          reason =
              'Pemakaian Anda rendah (${usagePerDay.toStringAsFixed(1)} GB/hari). Hemat biaya dengan paket lebih kecil.';
        } else {
          recommendation = 'current';
          reason = 'Paket Anda sudah sesuai dengan pemakaian.';
        }
      } else {
        recommendation = 'current';
        reason = 'Paket Anda sudah optimal untuk pola pemakaian saat ini.';
      }

      return {
        'recommendation': recommendation,
        'reason': reason,
        'currentSpeed': currentSpeed,
        'currentPrice': currentPrice,
        'recommendedSpeed': recommendedSpeed,
        'recommendedPrice': recommendedPrice,
        'usagePerDay': usagePerDay,
        'speedUtilization': speedUtilization,
        'savingsPerMonth': recommendation == 'downgrade'
            ? currentPrice - recommendedPrice
            : 0,
        'extraCostPerMonth': recommendation == 'upgrade'
            ? recommendedPrice - currentPrice
            : 0,
      };
    } catch (e) {
      LoggerService.error('Error getting package recommendation: $e');
      return {};
    }
  }

  // ==================== ADMIN REPORTING ====================

  /// Generate comprehensive revenue report
  Future<Map<String, dynamic>> getRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
    String? zone,
  }) async {
    try {
      Query query = FirebaseService.instance.paymentsCollection
          .where('paymentStatus', isEqualTo: 'paid')
          .where(
            'paidAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('paidAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      final paymentsSnapshot = await query.get();
      final payments = paymentsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Calculate totals
      double totalRevenue = 0.0;
      int totalTransactions = payments.length;
      final paymentMethods = <String, double>{};
      final dailyRevenue = <String, double>{};

      for (var payment in payments) {
        final amount = (payment['amount'] ?? 0) as num;
        final amountDouble = amount.toDouble();
        totalRevenue += amountDouble;

        // Group by payment method
        final method = payment['paymentMethod'] ?? 'unknown';
        paymentMethods[method] = (paymentMethods[method] ?? 0) + amountDouble;

        // Group by day
        final paidAt = (payment['paidAt'] as Timestamp).toDate();
        final dateKey = DateFormat('yyyy-MM-dd').format(paidAt);
        dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + amountDouble;
      }

      // Calculate average
      final avgTransactionValue = totalTransactions > 0
          ? totalRevenue / totalTransactions
          : 0.0;

      return {
        'totalRevenue': totalRevenue,
        'totalTransactions': totalTransactions,
        'avgTransactionValue': avgTransactionValue,
        'paymentMethods': paymentMethods,
        'dailyRevenue': dailyRevenue,
        'periodStart': startDate.toIso8601String(),
        'periodEnd': endDate.toIso8601String(),
      };
    } catch (e) {
      LoggerService.error('Error generating revenue report: $e');
      return {};
    }
  }

  /// Get customer growth statistics
  Future<Map<String, dynamic>> getCustomerGrowthReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final customersSnapshot = await FirebaseService
          .instance
          .customersCollection
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final customers = customersSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Daily new customers
      final dailySignups = <String, int>{};
      final packageDistribution = <String, int>{};
      final zoneDistribution = <String, int>{};

      for (var customer in customers) {
        // Daily breakdown
        final createdAt = (customer['createdAt'] as Timestamp).toDate();
        final dateKey = DateFormat('yyyy-MM-dd').format(createdAt);
        dailySignups[dateKey] = (dailySignups[dateKey] ?? 0) + 1;

        // Package distribution
        final packageName = customer['packageName'] ?? 'Unknown';
        packageDistribution[packageName] =
            (packageDistribution[packageName] ?? 0) + 1;

        // Zone distribution
        final zone = customer['zone'] ?? 'Unknown';
        zoneDistribution[zone] = (zoneDistribution[zone] ?? 0) + 1;
      }

      // Get active customers count
      final activeCustomersSnapshot = await FirebaseService
          .instance
          .customersCollection
          .where('status', isEqualTo: 'active')
          .get();

      return {
        'newCustomers': customers.length,
        'activeCustomers': activeCustomersSnapshot.docs.length,
        'dailySignups': dailySignups,
        'packageDistribution': packageDistribution,
        'zoneDistribution': zoneDistribution,
        'periodStart': startDate.toIso8601String(),
        'periodEnd': endDate.toIso8601String(),
      };
    } catch (e) {
      LoggerService.error('Error getting customer growth report: $e');
      return {};
    }
  }

  /// Get teknisi performance report
  Future<List<Map<String, dynamic>>> getTeknisiPerformanceReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get all tickets in period
      final ticketsSnapshot = await FirebaseService.instance.ticketsCollection
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final tickets = ticketsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Performance by teknisi
      final teknisiPerformance = <String, Map<String, dynamic>>{};

      for (var ticket in tickets) {
        final teknisiId = ticket['teknisiId'] as String?;
        if (teknisiId == null) continue;

        if (!teknisiPerformance.containsKey(teknisiId)) {
          teknisiPerformance[teknisiId] = {
            'totalTickets': 0,
            'resolvedTickets': 0,
            'avgResponseTime': 0.0,
            'responseTimes': <double>[],
          };
        }

        teknisiPerformance[teknisiId]!['totalTickets'] =
            (teknisiPerformance[teknisiId]!['totalTickets'] as int) + 1;

        if (ticket['status'] == 'resolved') {
          teknisiPerformance[teknisiId]!['resolvedTickets'] =
              (teknisiPerformance[teknisiId]!['resolvedTickets'] as int) + 1;

          // Calculate response time
          if (ticket['assignedAt'] != null && ticket['resolvedAt'] != null) {
            final assignedAt = (ticket['assignedAt'] as Timestamp).toDate();
            final resolvedAt = (ticket['resolvedAt'] as Timestamp).toDate();
            final responseTime = resolvedAt
                .difference(assignedAt)
                .inMinutes
                .toDouble();

            (teknisiPerformance[teknisiId]!['responseTimes'] as List<double>)
                .add(responseTime);
          }
        }
      }

      // Calculate averages and convert to list
      final performanceList = <Map<String, dynamic>>[];

      for (var entry in teknisiPerformance.entries) {
        final responseTimes = entry.value['responseTimes'] as List<double>;
        if (responseTimes.isNotEmpty) {
          entry.value['avgResponseTimeHours'] =
              (responseTimes.reduce((a, b) => a + b) / responseTimes.length) /
              60;
        } else {
          entry.value['avgResponseTimeHours'] = 0.0;
        }
        entry.value.remove('responseTimes'); // Remove raw data

        // Add teknisiId to the map
        performanceList.add({'teknisiId': entry.key, ...entry.value});
      }

      // Get teknisi names
      for (var perf in performanceList) {
        try {
          final teknisiData = await FirebaseService.instance.getUserById(
            perf['teknisiId'],
          );
          perf['name'] = teknisiData?['name'] ?? 'Unknown';
        } catch (e) {
          perf['name'] = 'Unknown';
        }
      }

      return performanceList;
    } catch (e) {
      LoggerService.error('Error getting teknisi performance report: $e');
      return [];
    }
  }

  /// Get comprehensive dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 0);

      // Current month revenue
      final currentRevenue = await getRevenueReport(
        startDate: monthStart,
        endDate: now,
      );

      // Last month revenue for comparison
      final lastRevenue = await getRevenueReport(
        startDate: lastMonthStart,
        endDate: lastMonthEnd,
      );

      // Customer growth
      final customerGrowthData = await getCustomerGrowthReport(
        startDate: monthStart,
        endDate: now,
      );

      // Mock data for tickets (should be replaced with real queries)
      final activeTickets = 15;
      final previousMonthTickets = 12;
      final pendingPackageRequests = 8;

      // Calculate growth percentages
      final currentRev = (currentRevenue['totalRevenue'] as num).toDouble();
      final lastRev = (lastRevenue['totalRevenue'] as num).toDouble();
      final revenueGrowth = lastRev > 0
          ? ((currentRev - lastRev) / lastRev * 100)
          : 0.0;

      final totalCustomers = customerGrowthData['activeCustomers'] ?? 0;
      final previousMonthCustomers =
          (totalCustomers - (customerGrowthData['newCustomers'] ?? 0)).clamp(
            0,
            totalCustomers,
          );
      final customerGrowth = previousMonthCustomers > 0
          ? ((totalCustomers - previousMonthCustomers) /
                previousMonthCustomers *
                100)
          : 0.0;

      final ticketGrowth = previousMonthTickets > 0
          ? ((activeTickets - previousMonthTickets) /
                previousMonthTickets *
                100)
          : 0.0;

      return {
        'totalCustomers': totalCustomers,
        'previousMonthCustomers': previousMonthCustomers,
        'customerGrowth': customerGrowth,
        'totalRevenue': currentRev,
        'previousMonthRevenue': lastRev,
        'revenueGrowth': revenueGrowth,
        'activeTickets': activeTickets,
        'previousMonthTickets': previousMonthTickets,
        'ticketGrowth': ticketGrowth,
        'pendingPackageRequests': pendingPackageRequests,
        'currentMonthRevenue': currentRev,
        'lastMonthRevenue': lastRev,
        'newCustomersThisMonth': customerGrowthData['newCustomers'],
        'activeCustomers': customerGrowthData['activeCustomers'],
        'totalTransactions': currentRevenue['totalTransactions'],
        'avgTransactionValue': currentRevenue['avgTransactionValue'],
      };
    } catch (e) {
      LoggerService.error('Error getting dashboard stats: $e');
      return {};
    }
  }
}
