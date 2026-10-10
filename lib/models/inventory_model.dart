import 'package:cloud_firestore/cloud_firestore.dart';

/// Equipment item in inventory
class InventoryItem {
  final String id;
  final String name;
  final String category; // modem, router, cable, tools
  final String barcode;
  final String serialNumber;
  final String status; // available, assigned, maintenance, broken
  final String? assignedTo; // teknisiId
  final String? location; // warehouse, teknisi, customer
  final DateTime? assignedAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.barcode,
    required this.serialNumber,
    this.status = 'available',
    this.assignedTo,
    this.location,
    this.assignedAt,
    required this.createdAt,
    this.metadata,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      barcode: data['barcode'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      status: data['status'] ?? 'available',
      assignedTo: data['assignedTo'],
      location: data['location'],
      assignedAt: data['assignedAt'] != null
          ? (data['assignedAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'barcode': barcode,
      'serialNumber': serialNumber,
      'status': status,
      'assignedTo': assignedTo,
      'location': location,
      'assignedAt':
          assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}

/// Stock request from teknisi
class StockRequest {
  final String id;
  final String teknisiId;
  final String teknisiName;
  final List<RequestItem> items;
  final String status; // pending, approved, rejected, delivered
  final String? notes;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? processedBy;

  StockRequest({
    required this.id,
    required this.teknisiId,
    required this.teknisiName,
    required this.items,
    this.status = 'pending',
    this.notes,
    required this.createdAt,
    this.processedAt,
    this.processedBy,
  });

  factory StockRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockRequest(
      id: doc.id,
      teknisiId: data['teknisiId'] ?? '',
      teknisiName: data['teknisiName'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((i) => RequestItem.fromJson(i))
              .toList() ??
          [],
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      processedAt: data['processedAt'] != null
          ? (data['processedAt'] as Timestamp).toDate()
          : null,
      processedBy: data['processedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teknisiId': teknisiId,
      'teknisiName': teknisiName,
      'items': items.map((i) => i.toJson()).toList(),
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'processedAt':
          processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'processedBy': processedBy,
    };
  }
}

/// Item in stock request
class RequestItem {
  final String category;
  final String itemName;
  final int quantity;
  final String? reason;

  RequestItem({
    required this.category,
    required this.itemName,
    required this.quantity,
    this.reason,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      category: json['category'] ?? '',
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] ?? 0,
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'itemName': itemName,
      'quantity': quantity,
      'reason': reason,
    };
  }
}

/// Stock level tracking
class StockLevel {
  final String category;
  final String itemName;
  final int currentStock;
  final int minimumStock;
  final int maximumStock;
  final String location;

  StockLevel({
    required this.category,
    required this.itemName,
    required this.currentStock,
    this.minimumStock = 5,
    this.maximumStock = 100,
    this.location = 'warehouse',
  });

  factory StockLevel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockLevel(
      category: data['category'] ?? '',
      itemName: data['itemName'] ?? '',
      currentStock: data['currentStock'] ?? 0,
      minimumStock: data['minimumStock'] ?? 5,
      maximumStock: data['maximumStock'] ?? 100,
      location: data['location'] ?? 'warehouse',
    );
  }

  bool get isLowStock => currentStock <= minimumStock;
  bool get isOutOfStock => currentStock == 0;
}
