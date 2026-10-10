import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';
import 'logger_service.dart';
import 'dart:math';

/// Service for Smart Scheduling & Route Optimization
class SchedulingService {
  static final SchedulingService instance = SchedulingService._internal();
  factory SchedulingService() => instance;
  SchedulingService._internal();

  final CollectionReference _schedulesCollection = FirebaseFirestore.instance
      .collection('work_schedules');
  // final CollectionReference _availabilityCollection =
  //     FirebaseFirestore.instance.collection('time_slot_availability'); // Reserved for future use

  // ==================== TIME SLOTS ====================

  final List<String> timeSlots = [
    '08:00-10:00',
    '10:00-12:00',
    '13:00-15:00',
    '15:00-17:00',
    '17:00-19:00',
  ];

  // ==================== SCHEDULE CREATION ====================

  /// Create work schedule for teknisi
  Future<String> createSchedule({
    required String teknisiId,
    required String teknisiName,
    required DateTime date,
    required List<ScheduleSlot> slots,
  }) async {
    try {
      // Optimize route
      final optimizedSlots = _optimizeRoute(slots);
      final routeStats = _calculateRouteStats(optimizedSlots);

      final scheduleData = {
        'teknisiId': teknisiId,
        'teknisiName': teknisiName,
        'date': Timestamp.fromDate(date),
        'slots': optimizedSlots.map((s) => s.toJson()).toList(),
        'optimizedRoute': routeStats['route'],
        'estimatedDistance': routeStats['distance'],
        'estimatedDuration': routeStats['duration'],
        'status': 'planned',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _schedulesCollection.add(scheduleData);

      LoggerService.info(
        'Schedule created for $teknisiName on ${date.toString().split(' ')[0]} with ${slots.length} tasks',
      );

      return docRef.id;
    } catch (e) {
      LoggerService.error('Error creating schedule: $e');
      rethrow;
    }
  }

  /// Optimize route using nearest neighbor algorithm (simplified)
  List<ScheduleSlot> _optimizeRoute(List<ScheduleSlot> slots) {
    if (slots.length <= 1) return slots;

    final optimized = <ScheduleSlot>[];
    final remaining = List<ScheduleSlot>.from(slots);

    // Start with highest priority
    remaining.sort((a, b) {
      final priorityOrder = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });

    optimized.add(remaining.removeAt(0));

    // Add nearest tasks
    while (remaining.isNotEmpty) {
      final current = optimized.last;
      var nearestIndex = 0;
      var minDistance = double.infinity;

      for (var i = 0; i < remaining.length; i++) {
        final distance = _calculateDistance(
          current.latitude ?? 0,
          current.longitude ?? 0,
          remaining[i].latitude ?? 0,
          remaining[i].longitude ?? 0,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }

      optimized.add(remaining.removeAt(nearestIndex));
    }

    return optimized;
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth radius in KM
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  /// Calculate route statistics
  Map<String, dynamic> _calculateRouteStats(List<ScheduleSlot> slots) {
    double totalDistance = 0;
    int totalDuration = 0;

    for (var i = 0; i < slots.length - 1; i++) {
      final distance = _calculateDistance(
        slots[i].latitude ?? 0,
        slots[i].longitude ?? 0,
        slots[i + 1].latitude ?? 0,
        slots[i + 1].longitude ?? 0,
      );

      totalDistance += distance;
      // Assume 40 km/h average speed + 60 min per task
      totalDuration += ((distance / 40) * 60).toInt() + 60;
    }

    return {
      'route': 'optimized', // In production, return encoded polyline
      'distance': totalDistance,
      'duration': totalDuration,
    };
  }

  // ==================== QUERY SCHEDULES ====================

  /// Get teknisi schedule by date
  Future<WorkSchedule?> getScheduleByDate(
    String teknisiId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _schedulesCollection
          .where('teknisiId', isEqualTo: teknisiId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return WorkSchedule.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      LoggerService.error('Error getting schedule: $e');
      return null;
    }
  }

  /// Get upcoming schedules
  Future<List<WorkSchedule>> getUpcomingSchedules(String teknisiId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _schedulesCollection
          .where('teknisiId', isEqualTo: teknisiId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('date')
          .limit(7)
          .get();

      return querySnapshot.docs
          .map((doc) => WorkSchedule.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting upcoming schedules: $e');
      return [];
    }
  }

  // ==================== TIME SLOT AVAILABILITY ====================

  /// Check available time slots
  Future<List<String>> getAvailableTimeSlots(
    String teknisiId,
    DateTime date,
  ) async {
    try {
      final schedule = await getScheduleByDate(teknisiId, date);

      if (schedule == null) return timeSlots;

      final bookedSlots = schedule.slots.map((s) => s.timeSlot).toSet();
      return timeSlots.where((slot) => !bookedSlots.contains(slot)).toList();
    } catch (e) {
      LoggerService.error('Error checking availability: $e');
      return timeSlots;
    }
  }

  /// Get workload balance across teknisi
  Future<Map<String, int>> getWorkloadBalance(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _schedulesCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final workload = <String, int>{};

      for (var doc in querySnapshot.docs) {
        final schedule = WorkSchedule.fromFirestore(doc);
        workload[schedule.teknisiId] = schedule.slots.length;
      }

      return workload;
    } catch (e) {
      LoggerService.error('Error getting workload balance: $e');
      return {};
    }
  }

  /// Find least busy teknisi
  Future<String?> findLeastBusyTeknisi(
    DateTime date,
    List<String> teknisiIds,
  ) async {
    try {
      final workload = await getWorkloadBalance(date);

      String? leastBusy;
      int minTasks = 999;

      for (var teknisiId in teknisiIds) {
        final tasks = workload[teknisiId] ?? 0;
        if (tasks < minTasks) {
          minTasks = tasks;
          leastBusy = teknisiId;
        }
      }

      return leastBusy;
    } catch (e) {
      LoggerService.error('Error finding least busy teknisi: $e');
      return null;
    }
  }

  // ==================== UPDATE SCHEDULE ====================

  /// Mark slot as completed
  Future<void> completeSlot(String scheduleId, int slotIndex) async {
    try {
      final doc = await _schedulesCollection.doc(scheduleId).get();
      if (!doc.exists) return;

      final schedule = WorkSchedule.fromFirestore(doc);
      final slots = schedule.slots;

      if (slotIndex >= slots.length) return;

      slots[slotIndex] = ScheduleSlot(
        customerId: slots[slotIndex].customerId,
        customerName: slots[slotIndex].customerName,
        address: slots[slotIndex].address,
        latitude: slots[slotIndex].latitude,
        longitude: slots[slotIndex].longitude,
        taskType: slots[slotIndex].taskType,
        timeSlot: slots[slotIndex].timeSlot,
        priority: slots[slotIndex].priority,
        status: 'completed',
        completedAt: DateTime.now(),
      );

      await _schedulesCollection.doc(scheduleId).update({
        'slots': slots.map((s) => s.toJson()).toList(),
      });

      LoggerService.info(
        'Slot $slotIndex marked as completed in schedule $scheduleId',
      );
    } catch (e) {
      LoggerService.error('Error completing slot: $e');
    }
  }
}
