import 'package:cloud_firestore/cloud_firestore.dart';

/// Work schedule for teknisi
class WorkSchedule {
  final String id;
  final String teknisiId;
  final String teknisiName;
  final DateTime date;
  final List<ScheduleSlot> slots;
  final String? optimizedRoute; // Encoded polyline or JSON
  final double? estimatedDistance; // in KM
  final int? estimatedDuration; // in minutes
  final String status; // planned, in_progress, completed

  WorkSchedule({
    required this.id,
    required this.teknisiId,
    required this.teknisiName,
    required this.date,
    required this.slots,
    this.optimizedRoute,
    this.estimatedDistance,
    this.estimatedDuration,
    this.status = 'planned',
  });

  factory WorkSchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkSchedule(
      id: doc.id,
      teknisiId: data['teknisiId'] ?? '',
      teknisiName: data['teknisiName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      slots: (data['slots'] as List<dynamic>?)
              ?.map((s) => ScheduleSlot.fromJson(s))
              .toList() ??
          [],
      optimizedRoute: data['optimizedRoute'],
      estimatedDistance: data['estimatedDistance']?.toDouble(),
      estimatedDuration: data['estimatedDuration'],
      status: data['status'] ?? 'planned',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teknisiId': teknisiId,
      'teknisiName': teknisiName,
      'date': Timestamp.fromDate(date),
      'slots': slots.map((s) => s.toJson()).toList(),
      'optimizedRoute': optimizedRoute,
      'estimatedDistance': estimatedDistance,
      'estimatedDuration': estimatedDuration,
      'status': status,
    };
  }
}

/// Time slot in schedule
class ScheduleSlot {
  final String customerId;
  final String customerName;
  final String address;
  final double? latitude;
  final double? longitude;
  final String taskType; // installation, maintenance, repair
  final String timeSlot; // 08:00-10:00, 10:00-12:00, etc
  final String priority; // low, medium, high, urgent
  final String status; // pending, completed, cancelled
  final DateTime? completedAt;

  ScheduleSlot({
    required this.customerId,
    required this.customerName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.taskType,
    required this.timeSlot,
    this.priority = 'medium',
    this.status = 'pending',
    this.completedAt,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      taskType: json['taskType'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'taskType': taskType,
      'timeSlot': timeSlot,
      'priority': priority,
      'status': status,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

/// Time slot availability
class TimeSlotAvailability {
  final String teknisiId;
  final DateTime date;
  final Map<String, bool> slots; // {"08:00-10:00": true, ...}

  TimeSlotAvailability({
    required this.teknisiId,
    required this.date,
    required this.slots,
  });

  factory TimeSlotAvailability.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimeSlotAvailability(
      teknisiId: data['teknisiId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      slots: Map<String, bool>.from(data['slots'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teknisiId': teknisiId,
      'date': Timestamp.fromDate(date),
      'slots': slots,
    };
  }
}
