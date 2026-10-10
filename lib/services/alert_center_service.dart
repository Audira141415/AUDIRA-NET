import 'package:flutter/material.dart';
import '../utils/logger.dart';
import 'dart:async';
import 'firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertCenterService {
  static final AlertCenterService _instance = AlertCenterService._internal();
  factory AlertCenterService() => _instance;
  AlertCenterService._internal();

  final List<SystemAlert> _alerts = [];
  final StreamController<List<SystemAlert>> _alertController =
      StreamController<List<SystemAlert>>.broadcast();

  Stream<List<SystemAlert>> get alertStream => _alertController.stream;
  List<SystemAlert> get alerts => List.from(_alerts);
  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  Timer? _systemHealthTimer;
  Timer? _performanceTimer;
  Timer? _paymentTimer;

  void startMonitoring() {
    // System health monitoring every 30 seconds
    _systemHealthTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSystemHealth();
    });

    // Performance monitoring every 60 seconds
    _performanceTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _checkPerformanceAlerts();
    });

    // Payment monitoring every 5 minutes
    _paymentTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkPaymentAlerts();
    });

    // Add welcome notification
    addAlert(
      SystemAlert(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Alert Center Aktif',
        message: 'Sistem monitoring real-time telah dimulai',
        type: AlertType.info,
        timestamp: DateTime.now(),
      ),
    );
  }

  void stopMonitoring() {
    _systemHealthTimer?.cancel();
    _performanceTimer?.cancel();
    _paymentTimer?.cancel();
  }

  void addAlert(SystemAlert alert) {
    _alerts.insert(0, alert);
    if (_alerts.length > 100) {
      _alerts.removeRange(100, _alerts.length);
    }
    _alertController.add(_alerts);
  }

  void markAsRead(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isRead: true);
      _alertController.add(_alerts);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _alerts.length; i++) {
      _alerts[i] = _alerts[i].copyWith(isRead: true);
    }
    _alertController.add(_alerts);
  }

  void removeAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    _alertController.add(_alerts);
  }

  Future<void> _checkSystemHealth() async {
    try {
      // Check Firestore connectivity by getting a simple query
      await FirebaseService.instance.customersCollection.limit(1).get();

      // Simulate network checks
      final now = DateTime.now();
      final random = DateTime.now().millisecond;

      // Simulate random network issues (5% chance)
      if (random % 100 < 5) {
        addAlert(
          SystemAlert(
            id: 'net_${now.millisecondsSinceEpoch}',
            title: 'Gangguan Jaringan',
            message: 'Latency tinggi terdeteksi pada node Jakarta Selatan',
            type: AlertType.network,
            priority: AlertPriority.high,
            timestamp: now,
            details: {
              'node': 'Jakarta Selatan',
              'latency': '${150 + random % 50}ms',
              'status': 'degraded',
            },
          ),
        );
      }

      // Check for server issues (3% chance)
      if (random % 100 < 3) {
        addAlert(
          SystemAlert(
            id: 'srv_${now.millisecondsSinceEpoch}',
            title: 'Server Load Tinggi',
            message: 'CPU usage mencapai 85%, pertimbangkan scaling',
            type: AlertType.system,
            priority: AlertPriority.medium,
            timestamp: now,
            details: {
              'cpu_usage': '85%',
              'memory_usage': '78%',
              'recommendations': 'Scale server resources',
            },
          ),
        );
      }
    } catch (e) {
      addAlert(
        SystemAlert(
          id: 'db_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Database Error',
          message: 'Koneksi database bermasalah',
          type: AlertType.system,
          priority: AlertPriority.critical,
          timestamp: DateTime.now(),
          details: {'error': e.toString()},
        ),
      );
    }
  }

  Future<void> _checkPerformanceAlerts() async {
    try {
      // Check bandwidth usage
      final activeCustomersSnapshot = await FirebaseService
          .instance
          .customersCollection
          .where('status', isEqualTo: 'active')
          .get();
      final activeCount = activeCustomersSnapshot.docs.length;

      // Simulate bandwidth usage
      final bandwidthUsage = (activeCount * 45.5);

      if (bandwidthUsage > 2000) {
        addAlert(
          SystemAlert(
            id: 'bw_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Bandwidth Usage Tinggi',
            message:
                'Total usage: ${bandwidthUsage.toStringAsFixed(1)} Mbps (>80% capacity)',
            type: AlertType.performance,
            priority: AlertPriority.high,
            timestamp: DateTime.now(),
            details: {
              'current_usage': '${bandwidthUsage.toStringAsFixed(1)} Mbps',
              'capacity': '2500 Mbps',
              'utilization':
                  '${(bandwidthUsage / 2500 * 100).toStringAsFixed(1)}%',
            },
          ),
        );
      }

      // Check for slow connections
      final slowConnections = DateTime.now().millisecond % 50;
      if (slowConnections > 40) {
        addAlert(
          SystemAlert(
            id: 'speed_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Kecepatan Bermasalah',
            message: 'Beberapa customer mengalami kecepatan di bawah standar',
            type: AlertType.performance,
            priority: AlertPriority.medium,
            timestamp: DateTime.now(),
            details: {
              'affected_customers': '${3 + DateTime.now().second % 5}',
              'avg_speed': '15.2 Mbps',
              'expected_speed': '50 Mbps',
            },
          ),
        );
      }
    } catch (e) {
      Logger.error('Performance check error', e);
    }
  }

  Future<void> _checkPaymentAlerts() async {
    try {
      // Check overdue payments
      final now = Timestamp.now();
      final overdueSnapshot = await FirebaseService.instance.billsCollection
          .where('status', isEqualTo: 'unpaid')
          .where('dueDate', isLessThan: now)
          .get();

      final overdueCount = overdueSnapshot.docs.length;
      final overdueAmount = overdueSnapshot.docs.fold<int>(0, (total, doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final amount = data?['amount'] as num?;
        return total + (amount?.toInt() ?? 0);
      });

      if (overdueCount > 0) {
        addAlert(
          SystemAlert(
            id: 'overdue_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Pembayaran Tertunggak',
            message:
                '$overdueCount tagihan tertunggak (Rp ${_formatCurrency(overdueAmount)})',
            type: AlertType.payment,
            priority: AlertPriority.high,
            timestamp: DateTime.now(),
            details: {
              'overdue_bills': overdueCount.toString(),
              'total_amount': overdueAmount.toString(),
              'action_needed': 'Send payment reminders',
            },
          ),
        );
      }

      // Check bills due soon (next 3 days)
      final threeDaysFromNow = Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 3)),
      );
      final dueSoonSnapshot = await FirebaseService.instance.billsCollection
          .where('status', isEqualTo: 'unpaid')
          .where('dueDate', isGreaterThanOrEqualTo: now)
          .where('dueDate', isLessThanOrEqualTo: threeDaysFromNow)
          .get();

      final dueSoonCount = dueSoonSnapshot.docs.length;
      if (dueSoonCount > 10) {
        addAlert(
          SystemAlert(
            id: 'due_soon_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Tagihan Jatuh Tempo',
            message: '$dueSoonCount tagihan akan jatuh tempo dalam 3 hari',
            type: AlertType.payment,
            priority: AlertPriority.medium,
            timestamp: DateTime.now(),
            details: {
              'bills_due_soon': dueSoonCount.toString(),
              'days_remaining': '3',
              'recommended_action': 'Send payment reminders',
            },
          ),
        );
      }
    } catch (e) {
      Logger.error('Payment alert check error', e);
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void dispose() {
    stopMonitoring();
    _alertController.close();
  }
}

enum AlertType { system, network, performance, payment, ticket, info }

enum AlertPriority { low, medium, high, critical }

class SystemAlert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? details;

  const SystemAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.priority = AlertPriority.medium,
    this.isRead = false,
    this.details,
  });

  SystemAlert copyWith({
    String? id,
    String? title,
    String? message,
    AlertType? type,
    AlertPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? details,
  }) {
    return SystemAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      details: details ?? this.details,
    );
  }

  IconData get icon {
    switch (type) {
      case AlertType.system:
        return Icons.computer;
      case AlertType.network:
        return Icons.wifi_off;
      case AlertType.performance:
        return Icons.speed;
      case AlertType.payment:
        return Icons.payment;
      case AlertType.ticket:
        return Icons.support_agent;
      case AlertType.info:
        return Icons.info;
    }
  }

  Color get color {
    switch (priority) {
      case AlertPriority.low:
        return Colors.green;
      case AlertPriority.medium:
        return Colors.orange;
      case AlertPriority.high:
        return Colors.red;
      case AlertPriority.critical:
        return Colors.purple;
    }
  }

  String get priorityText {
    switch (priority) {
      case AlertPriority.low:
        return 'Rendah';
      case AlertPriority.medium:
        return 'Sedang';
      case AlertPriority.high:
        return 'Tinggi';
      case AlertPriority.critical:
        return 'Kritis';
    }
  }
}
